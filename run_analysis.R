# Getting and Cleaning Data Course Project 
# Load data.table package
library(data.table)

# Set working directory
if(!dir.exists("C:/R_Test_Cleaning_Data/")) dir.create("C:/R_Test_Cleaning_Data/")
setwd("C:/R_Test_Cleaning_Data/")

# download and unzip the datasets
download.file( "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "download.zip" )
unzip("download.zip")

# reset the working directory
setwd("C:/R_Test_Cleaning_Data/UCI HAR Dataset")

# Files that will be used includes the following
# test/subject_test.txt  , test/X_test.txt  , test/y_test.txt exclude the file Inertial Signals
# train/subject_train.txt, train/X_train.txt, train/y_train.txt exclude the file Inertial Signals
trainfiles <- list.files( "train", full.names = TRUE )[-1]
testfiles <- list.files( "test" , full.names = TRUE )[-1]

# Read in all six files
files <- c( trainfiles, testfiles )
pdata <- lapply( files, read.table, stringsAsFactors = FALSE, header = FALSE )

# Step 1 : Merges the training and the test sets to create one data set, rbind the train and test data by each variable
pdata1 <- mapply ( rbind, pdata[ c(1:3) ], pdata[ c(4:6) ] )

# data2: the whole single dataset column 1 = subject, column 2~562 = feature,  column 563 = activity
pdata2 <- do.call( cbind, pdata1 )

# Step 2 : For the feature column, extracts only the measurements on the mean and standard deviation for each measurement

# match it using features.txt in list.file() 
featurenames <- fread( list.files(pattern="features.txt"), header = FALSE, stringsAsFactor = FALSE )

# set the column names for data2, does the task required in Step 3 : Appropriately labels the data set with descriptive variable names.
setnames( pdata2, c(1:563), c( "subject", featurenames$V2, "activity" ) )

# Extract only the column that have mean() or std() in the end
# Add 1 to it, cuz the first column in data2 is subject not feature
# Don't just use mean when doing matching, this will include meanFreq()
# Each backslash must be expressed as \\
measurements <- grep( "std|mean\\(\\)", featurenames$V2 ) + 1

# data3 : contains only the mean and standard deviation for feature column 
pdata3 <- pdata2[, c( 1, measurements, 563 ) ]

# Step 4 : Use descriptive activity names to name the activities in the data set
# match it using activity_labels.txt
activitynames <- fread( list.files(pattern="activity_labels.txt"), header = FALSE, stringsAsFactor = FALSE )
pdata3$activity <- activitynames$V2[ match( pdata3$activity, activitynames$V1 ) ]

# Step 5 : From the data set in step 4, creates a second, independent tidy data set, 
# with the average of each variable for each activity and each subject.
pdata4 <- aggregate( . ~ subject + activity, data = pdata3, FUN = mean )

# write out data4
setwd("C:/R_Test_Cleaning_Data/")
write.table( pdata4, "submission.txt", row.names = FALSE )



