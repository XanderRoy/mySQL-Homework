use SAKILA;
/* 1a. Display the first and last names of all actors from the table actor.*/

select FIRST_NAME, LAST_NAME
from ACTOR;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/
select concat(FIRST_NAME , ' ', LAST_NAME) as 'Actor Name'
from ACTOR; 

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/

select ACTOR_ID, FIRST_NAME, LAST_NAME
from ACTOR
where FIRST_NAME = 'Joe';

/* 2b. Find all actors whose last name contain the letters GEN: */
select FIRST_NAME, LAST_NAME
from ACTOR
where LAST_NAME like '%GEN%';

/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:*/
select FIRST_NAME, LAST_NAME
from ACTOR
where LAST_NAME like '%LI%' 
order by LAST_NAME, FIRST_NAME;

/*2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
select COUNTRY_ID, COUNTRY
from COUNTRY
where COUNTRY in ('Afghanistan', 'Bangladesh', 'China');

/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).*/
alter table ACTOR
add DESCRIPTION BLOB;

/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
alter table ACTOR
drop column DESCRIPTION;

/*4a. List the last names of actors, as well as how many actors have that last name.*/
select LAST_NAME, count(LAST_NAME)
from ACTOR
group by LAST_NAME;

/*4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
select LAST_NAME, count(LAST_NAME)
from ACTOR
group by LAST_NAME
having count(LAST_NAME) > 1;


/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.having count(LAST_NAME) > 1having count(LAST_NAME) > 1*/
update ACTOR
set FIRST_NAME = 'HARPO'
where FIRST_NAME = 'GROUCHO' and LAST_NAME = 'WILLIAMS';

/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
update ACTOR
set FIRST_NAME = 'GROUCHO'
where FIRST_NAME = 'HARPO' and LAST_NAME = 'WILLIAMS';


/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table. */

show create table ADDRESS;


/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:*/
select S.FIRST_NAME, S.LAST_NAME, A.ADDRESS 
from STAFF S
join ADDRESS A
on A.ADDRESS_ID = S.ADDRESS_ID ;

/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.*/
select S.FIRST_NAME,  S.LAST_NAME, sum(P.AMOUNT)
from STAFF S
join PAYMENT P
on S.STAFF_ID = P.STAFF_ID
where PAYMENT_DATE like '2005-08%'
group by S.LAST_NAME;

/*6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/
select F.TITLE, count(FA.ACTOR_ID)
from FILM F
inner join FILM_ACTOR FA
on F.FILM_ID = FA.FILM_ID
group by F.TITLE;

/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/
select count(INVENTORY_ID) as 'Total Copies of Hunchback Impossible'
from INVENTORY
where FILM_ID = (
	select FILM_ID
    from FILM
    where TITLE = 'HUNCHBACK IMPOSSIBLE');

/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
	![Total amount paid](Images/total_payment.png)*/
    
select C.LAST_NAME, C.FIRST_NAME, sum(P.AMOUNT) as 'Total Paid'
from CUSTOMER C
inner join PAYMENT P
on C.CUSTOMER_ID = P.CUSTOMER_ID
group by LAST_NAME, FIRST_NAME
order by LAST_NAME;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
 Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
 
select TITLE
from FILM
WHERE TITLE like 'K%' or TITLE like 'Q%' and LANGUAGE_ID = 1;

/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/
select first_name, last_name
from actor
where actor_id in (
	select actor_id
	from film_actor
	where film_id = (
		select film_id
		from film
		where title = 'ALONE TRIP'));

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
email addresses of all Canadian customers. Use joins to retrieve this information.*/
select FIRST_NAME, LAST_NAME, EMAIL
FROM CUSTOMER
WHERE ADDRESS_ID IN (
	select ADDRESS_ID
	from ADDRESS
	where CITY_ID in (
		select CITY_ID  
		from CITY
		where COUNTRY_ID = (  
			SELECT COUNTRY_ID 
			FROM COUNTRY 
			WHERE COUNTRY = 'CANADA')));
            
/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
 Identify all movies categorized as family films.*/
select F.TITLE as 'Family Friendly Movies'
from FILM F
join FILM_CATEGORY FC
on FC.FILM_ID = F.FILM_ID
join CATEGORY C
on FC.CATEGORY_ID = C.CATEGORY_ID
where C.NAME LIKE 'FAMILY';


/*7e. Display the most frequently rented movies in descending order.*/
SELECT f.title AS "Movies sorted by most rented"
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.inventory_id) DESC;

/*7f. Write a query to display how much business, in dollars, each store brought in.*/

SELECT s.store_id, SUM(amount) AS Gross
FROM payment p 
JOIN rental r
	ON (p.rental_id = r.rental_id)
JOIN inventory i
	ON (i.inventory_id = r.inventory_id)
JOIN store s
	ON (s.store_id = i.store_id)
GROUP BY s.store_id;


/*7g. Write a query to display for each store its store ID, city, and country.*/
SELECT a.address, s.store_id, c.city, cy.country
FROM address a 
JOIN store s
	ON (a.address_id = s.address_id)
JOIN city c
	ON (c.city_id = a.city_id)
JOIN country cy 
	ON (cy.country_id = c.country_id);
    
/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use 
the following tables: category, film_category, inventory, payment, and rental.)*/

SELECT c.name, SUM(p.amount) AS 'Gross revenue'
FROM category c
JOIN film_category fc
ON (c.category_id = fc.category_id)
JOIN inventory i
ON (fc.film_id = i.film_id)
JOIN rental r
ON (i.inventory_id = r.inventory_id) 
JOIN payment p
ON (p.rental_id = r.rental_id)
GROUP BY c.name
LIMIT 5;



/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top 
five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't
 solved 7h, you can substitute another query to create a view.*/
CREATE VIEW top_5_genres AS
SELECT c.name, SUM(p.amount) AS 'Gross revenue'
FROM category c
JOIN film_category fc
ON (c.category_id = fc.category_id)
JOIN inventory i
ON (fc.film_id = i.film_id)
JOIN rental r
ON (i.inventory_id = r.inventory_id) 
JOIN payment p
ON (p.rental_id = r.rental_id)
GROUP BY c.name
LIMIT 5;

/*8b. How would you display the view that you created in 8a?*/
SELECT * FROM
top_5_genres;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW top_5_genres;