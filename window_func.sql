
-- №1
-- Задание:

-- Примените оконные функции к таблице products и с помощью ранжирующих функций упорядочьте все товары по цене — от самых дорогих к самым дешёвым. Добавьте в таблицу следующие колонки:

-- Колонку product_number с порядковым номером товара (функция ROW_NUMBER).
-- Колонку product_rank с рангом товара с пропусками рангов (функция RANK).
-- Колонку product_dense_rank с рангом товара без пропусков рангов (функция DENSE_RANK).
-- Не забывайте указывать в окне сортировку записей — без неё ранжирующие функции могут давать некорректный результат, если таблица заранее не отсортирована. Деление на партиции внутри окна сейчас не требуется. Сортировать записи в результирующей таблице тоже не нужно.

-- Поля в результирующей таблице: product_id, name, price, product_number, product_rank, product_dense_rank

SELECT 
    product_id,
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS product_number,
    RANK() OVER (ORDER BY price DESC) AS product_rank,
    DENSE_RANK() OVER (ORDER BY price DESC) AS product_dense_rank
FROM 
    products;

-- LIMIT 100;

-- №2
-- Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке для каждой записи проставьте цену самого дорогого товара. Колонку с этим значением назовите max_price.

-- Затем для каждого товара посчитайте долю его цены в стоимости самого дорогого товара — просто поделите одну колонку на другую. Полученные доли округлите до двух знаков после запятой. Колонку с долями назовите share_of_max.

-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.

-- Поля в результирующей таблице: product_id, name, price, max_price, share_of_max

SELECT 
    product_id,
    name,
    price,
    MAX(price) OVER () AS max_price,
    ROUND(price / MAX(price) OVER (), 2) AS share_of_max
FROM 
    products
ORDER BY 
    price DESC,
    product_id;



-- №3
-- Примените две оконные функции к таблице products. Одну с агрегирующей функцией MAX, а другую с агрегирующей функцией MIN — для вычисления максимальной и минимальной цены.
-- Для двух окон задайте инструкцию ORDER BY по убыванию цены. Поместите результат вычислений в две колонки max_price и min_price.

-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.

-- Поля в результирующей таблице: product_id, name, price, max_price, min_price

-- После того как решите задачу, проанализируйте полученный результат и подумайте, почему получились именно такие расчёты. 
-- При необходимости вернитесь к первому шагу и ещё раз внимательно ознакомьтесь с тем, как работает рамка окна при указании сортировки.

SELECT 
    product_id,
    name,
    price,
    MAX(price) OVER (ORDER BY price DESC) AS max_price,
    MIN(price) OVER (ORDER BY price DESC) AS min_price
FROM 
    products
ORDER BY 
    price DESC,
    product_id;

-- №4 
-- Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням. При подсчёте числа заказов 
-- не учитывайте отменённые заказы (их можно определить по таблице user_actions).
-- Колонку с днями назовите date, а колонку с числом заказов — orders_count.

-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией SUM для расчёта накопительной суммы числа заказов. 
-- Не забудьте для окна задать инструкцию ORDER BY по дате.

-- Колонку с накопительной суммой назовите orders_count_cumulative. В результате такой операции значение накопительной суммы для последнего дня должно получиться равным общему числу заказов за весь период.

-- Сортировку результирующей таблицы делать не нужно.

-- Поля в результирующей таблице: date, orders_count, orders_count_cumulative

SELECT 
    date,
    orders_count,
    (SUM(orders_count) OVER (ORDER BY date))::integer AS orders_count_cumulative
FROM 
    (
        SELECT 
            creation_time::date AS date,
            COUNT(DISTINCT order_id) AS orders_count
        FROM 
            orders
        WHERE 
            order_id NOT IN (
                SELECT order_id
                FROM   user_actions
                WHERE  action = 'cancel_order'
            )
        GROUP BY 
            creation_time::date
    ) t;





-- SELECT creation_time::DATE AS date, COUNT(DISTINCT order_id) AS orders_count 
-- FROM orders
-- WHERE order_id NOT IN (
-- SELECT order_id 
-- FROM user_actions
-- WHERE action = 'cancel_order'
-- )
-- GROUP BY
--     creation_time::DATE



-- SELECT action, COUNT( DISTINCT order_id)
-- FROM user_actions
-- GROUP BY
--      action
     
     
-- SELECT COUNT(DISTINCT order_id) FROM orders;

-- SELECT * FROM orders LIMIT 10;

-- №5

-- Для каждого пользователя в таблице user_actions посчитайте порядковый номер каждого заказа.

-- Для этого примените оконную функцию ROW_NUMBER, используйте id пользователей для деления на патриции, 
-- а время заказа для сортировки внутри патриции. Отменённые заказы не учитывайте.

-- Новую колонку с порядковым номером заказа назовите order_number. Результат отсортируйте сначала по возрастанию id пользователя, 
-- затем по возрастанию порядкового номера заказа.

-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

-- Поля в результирующей таблице: user_id, order_id, time, order_number


SELECT 
    user_id, 
    order_id, 
    time, 
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY time) AS order_number,
    LAG(time) OVER (PARTITION BY user_id ORDER BY time) AS time_lag,
    time - LAG(time) OVER (PARTITION BY user_id ORDER BY time) AS time_diff
FROM 
    user_actions
WHERE 
    order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
    )    
ORDER BY 
    user_id, 
    order_id    
LIMIT 1000;


-- №6
-- На основе запроса из предыдущего задания для каждого пользователя рассчитайте, сколько в среднем времени проходит между его заказами. 
-- Посчитайте этот показатель только для тех пользователей, которые за всё время оформили более одного неотмененного заказа.

-- Среднее время между заказами выразите в часах, округлив значения до целого числа.
-- Колонку со средним значением времени назовите hours_between_orders. Результат отсортируйте по возрастанию id пользователя.

-- Добавьте в запрос оператор LIMIT и включите в результат только первые 1000 записей.

-- Поля в результирующей таблице: user_id, hours_between_orders


WITH t AS (
    SELECT 
        user_id, 
        order_id, 
        time, 
        time - LAG(time) OVER (PARTITION BY user_id ORDER BY time) AS time_diff,
        COUNT(order_id) OVER (PARTITION BY user_id) AS count_orders
    FROM 
        user_actions
    WHERE 
        order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
    ORDER BY 
        user_id, 
        order_id
)

SELECT 
    user_id,
    (EXTRACT(EPOCH FROM AVG(time_diff)) / 3600 )::INTEGER AS hours_between_orders
FROM 
    t
WHERE 
    count_orders > 1
GROUP BY
    user_id
ORDER BY 
    user_id
LIMIT 1000;


-- №7    
-- Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням. Вы уже делали это в одной из предыдущих задач. При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions). Колонку с числом заказов назовите orders_count.

-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией AVG для расчёта скользящего среднего числа заказов. Скользящее среднее для каждой записи считайте по трём предыдущим дням. Подумайте, как правильно задать границы рамки, чтобы получить корректные расчёты.

-- Полученные значения скользящего среднего округлите до двух знаков после запятой. Колонку с рассчитанным показателем назовите moving_avg. Сортировку результирующей таблицы делать не нужно.

-- Поля в результирующей таблице: date, orders_count, moving_avg

WITH count_orders AS (
    SELECT 
        creation_time::DATE AS date, 
        COUNT(DISTINCT order_id) AS orders_count
    FROM 
        orders
    WHERE 
        order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
    GROUP BY 
        creation_time::DATE
    ORDER BY 
        date
)

SELECT 
    date, 
    orders_count,
    ROUND(AVG(orders_count) OVER (ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), 2) AS moving_avg
FROM 
    count_orders;




-- №8
-- Задание:

-- Отметьте в отдельной таблице тех курьеров, которые доставили в сентябре 2022 года заказов больше, чем в среднем все курьеры.

-- Сначала для каждого курьера в таблице courier_actions рассчитайте общее количество доставленных в сентябре заказов. 
-- Затем в отдельном столбце с помощью оконной функции укажите, сколько в среднем заказов доставили в этом месяце все курьеры. 
-- После этого сравните число заказов, доставленных каждым курьером, со средним значением в новом столбце. 
-- Если курьер доставил больше заказов, чем в среднем все курьеры, то в отдельном столбце с помощью CASE укажите число 1, в противном случае укажите 0.

-- Колонку с результатом сравнения назовите is_above_avg, колонку с числом доставленных заказов каждым курьером — delivered_orders, а колонку со средним значением — avg_delivered_orders.
-- При расчёте среднего значения округлите его до двух знаков после запятой. Результат отсортируйте по возрастанию id курьера.

-- Поля в результирующей таблице: courier_id, delivered_orders, avg_delivered_orders, is_above_avg


-- Первый запрос:
SELECT 
    courier_id, 
    COUNT(DISTINCT order_id) AS delivered_orders,
    ROUND(AVG(COUNT(DISTINCT order_id)) OVER(), 2) AS avg_delivered_orders,
    CASE
        WHEN COUNT(DISTINCT order_id) > AVG(COUNT(DISTINCT order_id)) OVER() THEN 1
        ELSE 0
    END AS is_above_avg
FROM 
    courier_actions
WHERE 
    EXTRACT(MONTH FROM time::DATE) = 9 
    AND action = 'deliver_order'
GROUP BY 
    courier_id;

-- Второй запрос:
SELECT 
    courier_id, 
    delivered_orders,
    AVG(delivered_orders) OVER() AS avg_delivered_orders,
    CASE
        WHEN delivered_orders > ROUND(AVG(delivered_orders) OVER(), 2) THEN 1
        ELSE 0
    END AS is_above_avg
FROM 
    (
        SELECT 
            courier_id, 
            COUNT(DISTINCT order_id) AS delivered_orders
        FROM 
            courier_actions
        WHERE 
            EXTRACT(MONTH FROM time::DATE) = 9 
            AND action = 'deliver_order'
        GROUP BY 
            courier_id
    ) t;



-- №9
-- Задание:

-- По данным таблицы user_actions посчитайте число первых и повторных заказов на каждую дату.

-- Для этого сначала с помощью оконных функций и оператора CASE сформируйте таблицу, в которой напротив каждого заказа будет стоять отметка «Первый» или «Повторный» (без кавычек). 
-- Для каждого пользователя первым заказом будет тот, который был сделан раньше всего. Все остальные заказы должны попасть, соответственно, в категорию «Повторный». 
-- Затем на каждую дату посчитайте число заказов каждой категории.
-- Колонку с типом заказа назовите order_type, колонку с датой — date, колонку с числом заказов — orders_count.
-- В расчётах учитывайте только неотменённые заказы.
-- Результат отсортируйте сначала по возрастанию даты, затем по возрастанию значений в колонке с типом заказа.
-- Поля в результирующей таблице: date, order_type, orders_count

WITH type AS (
    SELECT 
        time::DATE AS date, 
        user_id, 
        order_id,
        CASE
            WHEN order_id = FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Первый'
            WHEN order_id != FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Повторный'
        END AS order_type
    FROM 
        user_actions
    WHERE 
        order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
)

SELECT 
    date, 
    order_type,
    COUNT(order_id) AS orders_count
FROM 
    type
GROUP BY 
    date, 
    order_type
ORDER BY 
    date, 
    order_type;



-- №10
-- К запросу, полученному на предыдущем шаге, примените оконную функцию и для каждого дня посчитайте долю первых и повторных заказов. 
-- Сохраните структуру полученной ранее таблицы и добавьте только одну новую колонку с посчитанными значениями.

-- Колонку с долей заказов каждой категории назовите orders_share. Значения в полученном столбце округлите до двух знаков после запятой.
-- В результат также включите количество заказов в группах, посчитанное на предыдущем шаге.

-- В расчётах по-прежнему учитывайте только неотменённые заказы.

-- Результат отсортируйте сначала по возрастанию даты, затем по возрастанию значений в колонке с типом заказа.

-- Поля в результирующей таблице: date, order_type, orders_count, orders_share


WITH type AS (
    SELECT 
        time::DATE AS date, 
        user_id, 
        order_id,
        CASE
            WHEN order_id = FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Первый'
            WHEN order_id != FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Повторный'
        END AS order_type
    FROM 
        user_actions
    WHERE 
        order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
)

SELECT 
    date,
    order_type,
    COUNT(order_id) AS orders_count,
    ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER (PARTITION BY date), 2) AS orders_share
FROM 
    type
GROUP BY 
    date, 
    order_type
ORDER BY 
    date, 
    order_type;



-- №10
-- Задание:
-- Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке для каждой записи проставьте среднюю цену всех товаров. 
-- Колонку с этим значением назовите avg_price.
-- Затем с помощью оконной функции и оператора FILTER в отдельной колонке рассчитайте среднюю цену товаров без учёта самого дорогого.
-- Колонку с этим средним значением назовите avg_price_filtered. Полученные средние значения в колонках avg_price и avg_price_filtered округлите до двух знаков после запятой.
-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, avg_price, avg_price_filtered



SELECT 
    product_id, 
    name, 
    price,
    ROUND(AVG(price) OVER (), 2) AS avg_price,
    ROUND(AVG(price) FILTER (WHERE price != (SELECT MAX(price) FROM products)) OVER (), 2) AS avg_price_filtered
FROM 
    products
ORDER BY 
    price DESC, 
    product_id;



-- №11
-- А теперь ещё одна задача на фильтрацию по окну — в этот раз посложнее.

-- Задание:
-- Для каждой записи в таблице user_actions с помощью оконных функций и предложения FILTER посчитайте, сколько заказов сделал и сколько отменил каждый пользователь на момент совершения нового действия.
-- Иными словами, для каждого пользователя в каждый момент времени посчитайте две накопительные суммы — числа оформленных и числа отменённых заказов.
-- Если пользователь оформляет заказ, то число оформленных им заказов увеличивайте на 1, если отменяет — увеличивайте на 1 количество отмен.
-- Колонки с накопительными суммами числа оформленных и отменённых заказов назовите соответственно created_orders и canceled_orders. 
-- На основе этих двух колонок для каждой записи пользователя посчитайте показатель cancel_rate, т.е. долю отменённых заказов в общем количестве оформленных заказов. 
-- Значения показателя округлите до двух знаков после запятой. Колонку с ним назовите cancel_rate.
-- В результате у вас должны получиться три новые колонки с динамическими показателями, которые изменяются во времени с каждым новым действием пользователя.
-- В результирующей таблице отразите все колонки из исходной таблицы вместе с новыми колонками. Отсортируйте результат по колонкам user_id, order_id, time — по возрастанию значений в каждой.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице:
-- user_id, order_id, action, time, created_orders, canceled_orders, cancel_rate

SELECT user_id, order_id, action, time, created_orders, canceled_orders,
ROUND(canceled_orders::NUMERIC/ created_orders, 2)  AS cancel_rate
FROM
    (SELECT user_id,order_id,action,time,
    COUNT(order_id) FILTER(WHERE action = 'create_order') OVER (PARTITION BY user_id ORDER BY time) AS created_orders,
    COUNT(order_id) FILTER(WHERE action = 'cancel_order') OVER (PARTITION BY user_id  ORDER BY time) AS canceled_orders
    FROM user_actions) AS t
ORDER BY user_id, order_id, time
LIMIT 1000;


-- №14
-- Из таблицы courier_actions отберите топ 10% курьеров по количеству доставленных за всё время заказов. 
-- Выведите id курьеров, количество доставленных заказов и порядковый номер курьера в соответствии с числом доставленных заказов.

-- У курьера, доставившего наибольшее число заказов, порядковый номер должен быть равен 1,
-- а у курьера с наименьшим числом заказов — числу, равному десяти процентам от общего количества курьеров в таблице courier_actions.

-- При расчёте номера последнего курьера округляйте значение до целого числа.

-- Колонки с количеством доставленных заказов и порядковым номером назовите соответственно orders_count и courier_rank. 
-- Результат отсортируйте по возрастанию порядкового номера курьера.

-- Поля в результирующей таблице: courier_id, orders_count, courier_rank 

-- SELECT * FROM courier_actions LIMIT 10;


WITH rank_courier AS (
    SELECT 
        courier_id, 
        orders_count,
        ROW_NUMBER() OVER (ORDER BY orders_count DESC, courier_id) AS courier_rank
    FROM 
        (
            SELECT 
                courier_id, 
                COUNT(DISTINCT order_id) AS orders_count
            FROM 
                courier_actions
            WHERE 
                action = 'deliver_order'
            GROUP BY 
                courier_id
        ) t
)

SELECT 
    courier_id, 
    orders_count, 
    courier_rank
FROM 
    rank_courier
WHERE 
    courier_rank <= ROUND(0.1 * (SELECT COUNT(*) FROM rank_courier));


-- №15
-- С помощью оконной функции отберите из таблицы courier_actions всех курьеров, которые работают в нашей компании 10 и более дней.
-- Также рассчитайте, сколько заказов они уже успели доставить за всё время работы.

-- Будем считать, что наш сервис предлагает самые выгодные условия труда и поэтому за весь анализируемый период ни один курьер не уволился из компании.
-- Возможные перерывы между сменами не учитывайте — для нас важна только разница во времени между первым действием курьера и текущей отметкой времени.

-- Текущей отметкой времени, относительно которой необходимо рассчитывать продолжительность работы курьера, считайте время последнего действия в таблице courier_actions.
-- Учитывайте только целые дни, прошедшие с момента первого выхода курьера на работу (часы и минуты не учитывайте).

-- В результат включите три колонки: id курьера, продолжительность работы в днях и число доставленных заказов. 
-- Две новые колонки назовите соответственно days_employed и delivered_orders. Результат отсортируйте сначала по убыванию количества отработанных дней, затем по возрастанию id курьера.

-- Поля в результирующей таблице: courier_id, days_employed, delivered_orders

WITH courier_data AS (
    SELECT
        courier_id,
        MIN(time) OVER (PARTITION BY courier_id) AS first_action_time,
        MAX(time) OVER () AS last_action_time,
        COUNT(*) FILTER (WHERE action = 'deliver_order') OVER (PARTITION BY courier_id) AS delivered_orders
    FROM
        courier_actions
),
courier_duration AS (
    SELECT
        courier_id,
        DATE_PART('day', last_action_time - first_action_time) AS days_employed,
        delivered_orders
    FROM
        courier_data
    GROUP BY
        courier_id, first_action_time, last_action_time, delivered_orders
)
SELECT
    courier_id,
    days_employed,
    delivered_orders
FROM
    courier_duration
WHERE
    days_employed >= 10
ORDER BY
    days_employed DESC,
    courier_id ASC;


WITH t AS
(SELECT courier_id, MIN(time::date)  AS min_day,
MAX(time::date) AS max_day,
MAX(time::date) - MIN(time::date  AS days_employed,
COUNT(DISTINCT order_id) FILTER (WHERE action = 'deliver_order'))AS delivered_orders
FROM courier_actions
GROUP BY
    courier_id
HAVING MAX(time::date) - MIN(time::date) >= 10) 
SELECT courier_id, days_employed, delivered_orders
FROM t
ORDER BY days_employed DESC, courier_id

-- №16
-- На основе информации в таблицах orders и products рассчитайте стоимость каждого заказа, ежедневную выручку сервиса и долю 
-- стоимости каждого заказа в ежедневной выручке, выраженную в процентах. В результат включите следующие колонки: id заказа, время создания заказа,
-- стоимость заказа, выручку за день, в который был совершён заказ, а также долю стоимости заказа в выручке за день, выраженную в процентах.

-- При расчёте долей округляйте их до трёх знаков после запятой.

-- Результат отсортируйте сначала по убыванию даты совершения заказа (именно даты, а не времени), 
-- потом по убыванию доли заказа в выручке за день, затем по возрастанию id заказа.

-- При проведении расчётов отменённые заказы не учитывайте.

-- Поля в результирующей таблице:

-- order_id, creation_time, order_price, daily_revenue, percentage_of_daily_revenue

WITH t AS (
    SELECT 
        creation_time,
        order_id, 
        UNNEST(product_ids) AS product_id
    FROM 
        orders 
    WHERE order_id NOT IN (
        SELECT order_id 
        FROM user_actions 
        WHERE action = 'cancel_order'
    )   
),
tt AS (
    SELECT 
        creation_time, 
        order_id, 
        SUM(price) AS order_price
    FROM t
    JOIN products ON t.product_id = products.product_id
    GROUP BY creation_time, order_id
)
SELECT 
    order_id, 
    creation_time, 
    order_price,
    SUM(order_price) OVER (PARTITION BY creation_time::DATE) AS daily_revenue,
    ROUND((order_price / SUM(order_price) OVER (PARTITION BY creation_time::DATE))*100,3) AS percentage_of_daily_revenue
FROM tt
ORDER BY 
    creation_time::DATE DESC, 
    percentage_of_daily_revenue DESC, 
    order_id ASC;


-- Задачи на JOIN
-- Объедините таблицы user_actions и users по ключу user_id. 
-- В результат включите две колонки с user_id из обеих таблиц.
-- Эти две колонки назовите соответственно user_id_left и user_id_right.
-- Также в результат включите колонки order_id, time, action, sex, birth_date. 
-- Отсортируйте получившуюся таблицу по возрастанию id пользователя (в любой из двух колонок с id).
-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT COUNT(DISTINCT a.user_id) AS users_count 
FROM user_actions a
JOIN users b USING(user_id);

SELECT COUNT (DISTINCT user_id) FROM user_actions;
SELECT COUNT (user_id) FROM users;

SELECT a.user_id user_id_left,b.user_id user_id_right,  order_id, time, action, sex, birth_date
FROM user_actions a
LEFT JOIN users b USING(user_id)
WHERE b.user_id IS NOT NULL
ORDER BY user_id_left;

SELECT a.birth_date AS users_birth_date,users_count,b.birth_date AS couriers_birth_date, couriers_count
FROM (
    SELECT birth_date, COUNT(user_id) AS users_count
    FROM users
    WHERE birth_date IS NOT NULL
    GROUP BY birth_date
) AS a
FULL JOIN
(
    SELECT birth_date, COUNT(courier_id) AS couriers_count
    FROM couriers
    WHERE birth_date IS NOT NULL
    GROUP BY birth_date
) AS b
ON a.birth_date = b.birth_date
ORDER BY users_birth_date, couriers_birth_date



SELECT COUNT(birth_date) AS dates_count
FROM
(SELECT birth_date
FROM users
WHERE birth_date IS NOT NULL
UNION ALL
SELECT birth_date
FROM couriers
WHERE birth_date IS NOT NULL) AS subquery




-- Задача 17.
-- Задание:

-- На основе информации в таблицах orders и products рассчитайте ежедневную выручку сервиса и отразите 
-- её в колонке daily_revenue. Затем с помощью оконных функций и функций смещения посчитайте ежедневный прирост выручки. 
-- Прирост выручки отразите как в абсолютных значениях, так и в % относительно предыдущего дня. 
-- Колонку с абсолютным приростом назовите revenue_growth_abs, а колонку с относительным — revenue_growth_percentage.
-- Для самого первого дня укажите прирост равным 0 в обеих колонках. 
-- При проведении расчётов отменённые заказы не учитывайте. Результат отсортируйте по колонке с датами по возрастанию.
-- Метрики daily_revenue, revenue_growth_abs, revenue_growth_percentage округлите до одного знака при помощи ROUND().
-- Поля в результирующей таблице: date, daily_revenue, revenue_growth_abs, revenue_growth_percentage


WITH filtered_orders AS (
    SELECT 
        creation_time,
        order_id, 
        UNNEST(product_ids) AS product_id
    FROM orders
    WHERE order_id NOT IN (
        SELECT order_id 
        FROM user_actions 
        WHERE action = 'cancel_order'
    )   
),
order_prices AS (
    SELECT 
        creation_time, 
        order_id, 
        SUM(price) AS order_price
    FROM filtered_orders
    JOIN products 
        ON filtered_orders.product_id = products.product_id
    GROUP BY creation_time, order_id
),
daily_revenue_table AS (
    SELECT 
        creation_time::DATE AS creation_date, 
        ROUND(SUM(order_price), 1) AS daily_revenue
    FROM order_prices
    GROUP BY creation_date
),
revenue_with_growth_abs AS (
    SELECT 
        creation_date AS date,
        daily_revenue,
        CASE
            WHEN daily_revenue - LAG(daily_revenue, 1) OVER (ORDER BY creation_date) IS NULL THEN 0
            ELSE ROUND(daily_revenue - LAG(daily_revenue, 1) OVER (ORDER BY creation_date), 1)
        END AS revenue_growth_abs
    FROM daily_revenue_table
)
SELECT 
    date,
    daily_revenue,
    revenue_growth_abs,
    CASE
        WHEN revenue_growth_abs / LAG(daily_revenue) OVER (ORDER BY date) IS NULL THEN 0
        ELSE ROUND(revenue_growth_abs / LAG(daily_revenue) OVER (ORDER BY date) * 100, 1)
    END AS  revenue_growth_percentage
FROM revenue_with_growth_abs
ORDER BY date;

-- Задача 18

-- С помощью оконной функции рассчитайте медианную стоимость всех заказов из таблицы orders, 
-- оформленных в нашем сервисе. В качестве результата выведите одно число. Колонку с ним назовите median_price. 
-- Отменённые заказы не учитывайте.
-- Поле в результирующей таблице: median_price

WITH ordered_values AS (
    SELECT 
        order_price,
        ROW_NUMBER() OVER (ORDER BY order_price) AS rank,
        COUNT(order_id) OVER () AS total_count
    FROM 
    (SELECT 
        order_id, 
        SUM(price) AS order_price
    FROM (
        SELECT 
            order_id, 
            UNNEST(product_ids) AS product_id
        FROM orders
        WHERE order_id NOT IN (
            SELECT order_id 
            FROM user_actions 
            WHERE action = 'cancel_order'
        )
    )AS filtered_orders
    JOIN products 
        ON filtered_orders.product_id = products.product_id
    GROUP BY 
            order_id    
    ) AS order_prices
)
-- SELECT order_price, rank, total_count
-- FROM ordered_values;
        
SELECT 
    CASE
        WHEN total_count / 2 != 0 THEN 
            (SELECT order_price FROM ordered_values WHERE rank = (total_count + 1) / 2)
        ELSE 
            (SELECT AVG(order_price) 
             FROM ordered_values 
             WHERE rank IN (total_count / 2, (total_count / 2) + 1))
    END AS median_price
FROM 
    ordered_values
LIMIT 1;




