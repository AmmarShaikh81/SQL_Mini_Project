use shaikh;
show tables;
drop table if exists books;
create table books(
	book_id serial primary key,
    title varchar(100),
    author varchar(100),
    genre varchar(100),
    published_year int,
    price numeric(10,2),
    stock int
);
drop table if exists orders;
select * from books;
drop table if exists customers;
create table customers(
     customer_id serial primary key,
     name varchar(100),
     email varchar(100),
     phone varchar(100),
     city varchar(100),
     country varchar(150)
);
create table orders(
     order_id serial primary key,
     customer_id int references orders(customer_id),
     book_id int references books(book_id),
     order_date date,
     quantity int,
     Total_amount numeric(10,2)
);
select * from books;
select * from books;
select * from customers;
select * from orders;
/*Retrive all the books in "Fiction genre*/
select * from books where genre='Fiction';

/*Find the books published after 1950 */
select * from books where published_year > 1950 ;

/* list all the customer from canada*/
select * from customers where country='canada';

/*Show orders Placed in November 2023 */
select * from orders where month(order_date)=11 and year(order_date)=2023;

/*Retrive the total stock of books availaible */
select sum(stock) from books;

/* find the details of most expensive book*/
select * from books where price=(
                                  select max(price) from books
                                  );
select * from orders;
/*show all the customer who ordered more than one book */
select * from orders where quantity > 1;

/* retrive all orders where total amount exceeds $20*/
select * from orders where total_amount > 20; 

/* List all the genre availaible int books table*/
select distinct genre from books;

/*find the book with lowest stock */
select * from books where stock=(
                                  select min(stock) from books
                                  ) limit 1;


/*Calculate the total revenue generated from all orders */
select sum(total_amount) from orders;

/*retieve the total number of books sold for each genre */
select genre,sum(o.quantity) from books as b inner join orders as o on b.book_id=o.book_id group by genre;

/*find the average price of books in fantasy genre */
select avg(price) from books where genre='fantasy';


/*find most frequently ordered book */
select book_id,count(order_id) as order_count from orders group by book_id order by order_count desc limit 1;

/*show the top 3 expensive books of fantasy genre */
select title from books where genre='fantasy' order by price desc limit 3;

/*retrive the total quantity of books sold by each author */
select author,sum(o.quantity) from orders o join books as b on o.booK_id=b.book_id group by b.author;

/*list the cities where customers who spent over $30 are located */
select distinct city from customers as c join orders as o on c.customer_id=o.customer_id where total_amount > 30;

/*calculate the stock remaining after fulfilling all orders */
select b.book_id,b.title,b.stock,coalesce(sum(o.quantity),0) as order_quantity,b.stock-coalesce (sum(o.quantity),0) as remaining_quantity 
from books b left join orders as o on b.book_id=o.book_id group by b.book_id;

/*find the top book in each genre*/
SELECT *
FROM (
    SELECT 
        b.genre,
        b.title,
        SUM(o.quantity) AS total_sold,
        ROW_NUMBER() OVER (PARTITION BY b.genre ORDER BY SUM(o.quantity) DESC) AS rn
    FROM books b
    JOIN orders o ON b.book_id = o.book_id
    GROUP BY b.genre, b.title
) t
WHERE rn = 1;

/*Ranking the books by sales (Window Functions*/
SELECT 
    b.title,
    SUM(o.quantity) AS total_sold,
    RANK() OVER (ORDER BY SUM(o.quantity) DESC) AS rank_position
FROM books b
JOIN orders o ON b.book_id = o.book_id
GROUP BY b.title;

/*genre wise sales using cte*/
WITH genre_sales AS (
    SELECT b.genre, SUM(o.quantity) AS total_sold
    FROM books b
    JOIN orders o ON b.book_id = o.book_id
    GROUP BY b.genre
)

SELECT *
FROM genre_sales
ORDER BY total_sold DESC;


/*top customer based on total spending using cte*/
WITH customer_spending AS (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)

SELECT *
FROM customer_spending
ORDER BY total_spent DESC
LIMIT 5;
