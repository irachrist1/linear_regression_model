#!/usr/bin/env python3

import argparse
import json
from pathlib import Path

import joblib
import pandas as pd


def interpret_risk(days):
    if days < 30:
        return "Low Risk (Active)"
    if days < 90:
        return "Medium Risk (Slowing)"
    if days < 365:
        return "High Risk (At Risk)"
    return "Critical (Abandoned)"


def load_feature_columns(path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def load_truth(path):
    if not path.exists():
        return None
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def main():
    base_dir = Path(__file__).resolve().parent

    parser = argparse.ArgumentParser(
        description="Load the saved best model and predict one model-ready input row."
    )
    parser.add_argument(
        "--input-csv",
        default=str(base_dir / "sample_test_row.csv"),
        help="Path to a one-row CSV with engineered feature columns.",
    )
    parser.add_argument(
        "--truth-json",
        default=str(base_dir / "sample_test_truth.json"),
        help="Optional JSON file containing the actual target value for comparison.",
    )
    args = parser.parse_args()

    model = joblib.load(base_dir / "best_model.joblib")
    scaler = joblib.load(base_dir / "scaler.joblib")
    feature_columns = load_feature_columns(base_dir / "feature_columns.json")

    input_path = Path(args.input_csv)
    row = pd.read_csv(input_path)
    if row.shape[0] != 1:
        raise ValueError(f"{input_path} must contain exactly one row for prediction.")

    missing_columns = [column for column in feature_columns if column not in row.columns]
    extra_columns = [column for column in row.columns if column not in feature_columns]
    if missing_columns:
        raise ValueError(f"Missing required feature columns: {missing_columns}")
    if extra_columns:
        row = row.drop(columns=extra_columns)

    row = row[feature_columns]
    prediction = float(model.predict(scaler.transform(row))[0])

    print("=== Saved Model Prediction ===")
    print(f"Input row        : {input_path.name}")
    print(f"Predicted value  : {prediction:.1f} days since last push")
    print(f"Risk category    : {interpret_risk(prediction)}")

    truth = load_truth(Path(args.truth_json))
    if truth is not None and "actual_days_since_last_push" in truth:
        actual = float(truth["actual_days_since_last_push"])
        print(f"Actual value     : {actual:.1f} days since last push")
        print(f"Absolute error   : {abs(actual - prediction):.1f} days")
        if "model_name" in truth:
            print(f"Saved best model : {truth['model_name']}")


if __name__ == "__main__":
    main()
