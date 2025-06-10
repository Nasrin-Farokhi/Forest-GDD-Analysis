# Install and load required packages
install.packages("readxl")   # For reading Excel files
install.packages("sf")       # For working with spatial (map) data
install.packages("rnaturalearth")      # For downloading natural earth map data
install.packages("rnaturalearthdata")  # Required support data for rnaturalearth
install.packages("ggplot2")  # For creating visualizations
install.packages("dplyr")    # For data manipulation

# Load libraries
library(readxl)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(tibble)
library(tidyr)

# Set working directory to your project folder
setwd("G:/دوره نرم افزار جنگل 2023/ProjectForest/Tree_Phenology_Project")

# -------------------- QUESTION 1 --------------------

# Read the "annual_production" sheet from Excel file
data <- read_excel("file_task.xlsx", sheet = "annual_production")

# View first rows of data
head(data)

# Filter rows for forest biome only (BIOME_TYPE == "F")
forest_data <- data %>% 
  filter(BIOME_TYPE == "F")

# Remove rows where ANPP is missing (NA)
forest_data <- forest_data %>%
  filter(!is.na(ANPP))

# Convert ANPP column from character to numeric
forest_data <- forest_data %>%
  mutate(ANPP = as.numeric(ANPP))

# Remove rows where ANPP conversion produced NA
forest_data <- forest_data %>%
  filter(!is.na(ANPP))

# Log-transform the ANPP values for normalization
forest_data <- forest_data %>%
  mutate(logANPP = log(ANPP))

# Perform Kruskal-Wallis test on logANPP by MANAGEMENT (M vs N)
kruskal_test <- kruskal.test(logANPP ~ MANAGEMENT, data = forest_data)
print(kruskal_test)

# Create and store a boxplot comparing logANPP between management types
x11()
p <- ggplot(forest_data, aes(x = MANAGEMENT, y = logANPP, fill = MANAGEMENT)) +
  geom_boxplot() +
  labs(
    title = "Comparison of logANPP Between Managed and Unmanaged Forests",
    x = "Forest Management (M = Managed, N = Natural)",
    y = "log(ANPP)"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("M" = "#66C2A5", "N" = "#FC8D62")) +
  theme(legend.position = "none")
print(p)

# Save the plot as high-resolution PNG
ggsave("logANPP_boxplot.png", plot = p, width = 8, height = 5, dpi = 300)

# Summary statistics of logANPP per management type
forest_data %>%
  group_by(MANAGEMENT) %>%
  summarise(
    count = n(),
    median_logANPP = median(logANPP),
    IQR_logANPP = IQR(logANPP),
    min = min(logANPP),
    max = max(logANPP)
  )

# Export cleaned dataset to CSV
write.csv(forest_data, "logANPP_data.csv", row.names = FALSE)

# -------------------- QUESTION 2 --------------------

# Load world map and filter to Europe
world <- ne_countries(scale = "medium", returnclass = "sf")
europe <- world %>% filter(region_un == "Europe")

# Filter forest sites located in European lat/lon ranges
europe_data <- forest_data %>%
  filter(LATITUDE >= 35, LATITUDE <= 70,
         LONGITUDE >= -25, LONGITUDE <= 40)

# Convert site coordinates into sf spatial object
europe_sites_sf <- st_as_sf(europe_data, coords = c("LONGITUDE", "LATITUDE"), crs = 4326)

# Plot European map with site points colored by management
x11()
ggplot() +
  geom_sf(data = europe, fill = "gray95", color = "gray60") +
  geom_sf(data = europe_sites_sf, aes(color = MANAGEMENT), size = 2, alpha = 0.8) +
  scale_color_manual(values = c("M" = "forestgreen", "N" = "dodgerblue"),
                     labels = c("Managed", "Unmanaged")) +
  labs(
    title = "European Forest Sites: Managed vs. Unmanaged",
    color = "Forest Type"
  ) +
  theme_minimal()

# Save the European map to PNG
ggsave("europe_forest_sites_map.png", width = 10, height = 6, dpi = 300)

# -------------------- QUESTION 3 --------------------

# Load daily temperature data from BUDBURST sheet
budburst_data <- read_excel("file_task.xlsx", sheet = "budburst")

# Set threshold temperature for GDD calculation
T_threshold <- 5

# ----------- GDD Calculation for 2018 ------------

# Extract 2018 temperature row
temp_2018 <- as.numeric(budburst_data[1, ])
names(temp_2018) <- names(budburst_data)

# Extract DOY numbers and filter until April 16 (DOY 106)
day_numbers <- as.numeric(sub("DOY", "", names(temp_2018)))
valid_days_2018 <- which(day_numbers <= 106)
temps_until_budburst <- temp_2018[valid_days_2018]

# Calculate daily heat (only if temp > threshold)
daily_heat_2018 <- pmax(temps_until_budburst - T_threshold, 0)

# Calculate GDD until budburst in 2018
GDD_2018 <- sum(daily_heat_2018)
print(GDD_2018)

# ----------- GDD Estimation for 2019 ------------

# Extract 2019 temperature row
temp_2019 <- as.numeric(budburst_data[2, ])

# Remove unrealistic values > 50°C
temp_2019[temp_2019 > 50] <- NA

# Replace NA with 0 to continue safely
temp_2019[is.na(temp_2019)] <- 0

# Compute daily heat and cumulative GDD for 2019
daily_heat_2019 <- pmax(temp_2019 - T_threshold, 0)
cumulative_GDD_2019 <- cumsum(daily_heat_2019)

# Identify first DOY in 2019 when cumulative GDD ≥ GDD_2018
budburst_day_2019 <- which(cumulative_GDD_2019 >= GDD_2018)[1]

# Convert DOY to calendar date
budburst_date_2019 <- as.Date(budburst_day_2019 - 1, origin = "2019-01-01")
print(budburst_date_2019)

# ----------- GDD Line Plot (2018 vs 2019) ------------

# Determine number of days in the dataset
num_days <- ncol(budburst_data)

# Recompute GDD series for both years (with NA cleaning)
temp_2018 <- as.numeric(budburst_data[1, 1:num_days])
temp_2018[temp_2018 > 50] <- NA
temp_2018[is.na(temp_2018)] <- 0
daily_heat_2018 <- pmax(temp_2018 - T_threshold, 0)
cumulative_GDD_2018 <- cumsum(daily_heat_2018)

# Create tidy tibble for plotting
gdd_data <- tibble(
  DayOfYear = 1:num_days,
  GDD_2018 = cumulative_GDD_2018,
  GDD_2019 = cumulative_GDD_2019[1:num_days]
)

# Pivot data for ggplot
gdd_long <- gdd_data %>%
  pivot_longer(cols = c(GDD_2018, GDD_2019),
               names_to = "Year",
               values_to = "GDD")

# Plot cumulative GDD for both years
x11()
ggplot(gdd_long, aes(x = DayOfYear, y = GDD, color = Year)) +
  geom_line(size = 1.2) +
  geom_hline(yintercept = GDD_2018, linetype = "dashed", color = "gray40") +
  labs(
    title = "Cumulative Growing Degree Days (GDD) for 2018 and 2019",
    subtitle = "Threshold Temperature = 5°C",
    x = "Day of Year",
    y = "Cumulative GDD",
    color = "Year"
  ) +
  scale_color_manual(values = c("GDD_2018" = "#1f77b4", "GDD_2019" = "#ff7f0e"),
                     labels = c("2018", "2019")) +
  theme_minimal()

# Save GDD plot to PNG
ggsave("GDD_Cumulative_2018_2019.png", width = 9, height = 6, dpi = 300)
