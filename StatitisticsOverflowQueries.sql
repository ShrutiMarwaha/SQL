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

LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/Badges.xml" 
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

LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/Posts.xml" 
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
	
LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/Comments.xml" 	
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
	
LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/PostHistory.xml"
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

LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/PostLinks.xml"
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

LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/Tags.xml"
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

LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/Users.xml"
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

LOAD XML LOCAL INFILE "/Users/shruti/git/SQL/StatitisticsOverflowData/Votes.xml"
	INTO TABLE Votes;
	
# What fraction of posts contain the 5th most popular tag?	
SELECT TagName FROM Tags
ORDER BY Count DESC 
LIMIT 4,1;

# tag: Id 188; tagName: probability; 
SELECT COUNT(*) FROM posts WHERE Tags LIKE "%<probability>%"; # 2081
SELECT COUNT(*) FROM posts; # 91976


SELECT COUNT(*) FROM posts 
WHERE Tags LIKE (SELECT CONCAT('%<', TagName, '>%') FROM Tags
			   ORDER BY Count DESC LIMIT 4,1);

SELECT ROUND(1.99, 1) from dual;

# final	# 0.0226254670		   
SELECT ROUND(FifthPopular.count/Total.count, 10) as fraction FROM
	(SELECT COUNT(*) as count FROM posts WHERE Tags LIKE (SELECT CONCAT('%<', TagName, '>%') FROM Tags
			   ORDER BY Count DESC LIMIT 4,1)) as FifthPopular,
	(SELECT COUNT(*) as count FROM posts) as Total;

# How much higher is the average answer's score than the average question's?
# PostTypeId  1 indicates question and 2 indicates answer
SELECT AVG(Score) FROM posts WHERE PostTypeId=1;
SELECT AVG(Score) FROM posts WHERE PostTypeId=2;

# final # 0.6466000000
SELECT ROUND(Answer.avg_score - Question.avg_score,10) as AvgScoreDiff FROM
	(SELECT AVG(Score) as avg_score FROM posts WHERE PostTypeId=2) as Answer,
	(SELECT AVG(Score) as avg_score FROM posts WHERE PostTypeId=1) as Question;

# What is the Pearson's correlation between a user's reputation and total score from posts (for valid users)?
SELECT COUNT(*) FROM Users ; # Reputation, AccountID, ID

SELECT COUNT(DISTINCT OwnerUserId) FROM posts; # OwnerUserId, score

SELECT * FROM posts WHERE OwnerUserId IS NOT NULL;

SELECT Id, Reputation FROM Users WHERE Id>0;

SELECT SUM(Score), OwnerUserId FROM posts
WHERE OwnerUserId IS NOT NULL and OwnerUserId>0
GROUP BY OwnerUserId;

# final
SELECT user_reputation.Id, user_reputation.Reputation, user_score.total_score
FROM 	(SELECT Id, Reputation FROM Users) as user_reputation
	RIGHT JOIN 
		(SELECT SUM(Score) as total_score, OwnerUserId FROM posts WHERE OwnerUserId IS NOT NULL and OwnerUserId>0 GROUP BY OwnerUserId) as user_score
	ON user_reputation.Id = user_score.OwnerUserId
ORDER BY user_reputation.Id;

# export the query result as csv and import it R and calculate correlation between columns 2 and 3 i.e, Reputation and  total_score

# How many more upvotes does the average answer receive than the average question?
# VoteTypeId=2 is UpMod which I think means upvote. So select post id which have UpMod.
SELECT Id, PostId FROM Votes WHERE VoteTypeId=2;

# PostTypeId  1 indicates question and 2 indicates answer
SELECT Id, PostTypeID FROM posts WHERE PostTypeID=1 or PostTypeID=2;


#Answer
SELECT count(*) as total_up_votes from Votes v, posts p where v.`PostId` = p.`Id` and v.`VoteTypeId`=2 and p.`PostTypeId`=2;
#Question
SELECT count(*) as total_up_votes from Votes v, posts p where v.`PostId` = p.`Id` and v.`VoteTypeId`=2 and p.`PostTypeId`=1;

				
# final
SELECT (Answer.total_up_votes - Question.total_up_votes) as diff_ans_ques_up_votes FROM
(SELECT count(*) as total_up_votes from Votes v, posts p where v.`PostId` = p.`Id` and v.`VoteTypeId`=2 and p.`PostTypeId`=2) as Answer,
(SELECT count(*) as total_up_votes from Votes v, posts p where v.`PostId` = p.`Id` and v.`VoteTypeId`=2 and p.`PostTypeId`=1) as Question;


# We would like to understand which actions lead to which other actions on stats overflow. For each valid user, create a chronological history of when the user took one of these three actions: posing questions, answering questions, or commenting. For each of these three possible actions, compute the unconditional probability of each action (three total) as well as the probability conditioned on the immediately preceding action (nine total). What is the largest quotient of the conditional probability of an action divided by its unconditioned probability?
########
CREATE TABLE UserAction (UserId INT, Action VARCHAR(1), ActionDate TIMESTAMP, PostId INT) 
SELECT OwnerUserId as UserId, 'q' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=1 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT OwnerUserId as UserId, 'a' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=2 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT UserId as UserId, 'c' as Action, CreationDate as ActionDate, PostId as PostId FROM comments WHERE UserId IS NOT NULL and UserId>0
ORDER BY UserId, ActionDate;
#########

## rough
SELECT UserId, COUNT(Action) FROM 
(SELECT OwnerUserId as UserId, 'q' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=1 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT OwnerUserId as UserId, 'a' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=2 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT UserId as UserId, 'c' as Action, CreationDate as ActionDate, PostId as PostId FROM comments WHERE UserId IS NOT NULL and UserId>0
ORDER BY UserId, ActionDate
) as UserActionData
GROUP BY UserId;

CREATE TABLE UserAction2 (UserId INT, Action VARCHAR(1), ActionCount INT) 
SELECT UserId, Action, COUNT(Action) as ActionCount FROM 
(SELECT OwnerUserId as UserId, 'q' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=1 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT OwnerUserId as UserId, 'a' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=2 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT UserId as UserId, 'c' as Action, CreationDate as ActionDate, PostId as PostId FROM comments WHERE UserId IS NOT NULL and UserId>0
ORDER BY UserId, ActionDate
) as UserActionData
GROUP BY UserId, Action;

SELECT TotalAction.UserId, QuestionAction.Count/TotalAction.Count FROM
(select UserId, Action, COUNT(*) as Count FROM UserAction where Action='q' GROUP BY UserId) as QuestionAction,
(select UserId, Action, COUNT(*) as Count FROM UserAction where Action='a' GROUP BY UserId) as AnswerAction,
(select UserId, Action, COUNT(*) as Count FROM UserAction where Action='c' GROUP BY UserId) as CommentAction,
(select UserId, Action, COUNT(*) as Count FROM UserAction GROUP BY UserId) as TotalAction GROUP BY UserId;

SELECT OwnerUserId as UserId, 'q' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=1 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT OwnerUserId as UserId, 'a' as Action, CreationDate as ActionDate, Id as PostId FROM posts WHERE PostTypeId=2 and OwnerUserId IS NOT NULL and OwnerUserId>0
UNION
SELECT UserId as UserId, 'c' as Action, CreationDate as ActionDate, PostId as PostId FROM comments WHERE UserId IS NOT NULL and UserId>0
ORDER BY UserId, ActionDate;
