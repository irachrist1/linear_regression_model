# FlutterApp

This Flutter app has been ported from the earlier local `summartive_ml` prototype and refactored into a one-page student score predictor for Summative Two.

Current status:

- one prediction screen
- categorical dropdowns and numeric inputs for the model variables
- `Predict` button wired to the FastAPI `/predict` endpoint
- result card showing predicted score, performance band, and engineered features

See [../IMPLEMENTATION_PLAN.md](/Users/christiantonny/Documents/School/linear_regression_model-1/summative/IMPLEMENTATION_PLAN.md) for the pivot plan.

## Run Locally

```bash
# from summative/API
uvicorn prediction:app --reload

# from summative/FlutterApp
flutter pub get
flutter run
```

## Use a Deployed API

When the API is deployed, pass its public base URL to Flutter:

```bash
flutter run --dart-define=API_BASE_URL=https://your-service.onrender.com
```
