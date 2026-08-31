--STORED PROCEDURE; 
--SQL sorgularýný ve iþlemlerini veritabanýnda isim vererek saklamamýzý saðlar.
--Bir sorguyu tekrar tekrar yazmak yerine procedure'ü çaðýrýrýz.

CREATE PROCEDURE usp_GetSalesbyYear 
	@Year INT
		
AS
BEGIN
	SET NOCOUNT ON -- Hatalarý engellemek ve performansý artýrmak için(Row Count mesajlarýný bastýrýr).
IF (

		SELECT 
			count(*) as OrderCount
		FROM sales.salesorderheader
		WHERE year(orderdate) = @Year) > 0

BEGIN

		SELECT	
			Year(orderdate) AS SalesYear,
			COUNT(*) AS OrderCount,
			SUM(Totaldue) AS TotalSales,
			AVG(Totaldue) AS AvgOrderValue
		FROM Sales.SalesOrderHeader
		WHERE Year(orderdate) = @Year
		GROUP BY Year(orderdate)
END
ELSE
BEGIN
	PRINT 'Bu yýla ait satýþ bulunamadý.'
END
END

exec usp_GetSalesbyYear 2012  -- Çaðýrma için kullanýmý.


CREATE OR ALTER PROCEDURE usp_GetSalesByYear
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Year < 2000
       OR @Year > (select year(max(orderdate)) from sales.salesorderheader)
    BEGIN
        PRINT 'Geçersiz yýl.';
        RETURN; -- Procedure'yi sonlandýrýr.
    END

    IF (SELECT 
			count(*) as OrderCount
		FROM sales.salesorderheader
		WHERE year(orderdate) = @Year) > 0
    BEGIN
        SELECT	
			Year(orderdate) AS SalesYear,
			COUNT(*) AS OrderCount,
			SUM(Totaldue) AS TotalSales,
			AVG(Totaldue) AS AvgOrderValue
		FROM Sales.SalesOrderHeader
		WHERE Year(orderdate) = @Year
		GROUP BY Year(orderdate)
    END
    ELSE
    BEGIN
        PRINT 'Bu yýla ait satýþ bulunamadý.';
    END
END
exec usp_GetSalesByYear 2013


CREATE OR ALTER PROCEDURE usp_GetSalesPersonPerformance
    @SalesPersonID INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. SalesPerson var mý?
    IF EXISTS (select 1 from sales.SalesPerson where BusinessEntityID = @SalesPersonID)
    BEGIN
        -- 2. Bu yýlda satýþý var mý?
        IF EXISTS (select 1 from sales.SalesOrderHeader where SalesPersonID = @SalesPersonID and year(orderdate) = @Year)
        BEGIN
            select
				SalesPersonID as person,
				year(orderdate) as salesyear,
				count(*) as ordercount,
				sum(totaldue) as totalsales,
				avg(totaldue) as avgordervalue
			from sales.SalesOrderHeader
			where salespersonid = @salespersonID and year(orderdate) = @year 
			group by year(orderdate), SalesPersonID
        END
        ELSE
        BEGIN
            PRINT 'Bu satýþ temsilcisinin bu yýlda satýþý bulunamadý.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Geçersiz SalesPersonID.';
        RETURN;
    END
END

EXEC usp_GetSalesPersonPerformance
    @SalesPersonID = 276,
    @Year = 2013;

CREATE OR ALTER PROCEDURE usp_GetSalesPersonPerformance
    @SalesPersonID INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. SalesPerson gerçekten var mý?
    IF NOT EXISTS
    (
        SELECT 1
        FROM Sales.SalesPerson
        WHERE BusinessEntityID = @SalesPersonID
    )
    BEGIN
        PRINT 'Geçersiz SalesPersonID.';
        RETURN;
    END;

    -- 2. Asýl SELECT
    SELECT
        SalesPersonID,
        YEAR(OrderDate) AS SalesYear,
        COUNT(*) AS OrderCount,
        SUM(TotalDue) AS TotalSales,
        AVG(TotalDue) AS AverageOrderValue
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID = @SalesPersonID
      AND YEAR(OrderDate) = @Year
    GROUP BY SalesPersonID, YEAR(OrderDate);

    IF @@ROWCOUNT = 0 -- @@ROWCOUNT: En son çalýþtýrýlan SQL ifadesinin kaç satýr etkilediðini/döndürdüðünü verir
BEGIN
    PRINT 'Bu satýþ temsilcisinin bu yýlda satýþý bulunamadý.';
END
END
EXEC usp_GetSalesPersonPerformance
    @SalesPersonID = 276,
    @Year = 2018;
