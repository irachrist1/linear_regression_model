# GitHub Repository Abandonment Risk Predictor

**Mission:** To help developers, teams, and organizations identify open-source repositories at risk of becoming inactive or abandoned — enabling early intervention to sustain healthy, active projects in the community.

**Problem:** Repository abandonment leads to unmaintained dependencies and security vulnerabilities affecting millions of downstream users. By modeling historical repository activity metrics, we predict how long a repo has gone without a push (days since last push), a direct proxy for abandonment risk.

**Dataset:** [GitHub Repositories Dataset](https://www.kaggle.com/datasets/nikhil25803/github-dataset) — Kaggle. Contains metadata for 10,000+ GitHub repositories including stars, forks, open issues, size, watchers, language, and timestamped activity across diverse programming languages and domains.

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
