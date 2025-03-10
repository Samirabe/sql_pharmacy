use pharmacy

-- Insert data into country_tbl
INSERT INTO country_tbl (country_id, country_name) VALUES
(1, 'USA'),
(2, 'France'),
(3, 'UK'),
(4, 'Germany');

-- Insert data into company_tbl
INSERT INTO company_tbl (company_id, company_name, country_id) VALUES
(1, 'Pfizer', 1),          -- USA
(2, 'Sanofi', 2),          -- France
(3, 'Bayer', 4),           -- Germany
(4, 'GlaxoSmithKline', 3); -- UK

-- Insert data into insurance_tbl
INSERT INTO insurance_tbl (insurance_id, insurance_name) VALUES
(1, 'Blue Cross'),
(2, 'Aetna'),
(3, 'UnitedHealthcare'),
(4, 'OtherInsurance');

-- Insert data into type_tbl
INSERT INTO type_tbl (type_id, type_name) VALUES
(1, 'Antibiotic'),
(2, 'Analgesic'),
(3, 'Antidepressant');

-- Insert data into drug_tbl
INSERT INTO drug_tbl (drug_id, drug_genericName, type_id) VALUES
(1, 'Amoxicillin', 1),
(2, 'Ibuprofen', 2),
(3, 'Sertraline', 3),
(4, 'Paracetamol', 2);

-- Insert data into commercial_tbl
INSERT INTO commercial_tbl (commercial_id, commercial_name, company_id, drug_id, commercial_price) VALUES
(1, 'Amoxil', 2, 1, 15.50),    -- Sanofi (France) - Amoxicillin
(2, 'Advil', 1, 2, 10.00),     -- Pfizer (USA) - Ibuprofen
(3, 'Zoloft', 3, 3, 25.00),    -- Bayer (Germany) - Sertraline
(4, 'Panadol', 4, 4, 8.50);    -- GlaxoSmithKline (UK) - Paracetamol

-- Insert data into prescription_tbl with bulk insert and random data
;WITH NumberSequence AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number
    FROM master.dbo.spt_values a
    CROSS JOIN master.dbo.spt_values b
    WHERE a.number < 50 -- Generates enough rows (e.g., ~2500)
),
PrescriptionData AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY number) AS prescription_id,
        'Prescription_' + RIGHT('000' + CAST(ROW_NUMBER() OVER (ORDER BY number) AS VARCHAR(3)), 3) AS prescription_name,
        'Family_' + CHAR(65 + ABS(CHECKSUM(NEWID()) % 26)) AS prescription_family,
        DATEADD(day, -ABS(CHECKSUM(NEWID()) % 70), CAST('2025-03-10' AS DATE)) AS prescription_date,
        CASE
            WHEN ROW_NUMBER() OVER (ORDER BY number) <= 120 THEN 1  -- Blue Cross (120)
            WHEN ROW_NUMBER() OVER (ORDER BY number) <= 270 THEN 2  -- Aetna (150)
            WHEN ROW_NUMBER() OVER (ORDER BY number) <= 400 THEN 3  -- UnitedHealthcare (130)
            ELSE 4                                                  -- OtherInsurance (50)
        END AS insurance_id
    FROM NumberSequence
)
INSERT INTO prescription_tbl (prescription_id, prescription_name, prescription_family, prescription_date, insurance_id)
SELECT prescription_id, prescription_name, prescription_family, prescription_date, insurance_id
FROM PrescriptionData
WHERE prescription_id <= 450; -- Limit to 450 rows

-- Insert data into order_tbl with bulk insert and random data
;WITH NumberSequence AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number
    FROM master.dbo.spt_values a
    CROSS JOIN master.dbo.spt_values b
    WHERE a.number < 50 -- Generates enough rows
),
OrderData AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY number) AS order_id,
        ROW_NUMBER() OVER (ORDER BY number) AS prescription_id,
        ABS(CHECKSUM(NEWID()) % 4) + 1 AS commercial_id,
        CASE ABS(CHECKSUM(NEWID()) % 3)
            WHEN 0 THEN '200mg'
            WHEN 1 THEN '500mg'
            ELSE '1000mg'
        END AS order_measure
    FROM NumberSequence
)
INSERT INTO order_tbl (order_id, prescription_id, commercial_id, order_measure)
SELECT order_id, prescription_id, commercial_id, order_measure
FROM OrderData
WHERE order_id <= 450; -- Limit to 450 rows




------------------------------------------
------------------ Verification-----------
------------------------------------------

SELECT i.insurance_name, COUNT(p.prescription_id) as prescription_count
FROM insurance_tbl i
LEFT JOIN prescription_tbl p ON i.insurance_id = p.insurance_id
GROUP BY i.insurance_id, i.insurance_name
HAVING COUNT(p.prescription_id) > 100;

----------------------------------------
--------- adding some other data--------
----------------------------------------


-- Add new countries
INSERT INTO country_tbl (country_id, country_name) VALUES
(5, 'Canada'),
(6, 'Japan');

-- Add new companies
INSERT INTO company_tbl (company_id, company_name, country_id) VALUES
(5, 'AstraZeneca', 3),  -- UK (existing country)
(6, 'Apotex', 5),       -- Canada (new country)
(7, 'Takeda', 6);       -- Japan (new country)

-- Add new insurance companies
INSERT INTO insurance_tbl (insurance_id, insurance_name) VALUES
(5, 'Cigna'),
(6, 'Humana');

-- Add new drug types
INSERT INTO type_tbl (type_id, type_name) VALUES
(4, 'Antiviral'),
(5, 'Antihistamine');

-- Add new drugs
INSERT INTO drug_tbl (drug_id, drug_genericName, type_id) VALUES
(5, 'Oseltamivir', 4),   -- Antiviral
(6, 'Cetirizine', 5),    -- Antihistamine
(7, 'Penicillin', 1);    -- Antibiotic (existing type)

-- Add new commercial products
INSERT INTO commercial_tbl (commercial_id, commercial_name, company_id, drug_id, commercial_price) VALUES
(5, 'Tamiflu', 5, 5, 30.00),     -- AstraZeneca (UK) - Oseltamivir
(6, 'Zyrtec', 6, 6, 12.50),      -- Apotex (Canada) - Cetirizine
(7, 'Penicillin-VK', 7, 7, 18.75), -- Takeda (Japan) - Penicillin
(8, 'Relenza', 1, 5, 32.00);      -- Pfizer (USA) - Oseltamivir (same drug, different commercial name)

-- Add new prescriptions (30 records)
;WITH NumberSequence AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number
    FROM master.dbo.spt_values a
    WHERE a.number < 30 -- Generate 30 rows
),
PrescriptionData AS (
    SELECT
        450 + ROW_NUMBER() OVER (ORDER BY number) AS prescription_id, -- Start after existing 450
        'Prescription_' + RIGHT('000' + CAST(450 + ROW_NUMBER() OVER (ORDER BY number) AS VARCHAR(3)), 3) AS prescription_name,
        'Family_' + CHAR(65 + ABS(CHECKSUM(NEWID()) % 26)) AS prescription_family,
        DATEADD(day, -ABS(CHECKSUM(NEWID()) % 30), CAST('2025-03-10' AS DATE)) AS prescription_date,
        ABS(CHECKSUM(NEWID()) % 6) + 1 AS insurance_id -- Randomly assign to insurance companies 1-6
    FROM NumberSequence
)
INSERT INTO prescription_tbl (prescription_id, prescription_name, prescription_family, prescription_date, insurance_id)
SELECT prescription_id, prescription_name, prescription_family, prescription_date, insurance_id
FROM PrescriptionData;

-- Add new orders (30 records, linked to the new prescriptions)
;WITH NumberSequence AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS number
    FROM master.dbo.spt_values a
    WHERE a.number < 30 -- Generate 30 rows
),
OrderData AS (
    SELECT
        450 + ROW_NUMBER() OVER (ORDER BY number) AS order_id, -- Start after existing 450
        450 + ROW_NUMBER() OVER (ORDER BY number) AS prescription_id, -- Match new prescription IDs
        ABS(CHECKSUM(NEWID()) % 8) + 1 AS commercial_id, -- Randomly assign to commercial products 1-8
        CASE ABS(CHECKSUM(NEWID()) % 3)
            WHEN 0 THEN '200mg'
            WHEN 1 THEN '500mg'
            ELSE '1000mg'
        END AS order_measure
    FROM NumberSequence
)
INSERT INTO order_tbl (order_id, prescription_id, commercial_id, order_measure)
SELECT order_id, prescription_id, commercial_id, order_measure
FROM OrderData;


----------------------------------verifacation ----------------------------------------

SELECT i.insurance_name, COUNT(p.prescription_id) as prescription_count
FROM insurance_tbl i
LEFT JOIN prescription_tbl p ON i.insurance_id = p.insurance_id
GROUP BY i.insurance_id, i.insurance_name
ORDER BY prescription_count DESC;
 --------------------------------------------------------------------------------------

SELECT TOP 5 * FROM prescription_tbl
WHERE prescription_id > 450
ORDER BY prescription_id;

SELECT TOP 5 * FROM order_tbl
WHERE order_id > 450
ORDER BY order_id;