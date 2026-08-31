--Ýþ Senaryosu

--CRM ekibi diyor ki:

--"Sisteme kayýtlý ama hiç sipariþ vermemiþ müþterileri listeleyin."

--Ýstenen kolonlar:

--CustomerID
--CustomerName
--CustomerType
--TerritoryID

select 
	c.customerid as CustomerID,  
	coalesce(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
	--COALESCE fonksiyonu, kendisine verilen parametrelerden boþ (NULL) olmayan ilk deðeri seçer.
	--Önce bireysel müþterinin adýný ve soyadýný birleþtirmeyi dener (p.FirstName + ' ' + p.LastName).
	--Eðer bu müþteri bireysel deðilse (yani isim bilgisi NULL ise), o zaman maðaza adýný (s.Name) alýr.
	case when c.personid is null then 'Store'
		 else 'Person' end as Customertype,
	TerritoryID as TerritoryID
from sales.Customer c 
left join person.person p on c.PersonID = p.BusinessEntityID
LEFT JOIN sales.Store s ON c.StoreID = s.BusinessEntityID
where not exists ( select 1 from sales.salesorderheader soh where c.CustomerID =soh.CustomerID)
--NOT EXISTS; hiçbir sonuç bulamamasýný þart koþar.
--Eðer müþterinin sipariþi varsa alt sorgu bir eþleþme bulur ve NOT EXISTS kuralý bozulduðu için o müþteri listeden çýkarýlýr.
--Geriye sadece sipariþ tablosunda hiç kaydý olmayan (hiç satýn alým yapmamýþ) müþteriler kalýr.



/* 
   ÖRNEK 1: EXISTS KULLANIMI
   Senaryo: 2014 yýlý içerisinde en az bir kez sipariþ vermiþ, yani "Aktif" durumdaki 
   müþterilerin listesi. 
*/

SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM Sales.Customer AS c
LEFT JOIN Person.Person AS p 
    ON c.PersonID = p.BusinessEntityID
WHERE EXISTS (
    -- Burada 1 yazmamýzýn nedeni verinin kendisini getirmek deðil, sadece kaydýn var olup olmadýðýný kontrol etmektir.
    SELECT 1 
    FROM Sales.SalesOrderHeader AS soh 
    WHERE soh.CustomerID = c.CustomerID 
      AND YEAR(soh.OrderDate) = 2014
);


/* 
   ÖRNEK 2: NOT EXISTS KULLANIMI
   Senaryo: Sistemde kayýtlý olan ancak bugüne kadar hiç sipariþ vermemiþ "Pasif/Potansiyel" müþteriler.
   
*/

SELECT 
    c.CustomerID,
    c.StoreID,
    c.TerritoryID
FROM Sales.Customer AS c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Sales.SalesOrderHeader AS soh 
    WHERE soh.CustomerID = c.CustomerID
);

