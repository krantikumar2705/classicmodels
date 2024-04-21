use film_rental;
select * from payment;
-- questions

-- 1. What is the total revenue generated from all rentals in the database? (2 Marks)
select sum(amount) as total_revenue from payment;

-- 2. How many rentals were made in each month_name? (2 Marks)
SELECT MONTHNAME(rental_date) month, count(MONTHNAME(rental_date)) rental_made  from rental
group by month order by rental_made desc;

-- 3. What is the rental rate of the film with the longest title in the database?
select max(length(title)),title,rental_rate from film
group by title, rental_rate
order by max(length(title)) desc
limit 1;

-- 4. What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)
select avg(rental_rate) from film as f
inner join inventory as i on i.film_id = f.film_id
inner join rental as r on r.inventory_id = i.inventory_id
where datediff(rental_date, "2005-05-24 22:53:30") >= 30;

-- 5. What is the most popular category of films in terms of the number of rentals? (3 Marks)
select count(fc.category_id),c.category_id, c.name as category_name from film_category as fc
inner join category as c on c.category_id = fc.category_id
group by c.category_id,c.name
order by count(fc.category_id) desc
limit 1;

-- 6. Find the longest movie duration from the list of films that have not been rented by any customer. (3 Marks)
select max(length), film_id,title from film
where film_id not in( select film_id from inventory)
group by film_id
order by max(length) desc
limit 1;

-- 7. What is the average rental rate for films, broken down by category?
select c.category_id,avg(f.rental_rate) from film as f
inner join film_category as fc on fc.film_id = f.film_id
inner join category as c on c.category_id = fc.category_id
group by category_id;

-- 8. What is the total revenue generated from rentals for each actor in the database?
SELECT a.actor_id, a.first_name, a.last_name, sum(p.amount) from payment as p 
 inner join rental as r on r.rental_id= p.rental_id
 inner join inventory as i on i.inventory_id = r.inventory_id
 inner join film as f on f.film_id = i.film_id
 inner join film_actor as fa on fa.film_id = f.film_id
 inner join actor as a on a.actor_id = fa.actor_id
 group by a.actor_id, a.first_name, a.last_name
 order by sum(p.amount) desc;
 
-- 9. Show all the actresses who worked in a film having a "Wrestler" in the description. (3 Marks)
select a.* from actor as a
inner join film_actor as fa on fa.actor_id = a.actor_id
inner join film as f on f.film_id = fa.film_id
where description like "%Wrestler%";

-- 10.	Which customers have rented the same film more than once? customer inventory film
select customer_id, count(rental_id) count_of_movie from rental
group by customer_id
having count(rental_id) > 1;

-- 11 How many films in the comedy category have a rental rate higher than the average rental rate? 
SELECT COUNT(*)
FROM film_category AS fc
INNER JOIN category AS c ON c.category_id = fc.category_id
INNER JOIN film AS f ON f.film_id = fc.film_id
WHERE c.name = 'Comedy' AND f.rental_rate > (
    SELECT AVG(f2.rental_rate)
    FROM film AS f2
    INNER JOIN film_category AS fc2 ON fc2.film_id = f2.film_id
    INNER JOIN category AS c2 ON c2.category_id = fc2.category_id
    WHERE c2.name = 'Comedy'
);

-- 12. Which films have been rented the most by customers living in each city? -- not sure -- 
select count(rental_id), ct.city from rental as r
inner join customer as c on c.customer_id = r.customer_id
inner join address as a on a.address_id  = c.address_id
inner join city as ct on ct.city_id  = a.city_id
group by ct.city;

-- 13 What is the total amount spent by customers whose rental payments exceed $200?  
select customer_id, sum(amount) from payment
group by customer_id
having sum(amount)>=200;

-- or 

SELECT c.customer_id, c.first_name, c.last_name ,sum(p.amount) from customer as c
inner join payment as p on p.customer_id = c.customer_id
group by c.customer_id, c.first_name, c.last_name 
having sum(p.amount)>200;

-- 14 Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] 
SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'rental';

-- 15.	Create a View for the total revenue generated by each staff member, broken down by store city with the country name
create view stafrevenuebycity as
select sum(amount),s.staff_id, city, country from staff as s
inner join address as a on a.address_id = s.address_id
inner join city as ct on ct.city_id = a.city_id
inner join country as c on c.country_id = ct.country_id
inner join payment as p on p.staff_id = s.staff_id
group by s.staff_id, city, country;

-- 16. Create a view based on rental information consisting of visiting_day, customer_name, the title of the film,  
-- no_of_rental_days, the amount paid by the customer along with the percentage of customer spending.
CREATE VIEW rental_info AS
SELECT
    DATE(r.rental_date) AS visiting_day,
    c.first_name || ' ' || c.last_name AS customer_name,
    f.title,
    DATEDIFF(r.return_date, r.rental_date) AS no_of_rental_days,
    f.rental_rate * DATEDIFF(r.return_date, r.rental_date) AS amount_paid,
    (f.rental_rate * DATEDIFF(r.return_date, r.rental_date)) / SUM(f.rental_rate * DATEDIFF(r.return_date, r.rental_date)) OVER () * 100 AS percentage_of_customer_spending
FROM
    rental r
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    INNER JOIN customer c ON r.customer_id = c.customer_id;
    
-- 17.	Display the customers who paid 50% of their total rental costs within one day.custo inve rent custo
SELECT c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS total_payment_amount,
    SUM(CASE WHEN p.payment_date <= DATE_ADD(r.rental_date, INTERVAL 1 DAY) THEN p.amount ELSE 0 END) AS payment_within_1_day
FROM 
    customer c
JOIN 
    payment p ON c.customer_id = p.customer_id
JOIN 
    rental r ON p.rental_id = r.rental_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    payment_within_1_day >= (0.5 * SUM(p.amount));



