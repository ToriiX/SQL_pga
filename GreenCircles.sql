-- 1
-- Task: Create a list of all the different (distinct) replacement costs of the films
-- What is the lowest replacement cost? 
SELECT DISTINCT(replacement_cost) as replacement_costs FROM film
ORDER BY replacement_costs;

-- 2 
-- Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
-- Question: How many films have a replacement cost in the "low" group?

SELECT 
CASE 
WHEN replacement_cost BETWEEN 9.99 AND 19.99
THEN 'low'
WHEN replacement_cost BETWEEN 20 AND 24.99
THEN 'medium'
ELSE 'high'
END as cost_range,
COUNT(*)
FROM film
GROUP BY cost_range

-- 3
-- Task: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
-- Question: In which category is the longest film and how long is it? 

SELECT title, length, c.name FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
GROUP BY c.name, length, title
HAVING c.name = 'Drama' OR c.name ='Sports'
ORDER BY length DESC;

-- 4 
-- Task: Create an overview of how many movies (titles) there are in each category (name).
-- Question: Which category (name) is the most common among the films? - ok- 
SELECT name, COUNT(name) as count FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
GROUP BY name
ORDER BY count DESC;

-- 5 
-- Task: Create an overview of the actors' first and last names and in how many movies they appear in.
-- Question: Which actor is part of most movies?? - ok - 

SELECT first_name, last_name, COUNT(fa.film_id) as no_movies FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
--JOIN film f
--ON fa.film_id = f.film_id
GROUP BY  first_name, last_name
ORDER BY no_movies DESC;


-- 6
-- Task: Create an overview of the addresses that are not associated to any customer.
-- Question: How many addresses are that? 

SELECT * FROM address a
LEFT JOIN customer c
ON a.address_id = c.address_id
WHERE first_name IS NULL;

-- 7
-- Task: Create the overview of the sales  to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur.
-- Question: What city is that and how much is the amount? 

SELECT city, SUM(p.amount) as count FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
JOIN address a
ON c.address_id = a.address_id
JOIN city ct
ON ct.city_id = a.city_id
GROUP BY city
ORDER BY count DESC;


-- 8 --
-- Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
-- Question: Which country, city has the least sales?

SELECT city, country, SUM(amount) as revenue FROM country c
JOIN city ct
ON c.country_id = ct.country_id
JOIN address a
ON a.city_id = ct.city_id
JOIN customer cu
ON cu.address_id = a.address_id
JOIN payment p
ON cu.customer_id = p.customer_id
GROUP BY city, country
ORDER BY revenue;

-- Alternatively 

SELECT 
country ||', ' ||city,
SUM(amount)
FROM payment p
LEFT JOIN customer c
ON p.customer_id=c.customer_id
LEFT JOIN address a
ON a.address_id=c.address_id
LEFT JOIN city ci
ON ci.city_id=a.city_id
LEFT JOIN country co
ON co.country_id=ci.country_id
GROUP BY country ||', ' ||city
ORDER BY 2 ASC;


--9
-- Task: Create a list with the average of the sales amount each staff_id has per customer.
-- Question: Which staff_id makes on average more revenue per customer?

SELECT 
staff_id,
ROUND(AVG(total),2) as avg_amount 
FROM 
(SELECT SUM(amount) as total, customer_id, staff_id
FROM payment
GROUP BY customer_id, staff_id) sub
GROUP BY staff_id;


-- 10
-- Task: Create a query that shows average daily revenue of all Sundays.
-- Question: What is the daily average revenue of all Sundays?

SELECT day_of_week, ROUND(AVG(total),2)
FROM
(SELECT DATE(payment_date), EXTRACT(dow from payment_date) as day_of_week, SUM(amount) as total 
FROM payment
GROUP BY DATE(payment_date),
EXTRACT(dow from payment_date)) daily
GROUP BY day_of_week
ORDER BY day_of_week;

-- For SundayS only:
SELECT 
ROUND(AVG(total),2)
FROM 
(SELECT
SUM(amount) as total,
DATE(payment_date),
EXTRACT(dow from payment_date) as weekday
FROM payment
WHERE EXTRACT(dow from payment_date)=0
GROUP BY DATE(payment_date),weekday) sun
