use pharmacy


--------------------------------------------------------------
-----0. To identify drugs that have been made in France ------
--------------------------------------------------------------

-- lets see what we got here

select * from country_tbl -- ===> france country_id =2
select * from company_tbl
select * from company_tbl where country_id = 2  -- ===> there is only one company in france : Sanofi : company_id =2
select * from commercial_tbl
select * from commercial_tbl where company_id=2
select * from commercial_tbl where company_id in (select company_id from company_tbl where country_id =2)


select distinct  d.drug_id, d.drug_genericName, c.commercial_name, co.company_name, co.country_id, ct.country_name
from drug_tbl d
join commercial_tbl c on d.drug_id = c.drug_id
 join company_tbl co on c.company_id = co.company_id
 join country_tbl ct on co.country_id = ct.country_id
where ct.country_name = 'France'

/* result:
1	Amoxicillin	Amoxil	Sanofi	2	France
*/




------------------------------------------------------------------------------------------------------------------
-----1. To identify the number of prescriptions that contains drugs made in France -------------------------------
------------------------------------------------------------------------------------------------------------------
select p.prescription_id, p.prescription_name
	from prescription_tbl p
		join order_tbl o on p.prescription_id = o.prescription_id
		join commercial_tbl c on o.commercial_id = c.commercial_id
		join company_tbl co on c.company_id = co.company_id
		join country_tbl ct on co.country_id = ct.country_id
	where ct.country_name = 'France';

/* result : 144 row */


select count(distinct p.prescription_id) as france_drug_prescription_count
	from prescription_tbl p
		join order_tbl o on p.prescription_id = o.prescription_id
		join commercial_tbl c on o.commercial_id = c.commercial_id
		join company_tbl co on c.company_id = co.company_id
		join country_tbl ct on co.country_id = ct.country_id
	where ct.country_name = 'France';

/* result = 144 */



------------------------------------------------------------------------------------------------------------------
-----2. To identify the name of insurance companies that had more than 100 prescroptions in previous year  -------
------------------------------------------------------------------------------------------------------------------

select i.insurance_name, count(p.prescription_id) as prescription_count
from insurance_tbl i
	join prescription_tbl p on i.insurance_id = p.insurance_id
where p.prescription_date >= '2024-01-01' and p.prescription_date < '2025-01-01'
group by i.insurance_id, i.insurance_name
having count(p.prescription_id) > 100;


/* result: 
empty
i should 
		1. add some more data in year 2024
		2. change the start of the year
*/

select i.insurance_name, count(p.prescription_id) as prescription_count
from insurance_tbl i
	join prescription_tbl p on i.insurance_id = p.insurance_id
where p.prescription_date >= '2024-03-10' and p.prescription_date < '2025-03-10'
group by i.insurance_id, i.insurance_name
having count(p.prescription_id) > 100;

/* result:
Blue Cross			158
Aetna				174
UnitedHealthcare	162
*/

------------------------------------------------------------------------------------------------------------------
-----3.A function to find the most expensive drug of evrer company  ----------------------------------------------
------------------------------------------------------------------------------------------------------------------

--where can i find prices?
use pharmacy
select * from drug_tbl
select * from commercial_tbl order by  company_id --===> what we need is commercial_price


-------------- creating function
go 
create function mostexpensivedrugofcompany (@company_id int)
returns table
as
return
(
    select top 1 with ties co.company_id, co.company_name, d.drug_id, d.drug_genericname,
						    c.commercial_id, c.commercial_name, c.commercial_price
    from commercial_tbl c
		join drug_tbl d on c.drug_id = d.drug_id
		join company_tbl co on c.company_id = co.company_id
    where co.company_id = @company_id
    order by c.commercial_price desc
)
go


select * from [dbo].[company_tbl]
/*
1	Pfizer				1
2	Sanofi				2
3	Bayer				4
4	GlaxoSmithKline		3
5	AstraZeneca			3
6	Apotex				5
7	Takeda				6
*/

-------------- calling the function:
--   most expensive drug for company_id = 1 (pfizer)
select * from mostexpensivedrugofcompany(1)

--   most expensive drug for company_id = 2 (sanofi)
select * from mostexpensivedrugofcompany(2)

/* to check if it was correct:
select * from commercial_tbl order by  company_id 
2	Advil	1	2	10.00
8	Relenza	1	5	32.00
1	Amoxil	2	1	15.50
3	Zoloft	3	3	25.00
4	Panadol	4	4	8.50
5	Tamiflu	5	5	30.00
6	Zyrtec	6	6	12.50
7	Penicillin-VK	7	7	18.75

*/

------------------------------------------------------------------------------------------------------------------
-----4. findong the most expensive drug of evrer category ( drug type)  ------------------------------------------
------------------------------------------------------------------------------------------------------------------
--  we need :[dbo].[drug_tbl], [dbo].[company_tbl], and [dbo].[commercial_tbl]

--- let's see all the drugs with their type and commercial name and price
select d.drug_id, d.drug_genericname, t.type_id, t.type_name, 
		c.commercial_id, c.commercial_name, c.commercial_price
from drug_tbl d
	 join type_tbl t on d.type_id = t.type_id
	 join commercial_tbl c on d.drug_id = c.drug_id
order by d.drug_id, c.commercial_price;

/* result
1	Amoxicillin	1	Antibiotic			1	Amoxil			15.50
2	Ibuprofen	2	Analgesic			2	Advil			10.00
3	Sertraline	3	Antidepressant		3	Zoloft			25.00
4	Paracetamol	2	Analgesic			4	Panadol			8.50
5	Oseltamivir	4	Antiviral			5	Tamiflu			30.00
5	Oseltamivir	4	Antiviral			8	Relenza			32.00
6	Cetirizine	5	Antihistamine		6	Zyrtec			12.50
7	Penicillin	1	Antibiotic			7	Penicillin-VK	18.75
*/



-- ok now get dens_rank of it

go
with mostexpensivedrugs as 
	(
    select  t.type_id, t.type_name, d.drug_id, d.drug_genericname, c.commercial_id, c.commercial_name, c.commercial_price,
			 dense_rank() over (partition by t.type_id order by c.commercial_price desc) as price_rank
    from type_tbl t
		join drug_tbl d on t.type_id = d.type_id
		join commercial_tbl c on d.drug_id = c.drug_id
	)

select  type_id, type_name, drug_id, drug_genericname, commercial_id, commercial_name, commercial_price
from mostexpensivedrugs
where price_rank = 1


--- I wrote this using cte, u could write it with select tho

/* result of cte
1	Antibiotic			7	Penicillin	7	Penicillin-VK		18.75
2	Analgesic			2	Ibuprofen	2	Advil				10.00
3	Antidepressant		3	Sertraline	3	Zoloft				25.00
4	Antiviral			5	Oseltamivir	8	Relenza				32.00
5	Antihistamine		6	Cetirizine	6	Zyrtec				12.50
*/


------------------------------------------------------------------------------------------------------------------
-----5. showing a list of drug names and their new prices with a 3% increase -------------------------------------
------------------------------------------------------------------------------------------------------------------

select * from [dbo].[commercial_tbl]

select commercial_name as drug_name, commercial_price * 1.03 as new_price
from commercial_tbl
order by commercial_name

/*result:
Advil				10.3000
Amoxil				15.9650
Panadol				8.7550
Penicillin-VK		19.3125
Relenza				32.9600
Tamiflu				30.9000
Zoloft				25.7500
Zyrtec				12.8750
*/

---easy peasy
------------------- if u want their generic names instead of commercial names:

select d.drug_genericname as drug_name, c.commercial_price * 1.03 as new_price
from drug_tbl d
	 join commercial_tbl c on d.drug_id = c.drug_id
order by d.drug_genericname

------------------- if u want to put them in a temp table:

-- declare table 
declare @temp_drug_prices table
(
    drug_name varchar(100),
    new_price decimal(10, 2)
)

-- insert data into table 
insert into @temp_drug_prices (drug_name, new_price)
select commercial_name as drug_name, commercial_price * 1.03 as new_price
from commercial_tbl
order by commercial_name


--  the report 
select drug_name, new_price
from @temp_drug_prices
order by drug_name

/*result
Advil			10.30
Amoxil			15.97
Panadol			8.76
Penicillin-VK	19.31
Relenza			32.96
Tamiflu			30.90
Zoloft			25.75
Zyrtec			12.88
*/
