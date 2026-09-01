--CTE, TEMP TABLE, TABLE VARIABLE;

--CTE (Common Table Expression);

--WITH ile baslar, sadece bir sonraki sorgu boyunca yasar — sanki o sorguya özel, isimlendirilmis bir alt sorgu gibi. Fiziksel olarak hiçbir yerde saklanmaz.

WITH HighValueCustomers AS (
    SELECT CustomerID, SUM(TotalDue) AS TotalSpent
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
    HAVING SUM(TotalDue) > 10000
)
SELECT * FROM HighValueCustomers ORDER BY TotalSpent DESC;

--TEMP TABLE;

--# ile baslar, session boyunca yasar, gerçek bir tablo gibi diskte (aslinda tempdb'de) tutulur,
--üzerine index koyabilirsin, birden fazla sorguda tekrar tekrar kullanabilirsin.

CREATE TABLE #HighValueProducts(
	ProductID int,
	Name nvarchar(50),
	ListPrice decimal(18,2)
	)
INSERT INTO #HighValueProducts
SELECT ProductID, Name, ListPrice
FROM Production.Product
where ListPrice > 1000
SELECT * FROM #HighValueProducts ORDER BY ListPrice DESC;

--TABLE VARIABLE

--Degisken gibi tanımlanır (@ ile), ama içinde tablo verisi tutar:

DECLARE @HighValueProducts TABLE (
    ProductID INT,
    Name NVARCHAR(50),
    ListPrice DECIMAL(18,2)
);

INSERT INTO @HighValueProducts
SELECT ProductID, Name, ListPrice
FROM Production.Product
WHERE ListPrice > 1000;

SELECT * FROM @HighValueProducts;

--Tek seferlik, okunabilirlik icin bir ara adim gerekiyorsa (uzun sorguyu parçalara bölmek) → CTE.
--Recursive bir şey yapman gerekiyorsa (örneğin bir organizasyon şemasinda üst-alt iliskisini gezmek) → CTE zorunlu, diğerleri bunu yapamaz.
--Büyük veriyle çalisiyorsan, birden fazla sorguda tekrar kullanacaksan, index gerekebilir → Temp Table.
--Küçük bir veri seti, stored procedure icinde kısa süreligine kullanacaksan → Table Variable (ama büyük veride kullanma, performans sorunu çıkarir)
