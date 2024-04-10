Rem: 1. Display the nobel laureates who were born after 1 Jul 1960
select * from nobel
where dob > DATE '1960-07-01';

Rem: 2. Display the Indian laureate (name, category, field, country, year awarded) who was awarded in the Chemistry category.
select name, category, field, country, year_award from nobel 
where country = 'India' AND category = 'Che';

Rem: 3. Display the laureates (name, category,field and year of award) who was awarded between 2000 and 2005 for the Physics or Chemistry category.
select name, category, field, year_award from nobel 
where year_award between 2000 and 2005 AND category in ('Phy', 'Che');

Rem: 4. Display the laureates name with their age at the time of award for the Peace category.
select name, year_award - EXTRACT(YEAR FROM dob) as age from nobel 
where category = 'Pea';

Rem: 5. Display the laureates (name,category,aff_role,country) whose name starts with “A” or ends with “a”, but not from Isreal.
select name, category, aff_role, country from nobel 
where (name LIKE 'A%' OR name LIKE '%a')  AND country != 'Isreal';

Rem: 6. Display the name, gender, affiliation, dob and country of laureates who was born in ‘1950’s. Label the dob column as Born 1950.
select name, gender, aff_role, dob as "Born 1950", country from nobel 
where EXTRACT(YEAR from dob) BETWEEN 1950 AND 1959;

Rem: 7. Display the laureates (name,gender,category,aff_role,country) whose name starts with A,D or H. Remove the laureate if he/she do not have any affiliation. Sort the results in ascending order of name.
select name, gender, category, aff_role, country FROM nobel
WHERE SUBSTR(name, 1, 1) in ('A', 'D', 'H') AND aff_role is not NULL
ORDER BY name;

Rem: 8. Display the university name(s) that has to its credit by having at least 2 nobel laureate with them.
select aff_role, count(*) from nobel
where INSTR(LOWER(aff_role), 'university') > 0
group by aff_role
having count(*) >= 2;

Rem: 9. List the date of birth of youngest and eldest laureates by country Wise, Label the column as Younger, Elder respectively. Include only the country having more than one laureate. Sort the output in the alphabetic order of country.
select country, MIN(dob) as "Younger", MAX(dob) as "Elder" from nobel
group by country
having count(*) > 1
order by country;

Rem: 10. Show the details (year award,category,field) where the award is shared among the laureates in the same category and field. Exclude the laureates from USA. Use TCL Statements.
SAVEPOINT BEFORE_QUERY_10;
select year_award, category, field from nobel
where country != 'USA'
group by year_award, category, field
having count(*) > 1;
COMMIT;

Rem: 11. Mark an intermediate point in the transaction (savepoint).
SAVEPOINT QUESTION_11;
select count(*) from nobel;

Rem: 12. Insert a new tuple into the nobel relation.
INSERT INTO nobel values (129, 'Winston Churchill', 'm', 'Lit', 'English', 1951, null, DATE '1890-01-01', 'UK');
SELECT * from nobel 
WHERE LAUREATE_ID = 129;

Rem: 13. Update the aff_role of literature laureates as 'Linguists'.
UPDATE nobel SET aff_role = 'Linguists' 
WHERE category = 'Lit';

SELECT * from nobel 
WHERE category = 'Lit';

Rem: 14. Delete the laureate(s) who was awarded in Enzymes field.
DELETE FROM nobel 
WHERE field = 'Enzymes';

select * from nobel 
where field = 'Enzymes';

Rem: 15. Discard the most recent update operations (rollback).
select count(*) from nobel;
ROLLBACK TO QUESTION_11;
select count(*) from nobel;

Rem: 16. Commit the changes.
COMMIT;

Rem: Check For New Tuple from 12.
SELECT * from nobel 
WHERE LAUREATE_ID = 129;

Rem: Check Aff Role of Linguists from 13.
SELECT * from nobel 
WHERE category = 'Lit';

Rem: Find laureates in the enzyme field from 14.
select * from nobel 
where field = 'Enzymes';

