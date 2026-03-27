# Divvy-Bike-Usage-Analysis
**Lead Analyst:** Mohammad Hamza Piracha

### **Project Summary**
This repository highlights my individual technical leadership in analyzing 5.7M+ records from Chicago's Divvy bike-share system. I served as the **Lead Data Engineer**, managing the end-to-end pipeline from raw data ingestion to advanced dimensionality reduction.

### **My Technical Contributions**
* **Big Data Pipeline:** Engineered a robust R script to ingest and merge 12 separate monthly datasets (5.7M+ rows), implementing rigorous filtering to eliminate maintenance noise and test data.
* **Dimensionality Reduction (PCA/t-SNE):** Personally executed PCA to determine that trip duration accounts for ~50% of dataset variance. Utilized t-SNE to visualize and validate high-dimensional clusters between 'Casual' and 'Member' segments (see `docs/MyContribution.pdf`).
* **Behavioral Trend Discovery:** Developed the statistical logic to quantify the "Commuter vs. Leisure" divide, proving that annual members dominate weekday traffic while casual ridership spikes by 100%+ in duration on weekends.
* **Feature Engineering:** Created high-value variables including `ride_length` (calculated from timestamps) and `day_of_week` to enable predictive modeling.

### **Visual Findings**
My analysis resulted in two key visualizations (available in this repo):
1. **Scree Plot:** Confirmed the importance of temporal features in predicting bike demand.
2. **t-SNE Scatter Plot:** Demonstrated clear cluster separation, suggesting targeted marketing strategies for casual riders.

### **Tech Stack**
* **Language:** R
* **Tools:** `tidyverse` (dplyr, ggplot2, lubridate), `FactoMineR` (PCA), `Rtsne` (t-SNE)
