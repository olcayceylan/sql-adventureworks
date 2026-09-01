--DECLARE;
-- Değişken oluşturur.

--SET;
-- Değişkene değer atar.
-- Genellikle tek bir değer atamak için kullanılır.

--SELECT @variable = ...
-- SELECT sonucunu değişkene atar.
-- Aynı SELECT ile birden fazla değişkene değer atanabilir.




DECLARE @EnYuksekSatis MONEY;
SELECT @EnYuksekSatis = MAX(salesytd)
FROM sales.SalesPerson
IF  @EnYuksekSatis > 500000
BEGIN
	PRINT 'Şirket rekor satış hedefine ulaştı!'

	SELECT BusinessEntityID,
	   SalesYTD,
	   Bonus
	FROM sales.salesperson
	WHERE SalesYTD = @EnYuksekSatis
END
ELSE
BEGIN
	PRINT 'Hedef henüz aşılmadı'
END
--"Sorgunun içindeki bir kolona değer yazdırırken şarta göre (örneğin 100'den büyükse 'Zengin' yazsın) karar vereceğim" diyorsan ?? CASE WHEN

--"Bir değişkene bakacağım, o değişkene göre ya A tablosuna INSERT yapacağım ya da B tablosundan SELECT yapacağım" diyorsan ?? IF / ELSE

--Eğer SET ile yapacak olursak;
DECLARE @EnYuksekSatis MONEY;
DECLARE @Hedef MONEY;

SET @Hedef = 5000000;

SELECT @EnYuksekSatis = MAX(SalesYTD)
FROM Sales.SalesPerson;

IF @EnYuksekSatis >= @Hedef
BEGIN
    PRINT 'Şirket satış hedefini aştı.';

    SELECT
        BusinessEntityID,
        SalesYTD,
        Bonus
    FROM Sales.SalesPerson
    WHERE SalesYTD = @EnYuksekSatis;
END
ELSE
BEGIN
    PRINT 'Şirket satış hedefinin altında.';
END;
