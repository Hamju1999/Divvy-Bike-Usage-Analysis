# Data Preparation, Cleaning, and Transformation

## Data Preparation
###  Installing Libraries
install.packages(c("dplyr", "tidyr", "lubridate", "tidymodels", "ggplot2", "dbscan"))
install.packages("isotree")
install.packages("magrittr")
library(isotree)
library(magrittr)
library(dplyr)
library(tidyr)
library(lubridate)
library(tidymodels)
library(ggplot2)
library(dbscan)

### Setting WD to dataset file and listing all dataset
setwd("C:/Divvy")
csv_files <- list.files(pattern = "*.csv")

### Reading and sorting dataframes
data_list <- list()
for (file in csv_files) {
  file_path <- file.path("C:/Divvy", file)
  data <- read.csv(file_path)
  data_list[[file]] <- data
}

### Merging data for all months into 1
merged_data <- do.call(rbind, data_list)

### Saving the merged data as merged_data
write.csv(merged_data, "C:/Divvy/merged_data.csv", row.names = FALSE)

## Data cleaning and Transformation
###  Data Cleaning
#### Removing Unnecessary Columns
necessary <- c("ride_id","rideable_type", "started_at", "ended_at", "start_station_name", "end_station_name", "member_casual")
annual <- merged_data %>% select(all_of(necessary))

#### Removing Missing Values
cleaned_annual <- annual %>% drop_na()
dim(cleaned_annual)

#### Convert 'started_at' and 'ended_at' to datetime
cleaned_annual <- cleaned_annual %>%
  mutate(
    started_at = ymd_hms(started_at),
    ended_at = ymd_hms(ended_at)
  )

#### Create new features: trip duration, day of the week, hour of the day
cleaned_annual <- cleaned_annual %>%
  mutate(
    trip_duration = as.numeric(difftime(ended_at, started_at, units = "mins")),
    day_of_week = wday(started_at, label = TRUE),
    start_hour = hour(started_at)
  )

#### Remove negative or zero trip durations
cleaned_annual <- cleaned_annual %>%
  filter(trip_duration > 0)

#### Handle outliers in trip duration (e.g., removing trips longer than 24 hours)
cleaned_annual <- cleaned_annual %>%
  filter(trip_duration <= 1440)

#### Check for consistency: 'ended_at' should be after 'started_at'
cleaned_annual <- cleaned_annual %>%
  filter(ended_at > started_at)
dim(cleaned_annual)

#### Verifying cleaned data and saving it for further analysis
dim(cleaned_annual)
summary(cleaned_annual)
write.csv(cleaned_annual, "C:/Divvy/cleaned_annual.csv", row.names = FALSE)

### Outlier Detection
#### Z-score Method for outlier detection
# The Z-score method standardizes the dataset and identifies outliers based on a threshold, usually 3 standard deviations from the mean.
# Calculate Z-scores
cleaned_annual <- cleaned_annual %>%
  mutate(z_score = (trip_duration - mean(trip_duration)) / sd(trip_duration))

# Filter out rows with Z-scores greater than 3 or less than -3
cleaned_annual <- cleaned_annual %>%
  filter(abs(z_score) <= 3) %>%
  select(-z_score)

#### Isolation Forest Method for outlier detection
# Isolation Forest is a machine learning algorithm that isolates observations by randomly selecting a feature and then randomly selecting a split value between the maximum and minimum values of the selected feature.
#### Isolation Forest Method for outlier detection
data_matrix <- as.matrix(cleaned_annual)

# Fit Isolation Forest model
iso_forest <- isolation.forest(data_matrix, ntrees = 100)

# Predict outliers
outlier_scores <- predict(iso_forest, data_matrix)

# Set a threshold for outlier scores
threshold <- 0.5

# Filter out outliers
cleaned_annual_isoforest <- cleaned_annual[outlier_scores < threshold, ]
write.csv(cleaned_annual_isoforest, "C:/Divvy/cleaned_annual_isoforest.csv", row.names = FALSE)

### Data Transformation
#### Normalization and Standardization
# Load necessary libraries including dplyr
library(dplyr)

# Min-Max Normalization
cleaned_annual_isoforest <- cleaned_annual_isoforest %>%
  mutate(trip_duration_normalized = (trip_duration - min(trip_duration))/(max(trip_duration) - min(trip_duration)))

# Standardization
cleaned_annual_isoforest <- cleaned_annual_isoforest %>%
  mutate(trip_duration_standardized = (trip_duration - mean(trip_duration)) / sd(trip_duration))

#### Log Transformation
# Log Transformation
cleaned_annual_isoforest <- cleaned_annual_isoforest %>%
  mutate(trip_duration_log = log(trip_duration + 1))

#### Date and Time Features
# Load necessary libraries including dplyr and lubridate
library(dplyr)
library(lubridate)

# Update date and time features
cleaned_annual_isoforest <- cleaned_annual_isoforest %>%
  mutate(
    start_date = as.Date(started_at),
    start_month = lubridate::month(started_at, label = TRUE),
    start_day = day(started_at),
    start_hour = hour(started_at),
    start_minute = minute(started_at),
    end_date = as.Date(ended_at),
    end_month = lubridate::month(ended_at, label = TRUE),
    end_day = day(ended_at),
    end_hour = hour(ended_at),
    end_minute = minute(ended_at)
  )

#### Feature Engineering
# Load necessary packages
library(dplyr)
library(tidyr)
library(lubridate)

# Assuming cleaned_annual_isoforest is your cleaned and preprocessed data

# Ensure rideable_type and member_casual are factors
cleaned_annual_isoforest <- cleaned_annual_isoforest %>%
  mutate(
    rideable_type = as.factor(rideable_type),
    member_casual = as.factor(member_casual)
  )

# Additional feature engineering
transformed_data <- cleaned_annual_isoforest %>%
  mutate(
    trip_duration_hours = trip_duration / 60,
    time_of_day = case_when(
      start_hour >= 5 & start_hour < 12 ~ "Morning",
      start_hour >= 12 & start_hour < 17 ~ "Afternoon",
      start_hour >= 17 & start_hour < 21 ~ "Evening",
      TRUE ~ "Night"
    ),
    season = case_when(
      month(started_at) %in% c(12, 1, 2) ~ "Winter",
      month(started_at) %in% c(3, 4, 5) ~ "Spring",
      month(started_at) %in% c(6, 7, 8) ~ "Summer",
      month(started_at) %in% c(9, 10, 11) ~ "Fall"
    )
  )

# Display the transformed dataset
head(transformed_data)
write.csv(transformed_data, "C:/Divvy/transformed_data.csv", row.names = FALSE)

### Distribution Analysis
#### Violin Plot for Member Type vs Trip Duration


#### Rug Plot of Trip Duration


#### Scatterplot Matrix for time duration


#### Member vs Casual Riders by Ride Type for Each Month


#### Member vs Casual Riders by Seasons


#### Time of Day Distribution


#### Starting Station Distribution (Top 10)


#### End Station Distribution (Top 10)


# Plot for busy hours of the day
ggplot(transformed_data, aes(x = factor(start_hour))) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Trips by Hour of the Day",
    x = "Hour of the Day",
    y = "Number of Trips"
  ) +
  theme_minimal()

# Plot for busy days of the week
ggplot(transformed_data, aes(x = day_of_week)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Trips by Day of the Week",
    x = "Day of the Week",
    y = "Number of Trips"
  ) +
  theme_minimal()

# 1. Number of Trips by Season
ggplot(transformed_data, aes(x = season)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Number of Trips by Season",
    x = "Season",
    y = "Number of Trips"
  ) +
  theme_minimal()

# 2. Number of Trips by Time of Day
ggplot(transformed_data, aes(x = time_of_day)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Number of Trips by Time of Day",
    x = "Time of Day",
    y = "Number of Trips"
  ) +
  theme_minimal()

# 3. Number of Trips by Weekday vs Weekend
ggplot(transformed_data, aes(x = weekday_weekend)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Number of Trips by Weekday vs. Weekend",
    x = "Day Type",
    y = "Number of Trips"
  ) +
  theme_minimal()
