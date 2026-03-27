# Divvy-Bike-Usage-Analysis
### **Executive Summary**
This repository focuses on identifying the behavioral nuances between 'Annual Members' and 'Casual Riders' within the 5.7M+ record Divvy dataset. My specific contribution involved engineering the metric aggregation layer to distinguish utility-based commuting from leisure-based usage.

### **Technical Contributions**
* **Advanced Aggregation:** Developed R scripts to summarize ride frequency and duration across multi-million row datasets.
* **Trend Discovery:** Quantified the weekday 'Commuter Peak' vs. the weekend 'Leisure Spike,' providing data-driven evidence for bike rebalancing.
* **Feature Integration:** Utilized cleaned data features (ride length, day of week) to build a comparative profile of user segments.

### **Key Findings**
* **Commuters (Members):** High frequency, short duration, focused on workdays (8 AM / 5 PM spikes).
* **Leisure (Casual):** 2x increase in trip duration on weekends with a bell-curve peak in the afternoon.

### **Stack**
* **Language:** R (tidyverse, ggplot2, lubridate)
* **Dataset:** 5.7M+ records (Chicago Open Data)
