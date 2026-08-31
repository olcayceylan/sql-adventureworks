--MERGE YAPISI; Update, Delete, Insert veya Update IsActive = 0 bu sorgularý tek komutla yapar,
--Temel amacý: Source (Kaynak) tablosundaki verilere bakarak Target (Hedef) tablosunu güncel tutmaktýr (Senkronize etmek).
	select * from Products_Target
	-- 1. HEDEF TABLO OLUÞTURMA: Ana verilerimizin tutulacaðý hedef tablo
CREATE TABLE Products_Target
(
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(50),
    Price DECIMAL(10,2),
    IsActive BIT -- Ürünün aktif (1) veya pasif (0) durumunu tutar
);

-- 2. KAYNAK TABLO OLUÞTURMA: Dýþarýdan veya yeni gelen verilerin olduðu kaynak tablo
CREATE TABLE Products_Source
(
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(50),
    Price DECIMAL(10,2)
);

-- Tablolarýn içini temizleme (Her ihtimale karþý sýfýrlama)
TRUNCATE TABLE Products_Target;
TRUNCATE TABLE Products_Source;

-- Hedef tabloya baþlangýç verilerini ekliyoruz (Mevcut Durum)
-- ID 1: Mouse (500 TL, Aktif)
-- ID 2: Keyboard (700 TL, Aktif)
-- ID 3: Monitor (5000 TL, Aktif)
INSERT INTO Products_Target (ProductID, ProductName, Price, IsActive)
VALUES
(1,'Mouse',500,1),
(2,'Keyboard',700,1),
(3,'Monitor',5000,1);

-- Kaynak tabloya yeni/güncel verileri ekliyoruz (Yeni Gelen Liste)
-- ID 2: Keyboard (Fiyatý 750 TL'ye yükselmiþ -> GÜNCELLENECEK)
-- ID 3: Monitor (Ayný kalmýþ -> DEÐÝÞMEYECEK)
-- ID 4: SSD (Yeni ürün -> HEDEFE EKLENECEK)
-- NOT: ID 1 (Mouse) yeni listede yok! -> PASÝFE ÇEKÝLECEK
INSERT INTO Products_Source (ProductID, ProductName, Price)
VALUES
(2,'Keyboard',750),
(3,'Monitor',5000),
(4,'SSD',1800);

-- Kaynak tablonun son halini ekrana basar
SELECT * FROM Products_Source;

-- =========================================================================
-- MERGE ÝÞLEMÝ (SENKRONÝZASYON)
-- =========================================================================

MERGE Products_Target AS T               -- Hedef tabloyu belirtiyoruz (Kýsaltmasý: T)
USING Products_Source AS S              -- Kaynak tabloyu belirtiyoruz (Kýsaltmasý: S)
ON T.productid = S.productid            -- Ýki tabloyu hangi anahtarla eþleþtireceðimizi söylüyoruz

-- 1. DURUM: Ürün hem Kaynakta hem Hedefte VARSA (Eþleþtiyse)
-- ID 2 ve ID 3 buraya girer. Hedefteki adý ve fiyatý kaynaktakilerle günceller.
WHEN MATCHED THEN
    UPDATE SET 
        t.productname = s.productname,
        t.price = s.price

-- 2. DURUM: Ürün Kaynakta VAR ama Hedefte YOKSA (Hedefte eþleþmeyenler)
-- ID 4 (SSD) buraya girer. Hedef tabloya yeni ürün olarak eklenir ve IsActive varsayýlan 1 (Aktif) yapýlýr.
WHEN NOT MATCHED BY TARGET THEN
    INSERT(ProductID, ProductName, Price, IsActive)
    VALUES(S.ProductID, S.ProductName, S.Price, 1)

-- 3. DURUM: Ürün Hedefte VAR ama Kaynakta YOKSA (Kaynaða göre eþleþmeyenler)
-- ID 1 (Mouse) artýk yeni listede/kaynakta olmadýðý için buraya girer. Silinmez, durumu pasif (IsActive = 0) yapýlýr.
WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET 
        t.IsActive = 0;

-- Merge iþlemi sonrasý Hedef Tablonun son halini gösterir
SELECT * FROM Products_Target;

-- DWH' da genelde DELETE yapýlmaz yerine;
WHEN NOT MATCHED BY SOURCE THEN 
	UPDATE SET
		IsActive = 0,
			UpdateDate = GETDATE()