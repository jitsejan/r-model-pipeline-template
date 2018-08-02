library('randomForest')
model <- readRDS("/opt/models/rf_model.Rds")

MODEL_VERSION <- "0.0.1"
VARIABLES <- list(
  pclass = "pclass = 1, 2, 3 (Ticket Class: 1st, 2nd, 3rd)",
  sex = "sex = male or female",
  age = "age = # in years",
  sibsp = "sibsp = # of siblings / spouses aboard",
  parch = "parch = # of parents / children aboard",
  title = "title = 'Master', 'Miss', 'Mr', 'Mrs', 'Rare Title'",
  gap = "",
  survival = "Successful submission will results in a calculated Survival Probability from 0 to 1 (Unlikely to More Likely)")

# test API working --------------------------------------------------------

#* @get /healthcheck
health_check <- function() {
  result <- data.frame(
    "input" = "",
    "status" = 200,
    "model_version" = MODEL_VERSION
  )
  
  return(result)
}

# # API landing page --------------------------------------------------------

#* @get /
#* @html
home <- function() {
  title <- "Titanic Survival API"
  body_intro <-  "Welcome to the Titanic Survival API!"
  body_model <- paste("We are currently serving model version:", MODEL_VERSION)
  body_msg <- paste("To received a prediction on survival probability,", 
                     "submit the following variables to the <b>/survival</b> endpoint:",
                     sep = "\n")
  body_reqs <- paste(VARIABLES, collapse = "<br/>")
  
  result <- paste(
    "<html>",
    "<h1>", title, "</h1>", "<br>",
    "<body>", 
    "<p>", body_intro, "</p>",
    "<p>", body_model, "</p>",
    "<p>", body_msg, "</p>",
    "<p>", body_reqs, "</p>",
    "</body>",
    "</html>",
    collapse = "\n"
  )
  
  return(result)
}


# helper functions for predict --------------------------------------------

transform_data <- function(input_data) {
  output_data <- data.frame(
    Age = input_data$Age,
    Pclass = factor(input_data$Pclass, levels=c(1, 2, 3)),
    Sex = factor(input_data$Sex, levels=c("male", "female")),
    SibSp = input_data$SibSp,
    Parch = input_data$Parch,
    Title = factor(input_data$Title, levels=c('Master', 'Miss', 'Mr', 'Mrs', 'Rare Title'))
  )
}

validate_feature_inputs <- function(age, pclass, sex, sibsp, parch, title) {
  age_valid <- (age >= 0 & age < 150)
  pclass_valid <- (pclass %in% c(1, 2, 3))
  sex_valid <- (sex %in% c("male", "female"))
  sibsp_valid <- (sibsp >= 0 & sibsp < 30)
  parch_valid <- (parch >= 0 & parch < 50)
  title_valid <- (title %in% c('Master', 'Miss', 'Mr', 'Mrs', 'Rare Title'))
  tests <- c("Age must be between 0 and 150", 
             "Pclass must be 1, 2, or 3", 
             "Sex must be either male or female",
             "Number of siblings/spouses should be between 0 and 50",
             "Number of parents/children should be between 0 and 30",
             "Title must be 'Master', 'Miss', 'Mr', 'Mrs' or'Rare Title'")
  test_results <- c(age_valid, pclass_valid, sex_valid, sibsp_valid, parch_valid, title_valid)
  if(!all(test_results)) {
    failed <- which(!test_results)
    return(tests[failed])
  } else {
    return("OK")
  }
}

# predict endpoint --------------------------------------------------------

#* @post /survival
#* @get /survival
predict_survival <- function(age=NA, pclass=NULL, sex=NULL, sibsp=0, parch=0, title="") {
  # Cast the input parameters to the right type
  age = as.integer(age)
  pclass = as.integer(pclass)
  sex = tolower(sex)
  sibsp = as.integer(sibsp)
  parch = as.integer(parch)
  title = tools::toTitleCase(title)
  # Validate the input
  valid_input <- validate_feature_inputs(age, pclass, sex, sibsp, parch, title)
  if (valid_input[1] == "OK") {
    payload <- data.frame(Age=age, Pclass=pclass, Sex=sex, SibSp=sibsp, Parch=parch, Title=title)
    clean_data <- transform_data(payload)
    prediction <- predict(model, clean_data, type="prob")
    result <- list(
      input = list(payload),
      response = list(
          "survival_probability" = prediction[1,2],
          "survival_prediction" = (prediction[1,2] >= 0.5)
      ),
      status = 200,
      model_version = MODEL_VERSION)
  } else {
    result <- list(
      input = list(
        age = age,
        pclass = pclass,
        sex = sex,
        sibsp = sibsp,
        parch = parch,
        title = title
      ),
      response = list(input_error = valid_input),
      status = 400,
      model_version = MODEL_VERSION)
  }

  return(result)
}
