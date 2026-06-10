# linear_regression_model

Predict student learning outcomes for early intervention in underserved communities — OULAD-based ML pipeline with FastAPI and Flutter.

## The problem

Educators lack early signals on which students will struggle before it's too late to intervene.

Course click data and demographics exist in OULAD — but turning them into actionable predictions requires a full pipeline, not a notebook that never ships.

## What it does

Train regressors on OULAD, serve predictions via FastAPI, consume them in a Flutter mobile app. API live on Render.

```
POST /predict → predicted outcome + confidence metadata
GET /health → service status
```

## Install

```bash
git clone https://github.com/irachrist1/linear_regression_model.git && cd linear_regression_model
# Download OULAD CSVs per summative/README
jupyter notebook multivariate.ipynb
cd summative/API && uvicorn main:app --reload
cd ../FlutterApp && flutter run
```

## How it works

- **OULAD merge pipeline.** Notebook joins demographics + VLE click streams into model-ready features.
- **Saved best model.** `predict_best_model.py` loads the winning regressor — reproducible inference, not retrain-on-request.
- **FastAPI service.** `/predict`, `/metadata`, `/health` endpoints — Flutter and other clients share one contract.
- **Flutter mobile predictor.** Calls deployed Render API — educators get predictions on device, not in a terminal.
- **Capstone architecture.** Notebook for exploration, API for serving, app for delivery — three layers, one problem.

Built by [Christian Tonny](https://github.com/irachrist1)
