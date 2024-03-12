Rem: 1. Display the nobel laureates who were born after 1 Jul 1960
select * from nobel where dob > DATE '1960-07-01';

Rem: 2. Display the Indian laureate (name, category, field, country, year awarded) who was awarded in the Chemistry category.
select name, category, field, country, year_award from nobel where country = 'India' AND category = 'Che';

Rem: 3. Display the laureates (name, category,field and year of award) who was awarded between 2000 and 2005 for the Physics or Chemistry category.
select name, category, field, year_award from nobel where year_award between 2000 and 2005 AND category in ('Phy', 'Che');

Rem: 4. Display the laureates name with their age at the time of award for the Peace category.
select name, year_award - EXTRACT(YEAR FROM dob) as age from nobel where category = 'Pea';