library(haven)
library(shinydashboard)
library(DT)
library(tidyr)
library(shiny)
library(ggplot2)
library(dplyr)
library(stringi)
library(shinythemes)
library(nestcolor)
library(teal)
library(teal.modules.clinical)
library(teal.modules.general)
library(plotly)
library(teal.widgets)


data <- teal_data( )
data = within(data,{
  
  
  ADSL <- read_sas("adsl.sas7bdat")
  ADAE <- read_sas("adae.sas7bdat")
  
  adlb <- read_sas("adlb.sas7bdat")
  adlb1 <- adlb[(adlb$CRIT1FL=="Y"),]
  adlb1$NEWTERM <- adlb1$CRIT1
  
  adlb2 <- adlb[(adlb$CRIT2FL=="Y"),]
  adlb2$NEWTERM <- adlb2$CRIT2
  
  adlb3 <- adlb[(adlb$CRIT3FL=="Y"),]
  adlb3$NEWTERM <- adlb3$CRIT3
  
  adlb4 <- adlb[(adlb$CRIT4FL=="Y"),]
  adlb4$NEWTERM <- adlb4$CRIT4
  
  adlb5 <- adlb[(adlb$CRIT5FL=="Y"),]
  adlb5$NEWTERM <- adlb5$CRIT5
  
  adlb6 <- adlb[(adlb$CRIT6FL=="Y"),]
  adlb6$NEWTERM <- adlb6$CRIT6
  
  adlb7 <- adlb[(adlb$CRIT7FL=="Y"),]
  adlb7$NEWTERM <- adlb7$CRIT7
  
  ADLB <- rbind(adlb1, adlb2, adlb3, adlb4, adlb5, adlb6, adlb7)

  ADLB$NEWARM <- "ALL"
  ADSL$NEWARM <- "ALL"
  ADAE$NEWARM <- "ALL"
  
  ADLB$NEWARM <- factor(ADLB$NEWARM)
  ADSL$NEWARM <- factor(ADSL$NEWARM)
  ADAE$NEWARM <- factor(ADAE$NEWARM)
})

datanames(data) <- c("ADSL", "ADLB","ADAE")

jk <- join_keys(
  join_key("ADSL", "ADSL", c("USUBJID",'NEWARM')),
  join_key("ADSL", "ADLB", c("USUBJID",'NEWARM')) , 
  join_key("ADSL", "ADAE", c("USUBJID",'NEWARM'))
  
)

join_keys(data) <- jk

ADLB <- data[["ADLB"]]
ADSL <- data[["ADSL"]]
ADAE <- data[["ADAE"]]

app <- init(
  
  data=data, 
  
  modules =modules(
    tm_data_table(
    ), 
    tm_t_summary(
      label = "Demographic Table",
      dataname = "ADSL",
      arm_var = choices_selected(c("NEWARM", "ARM"), "NEWARM"),
      add_total = FALSE,
      summarize_vars = choices_selected(
        c("SEX", "RACE",  "DCSREAS", "AGE", "ETHNIC","REGION1", 'WEIGHTBL','HEIGHTBL'),
        c("SEX", "RACE")
      ),
      useNA = "no"
    ), 
    tm_t_events(
      label = "Adverse Event Table",
      dataname = "ADAE",
      arm_var = choices_selected(c("NEWARM", "ARM"), "NEWARM"),
      llt = choices_selected(
        choices = variable_choices(ADAE, c("AETERM", "AEDECOD")),
        selected = c("AEDECOD")
      ),
      hlt = choices_selected(
        choices = variable_choices(ADAE, c("AEBODSYS", "AESOC")),
        selected = "AESOC"
      ),
      add_total = FALSE,
      event_type = "adverse event"
    ), 
    
    tm_t_events(
      label = "Liver Chemistry Table",
      dataname = "ADLB",
      arm_var = choices_selected(c("NEWARM", "ARM"), "NEWARM"),
      llt = choices_selected(
        choices = variable_choices(ADLB, c("NEWTERM")),
        selected = c("NEWTERM")
      ),
      hlt = choices_selected(
        choices = variable_choices(ADLB, c("PARAMCD", "PARAM")),
        selected = "PARAMCD"
      ),
      add_total = FALSE,
      event_type = "liver chemistry abnormality"
    )
    
  ) 
  )

shinyApp(app$ui, app$server)

