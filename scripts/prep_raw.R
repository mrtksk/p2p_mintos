
# Setup -------------------------------------------------------------------

library(dplyr)
library(readxl)
library(pryr)
library(lubridate)
vec_filenames <- list.files("./dat_in/raw", pattern = "loan_book")


# Prepare data ------------------------------------------------------------

dat_bind <- data_frame()
for (i in 1 : length(vec_filenames)){
  #Get data
  dat <- read_excel(path = file.path("dat_in", "raw", vec_filenames[i]))
  cat(".")
  
  #Modify stuff
  dat %>% 
    mutate(date_issue = ymd(as_date(`Issue Date`)),
           date_listing = ymd(as_date(`Listing Date`)),
           buyback = if_else(Buyback == "Yes", T, F),
           collat = if_else(Collateral == "Yes", T, F)) %>% 
    select(-`Issue Date`, -Id, -`Listing Date`, -Buyback, -Collateral) %>% 
    rename(cntry = Country,
           orig_loan = `Loan Originator`,
           type_loan = `Loan Type`,
           rate_loan = `Loan Rate Percent`,
           term_loan = Term,
           ltv_initial = `Initial LTV`,
           ltv = LTV,
           status_loan = `Loan Status`,
           reason_buyback = `Buyback reason`,
           amount_init = `Initial Loan Amount`,
           amount_remain = `Remaining Loan Amount`,
           curr = Currency) -> dat_prep 
  #Save Rds
  saveRDS(dat_prep, paste0("./dat_in/dat_mintos_", i, ".Rds"))
  #And bind together with full data:
  dat_bind <- bind_rows(dat_bind, dat_prep)
  
  cat(".")
}

saveRDS(dat_bind, "./dat_in/dat_mintos_full.Rds")
