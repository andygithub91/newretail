CREATE DATABASE IF NOT EXISTS crm;

USE crm;

CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(15),
    RegistrationDate DATETIME,
    Version INT DEFAULT 1
);

CREATE TABLE Coupons (
    CouponID INT AUTO_INCREMENT PRIMARY KEY,
    CouponName VARCHAR(100),
    RemainingQuantity INT,
    ValidFrom DATETIME,
    ValidUntil DATETIME
);

CREATE TABLE CustomerCoupons (
    CustomerCouponID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    CouponID INT,
    RedemptionDate DATETIME,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CouponID) REFERENCES Coupons(CouponID)
);
