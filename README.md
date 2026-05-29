# Divvy Bike Usage Analysis (Chicago 2023)

## Overview

Analysis of 5.7M+ Divvy bike-share records from Chicago (2023) covering
ridership patterns, behavioral segmentation, and dimensionality reduction
across casual and member rider groups.

## Team

Three-member project: Mohammad Hamza Piracha, Poshan Pandey,
Usman Matheen Hameed.

## My Contribution

My scope covered the data engineering pipeline and dimensionality
reduction analysis:

- **ETL Pipeline:** Ingested and merged 12 monthly CSV files into a
  unified 1.2GB master dataset using R. Removed unnecessary columns,
  handled missing values, filtered invalid trip durations (negative,
  zero, and trips exceeding 24 hours), and verified timestamp
  consistency.
- **Feature Engineering:** Derived `ride_length` from timestamps,
  `day_of_week`, `start_hour`, and seasonal segmentation features.
  Applied Z-score filtering and Isolation Forest for outlier detection.
  Performed min-max normalization, standardization, and log
  transformation on trip duration.
- **PCA:** Led the PCA phase across 10 features. Dim1 captured 49.3%
  of variance (primary driver: trip_duration), Dim2 captured 20%.
  Generated scree plots, variable contribution bar charts, individual
  biplots, combined biplots, and cos2-shaded biplots to separate casual
  vs member behavioral profiles.
- **t-SNE:** Applied t-SNE to confirm two distinct behavioral clusters
  between casual and member rider groups in non-linear high-dimensional
  space.

The clustering analysis (Elbow Method, Silhouette, Gap Statistic,
K-Means) was a team contribution.

## Key Findings

- Trip duration is the dominant variance driver, accounting for 49.3%
  of Dim1 in PCA.
- PCA and t-SNE both confirm clear separation between casual and member
  rider behavioral profiles.
- Casual riders have longer average trip durations, consistent with
  leisure and tourist usage patterns. Members show consistent weekday
  commuting behavior.

## Repository Structure

```
├── full-code/
│   ├── Data Cleaning and Data Transformation.Rmd
│   ├── Data-Analysis-and-Modeling.Rmd
│   ├── Divvy.R
│   ├── Divvy2.R
│   ├── visuals/               # All generated plots
│   └── docs/                  # Project report, proposal, presentation
├── personal-contribution/
│   ├── ContributionCode.r     # My ETL pipeline and PCA/t-SNE code
│   └── docs/MyContribution.pdf
└── README.md
```

## Technical Stack

- **Language:** R
- **Libraries:** dplyr, tidyr, lubridate, ggplot2, FactoMineR,
  factoextra, Rtsne, magrittr, dbscan, isotree, tidymodels

## Author

**Mohammad Hamza Piracha** |
Data Scientist & Applied AI Engineer |
[LinkedIn](https://www.linkedin.com/in/hamza-piracha) | hamzapiracha@live.com
