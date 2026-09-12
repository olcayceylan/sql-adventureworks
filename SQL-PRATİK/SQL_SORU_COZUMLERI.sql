use AdventureWorks2022


--1. Müþterinin en son sipariþ ve Gün farký
with sonsiparis as 
( 
	select c.CustomerID as musteriid,
		   soh.SalesOrderID as siparisid,
		   soh.OrderDate as siparistarihi,
		   soh.TotalDue as toplamtutar,
		   DATEDIFF(DAY, soh.OrderDate, getdate()) as gun_sayisi,
		   row_number()over(partition by c.CustomerID order by soh.OrderDate desc) as rn
	from sales.Customer c
	join sales.SalesOrderHeader soh
		on c.CustomerID = soh.CustomerID
) 
select musteriid,
	   siparisid,
	   siparistarihi,
	   toplamtutar,
	   gun_sayisi
from sonsiparis
	   where rn = 1



--2. Kategori Bazýnda En Karlý Ürün
/*Soru:
Her ürün kategorisinde en fazla toplam kâr getiren ürünü bulun.
Kâr = LineTotal - (UnitPrice * 0.7 * OrderQty) formülüyle hesaplanacaktýr.*/

select * from sales.SalesOrderDetail
select * from Production.Product
select * from Production.ProductCategory
select*from Production.ProductSubcategory
select
*
from(
select *,
	row_number()over(partition by kategori order by kar desc) as rn
from(
SELECT p.name as urun, pc.name as kategori, sum(sod.LineTotal - (UnitPrice * 0.7 * OrderQty)) as Kar
FROM sales.salesorderdetail sod
left join Production.Product p on sod.ProductID = p.ProductID
left join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
left join Production.ProductCategory pc on pc.ProductCategoryID = psc.ProductCategoryID
group by p.name, pc.name
) tbl
)tbl2
where rn = 1

	

 /*3. Aylýk Satýþ ve 3 Aylýk Hareketli Ortalama

Soru:
Her ay için toplam satýþ tutarýný bulun ve ayný zamanda son 3 ayýn ortalama satýþýný gösterin.
*/

with ayliktoplamsatis as (
select year(soh.orderdate) yil,
	   month(soh.orderdate) ay,
	   sum(sod.orderqty * sod.unitprice)as toplamtutar
from sales.salesorderdetail sod
join sales.salesorderheader soh
	on sod.salesorderid = soh.salesorderid
group by year(soh.orderdate),month(soh.orderdate)
)
select	yil,
		ay,
		toplamtutar,
		avg(toplamtutar)over(order by yil, ay rows between 2 preceding and current row) as son3aysatisort
from ayliktoplamsatis
order by yil,ay




/*4. Soru:
Satýþ temsilcilerinin toplam satýþlarýný hesaplayýn.
Toplam satýþa göre “High”, “Medium” veya “Low” performans sýnýfýna ayýrýn.
Sadece 100’ten fazla sipariþ almýþ temsilciler gösterilsin.*/

select * from sales.SalesPerson
select * from person.person
select * from Sales.SalesOrderHeader

select 
		sp.BusinessEntityID, p.FirstName as ad, p.LastName as soyad,
	   sum(soh.totaldue) as toplamtutar,
	   count(soh.SalesOrderID) as siparissayisi,
	   case when sum(soh.TotalDue) >= 5000000 then 'high'
			when sum(soh.TotalDue) >= 2000000 then 'medium'
			else 'low' 
	   end as perfomansseviye
from sales.SalesOrderHeader soh
join sales.SalesPerson sp
	on soh.SalesPersonID = sp.BusinessEntityID
join person.person p
	on sp.BusinessEntityID = p.BusinessEntityID
group by p.FirstName, p.LastName, sp.BusinessEntityID
having count(soh.salesorderid) > 100


/*5. Soru:
AdventureWorks’te henüz hiç sipariþi olmayan ürünleri listeleyin.*/


select p.ProductID, p.name from Production.Product p
where not exists (select 1 from sales.SalesOrderDetail soh where p.productid = soh.ProductID)



/*6. Ayný Gün Birden Fazla Sipariþ Veren Müþteriler
Soru:
Ayný gün içinde birden fazla sipariþ veren müþterileri bulun.
Müþteri adý, tarih ve sipariþ sayýsýný listeleyin.*/

select * from sales.customer
select * from person.person
select * from sales.SalesOrderDetail
select * from sales.SalesOrderHeader

select p.FirstName as musteriAdi,
	   cast(soh.orderdate as date) as siparistarihi, --Ayný gün için date e düþürülmeli.  --(orderdate diye alsaydýk direkt cast yapmadan, saatide alacaðýndan karýþacaktý)
	   count(soh.salesorderid) as siparissayisi
from sales.SalesOrderHeader soh 
join sales.customer c
	on soh.CustomerID = c.CustomerID
join person.person p
	on c.PersonID = p.BusinessEntityID
group by p.FirstName, soh.OrderDate
having count(soh.SalesOrderID) > 1


/*7. Ortalama Fiyatýn Üzerinde Satýlan Ürünler

Soru:
Satýþ detaylarýndaki ortalama birim fiyatýn üzerinde satýlmýþ ürünleri listeleyin.
Ürün adý, birim fiyat ve farkýný gösterin.*/



select 
	   p.Name as uruAdi,
	   sod.UnitPrice as birim_fiyat,	   
	   UnitPrice - (select avg(unitprice) from sales.SalesOrderDetail) as fark	   
from sales.SalesOrderDetail sod
join Production.Product p
	on sod.ProductID = p.ProductID
where UnitPrice > ( select avg(unitprice) from sales.SalesOrderDetail)



/*8. En Son Sipariþten Bu Yana Geçen Gün Sayýsý

Soru:
Her müþterinin en son sipariþ tarihini bulun ve bugüne kadar kaç gün geçtiðini hesaplayýn.*/

select CustomerID, max(orderdate) as son_gun, DATEDIFF(day, max(orderdate), GETDATE()) as gun_farki
from sales.SalesOrderHeader
group by CustomerID

/*9. Ürün Bazýnda En Yüksek Satýþ Kalemi
Soru:
Her ürün için en yüksek tutarlý satýþ kalemini (LineTotal) bulun.*/
--1.
select urun,	
	   tutar   
from (select productID as urun, LineTotal as tutar ,
		row_number()over(partition by productID order by linetotal desc ) as rn 
		from sales.SalesOrderDetail
)x
where rn = 1
order by urun
--2.
select productid as urun, max(linetotal) as en_yuksek
from sales.salesorderdetail sod
group by ProductID
order by 1



/*10. Yýllýk Satýþ Artýþ Yüzdesi

Soru:
Yýllara göre toplam satýþ tutarýný bulun ve önceki yýla göre artýþ yüzdesini hesaplayýn.*/

with yilliksatis as 
(
	select  year(soh.orderdate) yil, 
			sum(soh.totaldue) toplam_satis

	from sales.SalesOrderHeader soh
	group by year(soh.orderdate)
)
select yil, toplam_satis,
	 ROUND(
        (toplam_satis - LAG(toplam_satis) OVER (ORDER BY yil))
        * 100.0
        / LAG(toplam_satis) OVER (ORDER BY yil),
        2) as artis_yüzdesi
from yilliksatis


/*11.
Her müþterinin toplam sipariþ tutarýna göre sýralamasýný bulun.
Müþteri adý, toplam sipariþ tutarý ve kendi kategorisindeki (örneðin bireysel veya maðaza müþterisi) sýrasýný gösterin.*/

/*
Her ürün kategorisinde, son 6 ayda en fazla satýþ adedine ulaþan ürünü bulun.*/
;with urun_bilgi as (
select p.name as urun, pc.name as kategori, count(sod.salesorderid) as satis_adedi
from sales.SalesOrderDetail sod
join Production.Product p on sod.ProductID = p.ProductID
join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
join sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
where soh.orderdate >= DATEADD(month, -6, (select max(orderdate) from sales.salesorderheader))
group by p.name, pc.name
), siralama as(
select *, row_number()over(partition by kategori order by satis_adedi desc) as rn
from urun_bilgi
)
select * from siralama 
where rn = 1

/*12.
2011 yýlýndan itibaren her yýlýn en yüksek toplam satýþ yaptýðý ayý bulun.
Sonuçta yýl, ay ve toplam satýþ tutarý gösterilsin.*/

with AylikSatis as (
select 
		year(soh.orderdate) as yil,
		month(soh.orderdate) as ay,
		sum(soh.totaldue) as AylikToplamSatisTutari
from sales.SalesOrderHeader soh
where year(soh.OrderDate) >= 2011
group by year(soh.orderdate),
		 month(soh.orderdate)
)
select yil, ay, AylikToplamSatisTutari
from (select 
		 yil, ay, AylikToplamSatisTutari,
	   ROW_NUMBER()over(partition by yil order by AylikToplamSatisTutari desc) as rn 
from AylikSatis
)x
where rn = 1

/*13.
Her satýþ temsilcisinin son sipariþ tarihini, toplam satýþ tutarýný ve ortalama sipariþ tutarýný hesaplayýn.
Sonuçta sadece ortalama sipariþi 20.000 TL üzeri olan temsilciler gösterilsin.*/


select 		 
		 p.FirstName+' '+p.LastName as SatisTemsilciAdi,
	     max(soh.orderdate) as SonSiparisTarihi,
		 sum(soh.totaldue) as ToplamSatisTutari,
		 avg(soh.totaldue) as OrtalamaSiparisTutari
from sales.SalesPerson sp
join person.person p
	on sp.BusinessEntityID = p.BusinessEntityID
join sales.SalesOrderHeader soh
	on sp.BusinessEntityID = soh.SalesPersonID
group by sp.BusinessEntityID, p.FirstName, p.LastName
having avg(soh.totaldue) > 20000

/*14.
Hiç satýþ yapmamýþ satýþ temsilcilerini bulun.
Sadece aktif (geçerli bir departmanla iliþkili) çalýþanlar dikkate alýnsýn.*/

select * from HumanResources.EmployeeDepartmentHistory
select * from HumanResources.Department
select * from sales.SalesPerson
select * from sales.SalesOrderHeader
--1.
select sp.businessentityid as temsilci, p.firstname+' '+p.lastname as temsilciAdi
from sales.SalesPerson sp
join person.person p on sp.BusinessEntityID = p.BusinessEntityID
where exists ( select 1 from HumanResources.EmployeeDepartmentHistory he  where he.BusinessEntityID = sp.BusinessEntityID and he.EndDate is null)
and not exists (select 1 from sales.salesorderheader soh where sp.BusinessEntityID = soh.SalesPersonID)
--2.
select sp.businessentityid, p.firstname+' '+p.lastname as ad
from sales.SalesPerson sp
join person.person p on sp.BusinessEntityID = p.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory edh on sp.BusinessEntityID = edh.BusinessEntityID and edh.EndDate is null
left join sales.SalesOrderHeader soh on soh.SalesPersonID = sp.BusinessEntityID 
where soh.SalesOrderID is null


/*15.
Her ürün için en son satýþ tarihinden bu yana kaç gün geçtiðini hesaplayýn.
Ürün adý, son satýþ tarihi ve geçen gün sayýsýný gösterin.
Sonuç gün farkýna göre azalan sýrada listelensin.*/

select * from Production.Product
select * from sales.SalesOrderHeader
select * from sales.SalesOrderDetail

select p.name, max(soh.orderdate) as SonSatisTarihi,
	   DATEDIFF(day, max(soh.orderdate), GETDATE()) as GecenGun
from sales.SalesOrderHeader soh
join sales.SalesOrderDetail sod
	on soh.SalesOrderID = sod.SalesOrderID
join Production.Product p
	on sod.ProductID = p.ProductID
	group by p.name
	order by GecenGun asc

/*16.
Müþterilerin sipariþ verdikleri yýllara göre toplam sipariþ sayýlarýný bulun.
Ayný müþterinin farklý yýllardaki sipariþ trendini görmek için her müþteri-yýl çifti için ayrý bir satýr gösterin.*/

select c.customerid, p.FirstName+' '+p.lastname as musteriAdi, year(soh.orderdate) as yil, count(soh.salesorderid) as toplamsiparissayisi
from sales.SalesOrderHeader soh
join sales.Customer c on soh.CustomerID = c.CustomerID
left join person.Person p on c.PersonID = p.BusinessEntityID
left join sales.Store st on c.StoreID = st.BusinessEntityID
group by c.customerid, year(soh.orderdate), p.FirstName, p.LastName
order by CustomerID	, yil


/*17.
Her ürün kategorisi için, o kategoriye ait ürünlerin toplam satýþ tutarýnýn genel toplam içindeki yüzdesini bulun.*/
with kategorisatis as (
select pc.productcategoryid, pc.name as kategoriAdi, sum(sod.linetotal) as toplamsatistutari
from sales.SalesOrderDetail sod
join Production.Product p
	on sod.ProductID = p.ProductID
join Production.ProductSubcategory psc
	on p.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory pc
	on psc.ProductCategoryID = pc.ProductCategoryID
group by pc.ProductCategoryID,pc.name
)
select productcategoryid, kategoriAdi, round(toplamsatistutari,2) as ToplamSatis,
	   round(toplamsatistutari * 100.0
		/sum(toplamsatistutari)over(),2) as yuzde 
from kategorisatis
order by toplamsatistutari desc

/*18.
Her müþteri için ilk ve son sipariþ tarihleri arasýndaki farký (gün olarak) hesaplayýn.
Sonuçta müþteri adý, ilk sipariþ tarihi, son sipariþ tarihi ve fark gösterilsin.*/

select * from sales.Customer
select * from person.Person
select * from sales.SalesOrderHeader


select c.customerid, p.FirstName+' '+p.LastName as MusteriAdi, max(soh.orderdate) as SonSiparisTarihi,
		min(soh.orderdate) as ÝlkSiparisTarihi,
		datediff(day, max(soh.orderdate), min(soh.orderdate)) as GunFarki
from sales.customer c
join sales.SalesOrderHeader soh
	on c.CustomerID = soh.CustomerID
join person.person p
	on soh.CustomerID = p.BusinessEntityID
	group by c.CustomerID, p.FirstName, p.LastName
	order by GunFarki 

/*19.
Her satýþ temsilcisi için çalýþtýðý yýl içindeki satýþ artýþ yüzdesini hesaplayýn.
Yani, bir önceki yýl ile karþýlaþtýrýldýðýnda artýþ oranýný gösterin.*/

;with yilliksatis as (
select sp.BusinessEntityID as TemsilciNo, p.firstname+' '+p.lastname as TemsilciAdi,
	   year(soh.orderdate) as Yil, sum(soh.totaldue) as Satistutar
from sales.SalesPerson sp
left join person.person p on sp.BusinessEntityID = p.BusinessEntityID
join sales.SalesOrderHeader soh on sp.BusinessEntityID = soh.SalesPersonID
group by sp.BusinessEntityID, p.FirstName, p.LastName, year(soh.orderdate)
)
select TemsilciNo, TemsilciAdi, yil, Satistutar,
	   round((Satistutar - lag(Satistutar)over(partition by temsilcino order by yil))
	   * 100.0
		/ lag(satistutar)over(partition by temsilcino order by yil),2) as Yuzde
from yilliksatis


/*20.
Her ürünün toplam satýþ miktarýný bulun ve bu miktarý kendi kategorisindeki ortalama satýþ miktarýyla karþýlaþtýrýn.
Sonuçta ürün adý, kategori adý, toplam satýþ miktarý ve “Above Average” / “Below Average” olarak sýnýflandýrma gösterin.*/
;with urunkategoritoplam as (
select p.Name as urunAdi, pc.name as kategori, sum(sod.linetotal) as toplamsatis 
from sales.SalesOrderDetail sod
join production.Product p
	on sod.ProductID = p.ProductID
join Production.ProductSubcategory psc
	on p.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory pc
	on psc.ProductCategoryID = pc.ProductCategoryID
group by p.Name, pc.Name
), kategoriortalama as (
select *, avg(toplamsatis)over(partition by kategori) as ortalamatoplamsatis
from urunkategoritoplam
)
select urunAdi, kategori, toplamsatis, ortalamatoplamsatis,
		case when toplamsatis > avg(toplamsatis)over(partition by kategori) then 'Above Average'
			else 'Below Average'
		end as ortalama
from kategoriortalama


/*21.
Her satýþ temsilcisi için, son 12 ayda yaptýðý toplam satýþ tutarýný bulun.
Ayný zamanda, bir önceki 12 ay ile karþýlaþtýrýldýðýnda artýþ yüzdesini hesaplayýn.*/

select
*, lag(toplamSatis,1)over(order by yil) as onceki_yil,
round((toplamSatis - lag(toplamsatis)over(order by yil)) * 100.0 / lag(toplamsatis)over(order by yil),2) as fark
from
(
select sp.BusinessEntityID,year(soh.orderdate) as yil, month(soh.orderdate) ay, sum(totaldue) as toplamSatis
from sales.salesorderheader soh
join sales.SalesPerson sp on soh.SalesPersonID = sp.BusinessEntityID
where soh.orderdate >= dateadd(month,-12,(select max(orderdate) from sales.salesorderheader))
group by sp.BusinessEntityID, year(soh.orderdate),month(soh.orderdate)

)tt


/*22.
Her müþteri için, sipariþ verdiði ilk ürün ve o ürünün kategorisini bulun.*/
with musteriilkurun as (
select soh.customerid as Musteri, p.name as urunAdi, pc.ProductCategoryID as urunkategorisi, soh.orderdate,
		ROW_NUMBER()OVER(PARTITION BY soh.customerid ORDER BY soh.orderdate, soh.salesorderid, sod.salesorderdetailid) as rn
from sales.SalesOrderHeader soh
join sales.SalesOrderDetail sod
	on soh.SalesOrderID = sod.SalesOrderID
join Production.Product p
	on sod.ProductID = p.ProductID
join Production.ProductSubcategory psc
	on p.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory pc
	on psc.ProductCategoryID = pc.ProductCategoryID
)
select Musteri, urunAdi, urunkategorisi, orderdate as ilksiparistarihi
from musteriilkurun
where rn = 1
ORDER BY Musteri

select
*
from(
select soh.customerid, p.firstname + ' ' + p.lastname as musteriAdi, pr.name as urunAdi, pc.name as kategoriAdi,
row_number()over(partition by soh.salesorderid order by soh.orderdate desc) as sira
from sales.salesorderheader soh
join sales.salesorderdetail sod on soh.salesorderid = sod.salesorderid
join production.product pr on sod.productid = pr.productid
join production.productsubcategory psc on pr.productsubcategoryid = psc.productsubcategoryid
join production.productcategory pc on psc.productcategoryid = pc.productcategoryid
join person.person p on soh.customerid = p.BusinessEntityID
)aa
where sira = 1 

select * from sales.salesorderdetail

/*23.
Her ürün kategorisi için, satýþ sayýsý bakýmýndan en popüler 3 ürünü bulun.
Kategori adý, ürün adý, toplam satýþ miktarý ve sýrasýný gösterin.*/
select
*
from
(
select
*,row_number()over(partition by kategoriAdi order by toplam_satis desc) as sira
from(
select  p.productid as urunid, p.name as urunAdi, pc.name as kategoriAdi, count(sod.salesorderid) as toplam_satis
from sales.salesorderdetail sod
join production.product p on sod.productid = p.productid
left join production.productsubcategory psc on p.productsubcategoryid = psc.productsubcategoryid
join production.productcategory pc on psc.productcategoryid = pc.productcategoryid
group by p.name, pc.name, p.ProductID
)aa
)bb
where sira <= 3



/*24.
2011 yýlýnda yapýlan tüm sipariþlerde, her müþterinin ortalama sipariþ tutarýný ve ayný yýl içindeki genel ortalama sipariþ tutarýna göre farkýný bulun*/
with yillikortsiparis as
(
select soh.customerid, avg(soh.totaldue) as OrtTutar
from sales.salesorderheader soh
WHERE soh.OrderDate >= '2011-01-01'
  AND soh.OrderDate <  '2012-01-01'
group by soh.CustomerID
)
select CustomerID, OrtTutar,		
	   avg(OrtTutar)over() AS GenelOrtTutar,
	   OrtTutar - avg(OrtTutar)over() fark
from yillikortsiparis




/*25.
Hiç sipariþi bulunmayan müþterileri listeleyin, ancak sadece sistemde aktif (StoreID IS NULL) olan bireysel müþterileri gösterin.*/

select c.customerid
from sales.customer c
where not exists ( select 1 from sales.salesorderheader soh where c.CustomerID = soh.CustomerID) and c.StoreID is null



/*26.
Her satýþ temsilcisi için, bugüne kadar aldýðý toplam sipariþ sayýsý ve en son satýþ yaptýðý müþterinin adý gösterilsin.*/

with temsilci_siparis_sayisi as(
select sp.BusinessEntityID as temsilci, count(soh.salesorderid) as SiparisSayisi
from sales.SalesPerson sp
join sales.SalesOrderHeader soh on sp.BusinessEntityID = soh.SalesPersonID
group by sp.BusinessEntityID
),
en_son_urun as(
select soh.salespersonid as temsilci, soh.orderdate as tarih, c.customerid as musterino,
row_number()over(partition by soh.salespersonid order by soh.orderdate desc) as son_siparis
from sales.salesorderheader soh
join sales.Customer c on soh.CustomerID = c.CustomerID
)
select tss.temsilci, siparissayisi, p.firstname+' '+p.lastname as musteriAdi, son_siparis
from temsilci_siparis_sayisi tss
join sales.SalesPerson sp on tss.temsilci = sp.BusinessEntityID
join person.person p on sp.BusinessEntityID = p.BusinessEntityID
join en_son_urun esu on tss.temsilci = esu.temsilci and son_siparis = 1
join sales.Customer c on esu.musterino = c.CustomerID
left join person.person pp on c.PersonID = p.BusinessEntityID
order by 2 desc



/*27. Her ürünün, üretim maliyeti (StandardCost) ile satýþ fiyatý (ListPrice) arasýndaki farkýn yüzdesini hesaplayýn.
Bu oran %50’nin üzerindeyse “High Margin”, deðilse “Low Margin” olarak etiketleyin.*/

select * from Production.Product

;with urun_yuzde as(
select productid as urunno, name as urunadi, round((listprice - StandardCost) * 100.0 / nullif(StandardCost,0),2) as fark
from Production.Product
group by ProductID, name, ListPrice , StandardCost
)
select*,case when fark > 50 then 'High Margin'
		else 'Low Margin' end as pozisyon
from urun_yuzde






/*28. Satýþ tarihine göre, her sipariþ için bir önceki sipariþle arasýndaki gün farkýný bulun.
Müþteri adý, sipariþ tarihi ve fark gün sayýsý gösterilsin.*/

 select c.customerid, p.firstname+' '+p.lastname as musteriadi,  soh.SalesOrderID, soh.orderdate, 
						datediff(day,lag(soh.orderdate)over(partition by c.customerid order by soh.orderdate),soh.orderdate) as gun_farki
 from sales.customer c 
 join person.person p on c.PersonID = p.BusinessEntityID
 join sales.salesorderheader soh on c.CustomerID = soh.CustomerID



/*29. Her yýl için, o yýlýn toplam satýþ tutarýný ve bir önceki yýla göre artýþ veya azalýþ oranýný hesaplayýn.
Ayrýca artýþ gösteren yýllarý “Growth”, azalýþ gösterenleri “Decline” olarak sýnýflandýrýn..*/

with heryiltoplamtutar as (
select year(soh.orderdate) as yil, sum(soh.totaldue) as toplamtutar
from sales.salesorderheader soh
group by year(soh.orderdate)
)
select yil, toplamtutar, round( (toplamtutar - lag(toplamtutar)over(order by yil)) * 100.0 / lag(toplamtutar)over(order by yil), 2) as yuzdelik_kisim,
		case when lag(toplamtutar)over(order by yil) is null then null
			 when toplamtutar > lag(toplamtutar)over(order by yil) then 'growth'
			 else 'Decline'
		end as satisyuzdeleri
from heryiltoplamtutar



/*30. Her müþterinin yaptýðý ilk sipariþte hangi satýþ temsilcisiyle çalýþtýðýný bulun.
Müþteri adý, sipariþ tarihi ve satýþ temsilcisi adýný gösterin.*/

;with musterininilksiparisi as (
select c.customerid as musteri, p.firstname+' '+p.lastname as musteriadi, soh.salespersonid as salesperson, soh.salesorderid as siparisid, soh.orderdate as tarih, 
row_number()over(partition by soh.customerid order by soh.orderdate) as rn
from sales.customer c
join person.person p on c.PersonID = p.BusinessEntityID
join sales.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
),satistemsilcisi as(
select sp.businessentityid, p2.firstname+' '+p2.lastname as satistemsilcisi
from sales.SalesPerson sp
join person.person p2 on sp.BusinessEntityID = p2.BusinessEntityID
)
select mis.musteri, mis.musteriadi, mis.tarih, sts.satistemsilcisi 
from musterininilksiparisi mis
left join satistemsilcisi sts on mis.salesperson = sts.BusinessEntityID
where rn = 1




/*31. Her satýþ temsilcisi için, en yüksek tutarlý sipariþini ve bu sipariþin tarihini bulun.
Ayrýca satýþ tutarýna göre temsilciler arasýnda sýralama yapýn.*/


with enyuksektutar as (
select sp.businessentityid as salespersonid, p.firstname+' '+p.lastname as temsilciAdi, max(soh.totaldue) as enyuksektutari
from sales.salesperson sp
join person.person p on sp.BusinessEntityID = p.BusinessEntityID
join sales.salesorderheader soh on sp.BusinessEntityID = soh.SalesPersonID
group by sp.BusinessEntityID, p.FirstName, p.LastName
)
select eyt.salespersonid, temsilciAdi, enyuksektutari, soh.orderdate,rank()over(order by enyuksektutari desc) as Temsilcisira
from enyuksektutar eyt
join sales.salesorderheader soh on eyt.salespersonid = soh.SalesPersonID and eyt.enyuksektutari =soh.TotalDue




/*Her ürün kategorisi için, son 3 yýlda gerçekleþen toplam satýþ tutarlarýný yýl bazýnda listeleyin.*/

with herurunkategori as (
select  pc.name as kategoriAdi, year(soh.orderdate) as yil, sum(sod.linetotal) as taplamtutar
from sales.SalesOrderDetail sod
join sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
join Production.Product p on sod.ProductID = p.ProductID
left join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
left join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
where soh.orderdate >= dateadd(year, -3, (select max(orderdate) from sales.salesorderheader))
group by  pc.name, year(soh.orderdate)
)
select *
from herurunkategori
order by 1,2












44.

/*Satýþ detaylarý tablosunda, sipariþ satýrlarýný toplam tutarýna göre sýralayýn ve
her sipariþ içindeki kalemlerin yüzdesini (LineTotal / SUM(LineTotal) OVER(PARTITION BY SalesOrderID)) hesaplayýn.
WINDOW FUNCTION kullanýmý zorunludur.*/

select salesorderid, linetotal, sum(linetotal)over(partition by salesorderid) as toplamtutar,
			round(linetotal * 100.0 / sum(linetotal)over(partition by salesorderid),2) as yuzde
from sales.SalesOrderDetail


	   



45

Her ürün için, satýldýðý en yüksek ve en düþük fiyatý bulun.
Bu iki fiyat arasýndaki farký da (spread) gösterin.
MAX(), MIN(), ve GROUP BY kullanýn.

select p.name as urunadi, max(sod.linetotal) as enyukseksatisfiyati, min(sod.linetotal) as endusuksatisfiyati,
max(sod.linetotal) - min(sod.linetotal) as fark
from sales.salesorderdetail sod
join Production.Product p on sod.ProductID = p.ProductID
group by p.name


46.

Her müþterinin sipariþ verdiði son tarih ile ilk tarih arasýndaki gün farkýný hesaplayýn.
Bu fark 180 günden fazla olan müþteriler listelensin.
DATEDIFF(), MIN(), MAX(), ve HAVING kullanýn.


select customerid, min(orderdate) as ilksiparis, max(orderdate) sonsiparis,
datediff(day,min(orderdate),max(orderdate)) as fark
from sales.SalesOrderHeader
group by customerid
having datediff(day,min(orderdate),max(orderdate)) > 180

47.

Her satýþ temsilcisi için, çalýþtýðý yýl içindeki toplam satýþ tutarýný bulun.
Ayrýca ayný temsilcinin bir önceki yýlki satýþýna göre artýþ/azalýþ yüzdesini hesaplayýn.
CTE, LAG(), ve ROUND() fonksiyonlarýný kullanýn.

with satistemsilcisitopsatis as (
select sp.businessentityid as satistemsilcisi, year(soh.orderdate) as yil , sum(soh.totaldue) as toplamtutar			
from sales.SalesPerson sp
join sales.salesorderheader soh on sp.BusinessEntityID = soh.SalesPersonID
group by sp.BusinessEntityID, year(soh.orderdate)
),
oncekiyil as (
select satistemsilcisi, yil, toplamtutar,lag(toplamtutar)over(partition by satistemsilcisi order by yil)  as gecenyil		
from satistemsilcisitopsatis
)
select satistemsilcisi, yil, toplamtutar, gecenyil, round((toplamtutar - gecenyil)* 100.0 / gecenyil,2) as yuzdei,
				case when gecenyil is null then 'Ýlk Yil'
					when toplamtutar > gecenyil then 'artis'
					else 'azalis'
				end as Durum
from oncekiyil




48.

2023 yýlýnda yapýlan sipariþlerde, hafta bazýnda toplam satýþ tutarlarýný hesaplayýn.
Her haftanýn satýþýný bir önceki haftaya göre karþýlaþtýrarak artýþ yüzdesini bulun.
DATEPART(WEEK, OrderDate), SUM(), ve LAG() kullanýn.


with haftaliktoplamsatis as (
select datepart(week, soh.orderdate) as hafta,
	   sum(soh.totaldue) as toplamtutar
from sales.salesorderheader soh
where year(soh.orderdate) = '2013'
group by datepart(week, soh.orderdate) 
),gecenhafta as(
select hafta, toplamtutar, lag(toplamtutar)over(order by hafta) as gecenhaftaki
from haftaliktoplamsatis)
select hafta, toplamtutar, gecenhaftaki, 
				case 
					 when gecenhaftaki is null then null
					 else	round((toplamtutar - gecenhaftaki) * 100.0 / gecenhaftaki,2) 
				end as artisyuzdesi
from gecenhafta
order by hafta


49.

Her ürün kategorisinde, ortalama satýþ fiyatý genel ortalama fiyatýn üzerinde olan ürünleri listeleyin.
AVG(), HAVING, ve alt sorgu kullanýn.


select p.name as urun_adi, pc.name as kategori_adi, avg(sod.unitprice) as ortalama_tutar
from sales.SalesOrderDetail sod
join Production.Product p on sod.ProductID = p.ProductID
join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
group by p.name, pc.name
having avg(sod.unitprice) > (select avg(unitprice) from sales.SalesOrderDetail)
order by kategori_adi


50.

Müþterilerin sipariþ verdikleri en yoðun günleri (haftanýn günü bazýnda) bulun.
Her müþteri için, en çok sipariþ verdiði DATENAME(WEEKDAY, OrderDate) deðerini ve o güne ait sipariþ sayýsýný gösterin.
CTE, COUNT(), RANK() ve DATEPART() kullanýn.

with musterininenyogungunu as(
select customerid as musteri, datename(weekday, orderdate) as haftaningunleri, count(salesorderid) as siparissayisi,
rank()over(partition by customerid order by datename(weekday, orderdate) desc) as en_yogun_gun from sales.SalesOrderHeader
group by customerid, datename(weekday, orderdate)
)
select musteri, haftaningunleri, siparissayisi from musterininenyogungunu
where en_yogun_gun = 1

