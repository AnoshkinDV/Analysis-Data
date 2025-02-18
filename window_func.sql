{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "\n",
    "-- №1\n",
    "-- Задание:\n",
    "\n",
    "-- Примените оконные функции к таблице products и с помощью ранжирующих функций упорядочьте все товары по цене — от самых дорогих к самым дешёвым. Добавьте в таблицу следующие колонки:\n",
    "\n",
    "-- Колонку product_number с порядковым номером товара (функция ROW_NUMBER).\n",
    "-- Колонку product_rank с рангом товара с пропусками рангов (функция RANK).\n",
    "-- Колонку product_dense_rank с рангом товара без пропусков рангов (функция DENSE_RANK).\n",
    "-- Не забывайте указывать в окне сортировку записей — без неё ранжирующие функции могут давать некорректный результат, если таблица заранее не отсортирована. Деление на партиции внутри окна сейчас не требуется. Сортировать записи в результирующей таблице тоже не нужно.\n",
    "\n",
    "-- Поля в результирующей таблице: product_id, name, price, product_number, product_rank, product_dense_rank\n",
    "\n",
    "SELECT \n",
    "    product_id,\n",
    "    name,\n",
    "    price,\n",
    "    ROW_NUMBER() OVER (ORDER BY price DESC) AS product_number,\n",
    "    RANK() OVER (ORDER BY price DESC) AS product_rank,\n",
    "    DENSE_RANK() OVER (ORDER BY price DESC) AS product_dense_rank\n",
    "FROM \n",
    "    products;\n",
    "\n",
    "-- LIMIT 100;\n",
    "\n",
    "-- №2\n",
    "-- Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке для каждой записи проставьте цену самого дорогого товара. Колонку с этим значением назовите max_price.\n",
    "\n",
    "-- Затем для каждого товара посчитайте долю его цены в стоимости самого дорогого товара — просто поделите одну колонку на другую. Полученные доли округлите до двух знаков после запятой. Колонку с долями назовите share_of_max.\n",
    "\n",
    "-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.\n",
    "\n",
    "-- Поля в результирующей таблице: product_id, name, price, max_price, share_of_max\n",
    "\n",
    "SELECT \n",
    "    product_id,\n",
    "    name,\n",
    "    price,\n",
    "    MAX(price) OVER () AS max_price,\n",
    "    ROUND(price / MAX(price) OVER (), 2) AS share_of_max\n",
    "FROM \n",
    "    products\n",
    "ORDER BY \n",
    "    price DESC,\n",
    "    product_id;\n",
    "\n",
    "\n",
    "\n",
    "-- №3\n",
    "-- Примените две оконные функции к таблице products. Одну с агрегирующей функцией MAX, а другую с агрегирующей функцией MIN — для вычисления максимальной и минимальной цены.\n",
    "-- Для двух окон задайте инструкцию ORDER BY по убыванию цены. Поместите результат вычислений в две колонки max_price и min_price.\n",
    "\n",
    "-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.\n",
    "\n",
    "-- Поля в результирующей таблице: product_id, name, price, max_price, min_price\n",
    "\n",
    "-- После того как решите задачу, проанализируйте полученный результат и подумайте, почему получились именно такие расчёты. \n",
    "-- При необходимости вернитесь к первому шагу и ещё раз внимательно ознакомьтесь с тем, как работает рамка окна при указании сортировки.\n",
    "\n",
    "SELECT \n",
    "    product_id,\n",
    "    name,\n",
    "    price,\n",
    "    MAX(price) OVER (ORDER BY price DESC) AS max_price,\n",
    "    MIN(price) OVER (ORDER BY price DESC) AS min_price\n",
    "FROM \n",
    "    products\n",
    "ORDER BY \n",
    "    price DESC,\n",
    "    product_id;\n",
    "\n",
    "-- №4 \n",
    "-- Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням. При подсчёте числа заказов \n",
    "-- не учитывайте отменённые заказы (их можно определить по таблице user_actions).\n",
    "-- Колонку с днями назовите date, а колонку с числом заказов — orders_count.\n",
    "\n",
    "-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией SUM для расчёта накопительной суммы числа заказов. \n",
    "-- Не забудьте для окна задать инструкцию ORDER BY по дате.\n",
    "\n",
    "-- Колонку с накопительной суммой назовите orders_count_cumulative. В результате такой операции значение накопительной суммы для последнего дня должно получиться равным общему числу заказов за весь период.\n",
    "\n",
    "-- Сортировку результирующей таблицы делать не нужно.\n",
    "\n",
    "-- Поля в результирующей таблице: date, orders_count, orders_count_cumulative\n",
    "\n",
    "SELECT \n",
    "    date,\n",
    "    orders_count,\n",
    "    (SUM(orders_count) OVER (ORDER BY date))::integer AS orders_count_cumulative\n",
    "FROM \n",
    "    (\n",
    "        SELECT \n",
    "            creation_time::date AS date,\n",
    "            COUNT(DISTINCT order_id) AS orders_count\n",
    "        FROM \n",
    "            orders\n",
    "        WHERE \n",
    "            order_id NOT IN (\n",
    "                SELECT order_id\n",
    "                FROM   user_actions\n",
    "                WHERE  action = 'cancel_order'\n",
    "            )\n",
    "        GROUP BY \n",
    "            creation_time::date\n",
    "    ) t;\n",
    "\n",
    "\n",
    "\n",
    "\n",
    "\n",
    "-- SELECT creation_time::DATE AS date, COUNT(DISTINCT order_id) AS orders_count \n",
    "-- FROM orders\n",
    "-- WHERE order_id NOT IN (\n",
    "-- SELECT order_id \n",
    "-- FROM user_actions\n",
    "-- WHERE action = 'cancel_order'\n",
    "-- )\n",
    "-- GROUP BY\n",
    "--     creation_time::DATE\n",
    "\n",
    "\n",
    "\n",
    "-- SELECT action, COUNT( DISTINCT order_id)\n",
    "-- FROM user_actions\n",
    "-- GROUP BY\n",
    "--      action\n",
    "     \n",
    "     \n",
    "-- SELECT COUNT(DISTINCT order_id) FROM orders;\n",
    "\n",
    "-- SELECT * FROM orders LIMIT 10;\n",
    "\n",
    "-- №5\n",
    "\n",
    "-- Для каждого пользователя в таблице user_actions посчитайте порядковый номер каждого заказа.\n",
    "\n",
    "-- Для этого примените оконную функцию ROW_NUMBER, используйте id пользователей для деления на патриции, \n",
    "-- а время заказа для сортировки внутри патриции. Отменённые заказы не учитывайте.\n",
    "\n",
    "-- Новую колонку с порядковым номером заказа назовите order_number. Результат отсортируйте сначала по возрастанию id пользователя, \n",
    "-- затем по возрастанию порядкового номера заказа.\n",
    "\n",
    "-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.\n",
    "\n",
    "-- Поля в результирующей таблице: user_id, order_id, time, order_number\n",
    "\n",
    "\n",
    "SELECT \n",
    "    user_id, \n",
    "    order_id, \n",
    "    time, \n",
    "    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY time) AS order_number,\n",
    "    LAG(time) OVER (PARTITION BY user_id ORDER BY time) AS time_lag,\n",
    "    time - LAG(time) OVER (PARTITION BY user_id ORDER BY time) AS time_diff\n",
    "FROM \n",
    "    user_actions\n",
    "WHERE \n",
    "    order_id NOT IN (\n",
    "        SELECT order_id\n",
    "        FROM user_actions\n",
    "        WHERE action = 'cancel_order'\n",
    "    )    \n",
    "ORDER BY \n",
    "    user_id, \n",
    "    order_id    \n",
    "LIMIT 1000;\n",
    "\n",
    "\n",
    "-- №6\n",
    "-- На основе запроса из предыдущего задания для каждого пользователя рассчитайте, сколько в среднем времени проходит между его заказами. \n",
    "-- Посчитайте этот показатель только для тех пользователей, которые за всё время оформили более одного неотмененного заказа.\n",
    "\n",
    "-- Среднее время между заказами выразите в часах, округлив значения до целого числа.\n",
    "-- Колонку со средним значением времени назовите hours_between_orders. Результат отсортируйте по возрастанию id пользователя.\n",
    "\n",
    "-- Добавьте в запрос оператор LIMIT и включите в результат только первые 1000 записей.\n",
    "\n",
    "-- Поля в результирующей таблице: user_id, hours_between_orders\n",
    "\n",
    "\n",
    "WITH t AS (\n",
    "    SELECT \n",
    "        user_id, \n",
    "        order_id, \n",
    "        time, \n",
    "        time - LAG(time) OVER (PARTITION BY user_id ORDER BY time) AS time_diff,\n",
    "        COUNT(order_id) OVER (PARTITION BY user_id) AS count_orders\n",
    "    FROM \n",
    "        user_actions\n",
    "    WHERE \n",
    "        order_id NOT IN (\n",
    "            SELECT order_id\n",
    "            FROM user_actions\n",
    "            WHERE action = 'cancel_order'\n",
    "        )\n",
    "    ORDER BY \n",
    "        user_id, \n",
    "        order_id\n",
    ")\n",
    "\n",
    "SELECT \n",
    "    user_id,\n",
    "    (EXTRACT(EPOCH FROM AVG(time_diff)) / 3600 )::INTEGER AS hours_between_orders\n",
    "FROM \n",
    "    t\n",
    "WHERE \n",
    "    count_orders > 1\n",
    "GROUP BY\n",
    "    user_id\n",
    "ORDER BY \n",
    "    user_id\n",
    "LIMIT 1000;\n",
    "\n",
    "\n",
    "-- №7    \n",
    "-- Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням. Вы уже делали это в одной из предыдущих задач. При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions). Колонку с числом заказов назовите orders_count.\n",
    "\n",
    "-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией AVG для расчёта скользящего среднего числа заказов. Скользящее среднее для каждой записи считайте по трём предыдущим дням. Подумайте, как правильно задать границы рамки, чтобы получить корректные расчёты.\n",
    "\n",
    "-- Полученные значения скользящего среднего округлите до двух знаков после запятой. Колонку с рассчитанным показателем назовите moving_avg. Сортировку результирующей таблицы делать не нужно.\n",
    "\n",
    "-- Поля в результирующей таблице: date, orders_count, moving_avg\n",
    "\n",
    "WITH count_orders AS (\n",
    "    SELECT \n",
    "        creation_time::DATE AS date, \n",
    "        COUNT(DISTINCT order_id) AS orders_count\n",
    "    FROM \n",
    "        orders\n",
    "    WHERE \n",
    "        order_id NOT IN (\n",
    "            SELECT order_id\n",
    "            FROM user_actions\n",
    "            WHERE action = 'cancel_order'\n",
    "        )\n",
    "    GROUP BY \n",
    "        creation_time::DATE\n",
    "    ORDER BY \n",
    "        date\n",
    ")\n",
    "\n",
    "SELECT \n",
    "    date, \n",
    "    orders_count,\n",
    "    ROUND(AVG(orders_count) OVER (ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), 2) AS moving_avg\n",
    "FROM \n",
    "    count_orders;\n",
    "\n",
    "\n",
    "\n",
    "\n",
    "-- №8\n",
    "-- Задание:\n",
    "\n",
    "-- Отметьте в отдельной таблице тех курьеров, которые доставили в сентябре 2022 года заказов больше, чем в среднем все курьеры.\n",
    "\n",
    "-- Сначала для каждого курьера в таблице courier_actions рассчитайте общее количество доставленных в сентябре заказов. \n",
    "-- Затем в отдельном столбце с помощью оконной функции укажите, сколько в среднем заказов доставили в этом месяце все курьеры. \n",
    "-- После этого сравните число заказов, доставленных каждым курьером, со средним значением в новом столбце. \n",
    "-- Если курьер доставил больше заказов, чем в среднем все курьеры, то в отдельном столбце с помощью CASE укажите число 1, в противном случае укажите 0.\n",
    "\n",
    "-- Колонку с результатом сравнения назовите is_above_avg, колонку с числом доставленных заказов каждым курьером — delivered_orders, а колонку со средним значением — avg_delivered_orders.\n",
    "-- При расчёте среднего значения округлите его до двух знаков после запятой. Результат отсортируйте по возрастанию id курьера.\n",
    "\n",
    "-- Поля в результирующей таблице: courier_id, delivered_orders, avg_delivered_orders, is_above_avg\n",
    "\n",
    "\n",
    "-- Первый запрос:\n",
    "SELECT \n",
    "    courier_id, \n",
    "    COUNT(DISTINCT order_id) AS delivered_orders,\n",
    "    ROUND(AVG(COUNT(DISTINCT order_id)) OVER(), 2) AS avg_delivered_orders,\n",
    "    CASE\n",
    "        WHEN COUNT(DISTINCT order_id) > AVG(COUNT(DISTINCT order_id)) OVER() THEN 1\n",
    "        ELSE 0\n",
    "    END AS is_above_avg\n",
    "FROM \n",
    "    courier_actions\n",
    "WHERE \n",
    "    EXTRACT(MONTH FROM time::DATE) = 9 \n",
    "    AND action = 'deliver_order'\n",
    "GROUP BY \n",
    "    courier_id;\n",
    "\n",
    "-- Второй запрос:\n",
    "SELECT \n",
    "    courier_id, \n",
    "    delivered_orders,\n",
    "    AVG(delivered_orders) OVER() AS avg_delivered_orders,\n",
    "    CASE\n",
    "        WHEN delivered_orders > ROUND(AVG(delivered_orders) OVER(), 2) THEN 1\n",
    "        ELSE 0\n",
    "    END AS is_above_avg\n",
    "FROM \n",
    "    (\n",
    "        SELECT \n",
    "            courier_id, \n",
    "            COUNT(DISTINCT order_id) AS delivered_orders\n",
    "        FROM \n",
    "            courier_actions\n",
    "        WHERE \n",
    "            EXTRACT(MONTH FROM time::DATE) = 9 \n",
    "            AND action = 'deliver_order'\n",
    "        GROUP BY \n",
    "            courier_id\n",
    "    ) t;\n",
    "\n",
    "\n",
    "\n",
    "-- №9\n",
    "-- Задание:\n",
    "\n",
    "-- По данным таблицы user_actions посчитайте число первых и повторных заказов на каждую дату.\n",
    "\n",
    "-- Для этого сначала с помощью оконных функций и оператора CASE сформируйте таблицу, в которой напротив каждого заказа будет стоять отметка «Первый» или «Повторный» (без кавычек). \n",
    "-- Для каждого пользователя первым заказом будет тот, который был сделан раньше всего. Все остальные заказы должны попасть, соответственно, в категорию «Повторный». \n",
    "-- Затем на каждую дату посчитайте число заказов каждой категории.\n",
    "-- Колонку с типом заказа назовите order_type, колонку с датой — date, колонку с числом заказов — orders_count.\n",
    "-- В расчётах учитывайте только неотменённые заказы.\n",
    "-- Результат отсортируйте сначала по возрастанию даты, затем по возрастанию значений в колонке с типом заказа.\n",
    "-- Поля в результирующей таблице: date, order_type, orders_count\n",
    "\n",
    "WITH type AS (\n",
    "    SELECT \n",
    "        time::DATE AS date, \n",
    "        user_id, \n",
    "        order_id,\n",
    "        CASE\n",
    "            WHEN order_id = FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Первый'\n",
    "            WHEN order_id != FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Повторный'\n",
    "        END AS order_type\n",
    "    FROM \n",
    "        user_actions\n",
    "    WHERE \n",
    "        order_id NOT IN (\n",
    "            SELECT order_id\n",
    "            FROM user_actions\n",
    "            WHERE action = 'cancel_order'\n",
    "        )\n",
    ")\n",
    "\n",
    "SELECT \n",
    "    date, \n",
    "    order_type,\n",
    "    COUNT(order_id) AS orders_count\n",
    "FROM \n",
    "    type\n",
    "GROUP BY \n",
    "    date, \n",
    "    order_type\n",
    "ORDER BY \n",
    "    date, \n",
    "    order_type;\n",
    "\n",
    "\n",
    "\n",
    "-- №10\n",
    "-- К запросу, полученному на предыдущем шаге, примените оконную функцию и для каждого дня посчитайте долю первых и повторных заказов. \n",
    "-- Сохраните структуру полученной ранее таблицы и добавьте только одну новую колонку с посчитанными значениями.\n",
    "\n",
    "-- Колонку с долей заказов каждой категории назовите orders_share. Значения в полученном столбце округлите до двух знаков после запятой.\n",
    "-- В результат также включите количество заказов в группах, посчитанное на предыдущем шаге.\n",
    "\n",
    "-- В расчётах по-прежнему учитывайте только неотменённые заказы.\n",
    "\n",
    "-- Результат отсортируйте сначала по возрастанию даты, затем по возрастанию значений в колонке с типом заказа.\n",
    "\n",
    "-- Поля в результирующей таблице: date, order_type, orders_count, orders_share\n",
    "\n",
    "\n",
    "WITH type AS (\n",
    "    SELECT \n",
    "        time::DATE AS date, \n",
    "        user_id, \n",
    "        order_id,\n",
    "        CASE\n",
    "            WHEN order_id = FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Первый'\n",
    "            WHEN order_id != FIRST_VALUE(order_id) OVER (PARTITION BY user_id ORDER BY time) THEN 'Повторный'\n",
    "        END AS order_type\n",
    "    FROM \n",
    "        user_actions\n",
    "    WHERE \n",
    "        order_id NOT IN (\n",
    "            SELECT order_id\n",
    "            FROM user_actions\n",
    "            WHERE action = 'cancel_order'\n",
    "        )\n",
    ")\n",
    "\n",
    "SELECT \n",
    "    date,\n",
    "    order_type,\n",
    "    COUNT(order_id) AS orders_count,\n",
    "    ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER (PARTITION BY date), 2) AS orders_share\n",
    "FROM \n",
    "    type\n",
    "GROUP BY \n",
    "    date, \n",
    "    order_type\n",
    "ORDER BY \n",
    "    date, \n",
    "    order_type;\n",
    "\n",
    "\n",
    "\n",
    "-- №10\n",
    "-- Задание:\n",
    "-- Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке для каждой записи проставьте среднюю цену всех товаров. \n",
    "-- Колонку с этим значением назовите avg_price.\n",
    "-- Затем с помощью оконной функции и оператора FILTER в отдельной колонке рассчитайте среднюю цену товаров без учёта самого дорогого.\n",
    "-- Колонку с этим средним значением назовите avg_price_filtered. Полученные средние значения в колонках avg_price и avg_price_filtered округлите до двух знаков после запятой.\n",
    "-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.\n",
    "-- Поля в результирующей таблице: product_id, name, price, avg_price, avg_price_filtered\n",
    "\n",
    "\n",
    "\n",
    "SELECT \n",
    "    product_id, \n",
    "    name, \n",
    "    price,\n",
    "    ROUND(AVG(price) OVER (), 2) AS avg_price,\n",
    "    ROUND(AVG(price) FILTER (WHERE price != (SELECT MAX(price) FROM products)) OVER (), 2) AS avg_price_filtered\n",
    "FROM \n",
    "    products\n",
    "ORDER BY \n",
    "    price DESC, \n",
    "    product_id;\n",
    "\n",
    "\n",
    "\n",
    "-- №11\n",
    "-- А теперь ещё одна задача на фильтрацию по окну — в этот раз посложнее.\n",
    "\n",
    "-- Задание:\n",
    "-- Для каждой записи в таблице user_actions с помощью оконных функций и предложения FILTER посчитайте, сколько заказов сделал и сколько отменил каждый пользователь на момент совершения нового действия.\n",
    "-- Иными словами, для каждого пользователя в каждый момент времени посчитайте две накопительные суммы — числа оформленных и числа отменённых заказов.\n",
    "-- Если пользователь оформляет заказ, то число оформленных им заказов увеличивайте на 1, если отменяет — увеличивайте на 1 количество отмен.\n",
    "-- Колонки с накопительными суммами числа оформленных и отменённых заказов назовите соответственно created_orders и canceled_orders. \n",
    "-- На основе этих двух колонок для каждой записи пользователя посчитайте показатель cancel_rate, т.е. долю отменённых заказов в общем количестве оформленных заказов. \n",
    "-- Значения показателя округлите до двух знаков после запятой. Колонку с ним назовите cancel_rate.\n",
    "-- В результате у вас должны получиться три новые колонки с динамическими показателями, которые изменяются во времени с каждым новым действием пользователя.\n",
    "-- В результирующей таблице отразите все колонки из исходной таблицы вместе с новыми колонками. Отсортируйте результат по колонкам user_id, order_id, time — по возрастанию значений в каждой.\n",
    "-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.\n",
    "-- Поля в результирующей таблице:\n",
    "-- user_id, order_id, action, time, created_orders, canceled_orders, cancel_rate\n",
    "\n",
    "SELECT user_id, order_id, action, time, created_orders, canceled_orders,\n",
    "ROUND(canceled_orders::NUMERIC/ created_orders, 2)  AS cancel_rate\n",
    "FROM\n",
    "    (SELECT user_id,order_id,action,time,\n",
    "    COUNT(order_id) FILTER(WHERE action = 'create_order') OVER (PARTITION BY user_id ORDER BY time) AS created_orders,\n",
    "    COUNT(order_id) FILTER(WHERE action = 'cancel_order') OVER (PARTITION BY user_id  ORDER BY time) AS canceled_orders\n",
    "    FROM user_actions) AS t\n",
    "ORDER BY user_id, order_id, time\n",
    "LIMIT 1000;\n",
    "\n",
    "\n",
    "-- №14\n",
    "-- Из таблицы courier_actions отберите топ 10% курьеров по количеству доставленных за всё время заказов. \n",
    "-- Выведите id курьеров, количество доставленных заказов и порядковый номер курьера в соответствии с числом доставленных заказов.\n",
    "\n",
    "-- У курьера, доставившего наибольшее число заказов, порядковый номер должен быть равен 1,\n",
    "-- а у курьера с наименьшим числом заказов — числу, равному десяти процентам от общего количества курьеров в таблице courier_actions.\n",
    "\n",
    "-- При расчёте номера последнего курьера округляйте значение до целого числа.\n",
    "\n",
    "-- Колонки с количеством доставленных заказов и порядковым номером назовите соответственно orders_count и courier_rank. \n",
    "-- Результат отсортируйте по возрастанию порядкового номера курьера.\n",
    "\n",
    "-- Поля в результирующей таблице: courier_id, orders_count, courier_rank \n",
    "\n",
    "-- SELECT * FROM courier_actions LIMIT 10;\n",
    "\n",
    "\n",
    "WITH rank_courier AS (\n",
    "    SELECT \n",
    "        courier_id, \n",
    "        orders_count,\n",
    "        ROW_NUMBER() OVER (ORDER BY orders_count DESC, courier_id) AS courier_rank\n",
    "    FROM \n",
    "        (\n",
    "            SELECT \n",
    "                courier_id, \n",
    "                COUNT(DISTINCT order_id) AS orders_count\n",
    "            FROM \n",
    "                courier_actions\n",
    "            WHERE \n",
    "                action = 'deliver_order'\n",
    "            GROUP BY \n",
    "                courier_id\n",
    "        ) t\n",
    ")\n",
    "\n",
    "SELECT \n",
    "    courier_id, \n",
    "    orders_count, \n",
    "    courier_rank\n",
    "FROM \n",
    "    rank_courier\n",
    "WHERE \n",
    "    courier_rank <= ROUND(0.1 * (SELECT COUNT(*) FROM rank_courier));\n",
    "\n",
    "\n",
    "-- №15\n",
    "-- С помощью оконной функции отберите из таблицы courier_actions всех курьеров, которые работают в нашей компании 10 и более дней.\n",
    "-- Также рассчитайте, сколько заказов они уже успели доставить за всё время работы.\n",
    "\n",
    "-- Будем считать, что наш сервис предлагает самые выгодные условия труда и поэтому за весь анализируемый период ни один курьер не уволился из компании.\n",
    "-- Возможные перерывы между сменами не учитывайте — для нас важна только разница во времени между первым действием курьера и текущей отметкой времени.\n",
    "\n",
    "-- Текущей отметкой времени, относительно которой необходимо рассчитывать продолжительность работы курьера, считайте время последнего действия в таблице courier_actions.\n",
    "-- Учитывайте только целые дни, прошедшие с момента первого выхода курьера на работу (часы и минуты не учитывайте).\n",
    "\n",
    "-- В результат включите три колонки: id курьера, продолжительность работы в днях и число доставленных заказов. \n",
    "-- Две новые колонки назовите соответственно days_employed и delivered_orders. Результат отсортируйте сначала по убыванию количества отработанных дней, затем по возрастанию id курьера.\n",
    "\n",
    "-- Поля в результирующей таблице: courier_id, days_employed, delivered_orders\n",
    "\n",
    "WITH courier_data AS (\n",
    "    SELECT\n",
    "        courier_id,\n",
    "        MIN(time) OVER (PARTITION BY courier_id) AS first_action_time,\n",
    "        MAX(time) OVER () AS last_action_time,\n",
    "        COUNT(*) FILTER (WHERE action = 'deliver_order') OVER (PARTITION BY courier_id) AS delivered_orders\n",
    "    FROM\n",
    "        courier_actions\n",
    "),\n",
    "courier_duration AS (\n",
    "    SELECT\n",
    "        courier_id,\n",
    "        DATE_PART('day', last_action_time - first_action_time) AS days_employed,\n",
    "        delivered_orders\n",
    "    FROM\n",
    "        courier_data\n",
    "    GROUP BY\n",
    "        courier_id, first_action_time, last_action_time, delivered_orders\n",
    ")\n",
    "SELECT\n",
    "    courier_id,\n",
    "    days_employed,\n",
    "    delivered_orders\n",
    "FROM\n",
    "    courier_duration\n",
    "WHERE\n",
    "    days_employed >= 10\n",
    "ORDER BY\n",
    "    days_employed DESC,\n",
    "    courier_id ASC;\n",
    "\n",
    "\n",
    "WITH t AS\n",
    "(SELECT courier_id, MIN(time::date)  AS min_day,\n",
    "MAX(time::date) AS max_day,\n",
    "MAX(time::date) - MIN(time::date  AS days_employed,\n",
    "COUNT(DISTINCT order_id) FILTER (WHERE action = 'deliver_order'))AS delivered_orders\n",
    "FROM courier_actions\n",
    "GROUP BY\n",
    "    courier_id\n",
    "HAVING MAX(time::date) - MIN(time::date) >= 10) \n",
    "SELECT courier_id, days_employed, delivered_orders\n",
    "FROM t\n",
    "ORDER BY days_employed DESC, courier_id\n",
    "\n",
    "-- №16\n",
    "-- На основе информации в таблицах orders и products рассчитайте стоимость каждого заказа, ежедневную выручку сервиса и долю \n",
    "-- стоимости каждого заказа в ежедневной выручке, выраженную в процентах. В результат включите следующие колонки: id заказа, время создания заказа,\n",
    "-- стоимость заказа, выручку за день, в который был совершён заказ, а также долю стоимости заказа в выручке за день, выраженную в процентах.\n",
    "\n",
    "-- При расчёте долей округляйте их до трёх знаков после запятой.\n",
    "\n",
    "-- Результат отсортируйте сначала по убыванию даты совершения заказа (именно даты, а не времени), \n",
    "-- потом по убыванию доли заказа в выручке за день, затем по возрастанию id заказа.\n",
    "\n",
    "-- При проведении расчётов отменённые заказы не учитывайте.\n",
    "\n",
    "-- Поля в результирующей таблице:\n",
    "\n",
    "-- order_id, creation_time, order_price, daily_revenue, percentage_of_daily_revenue\n",
    "\n",
    "WITH t AS (\n",
    "    SELECT \n",
    "        creation_time,\n",
    "        order_id, \n",
    "        UNNEST(product_ids) AS product_id\n",
    "    FROM \n",
    "        orders \n",
    "    WHERE order_id NOT IN (\n",
    "        SELECT order_id \n",
    "        FROM user_actions \n",
    "        WHERE action = 'cancel_order'\n",
    "    )   \n",
    "),\n",
    "tt AS (\n",
    "    SELECT \n",
    "        creation_time, \n",
    "        order_id, \n",
    "        SUM(price) AS order_price\n",
    "    FROM t\n",
    "    JOIN products ON t.product_id = products.product_id\n",
    "    GROUP BY creation_time, order_id\n",
    ")\n",
    "SELECT \n",
    "    order_id, \n",
    "    creation_time, \n",
    "    order_price,\n",
    "    SUM(order_price) OVER (PARTITION BY creation_time::DATE) AS daily_revenue,\n",
    "    ROUND((order_price / SUM(order_price) OVER (PARTITION BY creation_time::DATE))*100,3) AS percentage_of_daily_revenue\n",
    "FROM tt\n",
    "ORDER BY \n",
    "    creation_time::DATE DESC, \n",
    "    percentage_of_daily_revenue DESC, \n",
    "    order_id ASC;\n",
    "\n",
    "\n",
    "-- Задачи на JOIN\n",
    "-- Объедините таблицы user_actions и users по ключу user_id. \n",
    "-- В результат включите две колонки с user_id из обеих таблиц.\n",
    "-- Эти две колонки назовите соответственно user_id_left и user_id_right.\n",
    "-- Также в результат включите колонки order_id, time, action, sex, birth_date. \n",
    "-- Отсортируйте получившуюся таблицу по возрастанию id пользователя (в любой из двух колонок с id).\n",
    "-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date\n",
    "\n",
    "SELECT COUNT(DISTINCT a.user_id) AS users_count \n",
    "FROM user_actions a\n",
    "JOIN users b USING(user_id);\n",
    "\n",
    "SELECT COUNT (DISTINCT user_id) FROM user_actions;\n",
    "SELECT COUNT (user_id) FROM users;\n",
    "\n",
    "SELECT a.user_id user_id_left,b.user_id user_id_right,  order_id, time, action, sex, birth_date\n",
    "FROM user_actions a\n",
    "LEFT JOIN users b USING(user_id)\n",
    "WHERE b.user_id IS NOT NULL\n",
    "ORDER BY user_id_left;\n",
    "\n",
    "SELECT a.birth_date AS users_birth_date,users_count,b.birth_date AS couriers_birth_date, couriers_count\n",
    "FROM (\n",
    "    SELECT birth_date, COUNT(user_id) AS users_count\n",
    "    FROM users\n",
    "    WHERE birth_date IS NOT NULL\n",
    "    GROUP BY birth_date\n",
    ") AS a\n",
    "FULL JOIN\n",
    "(\n",
    "    SELECT birth_date, COUNT(courier_id) AS couriers_count\n",
    "    FROM couriers\n",
    "    WHERE birth_date IS NOT NULL\n",
    "    GROUP BY birth_date\n",
    ") AS b\n",
    "ON a.birth_date = b.birth_date\n",
    "ORDER BY users_birth_date, couriers_birth_date\n",
    "\n",
    "\n",
    "\n",
    "SELECT COUNT(birth_date) AS dates_count\n",
    "FROM\n",
    "(SELECT birth_date\n",
    "FROM users\n",
    "WHERE birth_date IS NOT NULL\n",
    "UNION ALL\n",
    "SELECT birth_date\n",
    "FROM couriers\n",
    "WHERE birth_date IS NOT NULL) AS subquery\n",
    "\n",
    "\n",
    "\n",
    "\n",
    "-- Задача 17.\n",
    "-- Задание:\n",
    "\n",
    "-- На основе информации в таблицах orders и products рассчитайте ежедневную выручку сервиса и отразите \n",
    "-- её в колонке daily_revenue. Затем с помощью оконных функций и функций смещения посчитайте ежедневный прирост выручки. \n",
    "-- Прирост выручки отразите как в абсолютных значениях, так и в % относительно предыдущего дня. \n",
    "-- Колонку с абсолютным приростом назовите revenue_growth_abs, а колонку с относительным — revenue_growth_percentage.\n",
    "-- Для самого первого дня укажите прирост равным 0 в обеих колонках. \n",
    "-- При проведении расчётов отменённые заказы не учитывайте. Результат отсортируйте по колонке с датами по возрастанию.\n",
    "-- Метрики daily_revenue, revenue_growth_abs, revenue_growth_percentage округлите до одного знака при помощи ROUND().\n",
    "-- Поля в результирующей таблице: date, daily_revenue, revenue_growth_abs, revenue_growth_percentage\n",
    "\n",
    "\n",
    "WITH filtered_orders AS (\n",
    "    SELECT \n",
    "        creation_time,\n",
    "        order_id, \n",
    "        UNNEST(product_ids) AS product_id\n",
    "    FROM orders\n",
    "    WHERE order_id NOT IN (\n",
    "        SELECT order_id \n",
    "        FROM user_actions \n",
    "        WHERE action = 'cancel_order'\n",
    "    )   \n",
    "),\n",
    "order_prices AS (\n",
    "    SELECT \n",
    "        creation_time, \n",
    "        order_id, \n",
    "        SUM(price) AS order_price\n",
    "    FROM filtered_orders\n",
    "    JOIN products \n",
    "        ON filtered_orders.product_id = products.product_id\n",
    "    GROUP BY creation_time, order_id\n",
    "),\n",
    "daily_revenue_table AS (\n",
    "    SELECT \n",
    "        creation_time::DATE AS creation_date, \n",
    "        ROUND(SUM(order_price), 1) AS daily_revenue\n",
    "    FROM order_prices\n",
    "    GROUP BY creation_date\n",
    "),\n",
    "revenue_with_growth_abs AS (\n",
    "    SELECT \n",
    "        creation_date AS date,\n",
    "        daily_revenue,\n",
    "        CASE\n",
    "            WHEN daily_revenue - LAG(daily_revenue, 1) OVER (ORDER BY creation_date) IS NULL THEN 0\n",
    "            ELSE ROUND(daily_revenue - LAG(daily_revenue, 1) OVER (ORDER BY creation_date), 1)\n",
    "        END AS revenue_growth_abs\n",
    "    FROM daily_revenue_table\n",
    ")\n",
    "SELECT \n",
    "    date,\n",
    "    daily_revenue,\n",
    "    revenue_growth_abs,\n",
    "    CASE\n",
    "        WHEN revenue_growth_abs / LAG(daily_revenue) OVER (ORDER BY date) IS NULL THEN 0\n",
    "        ELSE ROUND(revenue_growth_abs / LAG(daily_revenue) OVER (ORDER BY date) * 100, 1)\n",
    "    END AS  revenue_growth_percentage\n",
    "FROM revenue_with_growth_abs\n",
    "ORDER BY date;\n",
    "\n",
    "-- Задача 18\n",
    "\n",
    "-- С помощью оконной функции рассчитайте медианную стоимость всех заказов из таблицы orders, \n",
    "-- оформленных в нашем сервисе. В качестве результата выведите одно число. Колонку с ним назовите median_price. \n",
    "-- Отменённые заказы не учитывайте.\n",
    "-- Поле в результирующей таблице: median_price\n",
    "\n",
    "WITH ordered_values AS (\n",
    "    SELECT \n",
    "        order_price,\n",
    "        ROW_NUMBER() OVER (ORDER BY order_price) AS rank,\n",
    "        COUNT(order_id) OVER () AS total_count\n",
    "    FROM \n",
    "    (SELECT \n",
    "        order_id, \n",
    "        SUM(price) AS order_price\n",
    "    FROM (\n",
    "        SELECT \n",
    "            order_id, \n",
    "            UNNEST(product_ids) AS product_id\n",
    "        FROM orders\n",
    "        WHERE order_id NOT IN (\n",
    "            SELECT order_id \n",
    "            FROM user_actions \n",
    "            WHERE action = 'cancel_order'\n",
    "        )\n",
    "    )AS filtered_orders\n",
    "    JOIN products \n",
    "        ON filtered_orders.product_id = products.product_id\n",
    "    GROUP BY \n",
    "            order_id    \n",
    "    ) AS order_prices\n",
    ")\n",
    "-- SELECT order_price, rank, total_count\n",
    "-- FROM ordered_values;\n",
    "        \n",
    "SELECT \n",
    "    CASE\n",
    "        WHEN total_count / 2 != 0 THEN \n",
    "            (SELECT order_price FROM ordered_values WHERE rank = (total_count + 1) / 2)\n",
    "        ELSE \n",
    "            (SELECT AVG(order_price) \n",
    "             FROM ordered_values \n",
    "             WHERE rank IN (total_count / 2, (total_count / 2) + 1))\n",
    "    END AS median_price\n",
    "FROM \n",
    "    ordered_values\n",
    "LIMIT 1;\n",
    "\n",
    "\n",
    "\n",
    "\n"
   ]
  }
 ],
 "metadata": {
  "language_info": {
   "name": "python"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}
