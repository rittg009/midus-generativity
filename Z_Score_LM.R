# hypothesis: loyolas generativity will negatively correlate with allostatic
# load measured as a sum of z scores of systolic and diastolic pressure, 
# heart rate, BMI, hb1ac, and CRP. generativity is protective of allostatic
#load.
library(tidyverse)
library(haven)
load("data/raw/da04652.0001.Rdata")
load("data/raw/da29282.0001.Rdata")
load("data/raw/da36346.0001.Rdata")
load("data/raw/da38837.0001.Rdata")
m2 <- da04652.0001
rm(da04652.0001)
m2bio <- da29282.0001; rm(da29282.0001)
m3 <- da36346.0001; rm(da36346.0001)
m3bio <- da38837.0001; rm (da38837.0001)

# covariates are only needed in the first one, going here
m2_clean <- m2 %>%
  select(
    M2ID,
    generativity2 = B1SGENER,
    sex = B1PRSEX,
    age = B1PAGE_M2
  )
#cleaning m3
m3_clean <- m3 %>%
  select(
    M2ID,
    generativity3 = C1SGENER 
  )

#now cleaning m3bio
m3bio_clean <- m3bio %>%
  select(
    M2ID,
    sys_m3   = C4VSB1BP, # systolic
    dia_m3   = C4VDB1BP, # diastolic
    pulse_m3 = C4VB1HR,  # heart rate
    bmi_m3   = C4PBMI,     # BMI
    hba1c_m3 = C4BHA1C,    # HbA1c
    crp_m3   = C4BCRP     # CRP
  )

#adding valid markers to rows
m3bio_clean <- m3bio_clean %>%
  rowwise() %>%
  mutate(
    valid_markers_m3 = sum(!is.na(c(sys_m3, dia_m3, pulse_m3, bmi_m3,hba1c_m3, crp_m3)))
  ) %>%
ungroup()

# clean m2bios's data
m2bio_clean <- m2bio %>%
  select(
    M2ID,
    sys_m2   = B4VSB1BP, # systolic 
    dia_m2   = B4VDB1BP, # diastolic
    pulse_m2 = B4VB1HR,  # heart rate
    bmi_m2   = B4PBMI,     # BMI
    hba1c_m2 = B4BHA1C,    # HbA1c
    crp_m2   = B4BCRP     # CRP
  )
#add valid markers
m2bio_clean <- m2bio_clean %>%
  rowwise() %>%
  mutate(
    valid_markers_m2 = sum(!is.na(c(sys_m2, dia_m2, pulse_m2, bmi_m2, hba1c_m2, crp_m2)))
    ) %>%
  ungroup()

# preliminary lm with only filtered 4/6 before running fiml.
#
#
#


#filter a group for an lm with only 4/6
m2bio_filtered <- m2bio_clean %>%
  filter(valid_markers_m2 >= 4)
#do the same for m3

m3bio_filtered <- m3bio_clean %>%
  filter(valid_markers_m3 >= 4)
    
#make master dataframe
master_df_filtered  <- m2_clean %>%
  left_join(m3_clean, by = "M2ID") %>%
  left_join(m2bio_filtered, by = "M2ID") %>%
  left_join(m3bio_filtered, by = "M2ID")

#make sure they have 4 across both
master_df_filtered <- master_df_filtered %>%
  filter(valid_markers_m2 >= 4, valid_markers_m3 >= 4)
scaled_df_filtered <- master_df_filtered %>%
  mutate(across(c(sys_m2, dia_m2, pulse_m2, bmi_m2, hba1c_m2, crp_m2,
                  sys_m3, dia_m3, pulse_m3, bmi_m3, hba1c_m3, crp_m3), 
                ~as.numeric(scale(.))))

# windsorize and combine everything
scaled_df_filtered <- scaled_df_filtered %>%
  mutate(across(c(sys_m2, dia_m2, pulse_m2, bmi_m2, hba1c_m2, crp_m2,
                  sys_m3, dia_m3, pulse_m3, bmi_m3, hba1c_m3, crp_m3),
                ~ifelse(abs(.) > 6, NA, pmin(pmax(., -3), 3)))) %>%
  mutate(
    al_m2 = rowSums(across(c(sys_m2, dia_m2, pulse_m2, bmi_m2, hba1c_m2, crp_m2)), na.rm = TRUE),
    al_m3 = rowSums(across(c(sys_m3, dia_m3, pulse_m3, bmi_m3, hba1c_m3, crp_m3)), na.rm = TRUE)
  )
scaled_df_filtered <- scaled_df_filtered %>%
  mutate(sex = as.factor(sex))
filtered_model <- lm(al_m3 ~ al_m2 + generativity2 + age + sex, data = scaled_df_filtered)
# fairly robust null. p = .278, and effect size is extremely weak and
# insignificant but actually opposite direction of hypothesis.


#survivorship bias check
nrow(m2bio_filtered) - nrow(m3bio_filtered)

#540 people, nearly half our final n just for bio tests, dropped out between studies.

#check the total amounts 
summary(m2_clean$generativity2)
sd(m2_clean$generativity2, na.rm = TRUE)

# median of 17, mean of 16.9. standard deviation of 3.855.

#analyze how many people dropped out with high gen and low gen.
survivorship_df <- m2_clean %>%
  filter(!is.na(generativity2)) %>%
  mutate( gen_group = case_when(
    generativity2 >= 17 + 3.855 ~ "high",
    generativity2 <= 17- 3.855 ~ "low"
  )) %>%
  mutate( 
    survived = M2ID %in% m3_clean$M2ID
  )
#summarize dropping out
survivorship_df %>% 
  group_by(gen_group) %>%
  summarise(
    n = n(),
    dropped_out = sum(!survived),
    pct_dropped = round(mean(!survived) * 100, 1)
  )

#final summary (survivorship bias meaning possibility of dropping because of poor health )

# generativity in the midus 2-3 datasets in a longitudinal analysis is not a 
# significant factor in predicting allostatic load as a summary of z scores.
# p = .278, and very weak effect size going opposite direction from hypothesis.
# however, after running a simple analysis on the possible effects of
# survivorship bias, ~36% of respondants from the midus 2 datasets with a
# loyolas generativity of 1 standard deviation (3.855) below median(17) (mean of 16.9) 
# dropped out from the midus 3 study. changed to 1 stanstard devation above the
# mean, that percentage drops to ~22%, an almost 13% drop. this is worth noting 
# as a possible indicator of survivorship bias. notably, this does not prove 
# anything about generativity predicting allostatic load, just indicates that
# this null is not generalizable to non survivorship biased populations.
# further could be done to prove this by also comparing the alloastatic load of
# those who dropped out. 