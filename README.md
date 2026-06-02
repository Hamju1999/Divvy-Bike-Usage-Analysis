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
K-Means) and distribution visualizations were team contributions.

## Key Findings

- Trip duration is the dominant variance driver, accounting for 49.3%
  of Dim1 in PCA.
- PCA and t-SNE both confirm clear separation between casual and member
  rider behavioral profiles.
- Casual riders have longer average trip durations, consistent with
  leisure and tourist usage patterns. Members show consistent weekday
  commuting behavior.

## Visuals

**PCA and t-SNE plots** (my contribution) are in
`personal-contribution/docs/MyContribution.pdf`.

**Distribution and clustering plots** (team contribution) are in
`full-code/visuals/`:

| File | Description |
|---|---|
| `violin_trip_duration.png` | Trip duration distribution by member type |
| `rug_plot_trip_duration.png` | Trip duration density rug plot |
| `scatterplot_matrix.png` | Scatterplot matrix - trip duration vs start hour |
| `member_vs_casual_by_month.png` | Ride counts by month - casual vs member |
| `member_vs_casual_by_season.png` | Ride counts by season - casual vs member |
| `time_of_day_distribution.png` | Trip distribution by time of day |
| `top10_start_stations.png` | Top 10 starting stations by trip count |
| `top10_end_stations.png` | Top 10 ending stations by trip count |
| `clustering_elbow_method.png` | Elbow method for optimal cluster count |
| `clustering_silhouette.png` | Silhouette method for optimal cluster count |
| `clustering_gap_statistic.png` | Gap statistic for optimal cluster count |
| `clustering_kmeans_viz.png` | K-Means cluster visualization |
| `cluster_scatter_start_hour.png` | Cluster scatter - start hour vs trip duration |
| `cluster_scatter_day_of_week.png` | Cluster scatter - day of week vs trip duration |
| `cluster_scatter_season.png` | Cluster scatter - season vs trip duration |
| `cluster_scatter_time_of_day.png` | Cluster scatter - time of day vs trip duration |

## Repository Structure

```
├── full-code/
│   ├── Data Cleaning and Data Transformation.Rmd  # Team pipeline
│   ├── Data-Analysis-and-Modeling.Rmd             # Team analysis
│   ├── Divvy.R                                    # ETL and cleaning
│   ├── Divvy2.R                                   # Analysis and modeling
│   ├── visuals/                                   # Team-generated plots
│   └── docs/                                      # Report, proposal, presentation
├── personal-contribution/
│   ├── ContributionCode.r     # My ETL pipeline and PCA/t-SNE code
│   └── docs/MyContribution.pdf  # My PCA and t-SNE visual outputs
└── README.md
```

## Technical Stack

- **Language:** R
- **Libraries:** dplyr, tidyr, lubridate, ggplot2, FactoMineR,
  factoextra, Rtsne, magrittr, dbscan, isotree, tidymodels, GGally,
  cluster

## License
[MIT](./LICENSE) © 2024 Mohammad Hamza Piracha

## Author

**Mohammad Hamza Piracha** |
Data Scientist & Applied AI Engineer |
[LinkedIn](https://www.linkedin.com/in/hamza-piracha) | hamzapiracha@live.com
