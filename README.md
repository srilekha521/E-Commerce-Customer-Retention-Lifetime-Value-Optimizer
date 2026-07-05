# E-Commerce Customer Retention & Lifetime Value Optimizer

## Project Overview

This project analyzes the Olist Brazilian E-Commerce dataset to understand customer purchasing behavior, identify high-value customers, measure customer retention, and predict customer churn.

The project combines SQL, Python, Machine Learning, and Power BI to build an end-to-end customer analytics solution. It includes data cleaning, RFM analysis, cohort analysis, customer segmentation, churn prediction, and interactive dashboards that provide actionable business insights.

---

## Objectives

- Clean and preprocess e-commerce data
- Perform RFM (Recency, Frequency, Monetary) Analysis
- Build Monthly Cohort Retention Analysis
- Identify High-Value Product Categories
- Calculate Average Order Value (AOV)
- Calculate Repeat Purchase Ratio
- Segment customers using K-Means Clustering
- Predict customer churn using Random Forest
- Visualize business insights using Power BI

---

## Dataset

**Dataset:** Olist Brazilian E-Commerce Dataset

Source:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## Technologies Used

- SQL (MySQL)
- Python
- Pandas
- NumPy
- Scikit-learn
- Matplotlib
- Seaborn
- Joblib
- Power BI
- Jupyter Notebook

---

## Project Workflow

```
Raw Dataset
      │
      ▼
SQL Data Cleaning
      │
      ▼
Feature Engineering
      │
      ▼
RFM Analysis
      │
      ▼
Cohort Analysis
      │
      ▼
Customer Segmentation
      │
      ▼
Churn Prediction
      │
      ▼
Power BI Dashboard
```

---

## SQL Analysis

The SQL phase includes:

- Data Cleaning
- Missing Value Handling
- Referential Integrity Checks
- Date Standardization
- RFM Analysis
- Cohort Analysis
- Monthly Retention Analysis
- High-Value Product Category Analysis
- Average Order Value (AOV)
- Repeat Purchase Ratio

---

## Python Analysis

The Python notebook performs:

- Data Loading
- Data Cleaning
- Feature Engineering
- Standard Scaling
- K-Means Clustering
- Customer Segmentation
- Churn Prediction
- Model Evaluation

---

## Machine Learning

Model Used:

- Random Forest Classifier

Evaluation Metrics:

- Accuracy
- Precision
- Recall
- F1-Score

Output:

- Customer Churn Prediction
- Churn Probability Scores
- Trained Model (.pkl)

---

## Power BI Dashboard

The dashboard includes:

- KPI Cards
- Customer Segmentation
- Revenue Analysis
- Customer Retention
- Monthly Cohort Analysis
- High-Value Product Categories
- Customer Churn Insights

---

## Project Structure

```text
E-Commerce-Customer-Retention-Lifetime-Value-Optimizer
│
├── Dataset/          # Raw Olist datasets
├── Outputs/          # Generated datasets and analytical outputs
├── SQL/              # SQL scripts and analytical views
├── Python/           # Jupyter notebook
├── Models/           # Trained Random Forest model
├── PowerBI/          # Interactive Power BI dashboard
├── Images/           # Dashboard screenshots
├── README.md
└── requirements.txt
```

## Folder Description

| Folder | Description |
|---------|-------------|
| Dataset | Raw Olist e-commerce datasets |
| Outputs | Generated datasets and analytical outputs |
| SQL | SQL scripts for data cleaning and analytics |
| Python | Jupyter notebook for analysis and machine learning |
| Models | Saved Random Forest model |
| PowerBI | Interactive Power BI dashboard |
| Images | Dashboard screenshots used in this README 

---

## Results

- Developed an end-to-end customer analytics pipeline.
- Identified customer segments using RFM Analysis and K-Means Clustering.
- Predicted customer churn using a Random Forest Classifier.
- Built interactive Power BI dashboards for customer retention, revenue analysis, and business KPIs.
- Generated actionable insights to support customer retention and marketing strategies.

---

## How to Run

1. Clone the repository.

```bash
git clone https://github.com/your-username/E-Commerce-Customer-Retention-Lifetime-Value-Optimizer.git
```

2. Install dependencies.

```bash
pip install -r requirements.txt
```

3. Open the Jupyter Notebook inside the `Python` folder.

4. Execute the notebook cells sequentially.

5. Open the Power BI dashboard (`.pbix`) to explore the visualizations.

## Future Improvements

- Deploy the model as a web application
- Automate data refresh
- Improve churn prediction with advanced models
- Add real-time customer analytics

---

## Dashboard Preview

### Customer Segmentation Dashboard

![Customer Segmentation Dashboard](Images/customer_segmentation_dashboard.png)

### Customer Analytics Dashboard

![Customer Analytics Dashboard](Images/customer_analytics_dashboard.png)

### Dashboard Interactivity & DAX Validation

![Dashboard Interactivity & DAX Validation](Images/dashboard_interactivity_dax_validation.png)

## Author

**Srilekha Mummadi**

GitHub:
https://github.com/srilekha521

LinkedIn:
https://www.linkedin.com/in/srilekha-mummadi
