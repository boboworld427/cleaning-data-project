
feature<-read.table("features.txt",header = F)
activity_labels<-read.table("activity_labels.txt")

X_test<-read.table("X_test.txt",header=F)
Y_test<-read.table("y_test.txt",header=F)
subject_test<-read.table("subject_test.txt")

X_train<-read.table("X_train.txt",header=F)
Y_train<-read.table("y_train.txt",header=F)
subject_train<-read.table("subject_train.txt")


names(subject_test)<-"ID"
names(subject_train)<-"ID"

names(Y_test)<-"activity"
names(Y_train)<-"activity"
Y_test$activity<-factor(Y_test$activity,labels=activity_labels$V2)  #change the numeric values to 
Y_train$activity<-factor(Y_train$activity,labels=activity_labels$V2)#factors and label the factors.


feature.names<-as.character(feature$V2)
names(X_test)<-feature.names 
names(X_train)<-feature.names


MeanAndStd<-grep("[Mm][Ee][Aa][Nn]|[Ss][Tt][Dd]",names(X_test))
X_test<-X_test[,MeanAndStd]                
X_train<-X_train[,MeanAndStd]
meanFreqAngle<-grep("[Mm][Ee][Aa][Nn][Ff][Rr][Ee][Qq]|[Aa][Nn][Gg][Ll][Ee]",names(X_test))
X_test<-X_test[,-meanFreqAngle]
X_train<-X_train[,-meanFreqAngle]
names(X_test)<-gsub("\\()|-","",names(X_test))
names(X_train)<-gsub("\\()|-","",names(X_train))

X_test<-cbind(subject_test,Y_test,X_test)    #combine with ID and activity columns
X_train<-cbind(subject_train,Y_train,X_train)

X_test<-cbind(group=factor("test"),X_test)   
X_train<-cbind(group=factor("training"),X_train)


library(dplyr)

X_test<-tbl_df(X_test)
X_train<-tbl_df(X_train)

fulltable<-rbind(X_test,X_train)


fulltable<-fulltable %>% select(ID,activity,group,grep("[Mm][Ee][Aa][Nn]",names(fulltable)),grep("[Ss][Tt][Dd]",names(fulltable)))%>%arrange(ID,activity,group)
#Selecting only he measure from mean and std


meantable<-fulltable %>% select(ID:group,grep("[Mm][Ee][Aa][Nn]",names(fulltable))) %>% mutate(measure=factor("mean")) 
stdtable<-fulltable %>%select(ID:group,grep("[Ss][Tt][Dd]",names(fulltable))) %>% mutate(measure=factor("standardDeviation"))

meantable<-select(meantable,ID:group,measure,grep("[Mm][Ee][Aa][Nn]",names(meantable))) 
stdtable<-select(stdtable,ID:group,measure,grep("[Ss][Tt][Dd]",names(stdtable)))

names(meantable)<-gsub("mean","",names(meantable))
names(stdtable)<-gsub("std","",names(stdtable))

newtable<-rbind(meantable,stdtable)
newtable<-select(newtable,ID,group,activity,measure,5:37)


names(newtable)<-gsub("^t","time",names(newtable))
names(newtable)<-gsub("^f","freqency",names(newtable))
names(newtable)<-gsub("[Bb][Oo][Dd][Yy][Bb][Oo][Dd][Yy]","Body",names(newtable))
names(newtable)<-gsub("[Aa][Cc][Cc]","Accelerometer",names(newtable))
names(newtable)<-gsub("[Gg][Yy][Rr][Oo]","Gyroscope",names(newtable))
names(newtable)<-gsub("[Mm][Aa][Gg]","Magnitute",names(newtable))


dim(newtable)
str(newtable)

newtable2<-aggregate(. ~ID+group+activity+measure, newtable, mean)
newtable2<-arrange(newtable2,ID)  

View(newtable2)

#write.table(newtable2, "c:/tidydata.txt", sep="\t",row.names=F)
