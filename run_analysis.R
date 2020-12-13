#download and initialize the libraries
install.packages("reshape2")
library(dataMaid)
library(reshape2)
library(plyr)
library(knitr)

#Download data and the files in the dataset
fileurl = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(fileurl,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}
path_rf <- file.path("./" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

#read and prepare data 
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE, sep = ' ')
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE, sep = ' ')
features <- read.table(file.path(path_rf, "features.txt" ),header = FALSE, sep = ' ')
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE, sep = ' ')
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE, sep = ' ')
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

#merge the train and the test data
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<- features$V2
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

##Extracts only the measurements on 
##the mean and standard deviation for each measurement
FeaturesNames<-features$V2[grep("mean\\(\\)|std\\(\\)", features$V2)]
selectedNames<-c(as.character(FeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
activityLabels <- as.character(activityLabels[,2])
Data$activity <- activityLabels[Data$activity]

#Appropriately labels the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
knit2html("codebook.Rmd")
data3 <- data.frame(Data2)
makeCodebook(data3)
use_readme_md(open = rlang::is_interactive())
