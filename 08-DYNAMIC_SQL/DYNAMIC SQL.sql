--DYNAMİC SQL;
--SQL sorgusunu calisma zamanında (runtime) metin olarak olusturup çalistirmaya yarar.
--Kolon/tablo adı çok sayıda seçenek içeriyorsa ve hepsi aynı tablo/yapıdan geliyorsa → Dynamic SQL mantıklı.
--Secenek sayisi az (2-3) ve/veya farkli tablolardan geliyorsa → IF/ELSE ile sabit sorgular yaz, Dynamic SQL'e gerek yok, daha temiz ve güvenli.
--N' → nvarchar olarak belirtmis oluruz. sp_executesql nvarchar olarak bekler.
--QUOTENAME → sadece disaridan gelen, değisken kolon/tablo adlari icin kullanilir.-- gelen parametreyi güvenli hale getirir.
--WHELİST Kontrolu → Kullanıcının gönderebileceği değeri, önceden belirlediğin izinli bir listeyle sınırlar.
--SP_EXECUTESQL → parametre kullanmana izin verir.
--SQL Injection riski onlemek icin → QUOTENAME + whitelist + sp_executesql parametreleri birlikte kullanılır.


--Alıştırma 1 — IF/ELSE ile sabit sorgular (Dynamic SQL YOK)

--Senaryo: İnsan kaynakları/yönetim diyor ki:

--"Çalışan performansını bazen departmana göre, bazen de satış bölgesine göre görmek istiyoruz. Sadece bu iki seçenek olacak, başka kolon eklenmeyecek."

--İstenen:

--@ViewType adında bir parametre alan bir stored procedure yaz.
--@ViewType = 'ByDepartment' gelirse: HumanResources.Employee ve HumanResources.EmployeeDepartmentHistory tablolarını kullanarak departmana göre çalışan sayısını göster (GROUP BY DepartmentID).
--@ViewType = 'ByTerritory' gelirse: Sales.SalesPerson tablosunu kullanarak bölgeye göre satış elemanı sayısını göster (GROUP BY TerritoryID).
--Sadece IF/ELSE kullan, Dynamic SQL kullanma — çünkü seçenek sayısı az ve farklı tablolardan geliyor.

create or alter procedure GetbyEmployee
	@ViewType nvarchar(50)
AS
BEGIN
	IF @ViewType = 'DepartmentID'
	begin
		select hed.departmentID ,count(*) as Calisan_Sayisi
		from HumanResources.Employee he
		join HumanResources.EmployeeDepartmentHistory hed on he.BusinessEntityID = hed.BusinessEntityID
		group by hed.DepartmentID
	end
	else if @ViewType = 'TerritoryID'
	begin
		select TerritoryID, count(*) as SatisElemani
		from sales.SalesPerson
		group by territoryid
	end
	else
	begin
		raiserror('Geçersiz kolon adı',16,1);
	end
end
EXEC GetbyEmployee @ViewType = 'TerritoryID'
EXEC GetbyEmployee @ViewType = 'DepartmentID'
go
--Alıştırma 2 — Dynamic SQL + QUOTENAME (çok seçenekli, aynı tablo)

--Senaryo: Finans ekibi diyor ki:

----"Genel amaçlı bir sipariş raporu istiyoruz. Bazen yıla (OrderDate'in yılına göre değil, 
--doğrudan bir kolona göre değil — burada gerçek bir kolon kullan), bazen ödeme yöntemine, 
--bazen de kredi kartı onay koduna göre gruplanmış toplam satışları görmek istiyoruz. İleride yeni kolonlar da eklenebilir."

--İstenen:

--Sales.SalesOrderHeader tablosundan uygun 3 farklı kolon seç (örneğin Status, OnlineOrderFlag, ShipMethodID).
--@GroupByColumn parametresi alan bir stored procedure yaz.
--Whitelist kontrolü ekle (IF @GroupByColumn NOT IN (...)).
--QUOTENAME ve N'...' kullanarak Dynamic SQL ile SUM(TotalDue) bazında gruplanmış sonucu döndür.


create or alter procedure GetByReport
	@GroupByColumn NVARCHAR(50)
AS
BEGIN
	IF @GroupByColumn NOT IN ('Status', 'OnlineOrderFlag', 'ShipMethodID') --whelist kontrolu
	BEGIN
		RAISERROR ('Geçersiz kolon adı', 16,1)
		RETURN;
	END

	DECLARE @SQL NVARCHAR(MAX) ;
		
		SET @SQL = N'
					select ' + QUOTENAME(@GroupByColumn) + N',SUM(TotalDue) as ToplamSatis
					from sales.salesorderheader
					group by ' + QUOTENAME(@GroupByColumn)+ N'
					order by ToplamSatis desc';
		exec sp_executesql @SQL;
end
EXEC GetByReport @GroupByColumn = 'Status'
EXEC GetByReport @GroupByColumn = 'OnlineOrderFlag'
EXEC GetByReport @GroupByColumn = 'ShipMethodID'
