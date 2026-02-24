Longitudinal Analysis of Generativity as Protective of Allostatic Load

  Hypothesis: Measured Loyola's generativity will act as protective of 
  future allostatic load measured as a composite of Z-scores. 
  (Negatively correlated)
  
  Data: This analysis used R data files from the ICPSR MIDUS (Midlife in the
  United States) 2 and 3 datasets, as well as the MIDUS 2 and 3 Biomarker
  projects. This data is restricted and therefore not included in the project. 
  Instructions on how to recreate found at the end.
  
  Methods: Generativity was measured from the standard of Loyola's generativity,
  and allostatic load was measured as a composite Z score of systolic and
  diastolic pressure, heart rate, BMI, Hb1Ac, and CRP. The Z scores were
  removed at a threshold of +-6 standard deviations from the mean, and
  winsorized at +-3 to prevent extreme outliers from overly affecting 
  allostatic load. A cutoff was made, requiring 4/6 of the markers to be
  recorded in both waves to be included in the final linear model. Sex and age
  were taken as covariates, and after final filtering we were left with an 
  n = 477. A lm() linear model was used to analyze allostatic load in wave
  three as predicted by allostatic load in wave 2, generativity in wave 2, age, 
  and sex. 
  
  Results: The study resulted in a null finding, with a very weak effect size
  for generativity in the opposite direction of the hypothesis, and an
  insignificant result with a p = .278. However, after running a simple analysis
  on the possible effects of survivorship bias, ~36% of respondants from the
  midus 2 datasets with a Loyolas generativity of 1 standard deviation (3.855) 
  below mean(16.9) (median of 17) dropped out from the midus 3 study. When
  changed to 1 standard deviation above the mean, that percentage dropped to
  ~22%, an almost 13% drop. This is worth noting as a possible indicator of
  survivorship bias. Notably, this does not say anything about generativity
  predicting allostatic load, only indicating that this null may be non
  generalizable to the general population. Further could be done to prove this
  by  comparing allostatic load of those who dropped out in a cross sectional
  nature. 
  
  How to reproduce: Download the MIDUS 2 and 3 datasets from ICPSR, as well 
  as the 2 and 3 biomarker projects (All as R files).
  ICPSR IDs
  da04652 — M2 survey
  da29282 — M2 biomarker
  da36346 — M3 survey
  da38837 — M3 biomarker
  create a data/raw/ folder system in the root project folder, and drop the R
  files contained in the DS0001 files of each dataset after unzipping. From
  there the script should run. 
  
  Jackson Rittgers, 2/23/26.
  
  