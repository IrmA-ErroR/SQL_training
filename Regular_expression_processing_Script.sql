--Регулярные выражения (PCRE)
--PCRE (Perl Compatible Regular Expressions) — библиотека регулярных выражений, основанная на синтаксисе Perl. Она позволяет выполнять мощный и гибкий поиск по строкам, используя сложные шаблоны. 
--
--PostgreSQL → SIMILAR TO, ~, ~* (чувствительность к регистру)
--________________________________________
--Принципы построения регулярных выражений:

--1️ Специальные символы
--•	. — любой символ
--•	^ — начало строки
--•	$ — конец строки
--•	\d — любая цифра (0-9)
--•	\D — не цифра
--•	\w — буква, цифра или _
--•	\W — не буква, не цифра, не _
--•	\s — пробельный символ
--•	\S — не пробел

--2️ Квантификаторы
--•	* — 0 или больше повторений (a* → ``, a, aaaa)
--•	+ — 1 или больше повторений (a+ → a, aaa)
--•	? — 0 или 1 раз (a? → ``, a)
--•	{n} — ровно n повторений (a{3} → aaa)
--•	{n,} — n или больше (a{2,} → aa, aaa, ...)
--•	{n,m} — от n до m раз (a{2,4} → aa, aaa, aaaa)

--3️ Группировка и альтернативы
--•	(abc) — группировка
--•	a|b — a или b

--4️ Жадные и ленивые квантификаторы
--•	.* — жадный (захватывает максимум символов)
--•	.*? — ленивый (захватывает минимум символов)
--5️ Обратные ссылки
--•	(\d)\1 — повторение цифры (например, 11, 22)
--________________________________________
--=============== Задачи ===============--
--1.	Найти всех клиентов, у которых номер карты содержит три или более одинаковых цифры подряд.

select c.customer_id, c.card_number
from customers c 
where c.card_number::text ~ '([0-9])\1\1';

-- или 

select c.customer_id, c.card_number
from customers c 
where c.card_number::text ~ '([0-9])\1{2}';


--2.	Определить транзакции, в которых IP-адрес содержит ровно три точки, но не является корректным IPv4-адресом.

--3.	Вывести всех клиентов, у которых номер карты состоит из чередующихся цифр (например, "1212121212121212").

--4.	Найти устройства, у которых fingerprint содержит хотя бы один специальный символ, но не содержит пробелов.
--5.	Определить торговцев, у которых название состоит из одного слова, содержащего хотя бы одну заглавную букву и хотя бы одну цифру.
--6.	Найти транзакции, сумма которых содержит нечетное количество знаков после запятой.
--7.	Определить клиентов, у которых номер карты начинается и заканчивается одной и той же цифрой и содержит минимум 10 символов.
--8.	Вывести список устройств, fingerprint которых является палиндромом.
--9.	Найти все транзакции, в которых сумма записана в научной нотации (например, "1.23E4").
--10.	Определить клиентов, у которых в номере карты есть хотя бы три последовательных четных или нечетных цифры.
--11.	Найти торговцев, у которых название содержит подстроку длиной ровно 5 символов, состоящую только из заглавных букв.
--12.	Вывести транзакции, в которых валюта содержит повторяющиеся буквы (например, "USDD" или "EERR").
--13.	Найти все устройства, в названии которых есть хотя бы одна цифра, но они не начинаются с цифры.
--14.	Определить транзакции, в которых IP-адрес начинается с "192.168." и заканчивается на "1".
--15.	Найти клиентов, у которых номер карты содержит число, которое является простым (например, "17" или "31").
--16.	Определить устройства, у которых fingerprint содержит подстроку длиной не менее 8 символов, состоящую только из строчных букв.
--17.	Найти транзакции, которые были совершены в последние 5 минут часа (например, "12:55", "14:59").
--18.	Вывести список торговцев, у которых в названии есть слово, начинающееся и заканчивающееся гласной буквой.
--19.	Найти всех клиентов, у которых номер карты содержит две одинаковые цифры, разделенные одной другой цифрой (например, "2x2").
--20.	Определить транзакции, в которых сумма оканчивается на две одинаковые цифры (например, "45.11" или "100.00").
--
--21.	Найти мерчантов, у которых название содержит подряд идущие две одинаковые буквы.
--22.	Определить устройства, у которых fingerprint начинается с трех цифр и заканчивается буквой.
--23.	Вывести IP-адреса, в которых все группы чисел имеют одинаковую длину (например, 192.168.011.022).
--24.	Найти клиентов, у которых номер карты содержит ровно четыре подряд идущие гласные буквы.
--25.	Определить транзакции, в которых сумма начинается с четного числа и заканчивается нечетным (например, 42.3).
--Если хочешь еще усложнить, могу добавить проверки с regexp_replace() или разбор строк через regexp_split_to_table(). 
--
