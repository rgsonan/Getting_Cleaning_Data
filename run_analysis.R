library(dplyr)

## Download the dataset

filename <- "UCI_HAR_Dataset.zip"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if (!file.exists(filename)){
  download.file(fileURL, filename, method="auto")
  unzip(filename) 
}

## Read all required files and assign it to data frame

features <- read.table("UCI HAR Dataset/features.txt",col.names=c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt",col.names = c("code","activity"))

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",col.names=c("subject"))
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt",col.names=features$functions)
y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt",col.names=c("code"))

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",col.names=c("subject"))
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt",col.names=features$functions)
y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt",col.names=c("code"))

## Merges the training and the test sets to create one data set.
x <- rbind(x_train,x_test)
y <- rbind(y_train,y_test)
subject <- rbind(subject_train,subject_test)

merged_data  <- cbind(subject,x,y)

## Extracts only the measurements on the mean and standard deviation for each measurement.
req_meas <- select(merged_data,subject,contains("mean"),contains("std"),code)

## Uses descriptive activity names to name the activities in the data set
req_meas$code <- activities[req_meas$code,2]

## Appropriately labels the data set with descriptive variable names.

names(req_meas)[ncol(req_meas)] ="Activity"

names(req_meas) <- gsub("Acc", "Accelerometer", names(req_meas))
names(req_meas) <- gsub("Gyro", "Gyroscope", names(req_meas))
names(req_meas) <- gsub("BodyBody", "Body", names(req_meas))
names(req_meas) <- gsub("Mag", "Magnitude", names(req_meas))
names(req_meas) <- gsub("^t", "Time", names(req_meas))
names(req_meas) <- gsub("^f", "Frequency", names(req_meas))
names(req_meas) <- gsub("tBody", "TimeBody", names(req_meas))
names(req_meas) <- gsub("-mean()", "Mean", names(req_meas), ignore.case = TRUE)
names(req_meas) <- gsub("-std()", "STD", names(req_meas), ignore.case = TRUE)
names(req_meas) <- gsub("-freq()", "Frequency", names(req_meas), ignore.case = TRUE)
names(req_meas) <- gsub("angle", "Angle", names(req_meas))
names(req_meas) <- gsub("gravity", "Gravity", names(req_meas))

## From the data set in step 4, creates a second, independent tidy data set with the average of 
## each variable for each activity and each subject

group_data <- group_by(req_meas,subject,Activity)
final_tidy_data <- summarize_all(group_data,funs(mean))

## Final tidy data set
write.table(final_tidy_data, "FinalData.txt", row.name=FALSE)
