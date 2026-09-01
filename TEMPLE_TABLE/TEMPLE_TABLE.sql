--TEMPLE TABLE;
--Veritabaninda kalici olarak yer kaplamayan sadece o anki oturumda var olan "kullan-at" tablolardir.
-- BAÞINA ' # ' isareti alir.
--INSERT INTO #Ogrenciler VALUES ('Ali', 85); gibi manuel eklemede yapilabilir.

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

--Senaryo

--Satýs ekibi diyor ki: "2011 yýlýnda siparis vermis müsterilerin,
--her birinin toplam kac siparis verdigini ve toplam ne kadar harcadigini (TotalDue) gösteren bir liste istiyoruz.
--Sadece toplamda 3'ten fazla siparis vermis müsterileri görmek istiyoruz."


create table #DenemeVol1 (
	CustomerID int,
	OrderCount int,
	TotalSpent decimal(18,2)
	)
--ALTER TABLE #DenemeVol1 -- Mevcut bir kolonun veri tipini degistirmek icin.
--ALTER COLUMN TotalSpent Decimal(18,2);

--ALTER TABLE #DenemeVol1  -- Yeni bir kolon ekelemk icin.
--ADD YeniKolon Ad nvarchar(50);

--ALTER TABLE #DenemeVol1   -- Mevcut bir kolonu silmek icin.
--DROP COLUMN TotalSpent;

insert into #DenemeVol1 (CustomerID, OrderCount, TotalSpent)
select 
	c.CustomerID,	
	count(*) as OrderCount,
	sum(soh.totaldue) as TotalSpent
from sales.SalesOrderHeader soh
left join sales.Customer c on soh.CustomerID = c.CustomerID
where year(soh.orderdate) = 2013
group by c.CustomerID
having count(*) > 3 


select * from #DenemeVol1 order by TotalSpent desc

