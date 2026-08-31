--İş Senaryosu

--CRM ekibi diyor ki:

--"Sisteme kayıtlı ama hiç sipariş vermemiş müşterileri listeleyin."

--İstenen kolonlar:

--CustomerID
--CustomerName
--CustomerType
--TerritoryID

select 
	c.customerid as CustomerID,  
	coalesce(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
	--COALESCE fonksiyonu, kendisine verilen parametrelerden boş (NULL) olmayan ilk değeri seçer.
	--Önce bireysel müşterinin adını ve soyadını birleştirmeyi dener (p.FirstName + ' ' + p.LastName).
	--Eğer bu müşteri bireysel değilse (yani isim bilgisi NULL ise), o zaman mağaza adını (s.Name) alır.
	case when c.personid is null then 'Store'
		 else 'Person' end as Customertype,
	TerritoryID as TerritoryID
from sales.Customer c 
left join person.person p on c.PersonID = p.BusinessEntityID
LEFT JOIN sales.Store s ON c.StoreID = s.BusinessEntityID
where not exists ( select 1 from sales.salesorderheader soh where c.CustomerID =soh.CustomerID)
--NOT EXISTS; hiçbir sonuç bulamamasını şart koşar.
--Eğer müşterinin siparişi varsa alt sorgu bir eşleşme bulur ve NOT EXISTS kuralı bozulduğu için o müşteri listeden çıkarılır.
--Geriye sadece sipariş tablosunda hiç kaydı olmayan (hiç satın alım yapmamış) müşteriler kalır.



/* 
   ÖRNEK 1: EXISTS KULLANIMI
   Senaryo: 2014 yılı içerisinde en az bir kez sipariş vermiş, yani "Aktif" durumdaki 
   müşterilerin listesi. 
*/

SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM Sales.Customer AS c
LEFT JOIN Person.Person AS p 
    ON c.PersonID = p.BusinessEntityID
WHERE EXISTS (
    -- Burada 1 yazmamızın nedeni verinin kendisini getirmek değil, sadece kaydın var olup olmadığını kontrol etmektir.
    SELECT 1 
    FROM Sales.SalesOrderHeader AS soh 
    WHERE soh.CustomerID = c.CustomerID 
      AND YEAR(soh.OrderDate) = 2014
);


/* 
   ÖRNEK 2: NOT EXISTS KULLANIMI
   Senaryo: Sistemde kayıtlı olan ancak bugüne kadar hiç sipariş vermemiş "Pasif/Potansiyel" müşteriler.
   
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

