# Behavioral-Analytics-User-Burnout
An end-to-end data pipeline using SQL Server and Power BI to identify cognitive fatigue and digital burnout. By tracking 7-day rolling behavioral baselines, this model isolates extreme usage spikes to predict user churn and prescribe targeted UX interventions.
# Behavioral Analytics: Predicting User Burnout & Attrition

## The Business Problem
Standard product analytics often misinterpret sudden, massive spikes in daily screen time as "high engagement." However, behavioral psychology indicates that these extreme deviations from a user's normal routine actually represent unsustainable binge behavior. This cognitive fatigue is a primary leading indicator of digital burnout and imminent platform churn. Instead of pushing more notifications to these users to drive short-term metrics, platforms must identify them early and apply targeted UX friction (e.g., "Take a break" prompts) to preserve long-term lifetime value (LTV).

## The Methodology
This project bridges statistical anomaly detection with psychological behavioral modeling to create an early-warning system for product teams. 

* **Data Engineering (SQL Server):** Built a telemetry processing pipeline to calculate a rolling 7-day average of normal user engagement (`BaselineAvgDwell`). The script then isolates days where usage violently spiked (`SpikeDwellTime`) and calculates the `FatigueSpikeRatio` to quantify the severity of the deviation.
* **Executive Visualization (Power BI):** Engineered an interactive risk-distribution dashboard mapping normal baseline routines against anomaly spikes. The dashboard employs strict conditional formatting thresholds to visually separate normal variance from critical burnout zones, providing operations teams with an immediate, actionable contact list sorted by risk severity.

## The Strategic Outcome
The model successfully analyzed user telemetry and isolated **143 critical-risk users** exhibiting severe behavioral deviations. The data revealed anomaly spikes up to **9.3x above a user's standard routine**. By isolating these specific cohorts in a dynamic Power BI table, product and operations teams are provided with prioritized, data-backed targets for immediate UX interventions, shifting the strategy from reactive churn management to proactive retention.

## Technical Stack
* **Database & Transformation:** SQL Server, T-SQL (Window Functions, CTEs, Rolling Aggregations)
* **Data Visualization:** Power BI (DAX, Conditional Formatting, Interactive Filtering)
* **Analytical Domain:** Quantitative Research, Behavioral Statistics

## Author
**Utkarsh Pandey** 
Integrating statistical analysis and psychological models to drive proactive, data-informed business strategies.
