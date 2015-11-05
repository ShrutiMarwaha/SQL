# this code show how to connect to SQL database from R and do further analysis in R.I have used data stored in local "StatisticsOverflow" database. 

install.packages("RMySQL")
library(RMySQL)
# Connecting to MySQL
mydb = dbConnect(MySQL(), user='root', password='', dbname='StatisticsOverflow', host='127.0.0.1')
#  list of the tables in our connection.
dbListTables(mydb)
dbListFields(mydb, "posts")
# To retrieve data from the database we need to save a results set object.
rs = dbSendQuery(mydb, "select Id,PostTypeId,AcceptedAnswerId,CreationDate  from posts")
# to access the results in R we need to use the fetch function.
PostsTable = fetch (rs,n=-1)
head(PostsTable)
QuestionPosts <- subset(PostsTable,PostTypeId==1)
AnswerPosts <- subset(PostsTable,PostTypeId==2)
head(QuestionPosts)
head(AnswerPosts)
MergedTable <- merge(QuestionPosts[,c(3,4)],AnswerPosts[,c(1,4)],by.x="AcceptedAnswerId",by.y="Id")
MergedTable[,c(2)] <- as.POSIXct(MergedTable[,c(2)])
MergedTable[,c(3)] <- as.POSIXct(MergedTable[,c(3)])
colnames(MergedTable)[c(2,3)] <- c("CreationDate.Question","CreationDate.Answer")
head(MergedTable)
# extract the hour when question was posted
MergedTable[,"HourOfQuestionPost"] <- format(MergedTable$CreationDate.Question,"%H")
MergedTable[,"TimeDiff"] <- MergedTable$CreationDate.Answer - MergedTable$CreationDate.Question
MedianTimeByPostHour <- by(MergedTable[, "TimeDiff"], MergedTable[,"HourOfQuestionPost"], median)
#plot(MedianTimeByPostHour)
plot(MedianTimeByPostHour/360,xlab="Hour of day",ylab="Median Time To Answer a Question (hrs)")
# difference between the largest and smallest median response times across question post hours. Divide by 360 to convert seconds to hours
difference <- (max(MedianTimeByPostHour) - min(MedianTimeByPostHour))/360
difference <- sprintf("%.10f",difference)
## another interesting analysis will be to see to observe the response time on different days of week, especially weekdays vs weekend. 
