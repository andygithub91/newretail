// 引入依賴
const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("mysql2/promise");
const redis = require("redis");
const { promisify } = require("util");

// 初始化 Express
const app = express();
app.use(bodyParser.json());

// 初始化 MySQL 連接池
const db = mysql.createPool({
  host: "mysql", // Docker Compose 中的 MySQL 服務名稱
  user: "root",
  password: "password",
  database: "crm",
});

// 初始化 Redis 連接
const redisClient = redis.createClient({ host: "redis", port: 6379 });
const getAsync = promisify(redisClient.get).bind(redisClient);
const setAsync = promisify(redisClient.set).bind(redisClient);

// 測試路由
app.get("/", (req, res) => {
  res.send("CRM 系統運行中");
});

// === 客戶管理 API ===

// 新增客戶
app.post("/customers", async (req, res) => {
  const { name, email, phoneNumber } = req.body;
  try {
    const [result] = await db.query(
      "INSERT INTO Customers (Name, Email, PhoneNumber, RegistrationDate) VALUES (?, ?, ?, NOW())",
      [name, email, phoneNumber]
    );
    res
      .status(201)
      .send({ message: "客戶新增成功", customerId: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).send("無法新增客戶");
  }
});

// 查詢所有客戶
app.get("/customers", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM Customers");
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("無法獲取客戶資料");
  }
});

// 更新客戶資料（樂觀鎖）
app.put("/customers/:id", async (req, res) => {
  const { id } = req.params;
  const { name, email, phoneNumber, version } = req.body;

  try {
    const [result] = await db.query(
      "UPDATE Customers SET Name = ?, Email = ?, PhoneNumber = ?, Version = Version + 1 WHERE CustomerID = ? AND Version = ?",
      [name, email, phoneNumber, id, version]
    );

    if (result.affectedRows === 0) {
      return res.status(409).send("資料已被其他人修改，請重新加載");
    }

    res.status(200).send("更新成功");
  } catch (err) {
    console.error(err);
    res.status(500).send("無法更新客戶資料");
  }
});

// === 優惠券管理 API ===

// 領取優惠券
app.post("/claim-coupon", async (req, res) => {
  const { userId, couponId } = req.body;

  try {
    // 獲取 Redis 中的剩餘數量
    const remaining = await getAsync(`coupon:${couponId}:remaining`);
    if (remaining <= 0) {
      return res.status(400).send("優惠券已領取完畢");
    }

    // 更新 Redis 中的剩餘數量
    await setAsync(`coupon:${couponId}:remaining`, remaining - 1);

    // 將領取記錄寫入 MySQL
    await db.query(
      "INSERT INTO CustomerCoupons (CustomerID, CouponID, RedemptionDate, ExpirationDate) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY))",
      [userId, couponId]
    );

    res.status(200).send("優惠券領取成功");
  } catch (err) {
    console.error(err);
    res.status(500).send("伺服器錯誤");
  }
});

// 近 30 天消費金額超過 500 元的客戶
app.get("/customers/high-spenders", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT c.CustomerID, c.Name, SUM(p.PurchaseAmount) AS TotalAmount, MAX(p.PurchaseDate) AS LastPurchaseDate
      FROM Customers c
      JOIN PurchaseHistory p ON c.CustomerID = p.CustomerID
      WHERE p.PurchaseDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      GROUP BY c.CustomerID, c.Name
      HAVING TotalAmount > 500;
    `);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("無法篩選客戶");
  }
});


// 啟動伺服器
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
