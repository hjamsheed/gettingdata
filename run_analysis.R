#Project

#Load Libraries
library(data.table)
"%+%"<-function(a,b){ paste0(a,b)}

#Set directories
PROJ_DIR=getwd()
DATA_DIR=PROJ_DIR%+%"/UCI HAR Dataset"
TRN_DIR=DATA_DIR%+%"/train"
TEST_DIR=DATA_DIR%+%"/test"
OUT_DIR = PROJ_DIR%+%"/output"

#Training Data Sets
sub_train=read.table(file=TRN_DIR%+%"/subject_train.txt")
X_train=read.table(file=TRN_DIR%+%"/X_train.txt")
Y_train=read.table(file=TRN_DIR%+%"/y_train.txt")

#Testing Data Sets
sub_test=read.table(file=TEST_DIR%+%"/subject_test.txt")
X_test=read.table(file=TEST_DIR%+%"/X_test.txt")
Y_test=read.table(file=TEST_DIR%+%"/y_test.txt")

#Data Columns index and Names for columns with mean and std
data_dict=fread(DATA_DIR%+%"/features.txt")
mean.desc=data.table(col.num=grep("mean",data_dict$V2)
                     ,col.desc=data_dict[grep("mean",data_dict$V2),V2])

std.desc=data.table(col.num=grep("std",data_dict$V2)
                     ,col.desc=data_dict[grep("std",data_dict$V2),V2])

#Selecting those columns for both the test and traing data set and adding the 
#the subject to each newly created data set
tmp_test =X_test[,c(mean.desc[,col.num],std.desc[,col.num])]
setnames(tmp_test,c("Test: "%+%mean.desc[,col.desc],"Test: "%+%std.desc[,col.desc]))
tmp_test=data.table(subject=sub_test$V1,tmp_test)

tmp_train =X_train[,c(mean.desc[,col.num],std.desc[,col.num])]
setnames(tmp_train,c("Train: "%+%mean.desc[,col.desc],"Train: "%+%std.desc[,col.desc]))
tmp_train=data.table(subject=sub_train$V1,tmp_train)

#Merge data sets using the subject as key full other join
setkey(tmp_test,subject)
setkey(tmp_train,subject)
tmp_data_full = merge(tmp_test,tmp_train,all=T)

setkey(tmp_data_full,subject)

#Calculating the average for each column by subject
avg.data.sub=tmp_data_full[,lapply(.SD,mean,na.rm=T),by=subject]

#Creating output directory if one doesn't exist and outputing results in text file
if(!file.exists(OUT_DIR)){dir.create(OUT_DIR)}
write.table(avg.data.sub,file=OUT_DIR%+%"/SGalaxy_Mov_Summary.txt",row.name=F, sep="\t")



