/* 
final exam : pharmacy
Samira BEsharatian
Esfand 1403 
*/

----------------------------------------------------------------------------------------------------------------- 
----------------------------------------------- Creating Database ----------------------------------------------- 
----------------------------------------------------------------------------------------------------------------- 

-- create database pharmacy

-- use pharmacy


create table country_tbl
(
    country_id int primary key,
    country_name nvarchar(100)
)

create table company_tbl 
(
    company_id int primary key,
    company_name nvarchar(100),
    country_id int,
    foreign key (country_id) references country_tbl(country_id)
)


create table insurance_tbl 
(
    insurance_id int primary key,
    insurance_name nvarchar(100)
)


create table type_tbl 
(
    type_id int primary key,
    type_name nvarchar(100)
)


create table drug_tbl
(
    drug_id int primary key,
    drug_genericname nvarchar(100),
    type_id int,
    foreign key (type_id) references type_tbl(type_id)
)


create table commercial_tbl 
(
    commercial_id int primary key,
    commercial_name nvarchar(100),
    company_id int,
    drug_id int,
    commercial_price decimal(10, 2),
    foreign key (company_id) references company_tbl(company_id),
    foreign key (drug_id) references drug_tbl(drug_id)
)


create table prescription_tbl 
(
    prescription_id int primary key,
    prescription_name nvarchar(100),
    prescription_family nvarchar(100),
    prescription_date date,
    insurance_id int,
    foreign key (insurance_id) references insurance_tbl(insurance_id)
)


create table order_tbl (
    order_id int primary key,
    prescription_id int,
    commercial_id int,
    order_measure nvarchar(100),
    foreign key (prescription_id) references prescription_tbl(prescription_id),
    foreign key (commercial_id) references commercial_tbl(commercial_id)
)

