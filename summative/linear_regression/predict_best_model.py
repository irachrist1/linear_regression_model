#!/usr/bin/env python3

import argparse
import json
from pathlib import Path

import joblib
import pandas as pd


def interpret_performance(score):
    if score >= 80:
        return "Distinction (High Performer)"
    if score >= 60:
        return "Pass (On Track)"
    if score >= 40:
        return "At Risk (Needs Support)"
    return "High Risk (Likely to Fail)"


def load_feature_columns(path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def load_truth(path):
    if not path.exists():
        return None
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def main():
    base_dir = Path(__file__).resolve().parent

    parser = argparse.ArgumentParser(
        description="Load the saved best model and predict the average assessment score for one student row."
    )
    parser.add_argument(
        "--input-csv",
        default=str(base_dir / "sample_test_row.csv"),
        help="Path to a one-row CSV with engineered feature columns.",
    )
    parser.add_argument(
        "--truth-json",
        default=str(base_dir / "sample_test_truth.json"),
        help="Optional JSON file with the actual target value for comparison.",
    )
    args = parser.parse_args()

    model = joblib.load(base_dir / "best_model.joblib")
    scaler = joblib.load(base_dir / "scaler.joblib")
    feature_columns = load_feature_columns(base_dir / "feature_columns.json")

    input_path = Path(args.input_csv)
    row = pd.read_csv(input_path)
    if row.shape[0] != 1:
        raise ValueError(f"{input_path} must contain exactly one row.")

    missing = [c for c in feature_columns if c not in row.columns]
    extra = [c for c in row.columns if c not in feature_columns]
    if missing:
        raise ValueError(f"Missing required feature columns: {missing}")
    if extra:
        row = row.drop(columns=extra)

    row = row[feature_columns]
    prediction = float(model.predict(scaler.transform(row))[0])

    print("=== Student Performance Prediction ===")
    print(f"Input row          : {input_path.name}")
    print(f"Predicted score    : {prediction:.1f} / 100")
    print(f"Performance level  : {interpret_performance(prediction)}")

    truth = load_truth(Path(args.truth_json))
    if truth is not None and "actual_avg_score" in truth:
        actual = float(truth["actual_avg_score"])
        print(f"Actual score       : {actual:.1f} / 100")
        print(f"Absolute error     : {abs(actual - prediction):.1f} points")
        print(f"Actual level       : {interpret_performance(actual)}")
        if "model_name" in truth:
            print(f"Saved best model   : {truth['model_name']}")


if __name__ == "__main__":
    main()
