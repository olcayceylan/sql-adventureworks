--MERGE YAPISI; Update, Delete, Insert veya Update IsActive = 0 bu sorguları tek komutla yapar,
--Temel amacı: Source (Kaynak) tablosundaki verilere bakarak Target (Hedef) tablosunu güncel tutmaktır (Senkronize etmek).
	select * from Products_Target
	-- 1. HEDEF TABLO OLUŞTURMA: Ana verilerimizin tutulacağı hedef tablo
CREATE TABLE Products_Target
(
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(50),
    Price DECIMAL(10,2),
    IsActive BIT -- Ürünün aktif (1) veya pasif (0) durumunu tutar
);

-- 2. KAYNAK TABLO OLUŞTURMA: Dışarıdan veya yeni gelen verilerin olduğu kaynak tablo
CREATE TABLE Products_Source
(
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(50),
    Price DECIMAL(10,2)
);

-- Tabloların içini temizleme (Her ihtimale karşı sıfırlama)
TRUNCATE TABLE Products_Target;
TRUNCATE TABLE Products_Source;

-- Hedef tabloya başlangıç verilerini ekliyoruz (Mevcut Durum)
-- ID 1: Mouse (500 TL, Aktif)
-- ID 2: Keyboard (700 TL, Aktif)
-- ID 3: Monitor (5000 TL, Aktif)
INSERT INTO Products_Target (ProductID, ProductName, Price, IsActive)
VALUES
(1,'Mouse',500,1),
(2,'Keyboard',700,1),
(3,'Monitor',5000,1);

-- Kaynak tabloya yeni/güncel verileri ekliyoruz (Yeni Gelen Liste)
-- ID 2: Keyboard (Fiyatı 750 TL'ye yükselmiş -> GÜNCELLENECEK)
-- ID 3: Monitor (Aynı kalmış -> DEĞİŞMEYECEK)
-- ID 4: SSD (Yeni ürün -> HEDEFE EKLENECEK)
-- NOT: ID 1 (Mouse) yeni listede yok! -> PASİFE ÇEKİLECEK
INSERT INTO Products_Source (ProductID, ProductName, Price)
VALUES
(2,'Keyboard',750),
(3,'Monitor',5000),
(4,'SSD',1800);

-- Kaynak tablonun son halini ekrana basar
SELECT * FROM Products_Source;

-- =========================================================================
-- MERGE İŞLEMİ (SENKRONİZASYON)
-- =========================================================================

MERGE Products_Target AS T               -- Hedef tabloyu belirtiyoruz (Kısaltması: T)
USING Products_Source AS S              -- Kaynak tabloyu belirtiyoruz (Kısaltması: S)
ON T.productid = S.productid            -- İki tabloyu hangi anahtarla eşleştireceğimizi söylüyoruz

-- 1. DURUM: Ürün hem Kaynakta hem Hedefte VARSA (Eşleştiyse)
-- ID 2 ve ID 3 buraya girer. Hedefteki adı ve fiyatı kaynaktakilerle günceller.
WHEN MATCHED THEN
    UPDATE SET 
        t.productname = s.productname,
        t.price = s.price

-- 2. DURUM: Ürün Kaynakta VAR ama Hedefte YOKSA (Hedefte eşleşmeyenler)
-- ID 4 (SSD) buraya girer. Hedef tabloya yeni ürün olarak eklenir ve IsActive varsayılan 1 (Aktif) yapılır.
WHEN NOT MATCHED BY TARGET THEN
    INSERT(ProductID, ProductName, Price, IsActive)
    VALUES(S.ProductID, S.ProductName, S.Price, 1)

-- 3. DURUM: Ürün Hedefte VAR ama Kaynakta YOKSA (Kaynağa göre eşleşmeyenler)
-- ID 1 (Mouse) artık yeni listede/kaynakta olmadığı için buraya girer. Silinmez, durumu pasif (IsActive = 0) yapılır.
WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET 
        t.IsActive = 0;

-- Merge işlemi sonrası Hedef Tablonun son halini gösterir
SELECT * FROM Products_Target;

-- DWH' da genelde DELETE yapılmaz yerine;
WHEN NOT MATCHED BY SOURCE THEN 
	UPDATE SET
		IsActive = 0,
			UpdateDate = GETDATE()
