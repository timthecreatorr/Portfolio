#ЗАДАНИЕ 1
# Создание базы данных
CREATE DATABASE AdStats;
USE AdStats;

CREATE TABLE users (
    date DATE NOT NULL,
    user_id CHAR(36) NOT NULL,
    view_adverts INT NOT NULL
);
 SELECT * FROM users;
 

#1/Напишите запрос SQL, выводящий одним числом количество уникальных пользователей в этой таблице в период с 2023-11-07 по 2023-11-15.
SELECT COUNT(DISTINCT user_id) AS unique_users
FROM users
WHERE date BETWEEN '2023-11-07' AND '2023-11-15';

#2/Определите пользователя, который за весь период посмотрел наибольшее количество объявлений. 
SELECT user_id, SUM(view_adverts) AS total_views
FROM users
GROUP BY user_id
ORDER BY total_views DESC
LIMIT 1;


#3/Определите день с наибольшим средним количеством просмотренных рекламных объявлений на пользователя, но учитывайте только дни с более чем 500 уникальными пользователями.
SELECT 
		date,
				AVG(view_adverts) AS avg_views_per_user
FROM users
GROUP BY date
HAVING COUNT(DISTINCT user_id) > 500
ORDER BY avg_views_per_user DESC
LIMIT 1;

#4/Напишите запрос возвращающий LT (продолжительность присутствия пользователя на сайте) по каждому пользователю. Отсортировать LT по убыванию.
SELECT 
    user_id,
    DATEDIFF(MAX(date), MIN(date)) AS LT
FROM users
GROUP BY user_id
ORDER BY LT DESC;

#5/Для каждого пользователя подсчитайте среднее количество просмотренной рекламы за день, а затем выясните, у кого самый высокий средний показатель среди тех, кто был активен как минимум в 5 разных дней.
SELECT 
		user_id,
				AVG(view_adverts) AS avg_ads_per_day
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM users
    GROUP BY user_id
    HAVING COUNT(DISTINCT date) >= 5
)
GROUP BY user_id
ORDER BY avg_ads_per_day DESC
LIMIT 1;


# ЗАДАНИЕ 2 
	# Создание базы данных
CREATE DATABASE mini_project;
USE mini_project;

# Создание таблицы T_TAB1
CREATE TABLE T_TAB1 (
    ID INT UNIQUE,
    GOODS_TYPE VARCHAR(50),
    QUANTITY INT,
    AMOUNT INT,
    SELLER_NAME VARCHAR(50)
);

# Заполнение таблицы T_TAB1 данными
INSERT INTO T_TAB1 (ID, GOODS_TYPE, QUANTITY, AMOUNT, SELLER_NAME)
VALUES
(1, 'MOBILE PHONE', 2, 400000, 'MIKE'),
(2, 'KEYBOARD', 1, 10000, 'MIKE'),
(3, 'MOBILE PHONE', 1, 50000, 'JANE'),
(4, 'MONITOR', 1, 110000, 'JOE'),
(5, 'MONITOR', 2, 80000, 'JANE'),
(6, 'MOBILE PHONE', 1, 130000, 'JOE'),
(7, 'MOBILE PHONE', 1, 60000, 'ANNA'),
(8, 'PRINTER', 1, 90000, 'ANNA'),
(9, 'KEYBOARD', 2, 10000, 'ANNA'),
(10, 'PRINTER', 1, 80000, 'MIKE');

# Создание таблицы T_TAB2
CREATE TABLE T_TAB2 (
    ID INT UNIQUE,
    NAME VARCHAR(50),
    SALARY INT,
    AGE INT
);

# Заполнение таблицы T_TAB2 данными
INSERT INTO T_TAB2 (ID, NAME, SALARY, AGE)
VALUES
(1, 'ANNA', 110000, 27),
(2, 'JANE', 80000, 25),
(3, 'MIKE', 120000, 25),
(4, 'JOE', 70000, 24),
(5, 'RITA', 120000, 29);

SELECT * FROM T_TAB1;
SELECT * FROM	T_TAB2;

#1/Напишите запрос, который вернёт список уникальных категорий товаров (GOODS_TYPE). Какое количество уникальных категорий товаров вернёт запрос?
# Список уникальных категорий товаров
SELECT DISTINCT GOODS_TYPE
FROM T_TAB1;

# Подсчёт количества уникальных категорий товаров
SELECT COUNT(DISTINCT GOODS_TYPE) AS unique_categories
FROM T_TAB1;

#2/Напишите запрос, который вернет суммарное количество и суммарную стоимость проданных мобильных телефонов. Какое суммарное количество и суммарную стоимость вернул запрос?
SELECT 
    SUM(QUANTITY) AS total_quantity,
    SUM(AMOUNT) AS total_amount
FROM T_TAB1
WHERE GOODS_TYPE = 'MOBILE PHONE';

#3/Напишите запрос, который вернёт список сотрудников с заработной платой > 100000. Какое кол-во сотрудников вернул запрос?
SELECT 
		NAME, 
				SALARY 
FROM T_TAB2
WHERE SALARY > 100000;

#4/Напишите запрос, который вернёт минимальный и максимальный возраст сотрудников, а также минимальную и максимальную заработную плату.
SELECT 
    MIN(AGE) AS Min_Age,
    MAX(AGE) AS Max_Age,
    MIN(SALARY) AS Min_Salary,
    MAX(SALARY) AS Max_Salary
FROM T_TAB2;

#5/Напишите запрос, который вернёт среднее количество проданных клавиатур и принтеров.
SELECT 
    AVG(QUANTITY) AS Avg_Quantity
FROM T_TAB1
WHERE GOODS_TYPE IN ('KEYBOARD', 'PRINTER');

#6/Напишите запрос, который вернёт имя сотрудника и суммарную стоимость проданных им товаров.
SELECT 
    T_TAB2.NAME AS Employee_Name, 
			SUM(T_TAB1.AMOUNT) AS Total_Sales
FROM T_TAB1
JOIN T_TAB2
ON T_TAB1.SELLER_NAME = T_TAB2.NAME
GROUP BY T_TAB2.NAME;

#7/Напишите запрос, который вернёт имя сотрудника, тип товара, кол-во товара, стоимость товара, заработную плату и возраст сотрудника MIKE.
SELECT 
    T_TAB2.NAME AS Employee_Name,
		T_TAB1.GOODS_TYPE AS Product_Type,
			T_TAB1.QUANTITY AS Quantity,
				T_TAB1.AMOUNT AS Product_Cost,
					T_TAB2.SALARY AS Salary,
						T_TAB2.AGE AS Age
FROM T_TAB1
JOIN T_TAB2 ON T_TAB1.SELLER_NAME = T_TAB2.NAME
WHERE T_TAB2.NAME = 'MIKE';

#8/Напишите запрос, который вернёт имя и возраст сотрудника, который ничего не продал. Сколько таких сотрудников
SELECT 
    T_TAB2.NAME AS Employee_Name, 
		T_TAB2.AGE AS Age,
			COUNT(*) OVER() AS Total_No_Sales_Employees
FROM T_TAB2
LEFT JOIN T_TAB1 ON T_TAB2.NAME = T_TAB1.SELLER_NAME
WHERE T_TAB1.SELLER_NAME IS NULL;


#9/Напишите запрос, который вернёт имя сотрудника и его заработную плату с возрастом меньше 26 лет? Какое количество строк вернул запрос?
SELECT 
    NAME AS Employee_Name, 
		SALARY AS Salary, 
			AGE AS Age
FROM T_TAB2
WHERE AGE < 26;
# ЗАПРОС ВЕРНУЛ 3 СТРОКИ 

#10/Сколько строк вернёт следующий запрос:
SELECT * FROM T_TAB1 t
JOIN T_TAB2 t2 ON t2.name = t.seller_name
WHERE t2.name = 'RITA';
# ОТВЕТ: Запрос вернет 0 строк.