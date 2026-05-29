# ETL PIPELINE
# Ingesting and cleaning 5.7M+ records from 12 monthly CSV files
library(dplyr)
library(lubridate)
library(magrittr)

# Scalable Data Ingestion
# Reads all monthly CSV files from the working directory
setwd("C:/Divvy")
csv_files <- list.files(pattern = "*.csv")
data_list <- list()
for (file in csv_files) {
  file_path <- file.path("C:/Divvy", file)
  data <- read.csv(file_path)
  data_list[[file]] <- data
}

# Unified Master Dataset Creation
merged_data <- do.call(rbind, data_list)

# Column Selection - retaining only analytically relevant fields
necessary_cols <- c("ride_id", "rideable_type", "started_at", "ended_at",
                    "start_station_name", "end_station_name", "member_casual")

annual_cleaned <- merged_data %>%
  select(all_of(necessary_cols)) %>%

  # Remove maintenance artifacts (HQ QR stations = internal test rides)
  filter(start_station_name != "HQ QR" | is.na(start_station_name)) %>%

  # Timestamp standardization and ride_length feature derivation
  mutate(
    started_at  = as.POSIXct(started_at, format = "%Y-%m-%d %H:%M:%S"),
    ended_at    = as.POSIXct(ended_at,   format = "%Y-%m-%d %H:%M:%S"),
    ride_length = as.numeric(difftime(ended_at, started_at, units = "mins"))
  ) %>%

  # Remove invalid trip durations (negative, zero)
  filter(ride_length > 0)

# Note: transformed_data (with normalization, log transform, outlier removal,
# and temporal features) is produced by the full team pipeline in Divvy.R.
# Load it before running Part 2 and Part 3.
# transformed_data <- read.csv("C:/Divvy/transformed_data.csv")

# PRINCIPAL COMPONENT ANALYSIS (PCA)
# 10-feature PCA to identify primary variance drivers in ridership behavior
# Dim1: 49.3% variance | Dim2: 20% variance
library(ggplot2)
library(FactoMineR)
library(factoextra)

# Sample 10,000 records for dimensionality reduction
set.seed(123)
sample_size  <- 10000
sampled_data <- transformed_data[sample(nrow(transformed_data), sample_size), ]

# Remove rows with NA in member_casual
sampled_data <- sampled_data %>% filter(!is.na(member_casual))

# 10-feature selection for PCA
reduction_data <- sampled_data %>%
  select(
    trip_duration,
    start_hour,
    trip_duration_normalized,
    trip_duration_standardized,
    trip_duration_log,
    start_day,
    start_minute,
    end_day,
    end_minute,
    trip_duration_hours
  )

# Remove duplicates and preserve row indices
reduction_data  <- reduction_data %>% distinct()
rownames(reduction_data) <- 1:nrow(reduction_data)
original_data   <- sampled_data[rownames(reduction_data), ]

# Standardize
reduction_data_scaled <- scale(reduction_data)

# Fit PCA
pca_result <- prcomp(reduction_data_scaled, center = TRUE, scale. = TRUE)

# Scree Plot - confirms trip_duration as primary variance driver (~49.3% Dim1)
fviz_eig(pca_result, addlabels = TRUE, ylim = c(0, 60)) +
  labs(title = "Scree Plot - Variance Explained by Each Principal Component")

# Variable Contribution Bar Chart - Dim1
fviz_contrib(pca_result, choice = "var", axes = 1, top = 10) +
  labs(title = "Contribution of Variables to Dim1 (trip_duration)")

# Variable Biplot (cos2-colored)
fviz_pca_var(pca_result,
             col.var      = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel        = TRUE) +
  labs(title = "Contribution of Variables")

# Individual PCA Biplot - casual vs member separation
fviz_pca_ind(pca_result,
             geom.ind   = "point",
             pointshape = 21,
             pointsize  = 2,
             fill.ind   = original_data$member_casual,
             col.ind    = "black",
             palette    = "jco",
             addEllipses = TRUE,
             legend.title = "User Type") +
  labs(title = "Individual PCA Biplot - Casual vs Member (Dim1: 49.3%, Dim2: 26.9%)")

# Combined Biplot - variables and individuals
fviz_pca_biplot(pca_result,
                geom.ind    = "point",
                pointshape  = 21,
                pointsize   = 2,
                fill.ind    = original_data$member_casual,
                col.ind     = "black",
                palette     = "jco",
                addEllipses = TRUE,
                label       = "var",
                col.var     = "black",
                repel       = TRUE,
                legend.title = "User Type") +
  labs(title = "Combined PCA Biplot")

# Combined Biplot with cos2 shading
fviz_pca_biplot(pca_result,
                geom.ind    = "point",
                pointshape  = 21,
                pointsize   = 2,
                fill.ind    = original_data$member_casual,
                col.ind     = "black",
                palette     = "jco",
                addEllipses = TRUE,
                label       = "var",
                col.var     = "cos2",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                repel       = TRUE,
                legend.title = "User Type") +
  labs(title = "Combined PCA Biplot with cos2 Shading")

# Additional PCA Scatter - trip_duration_hours vs start_hour
pca_scores <- as.data.frame(predict(pca_result))
colnames(pca_scores) <- colnames(reduction_data_scaled)

ggplot(pca_scores, aes(x = trip_duration_hours, y = start_hour)) +
  geom_point(aes(color = original_data$member_casual), alpha = 0.6) +
  labs(title = "PCA: trip_duration_hours vs start_hour",
       x = "trip_duration_hours", y = "start_hour") +
  theme_minimal()

# Additional PCA Scatter - start_day vs end_day
ggplot(pca_scores, aes(x = start_day, y = end_day)) +
  geom_point(aes(color = original_data$member_casual), alpha = 0.6) +
  labs(title = "PCA: start_day vs end_day",
       x = "start_day", y = "end_day") +
  theme_minimal()

# t-SNE
# Non-linear dimensionality reduction to validate casual vs member clustering
# Two distinct behavioral clusters confirmed in 2D embedding
library(Rtsne)

# Fit t-SNE on the same scaled 10-feature matrix
tsne_result <- Rtsne(reduction_data_scaled, dims = 2, perplexity = 30,
                     verbose = TRUE)

# Extract coordinates
tsne_coords <- as.data.frame(tsne_result$Y)

# t-SNE Scatter Plot
ggplot(tsne_coords, aes(x = V1, y = V2)) +
  geom_point(aes(color = original_data$member_casual), alpha = 0.6) +
  labs(title = "t-SNE: Casual vs Member Behavioral Clusters",
       x = "t-SNE 1", y = "t-SNE 2",
       color = "User Type") +
  theme_minimal()
