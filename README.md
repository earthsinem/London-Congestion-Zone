# London-Congestion-Zone
Applied Microeconometrics Project — Université de Neuchâtel (2023)

## 📄 Project Overview
This project analyzes the **impact of the London Congestion Charging Zone (CCZ) policy** on traffic accidents using **Difference-in-Differences (DiD)** methodology.

The CCZ was implemented to reduce traffic congestion, improve air quality, and enhance road safety. Our analysis evaluates whether the policy also led to measurable changes in road accident rates.

## 🎯 Objectives
- Assess the causal effect of the CCZ on the number of traffic accidents.
- Investigate potential **spillover effects** in surrounding non-treated areas.
- Test robustness using alternative model specifications.

## 📊 Data
We used panel data from:
- **Accident statistics** from the UK Department for Transport.
- **Geographic classification** of treated (inside CCZ) vs. control (outside CCZ) areas.
- Pre- and post-policy implementation accident counts.

**Period covered:** Multiple years before and after the CCZ introduction.

## 🛠 Methodology
- **Difference-in-Differences (DiD)** approach to estimate treatment effects.
- Pre-treatment trend analysis to verify the **parallel trends assumption**.
- Robustness checks including:
  - Alternative control groups.
  - Inclusion of time-varying covariates.
  - Spillover effect tests.

**Key Equation:**
\[
Accidents_{it} = \alpha + \beta (Treated_i \times Post_t) + \gamma_i + \delta_t + \epsilon_{it}
\]
Where:
- \( Treated_i \) = 1 if area is within CCZ, 0 otherwise.
- \( Post_t \) = 1 after policy implementation, 0 before.

## 📈 Results
- Significant reduction in the number of traffic accidents **inside the CCZ** after implementation.
- **Spillover effects**: Slight increases in surrounding areas, possibly due to traffic diversion.
- Robustness checks confirm the main findings.

## 📌 Key Figures
- **Figure 1:** Pre-treatment parallel trends.
- **Figure 2:** Estimated treatment effects.
- **Figure 3:** Spillover effect analysis.

## 💡 Conclusions
The London Congestion Charging Zone appears effective not only in reducing congestion but also in improving **road safety** within the treated area. Policymakers should, however, consider mitigation strategies for spillover effects in nearby regions.

## 📂 Repository Structure
├── data/ # Raw and processed datasets
├── london_congestion.do # Main Stata analysis script
└── README.md # Project documentation


## 🔗 References
- UK Department for Transport Accident Data
- London Congestion Charging Zone Policy Documentation
- Cameron & Trivedi (2005), *Microeconometrics: Methods and Applications*

---

**Author:** Sinem Demir  
Université de Neuchâtel — Applied Microeconometrics  
2023


