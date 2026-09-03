--PIVOT, UNPIVOT
--Satir halinde duran veriyi sutun haline cevirirken kullaniriz.

--Ýþ Senaryosu

--Finans ekibi diyor ki:

--"Her müþterinin 2012, 2013 ve 2014 yýllarýndaki toplam harcamasýný
--(TotalDue) yan yana üç ayrý sütunda görmek istiyoruz."

--Ýstenen kolonlar:
--CustomerID
--2012
--2013
--2014

--CASE WHEN ÝLE;
select customerID,
	sum(case when year(orderdate) = 2012 then totaldue else 0 end) as [2012],
	sum(case when year(orderdate) = 2013 then totaldue else 0 end) as [2013],
	sum(case when year(orderdate) = 2014 then totaldue else 0 end) as [2014]
from sales.salesorderheader
group by CustomerID

--PIVOT ÝLE;
SELECT *
FROM (
    select  -- Ham veri burada yer aliyor.
		CustomerID, 
		year(orderdate) as year,
		totaldue
	from sales.SalesOrderHeader
) AS SourceData
PIVOT (
    SUM(TotalDue) -- Hangi kolonun toplanacaðini belirtiyor.
    FOR [year] IN ([2012], [2013], [2014]) -- Hangi kolnun sütun basliklarina donusecegini gosteriyor.
) AS PivotTable;

SELECT *
FROM (
    select  -- Ham veri burada yer aliyor.
		CustomerID, 
		year(orderdate) as year,
		totaldue
	from sales.SalesOrderHeader
) AS SourceData
PIVOT (
    SUM(TotalDue) -- Hangi kolonun toplanacaðini belirtiyor.
    FOR [year] IN ([2012], [2013], [2014]) -- Hangi kolnun sütun basliklarina donusecegini gosteriyor.
) AS PivotTable;

--UNPIVOT ÝLE;
SELECT CustomerID, OrderYear, TotalDue
FROM (
    SELECT *
    FROM (
        SELECT 
            CustomerID,
            YEAR(OrderDate) AS OrderYear,
            TotalDue
        FROM Sales.SalesOrderHeader
    ) AS SourceData
    PIVOT (
        SUM(TotalDue)
        FOR OrderYear IN ([2012], [2013], [2014])
    ) AS PivotTable
) AS PivotedData
UNPIVOT (
    TotalDue FOR OrderYear IN ([2012], [2013], [2014])
) AS UnpivotedData;