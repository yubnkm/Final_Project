library(dplyr)
library(ggplot2)
library(oaxaca)
library(quantreg)
library(broom)
library(ggplot2)
library(readr)
library(modelsummary)


pums <- readRDS("data/pums_clean.rds")

## OLS
ols_model <- lm(
  logwage ~ immigrant + age + age2 + hours +
    edu_undergrad + occ_bluecollar + sex,
  data = pums
)
ols_statefe <- lm(
   logwage ~ immigrant + age + age2 + hours +
     edu_undergrad + occ_bluecollar + sex + state_fe,
   data = pums
)
modelsummary(list(ols_model, ols_statefe) , output = "output/ols_result.xlsx")

## Oaxaca-Blinder
oaxaca_nofe <- oaxaca(
  logwage ~ age + age2 + hours +
    edu_undergrad + occ_bluecollar + sex | immigrant,
  data = pums,
  R = 30
)
oaxaca_statefe <- oaxaca(
  logwage ~ age + age2 + hours +
    edu_undergrad + occ_bluecollar + sex + state_fe | immigrant,
  data = pums,
  R = 30
)

oaxaca_df1 <- summary(oaxaca_nofe)
oaxaca_df2 <- summary(oaxaca_statefe)
datasummary_df(
  bind_rows(
    cbind(Model = "No State FE", as.data.frame(t(oaxaca_df1$threefold$overall))),
    cbind(Model = "With State FE", as.data.frame(t(oaxaca_df2$threefold$overall)))
  ),
  output = "output/oaxaca_results.xlsx"
)

## Quantile (It's going to be slow due to data size)
qr25 <- rq(
    logwage ~ immigrant + age + age2 + hours +
      edu_undergrad + occ_bluecollar + sex,
    data = pums,
    method = "br",
    tau = 0.25
)
qr25_df <- summary(qr25, se = "nid")

qr50 <- rq(
    logwage ~ immigrant + age + age2 + hours +
        edu_undergrad + occ_bluecollar + sex,
    data = pums,
    method = "br",
    tau = 0.5
)  
qr50_df <- summary(qr50, se = "nid")

qr75 <- rq(
    logwage ~ immigrant + age + age2 + hours +
        edu_undergrad + occ_bluecollar + sex,
    data = pums,
    method = "br",
    tau = 0.75
)
qr75_df <- summary(qr75, se = "nid")

qr25_df_full <- as.data.frame(qr25_df$coefficients)
qr25_df_full$tau <- 0.25
qr25_df_full$term <- rownames(qr25_df_full)

qr50_df_full <- as.data.frame(qr50_df$coefficients)
qr50_df_full$tau <- 0.50
qr50_df_full$term <- rownames(qr50_df_full)

qr75_df_full <- as.data.frame(qr75_df$coefficients)
qr75_df_full$tau <- 0.75
qr75_df_full$term <- rownames(qr75_df_full)

qr_result <- dplyr::bind_rows(
  qr25_df_full,
  qr50_df_full,
  qr75_df_full
) %>% dplyr::select(tau, term, everything())

datasummary_df(qr_result, output = "output/qr_result.xlsx")

## Plotting
# Quantile results (immigrant coefficient)
immigrant_plot_df <- data.frame(
  tau = c(0.25, 0.5, 0.75),
  coef = c(
    qr25_df$coefficients["immigrant", "Value"],
    qr50_df$coefficients["immigrant", "Value"],
    qr75_df$coefficients["immigrant", "Value"]
  )
)
# OLS results (immigrant coefficient)
ols_coef <- coef(ols_model)["immigrant"]

# ggplot
imm_plot = ggplot(immigrant_plot_df, aes(x = tau, y = coef)) +
  geom_line(color = "black", size = 1) +
  geom_point(size = 3, color = "darkblue") +
  geom_hline(yintercept = ols_coef, linetype = "dashed", color = "red") +
  annotate("text", x = 0.26, y = ols_coef + 0.01, label = "OLS", color = "red", hjust = 0) +
  labs(
    title = "Immigrant Coefficient Across Quantiles",
    x = "Quantile (τ)",
    y = "Coefficient"
  ) +
  theme_bw(base_size = 14)
ggsave("output/immigrant_plot.png", plot = imm_plot, width = 7, height = 5, dpi = 300)

