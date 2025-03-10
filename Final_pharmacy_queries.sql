use pharmacy


--------------------------------------------------------------
-----1. To identify drugs that have been made in France ------
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




------------------------------------------------------------------------------------------
-----1. To identify the number of prescriptions that contains drugs made in France -------
------------------------------------------------------------------------------------------
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
where p.prescription_date >= '2024-01-01' AND p.prescription_date < '2025-01-01'
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
where p.prescription_date >= '2024-03-10' AND p.prescription_date < '2025-03-10'
group by i.insurance_id, i.insurance_name
having count(p.prescription_id) > 100;

/* result:
Blue Cross	158
Aetna	174
UnitedHealthcare	162
*/

------------------------------------------------------------------------------------------------------------------
-----3. To identify the name of insurance companies that had more than 100 prescroptions in previous year  -------
------------------------------------------------------------------------------------------------------------------
