CREATE DATABASE customers_transactions;
UPDATE customers SET Gender = NULL WHERE Gender ='';
UPDATE customers SET Age = NULL WHERE Age ='';
ALTER TABLE Customers MODIFY AGE INT NULL;

SELECT * FROM Transactions;

create table Transactions
(date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL (10,3),
Sum_payment DECIMAL (10,2));

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS_final.csv"
INTO TABLE Transactions
FIELDS TERMINATED  BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';



-- 1.0) клиенты с непрерывной историей за год (01.06.2015 — 01.06.2016) --
SELECT
    t.ID_client,
    COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) AS active_months
FROM
    transactions t
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    t.ID_client
HAVING
    active_months = 12;


-- 1.1) Средний чек клиента, Средняя сумма покупок в месяц, Количество операций за год --
WITH valid_clients AS (
    SELECT
        t.ID_client
    FROM
        transactions t
    WHERE
        t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY t.ID_client
    HAVING COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) = 12
)

SELECT
    t.ID_client,
    ROUND(AVG(t.Sum_payment), 2) AS avg_check,
    ROUND(SUM(t.Sum_payment)/12, 2) AS avg_monthly_payment,
    COUNT(*) AS total_operations
FROM
    transactions t
JOIN valid_clients vc ON vc.ID_client = t.ID_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    t.ID_client;


-- 2.0)Средняя сумма чека в месяц --
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    ROUND(AVG(Sum_payment), 2) AS avg_check
FROM
    transactions
WHERE
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month
ORDER BY
    month;

-- 2.1)Среднее количество операций в месяц --
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(*) AS operations
FROM
    transactions
WHERE
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month
ORDER BY
    month;

-- 2.2)Среднее количество клиентов, совершавших операции --
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(DISTINCT ID_client) AS active_clients
FROM
    transactions
WHERE
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month
ORDER BY
    month;

-- 2.3)Доля операций и суммы от общего объема --
WITH monthly_data AS (
    SELECT
        DATE_FORMAT(date_new, '%Y-%m') AS month,
        COUNT(*) AS monthly_ops,
        SUM(Sum_payment) AS monthly_sum
    FROM
        transactions
    WHERE
        date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY month
),
totals AS (
    SELECT
        COUNT(*) AS total_ops,
        SUM(Sum_payment) AS total_sum
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
)

SELECT
    m.month,
    m.monthly_ops,
    m.monthly_sum,
    ROUND(m.monthly_ops / t.total_ops * 100, 2) AS ops_share_pct,
    ROUND(m.monthly_sum / t.total_sum * 100, 2) AS sum_share_pct
FROM
    monthly_data m, totals t
ORDER BY
    m.month;

-- 2.4)Пол / Gender: M / F / NA + их доли по затратам по месяцам --
SELECT
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,
    c.Gender,
    COUNT(DISTINCT t.ID_client) AS clients_count,
    SUM(t.Sum_payment) AS total_payment,
    ROUND(SUM(t.Sum_payment) / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY DATE_FORMAT(t.date_new, '%Y-%m')) * 100, 2) AS payment_share_pct
FROM
    transactions t
JOIN
    customers c ON t.ID_client = c.Id_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month, c.Gender
ORDER BY
    month, c.Gender;

-- 2.5)Возрастные группы с шагом 10 лет + "NA", с суммой и количеством операций--
-- 2.5.1)За весь период:
SELECT
    CASE
        WHEN AGE IS NULL THEN 'NA'
        WHEN AGE BETWEEN 0 AND 9 THEN '00-09'
        WHEN AGE BETWEEN 10 AND 19 THEN '10-19'
        WHEN AGE BETWEEN 20 AND 29 THEN '20-29'
        WHEN AGE BETWEEN 30 AND 39 THEN '30-39'
        WHEN AGE BETWEEN 40 AND 49 THEN '40-49'
        WHEN AGE BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_operations,
    ROUND(SUM(t.Sum_payment), 2) AS total_payment
FROM
    transactions t
JOIN
    customers c ON t.ID_client = c.Id_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    age_group
ORDER BY
    age_group;

-- 2.5.2)Поквартально — средние значения и % --
SELECT
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,
    CASE
        WHEN AGE IS NULL THEN 'NA'
        WHEN AGE BETWEEN 0 AND 9 THEN '00-09'
        WHEN AGE BETWEEN 10 AND 19 THEN '10-19'
        WHEN AGE BETWEEN 20 AND 29 THEN '20-29'
        WHEN AGE BETWEEN 30 AND 39 THEN '30-39'
        WHEN AGE BETWEEN 40 AND 49 THEN '40-49'
        WHEN AGE BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS ops,
    ROUND(SUM(t.Sum_payment), 2) AS total,
    ROUND(SUM(t.Sum_payment) / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new))) * 100, 2) AS share_pct
FROM
    transactions t
JOIN
    customers c ON t.ID_client = c.Id_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    quarter, age_group
ORDER BY
    quarter, age_group;
