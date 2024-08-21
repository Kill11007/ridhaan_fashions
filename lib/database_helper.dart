import 'dart:async';

import 'package:path/path.dart';
import 'package:ridhaan_fashions/bill.dart';
import 'package:ridhaan_fashions/customer.dart';
import 'package:ridhaan_fashions/daily_sale.dart';
import 'package:ridhaan_fashions/purchase.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();

  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }
    _database = await init();

    return _database!;
  }

  Future<Database> init() async {
    String dbPath =
        join(await getDatabasesPath(), 'ridhaan_fashions_database.db');
    var database = openDatabase(
      dbPath,
      version: 11,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) =>
          _onUpgrade(db, oldVersion, newVersion),
    );
    return database;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    print("New Version: $newVersion, OldVersion: $oldVersion");
    if (newVersion == 7) {
      db.execute('''
      CREATE TABLE IF NOT EXISTS customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phoneNumber TEXT UNIQUE,
        name TEXT,
        totalPurchase INTEGER);
    ''');
    }

    if (newVersion == 10) {
      db.execute('''
      CREATE TABLE IF NOT EXISTS bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phoneNumber TEXT,
        customerName TEXT,
        products TEXT,
        discount INTEGER,
        total INTEGER);
    ''');
      db.execute('''
      CREATE TABLE IF NOT EXISTS customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phoneNumber TEXT UNIQUE,
        name TEXT,
        totalPurchase INTEGER);
    ''');
    }

    if (newVersion == 11) {
      db.execute('''
      CREATE TABLE IF NOT EXISTS daily_sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        createdDateTime TEXT,
        updatedDateTime TEXT,
        totalSale INTEGER);
    ''');
      db.execute('''
      CREATE TABLE IF NOT EXISTS daily_purchases(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        createdDateTime TEXT,
        updatedDateTime TEXT,
        totalPurchase INTEGER);
    ''');
      try {
        db.execute('''
      ALTER TABLE BILLS ADD COLUMN createdDateTime TEXT;
    ''');
        db.execute('''
      ALTER TABLE BILLS ADD COLUMN updatedDateTime TEXT;
    ''');
        db.execute('''
      ALTER TABLE customers ADD COLUMN createdDateTime TEXT;
    ''');
        db.execute('''
      ALTER TABLE customers ADD COLUMN updatedDateTime TEXT;
    ''');
      } catch (ex) {
        print("Exception");
      }
    }
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phoneNumber TEXT,
        customerName TEXT,
        products TEXT,
        discount INTEGER,
        createdDateTime TEXT,
        updatedDateTime TEXT,
        total INTEGER);
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phoneNumber TEXT UNIQUE,
        name TEXT,
        createdDateTime TEXT,
        updatedDateTime TEXT,
        totalPurchase INTEGER);
    ''');
    print("Database was created!");
  }

  Future<int> addBill(Bill bill) async {
    var client = await db;
    Customer? customer = await fetchCustomer(bill.phoneNumber);
    if (customer == null) {
      await addCustomer(Customer(
          phoneNumber: bill.phoneNumber,
          name: bill.customerName,
          totalPurchase: bill.total));
    } else {
      await updateCustomer(Customer(
          id: customer.id,
          phoneNumber: customer.phoneNumber,
          name: customer.name,
          totalPurchase: customer.totalPurchase + bill.total));
    }
    return client.insert('bills', bill.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> addCustomer(Customer customer) async {
    var client = await db;
    return client.insert('customers', customer.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> addDailySale(Sale sale) async {
    var client = await db;
    return client.insert('daily_sales', sale.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> totalSale() async {
    var client = await db;
    var result =
        await client.rawQuery("SELECT SUM(sale) AS total FROM daily_sales");
    return int.parse(result[0]["total"].toString());
  }

  Future<int> totalPurchase() async {
    var client = await db;
    var result = await client
        .rawQuery("SELECT SUM(purchase) AS total FROM daily_purchases");
    return int.parse(result[0]["total"].toString());
  }

  Future<List<Map<String, dynamic>>> dailySaleAndPurchase() async {
    var client = await db;
    return await client.rawQuery('''SELECT 
    DATE(createdDateTime) AS period, 
    SUM(totalSale) AS totalSales, 
    SUM(totalPurchase) AS totalPurchases
FROM 
    (SELECT createdDateTime, totalSale, 0 AS totalPurchase FROM daily_sales 
     UNION ALL 
     SELECT createdDateTime, 0 AS totalSale, totalPurchase FROM daily_purchases)
GROUP BY 
    period;
        ''');
  }

  Future<List<Map<String, dynamic>>> monthlySaleAndPurchase() async {
    var client = await db;
    return await client.rawQuery('''SELECT 
    STRFTIME('%Y-%m', createdDateTime) AS period, 
    SUM(totalSale) AS totalSales, 
    SUM(totalPurchase) AS totalPurchases
FROM 
    (SELECT createdDateTime, totalSale, 0 AS totalPurchase FROM daily_sales 
     UNION ALL 
     SELECT createdDateTime, 0 AS totalSale, totalPurchase FROM daily_purchases)
GROUP BY 
    period;
        ''');
  }

  Future<List<Map<String, dynamic>>> weeklySaleAndPurchase() async {
    var client = await db;
    return await client.rawQuery('''SELECT 
    STRFTIME('%Y-%W', createdDateTime) AS period, 
    SUM(totalSale) AS totalSales, 
    SUM(totalPurchase) AS totalPurchases
FROM 
    (SELECT createdDateTime, totalSale, 0 AS totalPurchase FROM daily_sales 
     UNION ALL 
     SELECT createdDateTime, 0 AS totalSale, totalPurchase FROM daily_purchases)
GROUP BY 
    period;
        ''');
  }

  Future<int> addDailyPurchase(Purchase purchase) async {
    var client = await db;
    return client.insert('daily_purchases', purchase.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Bill?> fetchBill(int id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('bills', where: 'id = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.isNotEmpty) {
      return Bill.fromDb(maps.first);
    }
    return null;
  }

  Future<Customer?> fetchCustomer(String phoneNumber) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client
        .query('customers', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
    var maps = await futureMaps;
    if (maps.isNotEmpty) {
      return Customer.fromDb(maps.first);
    }
    return null;
  }

  Future<List<Customer>> fetchCustomersByPhoneNumber(String phoneNumber) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
        'customers',
        where: 'phoneNumber LIKE ?',
        whereArgs: ['%$phoneNumber%']);
    var maps = await futureMaps;
    return [for (Map<String, dynamic> map in maps) Customer.fromDb(map)];
  }

  Future<List<Bill>> fetchBills() async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query('bills');
    var maps = await futureMaps;

    return [for (Map<String, dynamic> map in maps) Bill.fromDb(map)];
  }

  Future<List<Customer>> fetchCustomers() async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('customers');
    var maps = await futureMaps;
    return [for (Map<String, dynamic> map in maps) Customer.fromDb(map)];
  }

  Future<List<Sale>> fetchDailySale() async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('daily_sales');
    var maps = await futureMaps;
    return [for (Map<String, dynamic> map in maps) Sale.fromDb(map)];
  }

  Future<List<Purchase>> fetchDailyPurchase() async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('daily_purchases');
    var maps = await futureMaps;
    return [for (Map<String, dynamic> map in maps) Purchase.fromDb(map)];
  }

  Future<int> updateBill(Bill newBill) async {
    var client = await db;
    return client.update('bills', newBill.toMapForDb(),
        where: 'id = ?',
        whereArgs: [newBill.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateCustomer(Customer newCustomer) async {
    var client = await db;
    return client.update('customers', newCustomer.toMapForDb(),
        where: 'id = ?',
        whereArgs: [newCustomer.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeBill(int id) async {
    var client = await db;
    client.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future closeDb() async {
    var client = await db;
    client.close();
  }
}
