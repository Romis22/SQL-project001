-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
CREATE OR REPLACE VIEW v_czechia_payroll_by_field_year AS
(
SELECT cp.payroll_year AS `year`, ROUND(AVG(cp.value)) AS avgPay, cpib.name AS fieldName
FROM czechia_payroll cp
LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
WHERE cp.value_type_code = 5958 AND cp.value IS NOT NULL AND cp.industry_branch_code IS NOT NULL AND cp.calculation_code = 100
GROUP BY `year`, fieldName
ORDER BY cp.payroll_year
);

SELECT a.`year`, ROUND((100 * (a.avgPay - base.avgPay)/base.avgPay),2) AS yearChange, base.fieldName
FROM v_czechia_payroll_by_field_year base
RIGHT JOIN v_czechia_payroll_by_field_year a ON base.`year` = a.`year` - 1 AND base.fieldName = a.fieldName
WHERE a.`year` != 2000
ORDER BY yearChange, a.`year`, base.fieldName;

-- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
CREATE OR REPLACE VIEW v_czech_price_milk_bread_2006_2018 AS (
SELECT YEAR(cp.date_from) AS year_from_date, cpc.name, ROUND(AVG(cp.value),2) AS avg_price, cpc.price_unit AS unit
FROM czechia_price cp
LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
WHERE ((cpc.name LIKE '%mleko%') AND (YEAR(cp.date_from) IN (2006, 2018))) OR
((cpc.name LIKE '%chleb%') AND (YEAR(cp.date_from) IN (2006, 2018)))
GROUP BY year_from_date, name);

CREATE OR REPLACE VIEW v_czech_payroll_year_2006_2018 AS (
SELECT `year`, MIN(avgPay) AS minPay, MAX(avgPay) AS maxPay, ROUND(AVG(avgPay)) AS avgPay
FROM v_czechia_payroll_by_field_year
WHERE `year` IN (2006, 2018)
GROUP BY `year`
ORDER BY `year`
);

SELECT base.`year`, a.name, 
    ROUND(base.minPay/a.avg_price, 2) AS quantity_min, 
    ROUND(base.avgPay/a.avg_price, 2) AS quantity_avg,
    ROUND(base.maxPay/a.avg_price, 2) AS quantity_max,
    a.unit
FROM v_czech_payroll_year_2006_2018 base
JOIN v_czech_price_milk_bread_2006_2018 a ON base.`year` = a.year_from_date;

-- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
CREATE OR REPLACE VIEW v_czechia_price_by_years_categories AS
(
SELECT YEAR(cp.date_from) AS year_from_date, cpc.name, ROUND(AVG(cp.value),2) AS avg_price
FROM czechia_price cp
LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
GROUP BY year_from_date, cpc.name
);

SELECT base.name, ROUND(AVG(100*(a.avg_price - base.avg_price)/base.avg_price),2) AS yearlyChangeAvg
FROM v_czechia_price_by_years_categories base
JOIN v_czechia_price_by_years_categories a ON base.year_from_date = a.year_from_date - 1 AND base.name = a.name
GROUP BY base.name
ORDER BY yearlyChangeAvg;

SELECT a.year_from_date AS `year`, base.name, ROUND(100*(a.avg_price - base.avg_price)/base.avg_price,2) AS yearlyChange
FROM v_czechia_price_by_years_categories base
JOIN v_czechia_price_by_years_categories a ON base.year_from_date = a.year_from_date - 1 AND base.name = a.name
ORDER BY yearlyChange;

-- Vytvoření tabulky z úkolu.
CREATE TABLE IF NOT EXISTS t_roman_belov_project_SQL_primary_final AS
(
SELECT *
FROM v_czechia_price_by_years_categories prices
LEFT JOIN v_czechia_payroll_by_field_year pay ON
    prices.year_from_date = pay.`year`
);

-- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
CREATE OR REPLACE VIEW v_avgPriciesAndPays AS
(
SELECT a.`year`, base.avgPrice, a.avgPayAllFields
FROM (
    SELECT year_from_date, ROUND(AVG(avg_price),2) AS avgPrice
    FROM v_czechia_price_by_years_categories
    GROUP BY year_from_date) base
LEFT JOIN (
    SELECT `year`, ROUND(AVG(avgPay)) AS avgPayAllFields
    FROM v_czechia_payroll_by_field_year
    GROUP BY `year`) a ON base.year_from_date = a.`year`
);

SELECT a.`year`,
    ROUND(100*(a.avgPrice - base.avgPrice)/base.avgPrice,2) AS yearlyChangePrice,
    ROUND(100*(a.avgPayAllFields - base.avgPayAllFields)/base.avgPayAllFields,2) AS yearlyChangePay,
    ROUND(100*(a.avgPrice - base.avgPrice)/base.avgPrice,2) - ROUND(100*(a.avgPayAllFields - base.avgPayAllFields)/base.avgPayAllFields,2) AS diff
FROM v_avgpriciesandpays base
JOIN v_avgpriciesandpays a ON base.`year` = a.`year` - 1
ORDER BY diff DESC
LIMIT 1;

-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
CREATE OR REPLACE VIEW v_avgPriciesPaysAndCzGDP AS
(
SELECT base.`year`, base.avgPrice, base.avgPayAllFields, a.GDP
FROM v_avgpriciesandpays base
LEFT JOIN (
    SELECT *
    FROM economies e
    WHERE country LIKE 'Czech Republic' AND `year` BETWEEN 2006 AND 2018) a ON base.`year` = a.`year`
);

CREATE OR REPLACE VIEW v_GDPcorellation AS
(
SELECT a.`year`,
    ROUND(100*(a.avgPrice - base.avgPrice)/base.avgPrice,2) AS yearlyChangePrice,
    ROUND(100*(a.avgPayAllFields - base.avgPayAllFields)/base.avgPayAllFields,2) AS yearlyChangePay,
    ROUND(100*(a.GDP - base.GDP)/base.GDP,2) AS YearlyChangeGDP
FROM v_avgpriciespaysandczgdp base
JOIN v_avgpriciespaysandczgdp a ON base.`year` = a.`year` - 1
ORDER BY base.`year`
);

SELECT base.*,
    base.YearlyChangeGDP - base.yearlyChangePrice AS PriceGDP_sameyear,
    base.YearlyChangeGDP - base.yearlyChangePay AS PayGDP_sameyear,
    base.YearlyChangeGDP - a.yearlyChangePrice AS PriceGDP_secondyear,
    base.YearlyChangeGDP - a.yearlyChangePay AS PayGDP_secondyear
FROM v_gdpcorellation base
LEFT JOIN v_gdpcorellation a ON base.`year` = a.`year` - 1;