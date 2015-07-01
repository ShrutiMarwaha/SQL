select * from Movie;

# Find the titles of all movies directed by Steven Spielberg. 
select title 
from Movie
where director="Steven Spielberg";

# movie that received a rating of 4 or 5
select distinct mid
from Rating
where stars =4 or stars=5;

# Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 
select year
from Movie
where mid in (select distinct mid from Rating where stars =4 or stars=5)
order by year;

# Find the titles of all movies that have no ratings. 
select title
from Movie
where mid not in (select distinct mid from Rating);

# Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
select name
from Reviewer
where rID in (select rID from Rating where ratingDate is NULL);

# return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
select Re.name, M.title, Ra.stars, Ra.ratingDate
from Rating Ra, Movie M, Reviewer Re 
where Ra.rID = Re.rID and Ra.mID = M.mID
order by Re.name, M.title, Ra.stars;

# NOT SOLVED. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
select Re.name, m.title from Reviewer Re, Rating Ra1, Movie m where Ra1.mID=m.mID and
Re.rID = Ra1.rID and exists (select * from Rating Ra2 where Ra1.rID=Ra2.rID and Ra1.mID=Ra2.mID and Ra1.stars<Ra2.stars and Ra1.ratingDate<Ra2.ratingDate);
			  
select *
from Rating Ra1
where exists (select * from Rating Ra2
			  where Ra1.rID=Ra2.rID and Ra1.mID=Ra2.mID and Ra1.stars<Ra2.stars and Ra1.ratingDate<Ra2.ratingDate);

select name, Reviewer.rID, title, Movie.mID, stars, ratingDate
from Reviewer join Rating join Movie
on Reviewer.rID=Rating.rID and Movie.mID=Rating.mID;


## For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and highest number of stars. Sort by movie title. 
select title, max(stars)
from Movie join Rating using(mID)
Group by mID
order by title;

# For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
select title, max(stars)-min(stars)
from Movie join Rating using(mID)
Group by mID
order by max(stars)-min(stars) desc, title;

# Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 
select title, year, avg(stars)
from Movie join Rating using(mID)
Group by mID;

select year, avg(stars) as avg_stars
from Movie join Rating using(mID)
Group by mID having year>1980;

select year, avg(stars) as avg_stars
from Movie join Rating using(mID)
Group by mID having year<1980;


select avg(m1.stars)-avg(m2.stars) from Movie m1, Movie m2 join rating using(mID) group by mID;

select avg(b.avg_stars) - avg(a.avg_stars) as avg_stars from 
    (select avg(stars) as avg_stars from Movie join Rating using(mID) where year>1980 Group by mID) as a, 
    (select avg(stars) as avg_stars from Movie join Rating using(mID) where year<1980 Group by mID) as b;
