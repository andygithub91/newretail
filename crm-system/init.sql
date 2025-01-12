CREATE DATABASE IF NOT EXISTS crm;

USE crm;

-- Customers 表
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(15) NOT NULL,
    Address TEXT,
    RegistrationDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    MembershipLevel ENUM('Basic', 'Premium', 'VIP') DEFAULT 'Basic',
    Status ENUM('Active', 'Inactive') DEFAULT 'Active'
);

-- Coupons 表
CREATE TABLE Coupons (
    CouponID INT AUTO_INCREMENT PRIMARY KEY,
    CouponName VARCHAR(100) NOT NULL,
    DiscountType ENUM('Percentage', 'Fixed') NOT NULL,
    DiscountValue DECIMAL(10,2) NOT NULL,
    MinimumSpend DECIMAL(10,2),
    ValidFrom DATETIME NOT NULL,
    ValidUntil DATETIME NOT NULL,
    IssuedQuantity INT NOT NULL,
    RemainingQuantity INT NOT NULL,
    Status ENUM('Active', 'Expired') DEFAULT 'Active'
);

-- CustomerCoupons 表
CREATE TABLE CustomerCoupons (
    CustomerCouponID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    CouponID INT NOT NULL,
    Redeemed BOOLEAN DEFAULT FALSE,
    RedemptionDate DATETIME,
    ExpirationDate DATETIME NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CouponID) REFERENCES Coupons(CouponID)
);

-- PreferenceTags 表
CREATE TABLE PreferenceTags (
    TagID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    TagName VARCHAR(50) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- PurchaseHistory 表
CREATE TABLE PurchaseHistory (
    PurchaseID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProductDetails TEXT,
    PurchaseAmount DECIMAL(10,2) NOT NULL,
    PurchaseDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- VisitHistory 表
CREATE TABLE VisitHistory (
    VisitID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    VisitDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    VisitedPage VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 插入測試數據
INSERT INTO Customers (Name, Email, PhoneNumber, Address, MembershipLevel)
VALUES 
('Alice', 'alice@mail.com', '123456789', '123 Main St', 'Premium'),
('Bob', 'bob@mail.com', '987654321', '456 Elm St', 'VIP'),
('Charlie', 'charlie@mail.com', '555123456', '789 Oak St', 'Basic');

INSERT INTO Coupons (CouponName, DiscountType, DiscountValue, MinimumSpend, ValidFrom, ValidUntil, IssuedQuantity, RemainingQuantity)
VALUES 
('滿 500 減 50', 'Fixed', 50.00, 500.00, '2025-01-01', '2025-02-01', 100, 90),
('買一送一', 'Percentage', 100.00, NULL, '2025-01-10', '2025-03-01', 200, 150);

INSERT INTO CustomerCoupons (CustomerID, CouponID, ExpirationDate)
VALUES 
(1, 1, '2025-02-01'),
(2, 2, '2025-03-01');

INSERT INTO PreferenceTags (CustomerID, TagName)
VALUES 
(1, 'Electronics'),
(2, 'Books'),
(3, 'Fashion');

INSERT INTO PurchaseHistory (CustomerID, ProductDetails, PurchaseAmount)
VALUES 
(1, 'Laptop', 1000.00),
(1, 'Mouse', 50.00),
(2, 'Book', 20.00),
(3, 'Shirt', 30.00);

INSERT INTO VisitHistory (CustomerID, VisitDate, VisitedPage)
VALUES 
(1, '2025-01-01', '/home'),
(2, '2025-01-02', '/products'),
(3, '2025-01-03', '/contact');
