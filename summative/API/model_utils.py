from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Any

import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeRegressor

BASE_DIR = Path(__file__).resolve().parent
LINEAR_REGRESSION_DIR = BASE_DIR.parent / "linear_regression"
RUNTIME_DIR = BASE_DIR / "runtime"
RUNTIME_DIR.mkdir(parents=True, exist_ok=True)

BASE_MODEL_PATH = LINEAR_REGRESSION_DIR / "best_model.joblib"
BASE_SCALER_PATH = LINEAR_REGRESSION_DIR / "scaler.joblib"
FEATURE_COLUMNS_PATH = LINEAR_REGRESSION_DIR / "feature_columns.json"

RUNTIME_MODEL_PATH = RUNTIME_DIR / "best_model.joblib"
RUNTIME_SCALER_PATH = RUNTIME_DIR / "scaler.joblib"
RUNTIME_SUMMARY_PATH = RUNTIME_DIR / "retrain_summary.json"
BUFFER_PATH = RUNTIME_DIR / "retrain_samples.jsonl"

REGION_OPTIONS = [
    "East Anglian Region",
    "East Midlands Region",
    "Ireland",
    "London Region",
    "North Region",
    "North Western Region",
    "Scotland",
    "South East Region",
    "South Region",
    "South West Region",
    "Wales",
    "West Midlands Region",
    "Yorkshire Region",
]
REGION_MAP = {name: index for index, name in enumerate(REGION_OPTIONS)}

HIGHEST_EDUCATION_MAP = {
    "No Formal quals": 0,
    "Lower Than A Level": 1,
    "A Level or Equivalent": 2,
    "HE Qualification": 3,
    "Post Graduate Qualification": 4,
}

IMD_BAND_MAP = {
    "0-10%": 1,
    # The saved notebook model used a slightly inconsistent label here.
    # We keep the encoding aligned with the trained artifact for inference parity.
    "10-20": 5,
    "20-30%": 3,
    "30-40%": 4,
    "40-50%": 5,
    "50-60%": 6,
    "60-70%": 7,
    "70-80%": 8,
    "80-90%": 9,
    "90-100%": 10,
}

AGE_BAND_MAP = {
    "0-35": 0,
    "35-55": 1,
    "55<=": 2,
}

NUMERIC_LIMITS = {
    "num_of_prev_attempts": {"min": 0, "max": 6},
    "studied_credits": {"min": 30, "max": 630},
    "date_registration": {"min": -311, "max": 167},
    "total_clicks": {"min": 0, "max": 24139},
    "predicted_avg_score": {"min": 0, "max": 100},
}


def _load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


@lru_cache(maxsize=1)
def load_feature_columns() -> list[str]:
    return _load_json(FEATURE_COLUMNS_PATH)


def _artifact_paths() -> tuple[Path, Path]:
    model_path = RUNTIME_MODEL_PATH if RUNTIME_MODEL_PATH.exists() else BASE_MODEL_PATH
    scaler_path = RUNTIME_SCALER_PATH if RUNTIME_SCALER_PATH.exists() else BASE_SCALER_PATH
    return model_path, scaler_path


@lru_cache(maxsize=1)
def load_active_model_bundle() -> tuple[Any, StandardScaler]:
    model_path, scaler_path = _artifact_paths()
    return joblib.load(model_path), joblib.load(scaler_path)


def clear_model_cache() -> None:
    load_active_model_bundle.cache_clear()


def active_model_name() -> str:
    if RUNTIME_SUMMARY_PATH.exists():
        return _load_json(RUNTIME_SUMMARY_PATH).get("selected_model", "Linear Regression")
    truth_path = LINEAR_REGRESSION_DIR / "sample_test_truth.json"
    if truth_path.exists():
        return _load_json(truth_path).get("model_name", "Linear Regression")
    return "Linear Regression"


def performance_band(score: float) -> str:
    if score >= 80:
        return "Distinction (High Performer)"
    if score >= 60:
        return "Pass (On Track)"
    if score >= 40:
        return "At Risk (Needs Support)"
    return "High Risk (Likely to Fail)"


def build_feature_row(payload: dict[str, Any]) -> pd.DataFrame:
    row = pd.DataFrame(
        [
            {
                "gender": 1 if payload["gender"] == "F" else 0,
                "region": REGION_MAP[payload["region"]],
                "highest_education": HIGHEST_EDUCATION_MAP[payload["highest_education"]],
                "imd_band": IMD_BAND_MAP[payload["imd_band"]],
                "age_band": AGE_BAND_MAP[payload["age_band"]],
                "num_of_prev_attempts": int(payload["num_of_prev_attempts"]),
                "studied_credits": int(payload["studied_credits"]),
                "disability": 1 if payload["disability"] == "Y" else 0,
                "date_registration": float(payload["date_registration"]),
                "log_total_clicks": float(np.log1p(payload["total_clicks"])),
            }
        ]
    )
    return row[load_feature_columns()]


def predict_from_payload(payload: dict[str, Any]) -> dict[str, Any]:
    model, scaler = load_active_model_bundle()
    feature_row = build_feature_row(payload)
    prediction = float(model.predict(scaler.transform(feature_row))[0])
    prediction = max(0.0, min(100.0, prediction))
    return {
        "predicted_avg_score": round(prediction, 2),
        "performance_band": performance_band(prediction),
        "model_name": active_model_name(),
        "engineered_features": feature_row.iloc[0].to_dict(),
    }


def model_metadata() -> dict[str, Any]:
    return {
        "mission": "Student assessment score prediction for early intervention support.",
        "selected_model": active_model_name(),
        "feature_columns": load_feature_columns(),
        "categorical_options": {
            "gender": ["M", "F"],
            "region": REGION_OPTIONS,
            "highest_education": list(HIGHEST_EDUCATION_MAP.keys()),
            "imd_band": list(IMD_BAND_MAP.keys()),
            "age_band": list(AGE_BAND_MAP.keys()),
            "disability": ["N", "Y"],
        },
        "numeric_limits": NUMERIC_LIMITS,
    }


def load_buffered_samples() -> list[dict[str, Any]]:
    if not BUFFER_PATH.exists():
        return []
    samples: list[dict[str, Any]] = []
    with BUFFER_PATH.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                samples.append(json.loads(line))
    return samples


def append_retrain_sample(sample: dict[str, Any]) -> int:
    with BUFFER_PATH.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(sample) + "\n")
    return len(load_buffered_samples())


def clear_retrain_buffer() -> None:
    BUFFER_PATH.write_text("", encoding="utf-8")


def build_training_dataframe() -> pd.DataFrame:
    student_info = pd.read_csv(LINEAR_REGRESSION_DIR / "studentInfo.csv")
    student_assessment = pd.read_csv(LINEAR_REGRESSION_DIR / "studentAssessment.csv")
    assessments_df = pd.read_csv(LINEAR_REGRESSION_DIR / "assessments.csv")
    student_vle = pd.read_csv(LINEAR_REGRESSION_DIR / "studentVle.csv")
    student_reg = pd.read_csv(LINEAR_REGRESSION_DIR / "studentRegistration.csv")

    sa = student_assessment[student_assessment["is_banked"] == 0].copy()
    sa = sa.merge(
        assessments_df[["id_assessment", "code_module", "code_presentation"]],
        on="id_assessment",
        how="left",
    )
    avg_score = (
        sa.groupby(["id_student", "code_module", "code_presentation"])["score"]
        .mean()
        .reset_index()
        .rename(columns={"score": "avg_score"})
    )

    total_clicks = (
        student_vle.groupby(["id_student", "code_module", "code_presentation"])["sum_click"]
        .sum()
        .reset_index()
        .rename(columns={"sum_click": "total_clicks"})
    )

    reg = student_reg[
        ["id_student", "code_module", "code_presentation", "date_registration"]
    ].copy()

    df = (
        student_info.merge(
            avg_score, on=["id_student", "code_module", "code_presentation"], how="inner"
        )
        .merge(total_clicks, on=["id_student", "code_module", "code_presentation"], how="left")
        .merge(reg, on=["id_student", "code_module", "code_presentation"], how="left")
    )

    df["total_clicks"] = df["total_clicks"].fillna(0)
    df["date_registration"] = df["date_registration"].fillna(0)
    df = df.drop(columns=["id_student", "code_module", "code_presentation", "final_result"])

    df_fe = df.copy()
    df_fe["gender"] = (df_fe["gender"] == "F").astype(int)
    df_fe["disability"] = (df_fe["disability"] == "Y").astype(int)
    df_fe["highest_education"] = (
        df_fe["highest_education"].map(HIGHEST_EDUCATION_MAP).fillna(1).astype(int)
    )
    df_fe["imd_band"] = df_fe["imd_band"].map(IMD_BAND_MAP).fillna(5).astype(int)
    df_fe["age_band"] = df_fe["age_band"].map(AGE_BAND_MAP).fillna(0).astype(int)
    df_fe["region"] = df_fe["region"].map(REGION_MAP).astype(int)
    df_fe["log_total_clicks"] = np.log1p(df_fe["total_clicks"])
    df_fe = df_fe.drop(columns=["total_clicks"])
    df_fe = df_fe.fillna(df_fe.median(numeric_only=True))
    return df_fe


def _candidate_models(
    X_train_sc: np.ndarray,
    y_train: pd.Series,
    X_test_sc: np.ndarray,
    y_test: pd.Series,
) -> list[dict[str, Any]]:
    lr = LinearRegression()
    lr.fit(X_train_sc, y_train)
    lr_test_pred = lr.predict(X_test_sc)

    dt_best = None
    dt_best_mse = float("inf")
    for depth in range(1, 21):
        candidate = DecisionTreeRegressor(max_depth=depth, random_state=42)
        candidate.fit(X_train_sc, y_train)
        mse = mean_squared_error(y_test, candidate.predict(X_test_sc))
        if mse < dt_best_mse:
            dt_best = candidate
            dt_best_mse = mse

    rf_best = None
    rf_best_mse = float("inf")
    for n_estimators in [10, 25, 50, 75, 100, 150, 200]:
        candidate = RandomForestRegressor(
            n_estimators=n_estimators,
            max_depth=15,
            random_state=42,
            n_jobs=-1,
        )
        candidate.fit(X_train_sc, y_train)
        mse = mean_squared_error(y_test, candidate.predict(X_test_sc))
        if mse < rf_best_mse:
            rf_best = candidate
            rf_best_mse = mse

    return [
        {
            "name": "Linear Regression",
            "model": lr,
            "test_pred": lr_test_pred,
        },
        {
            "name": "Decision Tree",
            "model": dt_best,
            "test_pred": dt_best.predict(X_test_sc),
        },
        {
            "name": "Random Forest",
            "model": rf_best,
            "test_pred": rf_best.predict(X_test_sc),
        },
    ]


def retrain_from_buffer() -> dict[str, Any]:
    buffered_samples = load_buffered_samples()
    if not buffered_samples:
        return {
            "status": "skipped",
            "reason": "No submitted samples are waiting in the retraining buffer.",
            "buffered_samples": 0,
        }

    df_fe = build_training_dataframe()

    extra_rows = []
    for sample in buffered_samples:
        feature_row = build_feature_row(sample["features"]).iloc[0].to_dict()
        feature_row["avg_score"] = float(sample["actual_avg_score"])
        extra_rows.append(feature_row)

    df_augmented = pd.concat([df_fe, pd.DataFrame(extra_rows)], ignore_index=True)

    X = df_augmented.drop(columns=["avg_score"])
    y = df_augmented["avg_score"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    scaler = StandardScaler()
    X_train_sc = scaler.fit_transform(X_train)
    X_test_sc = scaler.transform(X_test)

    candidates = _candidate_models(X_train_sc, y_train, X_test_sc, y_test)
    scored_models = []
    for candidate in candidates:
        prediction = candidate["test_pred"]
        scored_models.append(
            {
                "name": candidate["name"],
                "model": candidate["model"],
                "test_mse": float(mean_squared_error(y_test, prediction)),
                "test_mae": float(mean_absolute_error(y_test, prediction)),
                "test_r2": float(r2_score(y_test, prediction)),
            }
        )

    best = min(scored_models, key=lambda item: item["test_mse"])

    final_scaler = StandardScaler()
    X_full_sc = final_scaler.fit_transform(X)
    final_model = best["model"].__class__(**best["model"].get_params())
    final_model.fit(X_full_sc, y)

    joblib.dump(final_model, RUNTIME_MODEL_PATH)
    joblib.dump(final_scaler, RUNTIME_SCALER_PATH)

    summary = {
        "status": "retrained",
        "selected_model": best["name"],
        "buffered_samples_used": len(buffered_samples),
        "training_rows": int(len(df_augmented)),
        "metrics": [
            {
                "name": item["name"],
                "test_mse": round(item["test_mse"], 4),
                "test_mae": round(item["test_mae"], 4),
                "test_r2": round(item["test_r2"], 4),
            }
            for item in scored_models
        ],
    }

    RUNTIME_SUMMARY_PATH.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    clear_retrain_buffer()
    clear_model_cache()
    return summary
