--TRIGGER;
--Trigger icerisinde 2 tablo otomatik olustururlur;
--1. INSERTED → yeni eklenen ya da güncellenmiş yeni veriyi tutar.
--2. DELETED → silinen ya da güncellenmeden önceki eski veriyi tutar. -- update durumunda her ikisi birden dolu olur.
--Performans acisindan icerisine agir kod yazilirsa eğer sistemi yavaslatabilir.
--zincirleme tetiklenmeler olabilir dikkatli tasarlanmaidir.

--Temel yapı;
--CREATE TRIGGER TR_trigger_name
--ON Production.Product -- ON hangi tabloyu izleyeceğimiz
--AFTER UPDATE -- Hangi olaydan sonra calisacak
--AS
--BEGIN
    -- kod
--END

--1.Ornek;
CREATE TABLE Production.PriceChangeLog (
    ProductID INT,
    OldPrice DECIMAL(18,2),
    NewPrice DECIMAL(18,2),
    ChangeDate DATETIME DEFAULT GETDATE()
);	

CREATE TRIGGER TR_Product_LogPriceChange
ON Production.Product
AFTER UPDATE
AS
BEGIN
    INSERT INTO Production.PriceChangeLog (ProductID, OldPrice, NewPrice)
    SELECT 
        i.ProductID,
        d.ListPrice AS OldPrice,
        i.ListPrice AS NewPrice
    FROM INSERTED i
    JOIN DELETED d ON i.ProductID = d.ProductID
    WHERE i.ListPrice <> d.ListPrice;  -- sadece fiyat gerçekten değiştiyse logla
END


--HumanResources.Employee tablosuna benzer bir "audit" (denetim) mantığı kur: SalariedFlag kolonu değiştiğinde (maaşlı/saatlik durumu değiştiğinde), bunu bir log tablosuna otomatik kaydeden bir trigger yaz. Önce log tablosunu oluştur (EmployeeID, OldValue, NewValue, ChangeDate kolonlarıyla), sonra trigger'ı yaz.

--2.Ornek;
create table HumanResources.AuditChangeLog (
	BusinessEntityID int,
	OldValue int,
	NewValue int,
	ChangeDate datetime default getdate()
	)

create trigger TR_Employee_LogAuditeChange
ON HumanResources.Employee 
AFTER UPDATE
AS
BEGIN
	INSERT INTO HumanResources.AuditChangeLog (BusinessEntityID, OldValue, NewValue)
	select
		i.BusinessEntityID,
		d.SalariedFlag as OldValue,
		i.SalariedFlag as NewValue
	from inserted i
	join deleted d on i.BusinessEntityID = d.BusinessEntityID
	where i.SalariedFlag <> d.SalariedFlag;
end

--Test
SELECT TOP 5 BusinessEntityID, SalariedFlag 
FROM HumanResources.Employee;

UPDATE HumanResources.Employee
SET SalariedFlag = 1  -- değiştirdiğimiz değer
WHERE BusinessEntityID = 4;

SELECT * FROM HumanResources.AuditChangeLog;