## finalproject
## Immigrant-Native Wage Gap Analysis (ACS PUMS 2023)

This project examines the wage gap between immigrants and native-born individuals using the 2023 ACS 1-Year PUMS dataset. The analysis includes OLS regressions, Oaxaca-Blinder decomposition, and quantile regressions.

## Project Structure
- data
    - `raw.csv`: The dataset used for analysis.
    - `pums_clean.csv`: Cleaned dataset after preprocessing.
- output
    - `ols_result.xlsx`: OLS regression results.
    - `oaxaca_result.xlsx`: Oaxaca-Blinder decomposition results.
    - `quantile_regression_result.xlsx`: Quantile regression results.
    - `immigrant_plot.png`: Plot of immigrant coefficient across quantiles and OLS

- R
    - `load_data.R`: Load and preprocess the data.
    - `reg.R`: Perform OLS regression, Oaxaca-Blinder decomposition, and quantile regression. And generate plots.
    
## Data source
U.S. Census Bureau — [ACS 1-Year PUMS 2023](https://www.census.gov/programs-surveys/acs/microdata.html)
