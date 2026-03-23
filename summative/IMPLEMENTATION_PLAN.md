# Summative Two Plan

## Mission We Are Continuing

Predict student assessment performance early enough for educators to identify learners who may need support, especially in rural and underserved communities.

## What Already Exists

- `summative/linear_regression/multivariate.ipynb` contains the full Summative One workflow using the OULAD dataset.
- The saved best model is `LinearRegression`, with notebook metrics:
  - Test MSE: `221.75`
  - Test MAE: `11.34`
  - Test R2: `0.1585`
- Saved inference artifacts already exist:
  - `best_model.joblib`
  - `scaler.joblib`
  - `feature_columns.json`
  - `sample_test_row.csv`
  - `sample_test_truth.json`
- The older local `summartive_ml` Flutter project has now been ported into `summative/FlutterApp` as a reusable UI and networking scaffold.

## Important Gap To Fix First

The notebook saved the model, scaler, and feature column order, but it did not save the `region` label-encoding map used during training. Before we expose predictions through an API, we need a deterministic preprocessing module that reproduces training-time feature engineering exactly.

## Current Model Inputs

The saved model expects these 10 engineered features:

1. `gender`
2. `region`
3. `highest_education`
4. `imd_band`
5. `age_band`
6. `num_of_prev_attempts`
7. `studied_credits`
8. `disability`
9. `date_registration`
10. `log_total_clicks`

Observed training ranges:

- `gender`: `0..1`
- `region`: `0..12`
- `highest_education`: `0..4`
- `imd_band`: `1..10`
- `age_band`: `0..2`
- `num_of_prev_attempts`: `0..6`
- `studied_credits`: `30..630`
- `disability`: `0..1`
- `date_registration`: `-311..167`
- `log_total_clicks`: `0.0..10.09`

For the API and Flutter app, we should prefer human-readable inputs for categories and compute the numeric encoding server-side.

## Implementation Phases

### Phase 1: Freeze Inference Logic

Goal: make prediction-time preprocessing match notebook training exactly.

Deliverables:

- `summative/API/model_utils.py` for feature engineering and inference helpers
- saved metadata file for categorical mappings, especially `region`
- a simple parity check showing API preprocessing matches `sample_test_row.csv`

Tasks:

- reconstruct and save the category maps used in the notebook
- decide whether the API should accept raw categories or already-encoded numbers
- move feature engineering out of the notebook into reusable Python code

### Phase 2: Build the FastAPI Service

Goal: satisfy Task 2 with a public prediction API and retraining hooks.

Deliverables:

- `summative/API/prediction.py`
- `summative/API/schemas.py`
- `summative/API/requirements.txt`
- Swagger docs available at `/docs`

Endpoints:

- `POST /predict`
- `POST /retrain/submit`
- `POST /retrain/trigger`
- `GET /health`

Implementation notes:

- use Pydantic models with strict datatypes and realistic ranges
- configure CORS for Flutter local development and the deployed mobile/web client, not wildcard `*`
- load `best_model.joblib`, `scaler.joblib`, and saved metadata from `summative/linear_regression`

### Phase 3: Refactor the Flutter App

Goal: turn the ported `DevPulse` scaffold into a one-page student prediction app.

Deliverables:

- one prediction screen only
- 10 input controls mapped to the model inputs
- a `Predict` button
- result/error area for predicted score and student risk band

Recommended UI mapping:

- dropdowns for `gender`, `region`, `highest_education`, `imd_band`, `age_band`, and `disability`
- numeric text fields for `num_of_prev_attempts`, `studied_credits`, `date_registration`, and raw `total_clicks`
- let the API compute `log_total_clicks` so the app stays user-friendly

Refactor targets:

- replace `DevPulse` naming with student-performance wording
- replace GitHub repo services with a single prediction service
- simplify to one screen and remove portfolio/repo-health flows

### Phase 4: Deploy and Finish Submission Assets

Goal: meet the rubric for public API access, app instructions, and demo readiness.

Deliverables:

- Render deployment with public `/docs` URL
- README updates with mission, API link, mobile run steps, and video link
- a short demo checklist for the final recording

Demo talking points already supported by the notebook:

- why Linear Regression was selected over Decision Tree and Random Forest
- loss discussion using MSE and MAE
- how new data would trigger retraining
- why CORS was configured to allow only known origins

## Suggested Build Order

1. Save preprocessing metadata and inference helpers.
2. Implement and test the FastAPI prediction service locally.
3. Refactor the Flutter app to the student predictor flow.
4. Deploy the API to Render and switch Flutter to the public URL.
5. Update the README and prepare the demo script.
