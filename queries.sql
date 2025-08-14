-- Этот запрос считает общее количество покупателей из таблицы customers.
SELECT COUNT(*) AS customers_count

FROM customers;


-- Этот запрос выбирает 10 сотрудников с наибольшей 
суммарной выручкой и общим количеством проведённых
сделок.
-- Выручка рассчитывается путём умножения количества
проданных товаров на их цену. 
-- Результат сортируется по убыванию выручки.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
INNER JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id, seller
ORDER BY
    income DESC
LIMIT 10;


-- Этот запрос сначала вычисляет среднюю выручку за
сделку для каждого сотрудника.
-- Затем он сравнивает эту индивидуальную среднюю
выручку со средней выручкой за сделку по всем продажам
в базе данных.
-- Результат округляется до целого числа и сортируется
по средней выручке по возрастанию.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    -- Используем AVG() для средней выручки
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM
    employees AS e
INNER JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id, seller
HAVING
    AVG(s.quantity * p.price)
    < (
        SELECT AVG(sq.quantity * pr.price)
        FROM sales AS sq
        INNER JOIN products AS pr ON sq.product_id = pr.product_id
    )
ORDER BY
    average_income ASC;


-- Этот запрос рассчитывает общую выручку для каждого
сотрудника по каждому дню недели.
-- Выручка округляется до целого числа, и результаты
сортируются сначала по числовому значению дня недели, а
затем по имени продавца.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    employees AS e
INNER JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    seller,
    EXTRACT(ISODOW FROM s.sale_date),
    TO_CHAR(s.sale_date, 'Day')
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date),
    seller;


-- Этот запрос категоризирует покупателей по возрастным
группам. Затем он подсчитывает количество покупателей в
каждой группе.
SELECT
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
        ELSE 'Неизвестно' -- Обработка возможных значений вне указанных групп
    END AS age_category,
    COUNT(c.customer_id) AS age_count
FROM
    customers AS c
GROUP BY
    age_category
ORDER BY
    age_category;

-- Этот отчёт группирует данные по месяцам (в формате
"ГГГГ-ММ") и подсчитывает количество уникальных
    покупателей и общую выручку за каждый месяц.
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    -- Округление выручки до ближайшего целого числа
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month ASC;


-- Этот запрос находит покупателей, чья самая ранняя
покупка была совершена с ценой товара, равной 0 (что
указывает на акцию).
-- Для каждого такого покупателя будут отображены его
имя и фамилия, дата первой акционной покупки и имя
продавца, совершившего эту сделку.
SELECT DISTINCT ON (c.customer_id)
    s.sale_date,
    c.first_name || ' ' || c.last_name AS customer,
    e.first_name || ' ' || e.last_name AS seller
FROM
    customers AS c
INNER JOIN
    sales AS s
    ON c.customer_id = s.customer_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
INNER JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
WHERE
    p.price = 0
ORDER BY
    c.customer_id ASC, s.sale_date ASC
