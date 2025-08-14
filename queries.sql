-- Запрос считает общее количество покупателей.
SELECT
    COUNT(*) AS customers_count
FROM
    customers;

---

-- Запрос выбирает 10 сотрудников с наибольшей выручкой и общим количеством сделок.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    seller
ORDER BY
    income DESC
LIMIT 10;

---

-- Запрос сначала вычисляет среднюю выручку за сделку для каждого сотрудника.
-- Сравнивает среднюю выручку со средней выручкой за сделку по всем продажам.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM
    employees AS e
JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    seller
HAVING
    AVG(s.quantity * p.price) < (
        SELECT
            AVG(sq.quantity * pr.price)
        FROM
            sales AS sq
        JOIN
            products AS pr
            ON sq.product_id = pr.product_id
    )
ORDER BY
    average_income ASC;

---

-- Запрос рассчитывает общую выручку для каждого сотрудника по каждому дню недели.
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    employees AS e
JOIN
    sales AS s
    ON e.employee_id = s.sales_person_id
JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    seller,
    EXTRACT(ISODOW FROM s.sale_date),
    TO_CHAR(s.sale_date, 'Day')
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date) ASC,
    seller ASC;

---

-- Этот запрос категоризирует покупателей по возрастным группам.
-- Затем он подсчитывает количество покупателей в каждой группе.
SELECT
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        WHEN c.age > 40 THEN '40+'
        ELSE 'Неизвестно'
    END AS age_category,
    COUNT(c.customer_id) AS age_count
FROM
    customers AS c
GROUP BY
    age_category
ORDER BY
    age_category;

---

-- Отчёт подсчитывает количество уникальных покупателей и общую выручку за месяц.
-- Выручка рассчитывается как сумма quantity * price для каждой продажи
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month ASC;

---

-- Запрос находит покупателей, чья самая ранняя покупка была совершена по акции.
SELECT DISTINCT ON (c.customer_id)
    c.first_name || ' ' || c.last_name AS customer,
    s.sale_date AS sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM
    customers AS c
JOIN
    sales AS s
    ON c.customer_id = s.customer_id
JOIN
    products AS p
    ON s.product_id = p.product_id
JOIN
    employees AS e
    ON s.sales_person_id = e.employee_id
WHERE
    p.price = 0
ORDER BY
    c.customer_id ASC, -- AM03: Указание направления сортировки
    s.sale_date ASC;
