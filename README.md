
# Forest Productivity and Budburst Phenology: Statistical and Spatial Analysis Using R

This repository contains a comprehensive scientific project in the field of environmental and ecological data analysis. The objective of this work is to investigate forest productivity and predict budburst timing in temperate tree species using climatic and ecological datasets. The entire analysis is implemented in the R programming language, utilizing a variety of specialized packages for statistical modeling, geospatial analysis, and data visualization. The project is organized into three main components:

## 🔍 Summary of Analyses

### 1. Comparative Analysis of Forest Productivity (ANPP)

To assess the impact of forest management on productivity, log-transformed values of Annual Net Primary Production (ANPP) were compared between managed and unmanaged forest sites. A non-parametric **Kruskal–Wallis test** was used to evaluate differences between groups, considering the non-normal distribution of the data.

### 2. Spatial Visualization of European Forest Sites

Using georeferenced data and geospatial tools such as `sf` and `rnaturalearth`, forest sites across Europe were mapped. Each site was categorized by management type, allowing for visual assessment of the spatial distribution of managed and natural forest ecosystems.

### 3. Budburst Modeling Based on Growing Degree Days (GDD)

To model tree budburst timing, the concept of **Growing Degree Days (GDD)** was applied. The GDD required for budburst in 2018 was calculated based on daily temperature data and then used to estimate the expected budburst date in 2019. This approach provides insight into interannual climatic variability and its influence on phenological responses.

## 📁 Repository Structure

- `DataAnalysis_Report.pdf` – Full analytical report including methods, results, figures, and interpretations  
- `Annotated_R_Code.R` – Fully executable R script with explanatory comments  
- `*.png` – Output graphics (boxplot, map, GDD plot)  
- `data/` – Raw Excel file used as input for the analyses

## 📦 R Packages Used

- `ggplot2`  
- `dplyr`  
- `readxl`  
- `sf`  
- `rnaturalearth`  
- `tidyverse`

## 📌 Project Information

This project was developed independently as an analytical exercise. It was designed to enhance practical skills in ecological data analysis, spatial visualization, and phenological modeling using R.
