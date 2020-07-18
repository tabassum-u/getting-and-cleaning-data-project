library(data.table)
library(tidyr)
library(dplyr)
library(gsubfn)

#read activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = F, col.names = c("Id", "activity"), stringsAsFactors = TRUE)
activity_labels

#read features
column_names <- read.table("./UCI HAR Dataset/features.txt")[, 2 ]
column_names

#extracting mean or sd
mean_or_sd <- grep("mean|sd", column_names, value = TRUE)
mean_or_sd

#read test file
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = column_names

#extracting mean or sd for test file
X_test_meansd <- X_test[, mean_or_sd]
X_test_meansd

y_test[, 2] <- activity_labels$activity[y_test[,1]]
y_test[, 2]

names(y_test) <- c("Id", "activity")

names(subject_test) <- c("subject")

testing <- cbind(subject_test, y_test, X_test)
testing_meansd <- cbind(subject_test, y_test, X_test_meansd)
head(testing_meansd)

#read train files
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = column_names

#extracting mean or sd for training file
X_train_meansd <- X_train[, mean_or_sd]

y_train[, 2] <- activity_labels$activity[y_train[,1]]
y_train[, 2]

names(y_train) <- c("Id", "activity")
names(subject_train) <- c("subject")

training <- cbind(subject_train, y_train, X_train)
training_meansd <- cbind(subject_train, y_train, X_train_meansd)

#merge test and train file
merging <- rbind(testing, training)
head(merging)

activity_labels <- gsub("_", " ", activity_labels$activity)
activity_labels

merging$activity <- factor(merging$activity, labels = activity_labels)

#merging mean or sd of test and train file
merging_meansd <- rbind(testing_meansd, training_meansd)
head(merging_meansd)

#tidy data
tidy <- merging_meansd %>%
    group_by(subject, activity) %>%
    summarize_all("mean") %>%
    gather(key = "feature", value= "mean", -activity, - subject, -Id)
tidy

#writing tidy data
write.table(tidy, file = "tidy.txt", sep = "\t", row.names = FALSE)