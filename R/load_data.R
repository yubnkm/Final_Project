library(data.table)
library(dplyr)

# Read data
pums_raw <- fread("data/raw.csv")

# Select relevant variables
pums <- pums_raw %>%
  select(
    SEX, AGEP, WKHP, PINCP, WAGP, SCHG, OCCP,
    YOEP, DECADE, CIT, NATIVITY,
    ADJINC, PWGTP, STATE
  ) %>%
filter(!is.na(PINCP), PINCP > 0,
       !is.na(WAGP), WAGP > 0,
       WKHP > 0)

# Adjust income for inflation
pums <- pums %>%
  mutate(
    adj_WAGP = WAGP * (ADJINC / 1e6),
    logwage = log(adj_WAGP),
    age = AGEP,
    age2 = AGEP^2,
    hours = WKHP
  )

# Recode factors
# EDUCATION dummies
pums <- pums %>%
  mutate(
    edu_undergrad = as.integer(SCHG %in% 16:18),
    edu_graduate = as.integer(SCHG %in% 19:21)
    # => baseline: SCHG <= 15 (HighSchoolOrLess)
  )

# OCCUPATION dummies
pums <- pums %>%
  mutate(
    occ_bluecollar = as.integer(OCCP >= 6200 & OCCP <= 9750)
    # => baseline: white-collar and other
  )

# SEX and CITIZENSHIP
pums <- pums %>%
  mutate(
    sex = factor(SEX, levels = c(1, 2), labels = c("Male", "Female")),
    citizen_binary = factor(ifelse(CIT %in% c(1,2,3,4), "Citizen", "NonCitizen")),
    immigrant = as.integer(NATIVITY == 2),
    years_in_us = ifelse(is.na(YOEP), 0, YOEP),
    weight = PWGTP
  )

pums <- pums %>%
  filter(
    !is.na(logwage),
    !is.na(sex),
    !is.na(citizen_binary)
  )

pums$state_fe <- factor(pums$STATE)


# Save cleaned data
saveRDS(pums, file = "data/pums_clean.rds")

