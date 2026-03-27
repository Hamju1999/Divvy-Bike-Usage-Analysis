library(googledrive)
library(dplyr)

# Authenticate and specify scope
drive_auth(scopes = "https://www.googleapis.com/auth/drive.readonly")

# Your Google Drive file URL
file_url <- "https://drive.google.com/file/d/1ENtG3huMNMBMekluWXfYlAGHWXSkQiLC/view?usp=sharing"

# Get the file ID from the URL
file_id <- drive_get(as_id(file_url))

# Download the file to a temporary location
drive_download(as_id(file_id), path = "transformed_data.csv", overwrite = TRUE)

# Load the transformed data
transformed_data <- read.csv("transformed_data.csv")

# Use the transformed_data as needed

# Load necessary libraries
library(ggplot2)
library(dplyr)

# Load the transformed data

# Violin Plot for Member Type vs Trip Duration
ggplot(transformed_data, aes(x = member_casual, y = trip_duration)) +
  geom_violin(fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Violin Plot of Trip Duration by Member Type",
    x = "Member Type",
    y = "Trip Duration (minutes)"
  ) +
  theme_minimal()

# Rug Plot of Trip Duration
ggplot(transformed_data, aes(x = trip_duration)) +
  geom_rug(sides = "b", color = "steelblue") +
  labs(
    title = "Rug Plot of Trip Duration",
    x = "Trip Duration (minutes)",
    y = "Density"
  ) +
  theme_minimal()

library(GGally)
numeric_columns <- transformed_data %>%
  select(trip_duration, start_hour) %>%
  na.omit()

ggpairs(numeric_columns) +
  labs(title = "Scatterplot Matrix for Time Duration") +
  theme_minimal()

# Member vs Casual Riders by Ride Type for Each Month
ggplot(transformed_data, aes(x = start_month, fill = member_casual)) +
  geom_bar(position = "dodge") +
  labs(
    title = "Member vs Casual Riders by Ride Type for Each Month",
    x = "Month",
    y = "Count",
    fill = "Member Type"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Member vs Casual Riders by Seasons
ggplot(transformed_data, aes(x = season, fill = member_casual)) +
  geom_bar(position = "dodge") +
  labs(
    title = "Member vs Casual Riders by Seasons",
    x = "Season",
    y = "Count",
    fill = "Member Type"
  ) +
  theme_minimal()

# Time of Day Distribution
ggplot(transformed_data, aes(x = time_of_day)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Distribution of Trips by Time of Day",
    x = "Time of Day",
    y = "Count"
  ) +
  theme_minimal()

# Starting Station Distribution (Top 10)
top_start_stations <- transformed_data %>%
  count(start_station_name, sort = TRUE) %>%
  top_n(10, wt = n)

ggplot(top_start_stations, aes(x = reorder(start_station_name, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Starting Stations",
    x = "Start Station",
    y = "Count"
  ) +
  theme_minimal()

# End Station Distribution (Top 10)
top_end_stations <- transformed_data %>%
  count(end_station_name, sort = TRUE) %>%
  top_n(10, wt = n)

ggplot(top_end_stations, aes(x = reorder(end_station_name, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Ending Stations",
    x = "End Station",
    y = "Count"
  ) +
  theme_minimal()

### Clustering

library(tidyr)
library(cluster)
library(factoextra)
library(dplyr)

# Sample a subset of the data
set.seed(123)
sample_size <- 10000  # Adjust sample size based on your memory constraints
sampled_data <- transformed_data[sample(nrow(transformed_data), sample_size), ]

# Convert non-numeric columns to numeric using their underlying integer codes
clustering_data <- sampled_data %>%
  select(trip_duration, start_hour, day_of_week, season, time_of_day) %>%
  mutate(across(c(day_of_week, season, time_of_day), ~ as.numeric(as.factor(.))))

# Check for NA values after conversion
if (any(is.na(clustering_data))) {
  warning("There are NA values in the data after conversion. Please check your data.")
}

# Scale the data
clustering_data_scaled <- scale(clustering_data)

# Elbow Method with sampled data
set.seed(123)
elbow_plot <- fviz_nbclust(clustering_data_scaled, kmeans, method = "wss") +
  labs(
    title = "Elbow Method for Optimal Number of Clusters (Sampled Data)",
    x = "Number of Clusters",
    y = "Total Within-Cluster Sum of Squares"
  ) +
  theme_minimal()
print(elbow_plot)

# Silhouette Method with sampled data
set.seed(123)
silhouette_plot <- fviz_nbclust(clustering_data_scaled, kmeans, method = "silhouette") +
  labs(
    title = "Silhouette Method for Optimal Number of Clusters (Sampled Data)",
    x = "Number of Clusters",
    y = "Average Silhouette Width"
  ) +
  theme_minimal()
print(silhouette_plot)

set.seed(123)
gap_stat <- clusGap(clustering_data_scaled, FUN = kmeans, nstart = 25, K.max = 10, B = 50)
gap_stat_plot <- fviz_gap_stat(gap_stat) +
  labs(
    title = "Gap Statistic Method for Optimal Number of Clusters (Sampled Data)",
    x = "Number of Clusters",
    y = "Gap Statistic"
  ) +
  theme_minimal()
print(gap_stat_plot)

optimal_clusters <- 3

set.seed(123)
kmeans_result <- kmeans(clustering_data_scaled, centers = optimal_clusters, nstart = 25)

# Add cluster assignments to the sampled data
sampled_data$cluster <- kmeans_result$cluster

# Evaluate clusters
wss <- sum(kmeans_result$withinss)
silhouette_score <- silhouette(sampled_data$cluster, dist(clustering_data_scaled))

# Print the evaluation metrics
cat("Total Within-Cluster Sum of Squares (WSS):", wss, "\n")
cat("Average Silhouette Width:", mean(silhouette_score[, 3]), "\n")

# Visualize the clusters
fviz_cluster(kmeans_result, data = clustering_data_scaled) +
  labs(
    title = paste("K-means Clustering with", optimal_clusters, "Clusters"),
    x = "Feature 1",
    y = "Feature 2"
  ) +
  theme_minimal()

# Visualize clusters using ggplot2
ggplot(sampled_data, aes(x = start_hour, y = trip_duration, color = as.factor(cluster))) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Clusters of Trip Duration vs Start Hour",
    x = "Start Hour",
    y = "Trip Duration (minutes)",
    color = "Cluster"
  ) +
  theme_minimal()

# Visualize clusters by day of the week
ggplot(sampled_data, aes(x = as.numeric(day_of_week), y = trip_duration, color = as.factor(cluster))) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Clusters of Trip Duration vs Day of the Week",
    x = "Day of the Week",
    y = "Trip Duration (minutes)",
    color = "Cluster"
  ) +
  theme_minimal()

# Visualize clusters by season
ggplot(sampled_data, aes(x = season, y = trip_duration, color = as.factor(cluster))) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Clusters of Trip Duration vs Season",
    x = "Season",
    y = "Trip Duration (minutes)",
    color = "Cluster"
  ) +
  theme_minimal()

# Visualize clusters by time of day
ggplot(sampled_data, aes(x = time_of_day, y = trip_duration, color = as.factor(cluster))) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Clusters of Trip Duration vs Time of Day",
    x = "Time of Day",
    y = "Trip Duration (minutes)",
    color = "Cluster"
  ) +
  theme_minimal()

# Libraries for PCA and visualization
library(Rtsne)
library(ggplot2)
library(dplyr)

# Sample a subset of the data
set.seed(123)
sample_size <- 10000  # Adjust sample size based on your memory constraints
sampled_data <- transformed_data[sample(nrow(transformed_data), sample_size), ]

# Filter out rows with NA in member_casual
sampled_data <- sampled_data %>% filter(!is.na(member_casual))

# Select columns for dimensionality reduction
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

# Remove duplicates
reduction_data <- reduction_data %>% distinct()

# Ensure row names are preserved
rownames(reduction_data) <- 1:nrow(reduction_data)

# Retain the corresponding rows in the original data
original_data <- sampled_data[rownames(reduction_data), ]

# Standardize the data
reduction_data_scaled <- scale(reduction_data)

# Perform PCA
pca_result <- prcomp(reduction_data_scaled, center = TRUE, scale. = TRUE)

# Extract PC scores
pca_scores <- as.data.frame(predict(pca_result))

# Set the column names of pca_scores to match the original features
colnames(pca_scores) <- colnames(reduction_data_scaled)

# Scree Plot
fviz_eig(pca_result)

# Contribution of variables
fviz_contrib(pca_result, choice = "var", axes = 1, top = 10) + labs(title = "Contribution of Variables to trip_duration")
fviz_pca_var(pca_result, col.var = "cos2", gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), repel = TRUE) + labs(title = "Contribution of Variables")

# Individual PCA Plot
fviz_pca_ind(pca_result, geom.ind = "point", pointshape = 21, pointsize = 2, fill.ind = original_data$member_casual, 
             col.ind = "black", palette = "jco", addEllipses = TRUE, legend.title = "Group")

# Biplot
fviz_pca_biplot(pca_result,geom.ind = "point", pointshape = 21, pointsize = 2, fill.ind = original_data$member_casual,  
                col.ind = "black",palette = "jco", addEllipses = TRUE, label = "var",  col.var = "black", repel = TRUE,legend.title = "Group")


# Combined biplot with cos2
fviz_pca_biplot(pca_result, geom.ind = "point", pointshape = 21, pointsize = 2, fill.ind = original_data$member_casual, 
                col.ind = "black", palette = "jco", addEllipses = TRUE, label = "var", col.var = "cos2", 
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),repel = TRUE,legend.title = "Group")

# Additional PCA Plots
ggplot(pca_scores, aes(x = trip_duration_hours, y = start_hour)) +
  geom_point(aes(color = original_data$member_casual), alpha = 0.6) +
  labs(
    title = "PCA: trip_duration_hours vs start_hour",
    x = "trip_duration_hours",
    y = "start_hour"
  ) +
  theme_minimal()

ggplot(pca_scores, aes(x = start_day, y = end_day)) +
  geom_point(aes(color = original_data$member_casual), alpha = 0.6) +
  labs(
    title = "PCA: start_day vs end_day",
    x = "start_day",
    y = "end_day"
  ) +
  theme_minimal()

# Perform t-SNE
tsne_result <- Rtsne(reduction_data_scaled, dims = 2, perplexity = 30, verbose = TRUE)

# Extract t-SNE coordinates
tsne_coords <- as.data.frame(tsne_result$Y)

# Visualize t-SNE results
ggplot(tsne_coords, aes(x = V1, y = V2)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "t-Distributed Stochastic Neighbor Embedding",
    x = "t-SNE 1",
    y = "t-SNE 2"
  ) +
  theme_minimal()
