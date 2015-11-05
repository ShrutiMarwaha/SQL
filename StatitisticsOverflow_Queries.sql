CREATE DATABASE StatisticsOverflow;

# load  badges.xml
CREATE TABLE badges (
  Id INT PRIMARY KEY,
  UserId INT,
  Name VARCHAR(255),
  Date TIMESTAMP,
  Class INT,
  TagBased VARCHAR(255)
);

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/Badges.xml" 
INTO TABLE badges;

SELECT COUNT(*) FROM badges;

# load  Posts.xml
CREATE TABLE posts (
  Id INT PRIMARY KEY,
  PostTypeId INT,
  AcceptedAnswerId INT,
  ParentId INT,
  CreationDate TIMESTAMP,
  Score INT,
  ViewCount INT,
  Body VARCHAR(255),
  OwnerUserId INT,
  OwnerDisplayName VARCHAR(255),
  LastEditorUserId INT,
  LastEditorDisplayName VARCHAR(255),
  LastEditDate TIMESTAMP,
  LastActivityDate TIMESTAMP,
  Title VARCHAR(255),
  Tags VARCHAR(255),
  AnswerCount INT,
  CommentCount INT,
  FavoriteCount INT,
  ClosedDate TIMESTAMP,
  CommunityOwnedDate TIMESTAMP
);

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/Posts.xml" 
INTO TABLE posts;

# load Comments.xml
CREATE TABLE comments 
(
  Id INT PRIMARY KEY,
  PostId INT,
  Score INT,
  Text VARCHAR(255),
  CreationDate TIMESTAMP,
  UserDisplayName VARCHAR(255),
  UserId INT
);

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/Comments.xml" 	
INTO TABLE comments;

# load PostHistory.xml
CREATE TABLE PostHistory 
(
  Id INT PRIMARY KEY,
  PostHistoryTypeId INT,
  PostId INT,
  RevisionGUID VARCHAR(255),
  CreationDate TIMESTAMP,
  UserId INT,
  Text VARCHAR(255),
  UserDisplayName VARCHAR(255),
  Comment VARCHAR(255)
);

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/PostHistory.xml"
INTO TABLE PostHistory;

# load PostLinks.xml
CREATE TABLE PostLinks
(
  Id INT PRIMARY KEY,
  CreationDate TIMESTAMP,
  PostId INT,
  RelatedPostId INT,
  LinkTypeId INT
);	

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/PostLinks.xml"
INTO TABLE PostLinks;

# load Tags.xml
CREATE TABLE Tags
(
  Id INT PRIMARY KEY,
  TagName VARCHAR(255),
  Count INT,
  ExcerptPostId INT,
  WikiPostId INT
);

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/Tags.xml"
INTO TABLE Tags;

# load Users.xml
CREATE TABLE Users
(
  Id INT PRIMARY KEY,
  Reputation INT,
  CreationDate TIMESTAMP,
  DisplayName VARCHAR(255),
  LastAccessDate TIMESTAMP,
  WebsiteUrl VARCHAR(255),
  Location VARCHAR(255),
  AboutMe VARCHAR(255),
  Views INT,
  UpVotes INT,
  DownVotes INT,
  AccountId INT,
  EmailHash VARCHAR(255),
  AGE INT
);	

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/Users.xml"
INTO TABLE Users;

# load votes.xml
CREATE TABLE Votes
(
  Id INT PRIMARY KEY,
  PostId INT,
  VoteTypeId INT,
  CreationDate TIMESTAMP,
  UserId INT,
  BountyAmount INT
);	

LOAD XML LOCAL INFILE "/Users/shruti/Desktop/WorkMiscellaneous/Fellowships/DataIncubator/Question2/Votes.xml"
INTO TABLE Votes;

#Q2.a What fraction of posts contain the 5th most popular tag?	
SELECT ROUND(FifthPopular.count/Total.count, 10) as fraction FROM
(SELECT COUNT(*) as count FROM posts WHERE Tags LIKE (SELECT CONCAT('%<', TagName, '>%') FROM Tags
                                                      ORDER BY Count DESC LIMIT 4,1)) as FifthPopular,
(SELECT COUNT(*) as count FROM posts) as Total;

#Q2.b How much higher is the average answer's score than the average question's?
SELECT ROUND(Answer.avg_score - Question.avg_score,10) as AvgScoreDiff FROM
(SELECT AVG(Score) as avg_score FROM posts WHERE PostTypeId=2) as Answer,
(SELECT AVG(Score) as avg_score FROM posts WHERE PostTypeId=1) as Question;

#Q2.c What is the Pearson's correlation between a user's reputation and total score from posts (for valid users)? #  0.9848617
SELECT user_reputation.Id, user_reputation.Reputation, user_score.total_score
FROM   (SELECT Id, Reputation FROM Users) as user_reputation
RIGHT JOIN 
(SELECT SUM(Score) as total_score, OwnerUserId FROM posts WHERE OwnerUserId IS NOT NULL and OwnerUserId>0 GROUP BY OwnerUserId) as user_score
ON user_reputation.Id = user_score.OwnerUserId;
# export the query result as csv and import it R and calculate correlation between columns 2 and 3 i.e, Reputation and  total_score
# IN R
#user_data <- read.csv("/Users/shruti/Desktop/query_result.csv")
#cor(user_data$Reputation,user_data$total_score,method="pearson")

#Q2.d How many more upvotes does the average answer receive than the average question?
# VoteTypeId=2 is UpMod which I think means upvote. So select post id which have UpMod.
# PostTypeId  1 indicates question and 2 indicates answer
SELECT (Answer.total_up_votes - Question.total_up_votes) as diff_ans_ques_up_votes FROM
(SELECT count(*) as total_up_votes from Votes v, posts p where v.`PostId` = p.`Id` and v.`VoteTypeId`=2 and p.`PostTypeId`=2) as Answer,
(SELECT count(*) as total_up_votes from Votes v, posts p where v.`PostId` = p.`Id` and v.`VoteTypeId`=2 and p.`PostTypeId`=1) as Question;

#Q2.e What is the difference between the largest and smallest median response times across question post hours? Solved in R
install.packages("RMySQL")
library(RMySQL)
# Connecting to MySQL
mydb = dbConnect(MySQL(), user='root', password='', dbname='StatisticsOverflow', host='127.0.0.1')
#  list of the tables in our connection.
dbListTables(mydb)
dbListFields(mydb, "posts" )
# To retrieve data from the database we need to save a results set object.
rs = dbSendQuery(mydb, "select Id,PostTypeId,AcceptedAnswerId,CreationDate  from posts")
# to access the results in R we need to use the fetch function.
PostsTable = fetch (rs,n=-1)
QuestionPosts <- subset(PostsTable,PostTypeId==1)
AnswerPosts <- subset(PostsTable,PostTypeId==2)
MergedTable <- merge(QuestionPosts[,c(3,4)],AnswerPosts[,c(1,4)],by.x="AcceptedAnswerId",by.y="Id")
MergedTable[,c(2)] <- as.POSIXct(MergedTable[,c(2)])
MergedTable[,c(3)] <- as.POSIXct(MergedTable[,c(3)])
colnames(MergedTable)[c(2,3)] <- c("CreationDate.Question","CreationDate.Answer")
# extract the hour when question was posted
MergedTable[,"HourOfQuestionPost"] <- format(MergedTable$CreationDate.Question,"%H")
MergedTable[,"TimeDiff"] <- MergedTable$CreationDate.Answer - MergedTable$CreationDate.Question
MedianTimeByPostHour <- by(MergedTable[, "TimeDiff"], MergedTable[,"HourOfQuestionPost"], median)
plot(MedianTimeByPostHour)
# difference between the largest and smallest median response times across question post hours. Divide by 60 to convert minutes to hours
difference <- (max(MedianTimeByPostHour) - min(MedianTimeByPostHour))/60
difference <- sprintf("%.10f",difference)
## another interesting analysis will be to see to observe the response time on different days of week, especially weekdays vs weekend. 

#Q2f. What is the largest quotient of the conditional probability of an action divided by its unconditioned probability?
CREATE TABLE UserAction (UserId INT, Action VARCHAR(1), ActionCount INT) 
SELECT UserId, Action, COUNT(Action) as ActionCount FROM 
(SELECT OwnerUserId as UserId, 'q' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=1 and OwnerUserId IS NOT NULL and OwnerUserId>0
 UNION
 SELECT OwnerUserId as UserId, 'a' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=2 and OwnerUserId IS NOT NULL and OwnerUserId>0
 UNION
 SELECT UserId as UserId, 'c' as Action, CreationDate as ActionDate, PostId as PostId FROM comments WHERE UserId IS NOT NULL and UserId>0
 ORDER BY UserId, ActionDate
) as UserActionData
GROUP BY UserId, Action;
# export the query result as table and import it R for further calculation
library(RMySQL)
# Connecting to MySQL
mydb = dbConnect(MySQL(), user='root', password='', dbname='StatisticsOverflow', host='127.0.0.1')
rs = dbSendQuery(mydb, "select *  from UserAction")
# to access the results in R we need to use the fetch function.
UserActionTable = fetch (rs,n=-1)
