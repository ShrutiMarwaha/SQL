select * from Student;

select * from Apply;

select * from College;	

# select students who have GPA greater than 3.6
select *
from Student
where GPA > 3.6;

# print student names and majors they have applied to
select distinct sName, major
from Student, Apply
where Student.sID = Apply.sID;

# select student, gpa and decision who applied to cs in stanford and were from high school of size less than 1000
select sName, GPA, decision
from Student, Apply
where Student.sID = Apply.sID
	and sizeHS < 1000 and cName="Stanford" and major="CS";

# college which has enrollment greater than 20000 and major as CS
select distinct College.cName
from College, Apply
where College.cName = Apply.cName 
	and enrollment>20000 and major="CS";
	
# select student id, name, gpa, college name and enrollment and sort by highest gpa and then by enrollment
select Student.sID, sName, GPA, Apply.cName, enrollment
from Student, College, Apply
where Student.sID = Apply.sID and Apply.cName = College.cName
order by GPA desc, enrollment;

## string matching
# select student ids who have applied for bio related courses
select sID, major
from Apply
where major like "%bio%" ;

## arithmetic operations on columns
select sID, sName, GPA, sizeHS, GPA*(sizeHS/1000)
from Student;

## Table variables
select S.sID, sName, GPA, A.cName, enrollment
from Student S, College C, Apply A
where S.sID = A.sID and A.cName = C.cName;

## to find students who have same GPA
select s1.sID, s1.sName, s1.GPA, s2.sID, s2.sName, s2.GPA
from student s1, student s2
where s1.GPA = s2.GPA and s1.sID < s2.sID;
	
## set operators
## union of student and college names with duplicates allowed and sorted
select sName as name from Student
union all
select cName as name from College
order by name;

## id of students who applied for both CS and EE
# intersect doesnt work in mysql
select sID from Apply where major="CS"
intersect
select sID from Apply where major="EE";

select distinct a1.sID 
from Apply a1, Apply a2
where a1.sID = a2.sID and a1.major="CS" and a2.major="EE";	

# select all students, sid and gpa who applied to CS
## importance of nested where; it will be a problem if you select only sName or GPA. distinct option will remove duplication even when its different ids. So use nested where
select distinct s.sID, sName, GPA 
from Apply a, Student s
where a.sID = s.sID and major="CS";

select sID, sName, GPA 
from Student 
where sID in (select sID from Apply where major="CS")


