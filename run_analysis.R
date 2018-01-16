## Script to megre Training and Test datasets from Samsung wearable to create a single dataset
## Extract mean and Standard Deviation from the dataset
## Apply descriptive activity names
## Apply descriptive variable names
## Creata a Tidy dataset with mean std of each variable for each activity and each subject

library(reshape2)

dir <- getwd()
filename <- "getdata_dataset.zip"

## Download the file and extract in the current dir:
if (!file.exists(filename)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename)
}

# Read the files extracted and load data into separate tables - activity labels & features
activity <- read.table(".\\UCI HAR Dataset\\activity_labels.txt")
features <- read.table(".\\UCI HAR Dataset\\features.txt")

# mean and standard deviation from 2nd column of features table

mean_std <- grepl("*mean*|*std*",features[,2])

# Clean the names for use as labels in final table
label_names <- features[mean_std,2] 
label_names = gsub("-mean","mean",label_names) 
label_names = gsub("-std","std",label_names) 
label_names = gsub("[-()]","",label_names)

# Load the train and test files

train <- read.table(".\\UCI HAR Dataset\\train\\X_train.txt")[mean_std]
trainActivities <- read.table(".\\UCI HAR Dataset\\train\\Y_train.txt")
trainSubjects <- read.table(".\\UCI HAR Dataset\\train\\subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table(".\\UCI HAR Dataset\\test\\X_test.txt")[mean_std]
testActivities <- read.table(".\\UCI HAR Dataset\\test\\Y_test.txt")
testSubjects <- read.table(".\\UCI HAR Dataset\\test\\subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge test and train and add labels using mean and std columns. First 2 are subject, activity
finaldata <- rbind(test,train)
colnames(finaldata) <- c("subject","activity", label_names)

# Tidy the data using factors and melt
finaldata$activity <- factor(finaldata$activity, levels = activity[,1], labels = activity[,2])
finaldata$subject <- as.factor(finaldata$subject)

# melt and cast the data to get the means

melteddata <- melt(finaldata, id = c("subject", "activity"))
means <- dcast(melteddata, subject + activity ~ variable, mean)

# Create tidy.txt
write.table(means, "tidy.txt", row.names = FALSE, quote = FALSE)


