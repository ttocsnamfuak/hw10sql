use sakila;

-- 1a. Display the first and last names of all actors from the table actor

select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name

ALTER TABLE actor ADD COLUMN ActorName VARCHAR(50);

UPDATE actor SET ActorName = CONCAT(first_name, '  ', last_name);

UPDATE actor SET `ActorName` = UPPER( `ActorName` );

select ActorName from Actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

select ActorName
from actor
where ActorName like "%GEN";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select last_name
from actor
where last_name like '%LI%';

--  Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select *
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

alter table actor add column middle_name varchar(50);


-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

alter table actor change middle_name middle_name blob;

-- 3c. Now delete the middle_name column.

ALTER TABLE actor DROP COLUMN middle_name;


-- 4a. List the last names of actors, as well as how many actors have that last name.

select a.last_name, num_row
from actor   a
inner join ( 
    select  last_name, count(*) as num_row 
    from actor 
    group by last_name
  ) t on t.last_name  = a.last_name
  group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select a.last_name, num_row
from actor   a
inner join ( 
    select  last_name, count(*) as num_row 
    from actor 
    group by last_name
  ) t on t.last_name  = a.last_name
  where num_row > 1
  group by last_name;
  
-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
SET first_name='Harpo'
WHERE last_name = "williams";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (

update actor
set first_name='Groucho'
where last_name = "williams" and first_name = "Harpo";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?


SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select a.last_name, amt_row
from staff   a
inner join ( 
    select  staff_id, sum(amount) as amt_row 
    from payment 
    group by staff_id
  ) t on t.staff_id  = a.staff_id;
  
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select a.title, act_row
from film   a
inner join ( 
    select  film_id, count(actor_id) as act_row 
    from film_actor 
    group by film_id
  ) t on t.film_id  = a.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
  
  select count(inventory_id)
  from inventory
  where (
	select film_id
	from film
	where title = "Hunchback Impossible"
    );
  
 -- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
 
select a.last_name, sum_row
from customer   a
inner join ( 
    select  customer_id, sum(amount) as sum_row 
    from payment 
    group by customer_id
  ) t on t.customer_id  = a.customer_id
  order by a.last_name;
  
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

  select title
  from film
  where language_id = (
	select language_id
	from language
	where name = "English"
    ) and title like '[kq]%';
    
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select last_name
from actor
where actor_id in (
			select actor_id
            from film_actor
            where film_id = (
						select film_id
                        from  film
                        where title = "Alone Trip"
                        )
			)
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name, email
from customer
where address_id in (
		select address_id
		from address
		where city_id in (
				select city_id
				from city
				where country_id = (
						select country_id
						from country
						where country = 'canada'
						)
				)
		);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

select title
from film
where film_id in (
	select film_id
	from film_category
	where category_id = (
		select category_id
		from category
		where name = 'family'
		)
	);

-- 7e. Display the most frequently rented movies in descending order

SELECT f.title, i.film_id, count(rental_date) as cnt
FROM inventory i
JOIN rental r 
	ON i.inventory_id = r.inventory_id
JOIN film f
	ON i.film_id = f.film_id
GROUP BY film_id desc; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select s.store_id, sum(amount) as amt
from store s
join staff stf
	on s.store_id = stf.store_id
join payment p
	on stf.staff_id = p.staff_id
GROUP BY store_id;

select * from sales_by_store;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store
join address
	on store.address_id = address.address_id
join city
	on address.city_id = city.city_id
join country
	on city.country_id = country.country_id
group by store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT f.title, i.film_id, sum(amount) as amt
FROM inventory i
JOIN rental r 
	ON i.inventory_id = r.inventory_id
JOIN film f
	ON i.film_id = f.film_id
JOIN payment p
	ON r.staff_id = p.staff_id
GROUP BY film_id desc; 

show create view sales_by_film_category;

select * from sales_by_film_category limit 5;
 
 -- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view
 
Create View `MyTopView` as 
	select store.store_id, city.city, country.country
	from store
	join address
		on store.address_id = address.address_id
	join city
		on address.city_id = city.city_id
	join country
		on city.country_id = country.country_id
	group by store_id;
 
 -- 8b. How would you display the view that you created in 8a?
 
 select * from MyTopView;
 
 -- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
 
 DROP VIEW MyTopView;