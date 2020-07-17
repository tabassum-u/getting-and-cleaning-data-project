install.packages("data.table")
install.packages("reshape2")

library(data.table)
library(reshape2)

#read activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

#read features
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

#extracting mean or sd
mean_or_sd <- grepl("mean|sd", features)


#read test file
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

#extracting mean or sd for test file
X_test_meansd <- X_test[, mean_or_sd]


y_test[, 2] <- activity_labels[y_test[,1]]
y_test[, 2]

names(y_test) <- c("Id", "activity_labels")
names(subject_test) <- c("subject")

testing <- cbind(as.data.table(subject_test), y_test, X_test)

#read train files
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

#extracting mean or sd for training file
X_train_meansd <- X_train[, mean_or_sd]

y_train[, 2] <- activity_labels[y_train[,1]]
y_train[, 2]

names(y_train) <- c("Id", "activity_labels")
names(subject_train) <- c("subject")

training <- cbind(as.data.table(subject_train), y_train, X_train)

#merge test and train file
merging <- rbind(testing, training)


set_id <- c("subject", "Id", "activity_labels")
labelling <- setdiff(colnames(merging), set_id)


#for tidy data
melting <- melt(merging, id = set_id, measure.vars = labelling)
tidy <- dcast(melting, subject + activity_labels ~ variable, mean )


write.table(tidy, "./tidy.txt")