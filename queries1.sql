-- Этот запрос считает общее количество покупателей из таблицы customers.
SELECT COUNT(*) AS customers_count

FROM customers;

-- Этот запрос выбирает 10 сотрудников с наибольшей суммарной выручкой и общим количеством проведённых сделок.
-- Выручка рассчитывается путём умножения количества проданных товаров на их цену. 
-- Результат сортируется по убыванию выручки.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    SUM(s.quantity * p.price) AS income
FROM
    employees e
JOIN
    sales s ON e.employee_id = s.sales_person_id
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
    FLOOR(SUM(s.quantity * p.price) / COUNT(s.sales_id)) AS average_income
FROM
    employees e
JOIN
    sales s ON e.employee_id = s.sales_person_id
JOIN
    products p ON s.product_id = p.product_id
GROUP BY
    e.employee_id, seller
HAVING
    (SUM(s.quantity * p.price) / COUNT(s.sales_id)) < (SELECT AVG(sq.quantity * pr.price) FROM sales sq JOIN products pr ON sq.product_id = pr.product_id)
ORDER BY
    average_income ASC;

-- Этот запрос рассчитывает общую выручку (количество проданного товара умноженное на его цену) для каждого сотрудника по каждому дню недели.
-- Выручка округляется до целого числа, и результаты сортируются сначала по числовому значению дня недели, а затем по имени продавца.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    CASE EXTRACT(DOW FROM s.sale_date)
        WHEN 0 THEN 'sunday'
        WHEN 1 THEN 'monday'
        WHEN 2 THEN 'tuesday'
        WHEN 3 THEN 'wednesday'
        WHEN 4 THEN 'thursday'
        WHEN 5 THEN 'friday'
        WHEN 6 THEN 'saturday'
    END AS day_of_week,
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
    EXTRACT(DOW FROM s.sale_date)
ORDER BY
    EXTRACT(DOW FROM s.sale_date),
    seller;
