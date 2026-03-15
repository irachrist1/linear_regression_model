# Open-Source Learning Infrastructure Sustainability Predictor

**Mission:** Expand access to personalized, technology-enabled learning for students in rural and underserved communities by strengthening the digital tools that support their learning journey.

**Problem:** Many affordable education platforms depend on open-source software, and when those repositories become inactive, students and schools lose reliable systems for continuous learning.

**Dataset:** [GitHub Repositories Dataset](https://www.kaggle.com/datasets/nikhil25803/github-dataset) from Kaggle with 10,000+ repositories and features like stars, forks, issues, size, language, and activity timestamps.

**Task 2 Prep:** `summative/linear_regression/predict_best_model.py` loads the saved best model and predicts one held-out test row as an early warning signal for tool sustainability.

## Repository Structure

```
linear_regression_model/
├── summative/
│   ├── linear_regression/
│   │   └── multivariate.ipynb   ← Main notebook
│   ├── API/                     ← (empty for now)
│   └── FlutterApp/              ← (empty for now)
└── README.md
```

## Notebook Contents (`multivariate.ipynb`)

- Exploratory Data Analysis with 4 meaningful visualizations
- Feature engineering and encoding
- Data standardization
- Linear Regression (with gradient descent via SGDRegressor)
- Decision Tree Regressor
- Random Forest Regressor
- Loss curves for train and test data
- Scatter plot of actual vs predicted (before/after linear fit)
- Best model saved as `best_model.joblib`
- Single-row prediction script

## Prediction Script

Run `python3 summative/linear_regression/predict_best_model.py` after executing the notebook to load the saved artifacts and predict one row from the held-out test data.
