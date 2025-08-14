-- Этот запрос считает общее количество покупателей из таблицы customers.
SELECT COUNT(*) AS customers_count
FROM customers;

-- Этот запрос выбирает 10 сотрудников с наибольшей суммарной выручкой и общим количеством проведённых сделок.
-- Выручка рассчитывается путём умножения количества проданных товаров на их цену. 
-- Результат сортируется по убыванию выручки.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales s
JOIN
    employees e ON s.sales_person_id = e.employee_id
JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    e.employee_id, seller
ORDER BY
    income DESC
LIMIT 10;

-- Этот запрос сначала вычисляет среднюю выручку за сделку для каждого сотрудника (общая сумма продаж, делённая на количество совершённых им продаж).
-- Затем он сравнивает эту индивидуальную среднюю выручку со средней выручкой за сделку по всем продажам в базе данных.
-- Результат округляется до целого числа и сортируется по средней выручке по возрастанию.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income -- Используем AVG() для средней выручки
FROM
    employees e
JOIN
    sales s ON e.employee_id = s.sales_person_id
JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    e.employee_id, seller
HAVING
    AVG(s.quantity * p.price) < (SELECT AVG(sq.quantity * pr.price) FROM sales sq JOIN products pr ON sq.product_id = pr.product_id)
ORDER BY
    average_income ASC;

-- Этот запрос рассчитывает общую выручку (количество проданного товара умноженное на его цену) для каждого сотрудника по каждому дню недели.
-- Выручка округляется до целого числа, и результаты сортируются сначала по числовому значению дня недели, а затем по имени продавца.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week, 
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    employees e
JOIN
    sales s ON e.employee_id = s.sales_person_id
JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    seller,
    EXTRACT(ISODOW FROM s.sale_date), 
    TO_CHAR(s.sale_date, 'Day') 
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date), 
    seller;

-- Этот запрос категоризирует покупателей по возрастным группам: "16-25", "26-40" и "40+". 
-- Затем он подсчитывает количество покупателей в каждой группе.
SELECT
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
        ELSE 'Неизвестно' -- Обработка возможных значений вне указанных групп
    END AS age_category,
    COUNT(c.customer_id) AS age_count
FROM
    customers c
GROUP BY
    age_category
ORDER BY
    age_category;

-- Этот отчёт группирует данные по месяцам (в формате "ГГГГ-ММ") и подсчитывает количество уникальных покупателей и общую выручку за каждый месяц.
-- Выручка рассчитывается как сумма quantity * price для каждой продажи
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income -- Округление выручки до ближайшего целого числа
FROM
    sales s
JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month ASC;

-- Этот запрос находит покупателей, чья самая ранняя покупка была совершена с ценой товара, равной 0 (что указывает на акцию).
-- Для каждого такого покупателя будут отображены его имя и фамилия, дата первой акционной покупки и имя продавца, совершившего эту сделку.
-- Необходимо использовать оператор DISTINCT, чтобы выбрать уникальные комбинации.
SELECT DISTINCT ON (c.customer_id)
    c.first_name || ' ' || c.last_name AS customer,
    s.sale_date AS sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM
    customers c
JOIN
    sales s ON c.customer_id = s.customer_id
JOIN
    products p ON s.product_id = p.product_id
JOIN
    employees e ON s.sales_person_id = e.employee_id
WHERE
    p.price = 0
ORDER BY
    c.customer_id, s.sale_date ASC
