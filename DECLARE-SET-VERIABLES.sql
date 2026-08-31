--DECLARE;
-- Deðiþken oluþturur.

--SET;
-- Deðiþkene deðer atar.
-- Genellikle tek bir deðer atamak için kullanýlýr.

--SELECT @variable = ...
-- SELECT sonucunu deðiþkene atar.
-- Ayný SELECT ile birden fazla deðiþkene deðer atanabilir.




DECLARE @EnYuksekSatis MONEY;
SELECT @EnYuksekSatis = MAX(salesytd)
FROM sales.SalesPerson
IF  @EnYuksekSatis > 500000
BEGIN
	PRINT 'Þirket rekor satýþ hedefine ulaþtý!'

	SELECT BusinessEntityID,
	   SalesYTD,
	   Bonus
	FROM sales.salesperson
	WHERE SalesYTD = @EnYuksekSatis
END
ELSE
BEGIN
	PRINT 'Hedef henüz aþýlmadý'
END
--"Sorgunun içindeki bir kolona deðer yazdýrýrken þarta göre (örneðin 100'den büyükse 'Zengin' yazsýn) karar vereceðim" diyorsan ?? CASE WHEN

--"Bir deðiþkene bakacaðým, o deðiþkene göre ya A tablosuna INSERT yapacaðým ya da B tablosundan SELECT yapacaðým" diyorsan ?? IF / ELSE

--Eðer SET ile yapacak olursak;
DECLARE @EnYuksekSatis MONEY;
DECLARE @Hedef MONEY;

SET @Hedef = 5000000;

SELECT @EnYuksekSatis = MAX(SalesYTD)
FROM Sales.SalesPerson;

IF @EnYuksekSatis >= @Hedef
BEGIN
    PRINT 'Þirket satýþ hedefini aþtý.';

    SELECT
        BusinessEntityID,
        SalesYTD,
        Bonus
    FROM Sales.SalesPerson
    WHERE SalesYTD = @EnYuksekSatis;
END
ELSE
BEGIN
    PRINT 'Þirket satýþ hedefinin altýnda.';
END;