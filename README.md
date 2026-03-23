# Student Learning Outcome Predictor

**Mission:** Expand access to personalized, technology-enabled learning for students in rural and underserved communities.

**Problem:** Students from disadvantaged backgrounds often fall behind without early support. By predicting a student's average assessment score from their demographics and learning engagement, educators can identify struggling learners early and deliver timely, personalized intervention.

**Dataset:** [Open University Learning Analytics Dataset (OULAD)](https://www.kaggle.com/datasets/anlgrbz/student-demographics-online-education-dataoulad) — anonymized records for ~32,000 students across 7 courses, including demographics (deprivation index, disability, region), registration timing, Virtual Learning Environment click activity, and assessment scores.

**Task 2 Prep:** `summative/linear_regression/predict_best_model.py` loads the saved best model and predicts the average assessment score for one held-out student row.

## Repository Structure

```
linear_regression_model/
├── summative/
│   ├── linear_regression/       ← Summative One notebook, dataset, plots, and saved model artifacts
│   ├── API/                     ← Summative Two FastAPI service for prediction, metadata, and retraining
│   └── FlutterApp/              ← Flutter mobile app for student score prediction with API integration
└── README.md
```

## Data Setup

Download the OULAD dataset from Kaggle and place the following CSV files inside `summative/linear_regression/` before running the notebook:

- `studentInfo.csv`
- `studentAssessment.csv`
- `assessments.csv`
- `studentVle.csv`
- `studentRegistration.csv`

## Main Files

- `summative/linear_regression/multivariate.ipynb` — full regression workflow: data merging, visualizations, feature engineering, model training, comparison, and saving
- `summative/linear_regression/predict_best_model.py` — loads the saved best model and predicts one held-out student row
- `summative/API/prediction.py` — FastAPI app with `/predict`, `/metadata`, `/health`, and retraining endpoints
- `summative/API/model_utils.py` — reusable preprocessing and inference logic that mirrors the notebook transformations

## API Endpoint

> **Public URL:** https://linear-regression-model-83q9.onrender.com
> Swagger UI: https://linear-regression-model-83q9.onrender.com/docs

## Video Demo

> **YouTube:** _Add link here after recording_

## Running the Mobile App

```bash
# Install Flutter dependencies
cd summative/FlutterApp
flutter pub get

# Run on a connected device or emulator
flutter run

# To point at the deployed API instead of localhost:
flutter run --dart-define=API_BASE_URL=https://your-render-url.onrender.com
```

## Running the API Locally

```bash
cd summative/API
pip install -r requirements.txt
uvicorn prediction:app --reload
# Visit http://127.0.0.1:8000/docs for Swagger UI
```
