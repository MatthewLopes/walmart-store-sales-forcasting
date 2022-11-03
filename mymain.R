# Libraries
library(glmnet)


# Source: https://www.kaggle.com/code/sarvaninandipati/analysis-prediction-of-walmart-sales-using-r/notebook

# Get Datasets
#train <- readr::read_csv('train_ini.csv')
#test <- readr::read_csv('test.csv')


mypredict <- function() {
  
  #Preprocessing train
  data4 <- train
  
  data4['IsHoliday'] = as.integer(as.logical(data4$IsHoliday))
  
  #formatting date to dd-mm-yyyy
  data4$Date <- format(data4$Date, "%d-%m-%Y")
  
  #changing date column in dataframe to date format & arranging in ascending order as per dates
  data4$Date <- lubridate::dmy(data4$Date)
  data4 <- dplyr::arrange(data4,Date)
  
  #Creating a week number,month,quarter column in dataframe
  data4$Week_Number <- lubridate::week(data4$Date)
  
  #adding quarter & month columns
  data4$month <- lubridate::month(data4$Date)
  data4$quarter <- lubridate::quarter(data4$Date)
  
  
  ##Creating a event type dataframe##
  
  # creating Holiday_date vector
  Holiday_date <- c("12-02-2010", "11-02-2011", "10-02-2012", "08-02-2013","10-09-2010", "09-09-2011", "07-09-2012", "06-09-2013","26-11-2010", "25-11-2011", "23-11-2012", "29-11-2013","31-12-2010", "30-12-2011", "28-12-2012", "27-12-2013")
  
  #assigning date format to Holiday_date vector
  Holiday_date <- lubridate::dmy(Holiday_date)
  
  #Creating Events vector
  Events <-c(rep("Super Bowl", 4), rep("Labor Day", 4),rep("Thanksgiving", 4), rep("Christmas", 4))
  
  #Creating dataframe with Events and date
  Holidays_Data <- data.frame(Events,Holiday_date)
  
  #merging both dataframes
  data4<-merge(data4,Holidays_Data, by.x= "Date", by.y="Holiday_date", all.x = TRUE)
  
  #Replacing null values in Event with No_Holiday
  data4$Events = as.character(data4$Events)
  data4$Events[is.na(data4$Events)]= "No_Holiday"
  
  #Drop Unwanted columns and create train.x and train.y
  x_train_drop <- c('Date', 'Weekly_Sales')
  train.x = data4[,!(names(data4) %in% x_train_drop)]
  train.y = train['Weekly_Sales']
  
  #Convert to factor and numeric
  train.x$Events <- as.numeric(as.factor(train.x$Events))
  train.x$IsHoliday <- as.numeric(train.x$IsHoliday)
  train.x$quarter <- as.numeric(train.x$quarter)
  
  
  
  #Preprocessing test
  test['IsHoliday'] = as.integer(as.logical(test$IsHoliday))
  
  data5 <- test
  
  #formatting date to dd-mm-yyyy
  data5$Date <- format(data5$Date, "%d-%m-%Y")
  
  #changing date column in dataframe to date format & arranging in ascending order as per dates
  data5$Date <- lubridate::dmy(data5$Date)
  data5 <- dplyr::arrange(data5,Date)
  
  #Creating a week number,month,quarter column in dataframe
  data5$Week_Number <- lubridate::week(data5$Date)
  
  #adding quarter & month columns
  data5$month <- lubridate::month(data5$Date)
  data5$quarter <- lubridate::quarter(data5$Date)
  
  
  ##Creating a event type dataframe##
  
  # creating Holiday_date vector
  Holiday_date <- c("12-02-2010", "11-02-2011", "10-02-2012", "08-02-2013","10-09-2010", "09-09-2011", "07-09-2012", "06-09-2013","26-11-2010", "25-11-2011", "23-11-2012", "29-11-2013","31-12-2010", "30-12-2011", "28-12-2012", "27-12-2013")
  
  #assigning date format to Holiday_date vector
  Holiday_date <- lubridate::dmy(Holiday_date)
  
  #Creating Events vector
  Events <-c(rep("Super Bowl", 4), rep("Labor Day", 4),rep("Thanksgiving", 4), rep("Christmas", 4))
  
  #Creating dataframe with Events and date
  Holidays_Data <- data.frame(Events,Holiday_date)
  
  #merging both dataframes
  data5<-merge(data5,Holidays_Data, by.x= "Date", by.y="Holiday_date", all.x = TRUE)
  
  #Replacing null values in Event with No_Holiday
  data5$Events = as.character(data5$Events)
  data5$Events[is.na(data5$Events)]= "No_Holiday"
  
  #Drop Unwanted columns and create test.x
  x_test_drop <- c('Date', 'Weekly_Sales')
  test.x = data5[,!(names(data5) %in% x_test_drop)]
  
  #Convert to factor and numeric
  test.x$Events <- as.numeric(as.factor(test.x$Events))
  test.x$IsHoliday <- as.numeric(test.x$IsHoliday)
  test.x$quarter <- as.numeric(test.x$quarter)
  
  
  #model = lm(formula = as.matrix(train.y) ~ . , data = train.x)
  #y_pred_train = predict(model, newdata = test.x)
  #y_pred_train
  
  #Lasso Regression
  cv.out = cv.glmnet(as.matrix(train.x), as.matrix(train.y), alpha = 0)
  best.lam = cv.out$lambda.min
  #best.lam = cv.out$lambda.1se
  Ytest.pred = predict(cv.out, s = best.lam, newx = as.matrix(test.x))
  Ytest.pred.df = data.frame(Date = test[3], Store = test[1], Dept = test[2], Weekly_Pred = Ytest.pred)
  colnames(Ytest.pred.df)[4]<-"Weekly_Pred"
  
  
  
  # date weekly_pred
  
  return(Ytest.pred.df)
}

