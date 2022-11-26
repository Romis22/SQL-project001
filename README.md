SQL První projekt - Engeto
===

Úkolem projektu je zodpovězení 5 otázek z dostupných dat:
1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Čistá sada SQL vytvořená pro odpověďi je v souboru Project_001.sql.
SQL sada se zodpovězením otázek a s postupem je v sadě Project_001_comment.sql.

Odpovědi na dotazy:
1) V průběhu let mzda klesala v některých oborech a v různých letech. Z tabulky je vidět, že nejvýraznější snížení mezd bylo v roce 2013
pro obor Peněžictví a pojišťovnictví kolem 9%.
2) V roce 2006 bylo možné koupit chleba za celoroční mzdu: minimálně 689 kg, průměrně 1262 kg a maximálně 2441 kg.
V roce 2006 bylo možné koupit mléko za celoroční mzdu: minimálně 769 l, průměrně 1409 l a maximálně 2725 l.
V roce 2018 bylo možné koupit chleba za celoroční mzdu: minimálně 754 kg, průměrně 1319 kg a maximálně 2289 kg.
V roce 2018 bylo možné koupit mléko za celoroční mzdu: minimálně 922 l, průměrně 1614 l a maximálně 2799 l.
Z čísel je patrné že za minimální a průměrnou mzdu je možné v roce 2018 koupit více mléka i chleba než v roce 2006.
Za maximální mzdu v roce 2018 je možné koupit méně chleba než v roce 2006. Cena mléka pravděpobně stoupala v 2006 až 2018 pomaleji.
3) Během let 2007 až 2018 existují položky, které cenově nerostly, ale dokonce jejich cena klesala.
Nejvýraznější položkou s průměrným meziročním poklesem je Cukr krystalový, kde jeho průměrný meziroční pokles je -1,92%.
V roce 2016 jeho průměrná cena byla 21,73 Kč a v roce 2018 jeho průměrná cena byla 15,75 Kč.
Maximální meziroční pokles byl u položky Rajská jablka červená kulatá v roce 2007 s -30,28%.
4) V roce 2013 byl nárůst cen potravin o 5,1% zatímco mzdy klesly o 1,56%, tedy rozdíl mezi nárůstem cen potravin a poklesem mezd byl 6,66%.
Toto je nejvýraznější rozdíl mezi nárustem cen potravin a poklesem průměrné mzdy.
5) Výška HDP nemá vliv na změny ve mzdách a potravinách. Dle číslených hodnot spolu změny cen nekorelují. Nekorelují spolu ani trendy.