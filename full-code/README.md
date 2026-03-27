# CSP-571 Project: Divvy Bike Usage Analysis

This project analyzes Divvy bike usage patterns in Chicago for the year 2023, focusing on member vs casual riders, ride types, and temporal patterns. The dataset includes ride data for each month of 2023.

## Data Preparation

- **Data Collection**: Monthly ride data for the entire year of 2023 was downloaded.
- **Data Merging**: All monthly datasets were combined into a single dataset for further analysis.

## Data Cleaning

The following steps were performed to clean the data:

1. Removed unnecessary columns.
2. Removed rows with missing values.
3. Converted `started_at` and `ended_at` columns to datetime format.
4. Created new features: trip duration, day of the week, and start hour.
5. Removed trips with non-positive durations and those longer than 24 hours.
6. Ensured consistency by keeping trips where `ended_at` is after `started_at`.

## Feature Engineering

1. Normalized trip duration.
2. Extracted additional date and time features (e.g., start month, start day, etc.).
3. One-hot encoded categorical variables (`rideable_type` and `member_casual`).
4. Segmented trips by time of day and season.

## Distribution Analysis

- **Member vs Casual Riders**: Analyzed ride types for each month, seasons, and time of day.
- **Station Analysis**: Plotted the distribution of starting and ending stations.
## Clustering

- **Member vs Casual Riders**: Analyzed ride types for each month, seasons, and time of day.
- **Station Analysis**: Plotted the distribution of starting and ending stations.

## Requirements

- R version 4.4.1 or later
- Libraries: `dplyr`, `tidyr`, `lubridate`, `tidymodels`, `ggplot2`, `dbscan`, `isotree`, `magrittr`

## How to Run

1. Clone the repository.
2. Install the required libraries.
3. Follow the data preparation and cleaning steps outlined in the scripts.
4. Execute the analysis and visualization scripts to generate insights.


