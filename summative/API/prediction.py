from __future__ import annotations

import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from model_utils import (
    active_model_name,
    append_retrain_sample,
    load_buffered_samples,
    model_metadata,
    predict_from_payload,
    retrain_from_buffer,
)
from schemas import (
    PredictionInput,
    PredictionResponse,
    RetrainSample,
    RetrainSubmitResponse,
)


def configured_origins() -> list[str]:
    defaults = [
        "http://localhost",
        "http://127.0.0.1",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:52580",
        "http://127.0.0.1:52580",
    ]
    configured = os.getenv("ALLOWED_ORIGINS")
    if configured:
        defaults.extend(origin.strip() for origin in configured.split(",") if origin.strip())
    render_url = os.getenv("RENDER_EXTERNAL_URL")
    if render_url:
        defaults.append(render_url.rstrip("/"))
    return sorted(set(defaults))


app = FastAPI(
    title="Student Learning Outcome Predictor API",
    description=(
        "FastAPI service for predicting average student assessment scores "
        "using the Summative One OULAD regression model."
    ),
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=configured_origins(),
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Accept", "Authorization", "Content-Type", "Origin"],
)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "status": "ok",
        "message": "Student Learning Outcome Predictor API is running.",
        "model_name": active_model_name(),
        "docs_url": "/docs",
    }


@app.get("/health")
def health() -> dict[str, object]:
    return {
        "status": "ok",
        "model_name": active_model_name(),
        "buffered_samples": len(load_buffered_samples()),
    }


@app.get("/metadata")
def metadata() -> dict[str, object]:
    return model_metadata()


@app.post("/predict", response_model=PredictionResponse)
def predict(payload: PredictionInput) -> PredictionResponse:
    result = predict_from_payload(payload.model_dump(mode="json"))
    return PredictionResponse(**result)


@app.post("/retrain/submit", response_model=RetrainSubmitResponse)
def submit_retrain_sample(sample: RetrainSample) -> RetrainSubmitResponse:
    buffered = append_retrain_sample(
        {
            "features": sample.features.model_dump(mode="json"),
            "actual_avg_score": sample.actual_avg_score,
        }
    )
    return RetrainSubmitResponse(status="sample buffered", buffered_samples=buffered)


@app.post("/retrain/trigger")
def trigger_retrain() -> dict[str, object]:
    return retrain_from_buffer()
