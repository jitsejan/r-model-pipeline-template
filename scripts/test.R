library('randomForest')
# (1) Read data
test <- read.csv("/opt/data/test.csv", stringsAsFactors = F)
# (2) Feature engineering
# Grab title from passenger names
test$Title <- gsub('(.*, )|(\\..*)', '', test$Name)
# reassign 'Mlle', 'Mme', 'Ms' accordingly
test$Title[test$Title == 'Mlle']        <- 'Miss' 
test$Title[test$Title == 'Ms']          <- 'Miss'
test$Title[test$Title == 'Mme']         <- 'Mrs'
# assign anything other than 'Master', 'Miss', 'Mr', and 'Mrs' as 'Rare Title'
test$Title[!test$Title %in% c('Master', 'Miss', 'Mr', 'Mrs')] <- 'Rare Title'
# (3) Missing values
# create simple linear regression model to fill in missing values for Age
# use the same model to impute missing values in the test set (i.e. do not refit model)
imput <- test[!is.na(test$Age),]
linearMod <- lm(Age ~ Pclass + Sex + SibSp, data = imput)
# impute missing values
ageImpute <- predict(linearMod, test)
test[is.na(test$Age), 'Age'] <- ageImpute[is.na(test$Age)]
# (4) Load model
set.seed(754)

rf_model <- readRDS("/opt/models/rf_model.Rds")
# TODO: Read feature names from CSV
factor_vars <- c('Pclass', 'Sex', 'SibSp', 'Parch', 'Title')

test[factor_vars] <- lapply(test[factor_vars], function(x) as.factor(x))
predict(rf_model, test)