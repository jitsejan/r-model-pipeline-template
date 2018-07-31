library('randomForest') # classification algorithm

# (1) Read data
# Read data
rm(list=ls())
train <- read.csv("/opt/data/train.csv", stringsAsFactors = F)

# check data
str(train)

# (2) Feature engineering
# Grab title from passenger names
train$Title <- gsub('(.*, )|(\\..*)', '', train$Name)

str(train)

# Show title counts by sex
table(train$Sex, train$Title)

# reassign 'Mlle', 'Mme', 'Ms' accordingly
train$Title[train$Title == 'Mlle']        <- 'Miss' 
train$Title[train$Title == 'Ms']          <- 'Miss'
train$Title[train$Title == 'Mme']         <- 'Mrs'

# assign anything other than 'Master', 'Miss', 'Mr', and 'Mrs' as 'Rare Title'
train$Title[!train$Title %in% c('Master', 'Miss', 'Mr', 'Mrs')] <- 'Rare Title'

table(train$Sex, train$Title)


# (3) Missing values
# create simple linear regression model to fill in missing values for Age
# use the same model to impute missing values in the test set (i.e. do not refit model)
imput <- train[!is.na(train$Age),]
linearMod <- lm(Age ~ Pclass + Sex + SibSp, data = imput)

# impute missing values
ageImpute <- predict(linearMod, train)
train[is.na(train$Age), 'Age'] <- ageImpute[is.na(train$Age)]


# (4) Build model
set.seed(754)

factor_vars <- c('Survived', 'Pclass', 'Sex', 'SibSp', 'Parch', 'Title')

train[factor_vars] <- lapply(train[factor_vars], function(x) as.factor(x))

rf_model <- randomForest(Survived ~ Pclass + Sex + Age + SibSp + Parch + Title,
                         data = train, ntree=500, mtry=2)

save(rf_model, file="/opt/models/rf_model.rda")