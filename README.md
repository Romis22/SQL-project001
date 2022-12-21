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

Postup a komentář:
1)
- Dle propojení czechia_payroll_value_type cpvt ON cpvt.code = cp.value_type_code jsem zjistil, že je potřeba vyfiltrovat výsledky pouze s cp.value_type_code = 5958 - kde kód 5958 počítá průměrnou hrubou mzdu na zaměstnance. Sloupce jsem pro přehlednost skryl.
- Pro přesnost dat a jistotu při zpracování dat vylučují hodnoty cp.value, které jsou NULL.
- Ověřil jsem si, že všechny jednotky hrubé mzdy jsou v Kč a sloupce jsem pro přehlednost skryl.
- Zvolil jsem calculation code = 100. Znamená to, že jsou započítané jen fyzické hrubé mzdy platné pro celé úvazky. Kód 200 platí pro přepočtené výsledky částečných úvázku přepočtených na celé. Takovéto úvazky jsou lépe placené než úvazky plné. Pro přesnost by bylo potřeba udělat vážený průměr, který z dostupných dat udělat nelze.
- 86 a 86 záznamů s cp.industry_branch_code je NULL -> vyřazuji.
- Vypočítal jsem průměrnou mzdu na jednotlivé roky tzn. průměr z čtvrtletí.
- Pro přehlednější následný zápis vytvářím pohled v_czechia_payroll_by_field_year.
- Pro výpočet růstu jsem použil JOIN na pohled sám na sebe s posunutým rokem.
- Rok pro base.`year` nemůže být použit, protože nemáme výsledky pro rok 2000, nemáme data k předcházejícímu datu. Měříme tedy období růstu či snížení meziročně v letech 2001 - 2021.
- Pro jistotu jsem prověřil, zda v některém z oborů klesla mzda mezi rokem 2000 a 2021. Všechny obory z roku 2000 do roku 2021 narostly o více než 129%.
2)
- Zjistil jsem kódy pro mléko a chleba pomocí klauzule LIKE a ověřil jsem si, že jiné podobné produkty nejsou v tabulce.
- Zjistil jsem že roky pro porovnání cen jsou 2006 až 2018, mzdy jsou pro roky 2000 až 2021. Srovnatelné období je tedy roky 2006 a 2018.
- Propojil jsem tabulky czechia_price s czechia_price_category pomocí kódu a vytvořil pohled v_czech_price_milk_bread_2006_2018 s rokem, názvem, průměrnou cenou v daném roce a jednotkou daného produktu.
- Vytvořil jsem pohled v_czech_payroll_year_2006_2018 s minimální, průměrnou a maximální mzdou v letech 2006 a 2018. Použil jsem již vytvořený pohled z minulého úkolu v_czechia_payroll_by_field_year
- Vytvořené pohledy jsem spojil přes rok a výpočtem jsem stanovil množství produktů, které bylo za roky 2006 a 2018 koupit.
- Výsledky jsem rozdělil na 3 kategorie. Množství daného produktu, které je možné koupit v dané roky za minimální, průměrnou a maximální průměrnou mzdu v oboru.
3)
- Tabulku czech_price jsem spojil s category_code pro spojení s názevem položky.
- Z tabulky czech_price jsem pomocí funkce YEAR vyselektoval rok a pomocí následné agregace jsem vypočítal průměrnou roční cenu jednotlivých položek.
- Toto jsem uložil jako pohled v_czechia_price_by_years_categories.
- Dále jsem spojil pohled sám na sebe pro určení meziročních růstů.
- V první variantě jsem hledal nejnižší růsty v celém období mezi lety 2006 až 2018.
- V druhé variantě jsem hledal nejnižší růsty v jednom z roků mezi lety 2006 až 2018.
4)
- Z pohledů v_czechia_price_by_years_categories a v_czechia_payroll_by_field_year jsem agregoval průměrné ceny a mzdy za jednotllivé roky.
- Tyto pohledy jsem sjednotil přes LEFT JOIN do jednoduchého pohledu.
- Následně jsem pohled použil pro stanovení procentuálního růstu cen a mezd mezi jednotlivými roky a to pomocí spojení JOIN toho samého pohledu o rok později.
- Následně jsem vypočítal procentuální růsty a poklesy cen a mezd.
- Mezi procentuálním růstem nebo poklesem cen a mezd jsem vypočítal rozdíl. Ten jsem seřadil od nejvýššího a stanovil limit 1.
5)
- Vytvořil jsem si pohled v_avgPriciesPaysAndCzGDP, ve kterém jsem napojil pohled v_avgpriciesandpays z minulého úkolu (průměrné ceny potravin a průměrné mzdy v letech).
- Na tento pohled jsem napojil HDP v ČR pomocí roku. Dále jsem vytvořený pohled napojil pomocí funkce JOIN sám na sebe a vypočítal procentuální nárůst nebo pokles mezd, cen potravin a HDP v letech 2007 až 2018.
- Pro přehlednější hledání korelací jsem z výše psaného vytvořil pohled v_GDPcorellation. Ten jsem opět pomocí funkce JOIN napojil sám na sebe s posunem 1 roku.
- Při připojení jsem vypočítal procentuální rozdíly mezi HDP a cenami potravin, mzdami ve stejném roce a v roce následujícím.
- Zjistil jsem že čísla nekorelují a to ani trendově tzn. pro každou kategorii jsou velké číselné rozdíly a hodnoty jsou záporné i kladné.
- Lepší způsob, jak zkontrolovat korelace jsou grafy, kde jsou výsledky a korelace viditelné z prvního pohledu.