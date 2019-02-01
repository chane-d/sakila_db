use sakila;

select * from actor;

/* #1a 
Display the first and last names of all actors from the table actor.
*/
select first_name, last_name 
from actor;

/* #1b 
Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
*/
select UPPER(concat (first_name, " ", last_name)) as "Actor Name" 
from actor;

/* #2a
 You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
 What is one query would you use to obtain this information?
 */
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

/* #2b
 Find all actors whose last name contain the letters GEN:
 */
select actor_id, first_name, last_name
from actor
where last_name like "%GEN%";

/* #2c
 Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
 */
select actor_id, last_name, first_name
from actor
where last_name like "%LI%"
order by last_name, first_name;

/* #2d
 Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
 */
 select country_id, country, last_update
 from country
 where country IN ("Afghanistan", "Bangladesh", "China")
 ;
 
 /* #3a
 You want to keep a description of each actor. You don't think you will be performing queries on a description,
 so create a column in the table actor named description
 and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
 */
alter table actor
add description Blob;

 /* #3b
 Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
 */
alter table actor
drop column description;

 /* #4a
 List the last names of actors, as well as how many actors have that last name.
 */
select last_name, count(last_name) as "Count of Last Name"
from actor
group by last_name;

 /* #4b
 List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
 */
select last_name, count(last_name) as "Count of Last Name"
from actor
group by last_name
having count(last_name) >=2;

/* #4c
The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
*/
 select *
 from actor
 where first_name= "GROUCHO";
 
update actor
set first_name="HARPO"
where actor_id=172;
 
/* #4d
Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
*/
update actor
set first_name="GROUCHO"
where first_name="HARPO";

/* #5a
You cannot locate the schema of the address table. Which query would you use to re-create it?
*/
show create table sakila.address;

'CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8'

/* #6a
Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
*/
select * from address;
select * from staff;

select first_name, last_name, address
from staff
inner join address
on staff.address_id=address.address_id;

/* #6b
Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
*/
select first_name, last_name, sum(amount) as "Total Amount Rung up by Staff in August of 2005"
from staff s
inner join payment p
on s.staff_id = p.staff_id
where payment_date like "2005-08%"
group by p.staff_id
order by last_name ASC;

/* #6c
List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
*/
select * from film;
select * from film_actor;

select title, count(actor_id) as "Number of Actors per Film"
from film f
inner join film_actor fa
on f.film_id = fa.film_id
group by fa.film_id;

/* #6d
How many copies of the film Hunchback Impossible exist in the inventory system?
*/
select * from inventory;

select title, count(inventory_id) as "Copies of Hunchback Impossible in Stock"
from film f
inner join inventory i
on f.film_id = i.film_id
where f.title = "Hunchback Impossible";

/* #6e
Using the tables payment and customer and the JOIN command, list the total paid by each customer.
List the customers alphabetically by last name:
*/
select * from payment;
select * from customer;

select first_name, last_name, sum(amount) as "Total Amount Paid"
from customer c
inner join payment p
on c.customer_id = p.customer_id
group by c.customer_id
order by last_name ASC;

/* #7a
The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
*/
select * from film;
select * from language;

select title
from film
where language_id in (
	select language_id
	from language
	where name = "English")
and title like "K%" or title like "Q%";

/* #7b
Use subqueries to display all actors who appear in the film Alone Trip.
*/
select first_name, last_name
from actor
where actor_id in (
	select actor_id
	from film_actor
	where film_id in (
		select film_id
		from film
		where title = "Alone Trip"
		)
	);

/* #7c
You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
Use joins to retrieve this information.
*/
select * from customer;
select * from address;
select * from country;
select * from city;

select first_name, last_name, email
from customer cu
left join address a
on cu.address_id = a.address_id
left join city ci
on a.city_id = ci.city_id
left join country co
on ci.country_id = co.country_id
where country = "Canada";

/* #7d
Sales have been lagging among young families, and you wish to target all family movies for a promotion.
Identify all movies categorized as family films.
*/
select * from film;
select * from film_category;
select * from category;

select title
from film
where film_id in (
	select film_id
	from film_category
	where category_id in (
		select category_id
		from category
		where name = "Family"
		)
	);

/* #7e
Display the most frequently rented movies in descending order.
*/
select * from film_text;
select * from inventory;
select * from rental;

select i.film_id, f.title, count(r.inventory_id)
from inventory i
inner join rental r
on i.inventory_id = r.inventory_id
inner join film_text f
on i.film_id = f.film_id
group by r.inventory_id
order by count(r.inventory_id) DESC;

/* #7f
Write a query to display how much business, in dollars, each store brought in.
*/
select store.store_id, sum(amount)
from store
inner join staff
on store.store_id = staff.store_id
inner join payment p
on p.staff_id = staff.staff_id
group by store.store_id
order by sum(amount);

/* #7g
Write a query to display for each store its store ID, city, and country.
*/
select * from store;
select * from customer;
select * from staff;
select * from address;
select * from city;
select * from country;

select s.store_id, city, country
from store s
inner join customer cu
on s.store_id = cu.store_id
inner join staff st
on s.store_id = st.store_id
inner join address a
on cu.address_id = a.address_id
inner join city ci
on a.city_id = ci.city_id
inner join country co
on ci.country_id = co.country_id;

/* #7h
List the top five genres in gross revenue in descending order. (Hint: you may need to use the following 
tables: category, film_category, inventory, payment, and rental.)
*/
select * from category;
select * from film_category;
select * from inventory;
select * from rental;
select * from payment;

select name, sum(p.amount)
from category c
inner join film_category fc
on c.category_id = fc.category_id
inner join inventory i
on fc.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
inner join payment p
on r.rental_id = p.rental_id
group by name
order by sum(p.amount) DESC
limit 5;

/* #8a
In your new role as an executive, you would like to have an easy way of viewing the top five genres by gross revenue.
Use the solution from the problem above to create a view.
If you haven't solved 7h, you can substitute another query to create a view.
*/
CREATE VIEW top_five_grossing_genres AS

select name, sum(p.amount)
from category c
inner join film_category fc
on c.category_id = fc.category_id
inner join inventory i
on fc.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
inner join payment p
on r.rental_id = p.rental_id
group by name
order by sum(p.amount) DESC
limit 5;

/* #8b
How would you display the view that you created in 8a?
*/

select * from top_five_grossing_genres;

/* #8c
How would you display the view that you created in 8a?
*/
drop view top_five_grossing_genres;

