-- ===================== Задачи: Основы SQL ===================== --
--1.	Вывести все записи из таблицы customers.
select *
from customers c ;

--2.	Найти всех клиентов, у которых номер карты начинается с "567".
select c.customer_id, c.card_number, c.card_type
from customers c 
where cast(c.card_number as text) like '567%';

--3.	Отобразить транзакции, где сумма больше 5000000.
select * 
from transactions t 
where t.amount > 5000000;

--4.	Вывести список всех high_risk_merchant.
select * 
from merchants m 
where m.high_risk_merchant is True;

--5.	Найти транзакции, совершённые в валюте "USD".
select * 
from transactions t 
where t.currency ilike 'USD';

--6.	Вывести транзакции, совершённые после 20 октября 2024 года.
select * 
from transactions t 
where "timestamp" > '2024-10-20'
order by 2;

--7.	Получить уникальные категории merchant_category.
select m.merchant_category unique
from merchants m ;

--8.	Найти среднюю сумму всех транзакций.
select avg(amount)
from transactions t ;

--9.	Определить максимальную и минимальную сумму транзакций.
select min(amount), max(amount)
from transactions t ;

--10.	Найти клиентов, у которых card_type = "Visa".
select c.customer_id
from customers c
where card_type like 'Gold Credit';


--11.	Вывести 10 последних зарегистрированных клиентов (по customer_id).
select *
from customers c 
order by 1 desc 
limit 10;

SELECT * 
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY customer_id DESC) AS rn
    FROM card_transactions.customers
) sub
WHERE rn <= 10;


--12.	Подсчитать количество транзакций каждого клиента.
select t.customer_id, count(*) 
from transactions t  
group by t.customer_id;

--13.	Найти самую крупную транзакцию.
select t.transaction_id, t.amount
from transactions t 
where t.amount = (
	select max(tt.amount) 
	from transactions tt )
;

SELECT t.transaction_id, t.amount
FROM transactions t
ORDER BY amount DESC
LIMIT 1;

--14.	Вывести 5 самых дорогих транзакций.
SELECT t.transaction_id, t.amount
FROM transactions t
ORDER BY amount DESC
LIMIT 5;

--15.	Отобразить все транзакции клиента с customer_id = '10022'.
select t.customer_id , count(*)
from transactions t 
group by t.customer_id;

select *
from transactions t 
where cast(t.customer_id as int) = 10022;

--16	Вывести для каждого пользователя его последний платеж
select distinct on (t.customer_id) t.customer_id, t.transaction_id, t."timestamp", t.amount
from transactions t 
order by 1, t."timestamp" desc

-- 17 Вывести для каждого клиента количество дней/месяцев/лет после последней транзакции

select t.customer_id , 
	MAX(t."timestamp")::date AS last_transaction,
	date_part('day', current_timestamp - MAX(t."timestamp")) as days_since_trans,
	date_part('months', age(now(), MAX(t."timestamp"))) + date_part('year', age(now(), MAX(t."timestamp"))) * 12 as months_since_trans,
	date_part('year', age(now(), MAX(t."timestamp"))) as years_since_trans
from transactions t 
group by 1;



-- ===================== Задачи: Агрегатные функции и GROUP BY ===================== --
--1.	Подсчитать количество клиентов в customers.
select count(*)
from customers c ;

--2.	Какая средняя сумма транзакции, если не учитывать 10% самых дорогих и 10% самых дешевых транзакций? (Требуется исключить крайние 10% данных.)

--select avg(t.amount )
--from transactions t 
--union all
select avg(filtered.amount)
from (
	select tt.amount 
	from transactions tt
	order by tt.amount
	OFFSET (SELECT COUNT(*) * 0.1 FROM transactions)
    FETCH NEXT (SELECT COUNT(*) * 0.8 FROM transactions) ROWS ONLY
) AS filtered;
	

--3.	Каково общее количество транзакций, если учитывать только тех клиентов, у которых было больше 3000 транзакции?
select sum(transactions_by_cust)
from (
	select t.customer_id, count(*) as transactions_by_cust
	from transactions t 
	group by 1
	having count(*) >= 3000
 ) as t;

--4.	Какая максимальная сумма транзакции в каждой категории merchant_category? (Результат должен быть представлен в порядке убывания максимальных значений.)

select m.merchant_category , max(t.amount)
from transactions t 
join merchants m on m.merchant_id = t.merchant_id  
group by m.merchant_category ;

--5.	Сколько различных клиентов по каждой категории карты сделали хотя бы одну транзакцию? 

select c.card_type, count(*)
from customers c 
group by c.card_type;

--6.	Какова средняя сумма мошеннических транзакций?
select avg(t.amount)
from transactions t 
join fraud_status fs2 on fs2.transaction_id = t.transaction_id
where fs2.is_fraud is true;

--7.	Какие категории merchant_category имеют среднюю сумму транзакций выше 2000, но при этом не содержат транзакции более 10 000? (Двойное условие: средняя сумма высокая, но нет слишком больших платежей.)

select * 
from (
	select m.merchant_category, avg(t.amount) as avg_amount
	from transactions t
	join merchants m on m.merchant_id = t.merchant_id
	group by m.merchant_category
	having max(t.amount) <= 10000000
	) t1
where t1.avg_amount > 40000;


SELECT m.merchant_category, AVG(t.amount) AS avg_amount
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_category
HAVING AVG(t.amount) > 40000
   AND MAX(t.amount) <= 10000000;


--8.	Какая суммарная сумма транзакций по каждому клиенту, если учитывать только транзакции, совершенные в будние дни? (Фильтрация по weekend_transaction = FALSE.)
select t.customer_id, sum(t.amount)
from transactions t 
where t.weekend_transaction is false
group by t.customer_id ;

--9.	Каково соотношение количества транзакций между high_risk_merchant и остальными? (Нужно не просто подсчитать, но и вывести долю каждой группы.)
select sum(cast(m.high_risk_merchant as int)) * 100 / count(*)
from merchants m ;

--10.	В каких категориях merchant_category есть хотя бы 10 уникальных merchant? (Важно выбрать только категории, где есть разнообразие продавцов.)

select m.merchant_category, count(distinct m.merchant) as unique_m
from merchants m 
group by 1
having count(distinct m.merchant) > 10;

--11.	Каково среднее количество транзакций на одного клиента, если исключить 5% клиентов с наименьшим числом транзакций? (Чтобы убрать неактивных пользователей.)

select * 
from (
	select t.customer_id, count(t.transaction_id)
	from transactions t 
	group by 1
	order by 2
	) tt
OFFSET (SELECT COUNT(distinct customer_id) * 0.05 FROM transactions)

--12.	Какие 3 клиента потратили больше всего, но не делали покупок у high_risk_merchant? (Фильтрация по high_risk_merchant = FALSE.)
select *
from merchants m 

select t.customer_id, round(sum(t.amount))
from transactions t 
join merchants m on m.merchant_id = t.merchant_id
where m.high_risk_merchant is false
group by 1
order by 2 desc
fetch first 3 rows with ties;

--13.	Какая категория merchant_category встречается чаще всего среди немошеннических транзакций?

select m.merchant_category, count(*)
from transactions t 
join fraud_status fs2 on fs2.transaction_id = t.transaction_id
join merchants m  on m.merchant_id = t.merchant_id
where fs2.is_fraud is false
group by 1
order by 2 desc
fetch first 1 rows only;

--14.	Какова медианная сумма транзакций в каждом merchant_category? (Тут подвох — медиана не является агрегатной функцией в SQL, ее нужно рассчитывать вручную.)

select m.merchant_category,  PERCENTILE_CONT(0.5) within group (order by t.amount) as median 
from transactions t 
join merchants m on m.merchant_id = t.merchant_id 
GROUP BY merchant_category;

WITH ordered_transactions AS (
    SELECT 
        m.merchant_category,
        t.amount,
        ROW_NUMBER() OVER (PARTITION BY m.merchant_category ORDER BY t.amount) AS row_num,
        COUNT(*) OVER (PARTITION BY m.merchant_category) AS total_rows
    FROM transactions t
    JOIN merchants m ON t.merchant_id = m.merchant_id
)
SELECT merchant_category, AVG(amount) AS median_amount
FROM ordered_transactions
WHERE row_num IN (total_rows / 2, total_rows / 2 + 1)
GROUP BY merchant_category;


--15.	Какие клиенты совершили более 2000 транзакций, но ни одной из них не у high_risk_merchant? (Важно исключить клиентов, взаимодействовавших с рискованными продавцами.)

select t.customer_id, count(t.transaction_id) as tr_count
from transactions t 
join merchants m on m.merchant_id = t.merchant_id
where m.high_risk_merchant is false
group by 1 
having count(t.transaction_id) > 2000
order by 2 desc;


-- ===================== Задачи: JOIN'ы

--1.	Вывести список клиентов и их транзакций, но не показывать клиентов, у которых card_type Debit  
select t.transaction_id , c.customer_id, c.card_number , c.card_type
from transactions t 
join customers c on c.customer_id = t.customer_id 
where c.card_type not like '%Debit';

--2.	Найти список merchants, но только тех, у кого средняя сумма транзакций выше 5 000 000 000.  
select m.merchant, sum(t.amount)
from transactions t 
join merchants m on m.merchant_id = t.merchant_id
group by 1
having sum(t.amount) > 5000000000;

--3.	Определить с каких карт и на какую сумму совершались мошеннические транзации.  

select c.card_number , c.card_type, sum(t.amount)
from transactions t 
join customers c on c.customer_id = t.customer_id
join fraud_status fs2 on fs2.transaction_id = t.transaction_id
where fs2.is_fraud is true
group by 1, 2
order by 1;


--4.	Вывести список транзакций вместе с названием устройства (`device`), но если устройство неизвестно, подставить "Unknown Device".  
select t.transaction_id , COALESCE(d.device, 'Unknown Device') AS device_name
from transactions t 
join devices d on d.device_id = t.device_id

--5.	Найти клиентов, совершивших более 30 транзакций, но с разными merchant_id (чтобы не учитывать спам-операции в одном месте). 

SELECT t.customer_id, 
FROM (
    SELECT customer_id, COUNT(DISTINCT merchant_id) AS unique_merchants
    FROM transactions
    GROUP BY customer_id
    HAVING COUNT(transaction_id) > 30
) t
WHERE t.unique_merchants > 3;


--6.	Определить merchants, у которых не было транзакций (`LEFT JOIN`).
select * from merchants m ;

insert into merchants 
values (1200, 'OZON', 'Retail', 'online', False);

select m.merchant_id, m.merchant 
from merchants m 
left join transactions t on t.merchant_id = m.merchant_id
where t.merchant_id is null;


--7.	Объединить (`UNION`) список customers и merchants у кого id начинается с "5".  
select c.customer_id::int as id
from customers c 
where c.customer_id::varchar like '5%'
union 
select m.merchant_id::int as id
from merchants m 
where m.merchant_id::varchar like '5%';

--8.	Определить транзакции, превышающие среднюю сумму, но внутри каждого merchant_category (чтобы учитывать специфику каждой ниши).  

-----------TO DO
select m.merchant_category, round(avg(t.amount), 2)
from transactions t 
join merchants m on m.merchant_id = t.merchant_id
group by 1;

--9.	Вывести самые крупные транзакции и соответствующих клиентов, но если сумма выше 100000, скрыть имя клиента (заменить на "VIP Client").  
--10.	Найти всех клиентов и их последние транзакции, но если у клиента нет транзакций, поставить NULL в этом столбце (использовать `LEFT JOIN` + `MAX(transaction_date)`).  
--11.	Определить среднюю сумму транзакции для каждого клиента, но не учитывать транзакции с аномально высокой суммой (например, выше 99-го перцентиля всех транзакций).  
--12.	Вывести количество транзакций по месяцам, но исключить месяцы, в которых было менее 100 транзакций.  
--13.	Найти клиентов, совершивших транзакции у `merchant_id = 5`, но только если они сделали там более 2 покупок.  
--14.	Определить все `devices` и количество использованных транзакций, но если устройство использовалось менее 10 раз, пометить его как "Rare Device".  
--15.	Найти топ-5 устройств по количеству транзакций, но исключить устройства, у которых менее 5 уникальных клиентов (чтобы не учитывать тестовые устройства). 