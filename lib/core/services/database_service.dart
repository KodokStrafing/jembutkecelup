import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();
  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');
    return openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE budgets ADD COLUMN period TEXT NOT NULL DEFAULT 'monthly'");
      await db.execute('ALTER TABLE budgets ADD COLUMN startDate TEXT');
      await db.execute('ALTER TABLE budgets ADD COLUMN description TEXT');
      final now = DateTime.now().toIso8601String();
      await db.update('budgets', {'startDate': now}, where: 'startDate IS NULL');
    }
    if (oldVersion < 3) {
      // Add recurrence column to scheduled transactions.
      // 'none' = run once, 'daily' | 'weekly' | 'monthly' = auto-requeue.
      await db.execute("ALTER TABLE transactions ADD COLUMN recurrence TEXT NOT NULL DEFAULT 'none'");
      // lastExecuted: when auto-execution last fired for this scheduled tx.
      await db.execute('ALTER TABLE transactions ADD COLUMN lastExecuted TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, type TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        icon TEXT NOT NULL, colorValue INTEGER NOT NULL,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, icon TEXT NOT NULL,
        colorValue INTEGER NOT NULL, type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL, subtitle TEXT,
        amount REAL NOT NULL, type TEXT NOT NULL,
        categoryId INTEGER, accountId INTEGER,
        date TEXT NOT NULL, note TEXT,
        isScheduled INTEGER NOT NULL DEFAULT 0,
        recurrence TEXT NOT NULL DEFAULT 'none',
        lastExecuted TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id),
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER, label TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL DEFAULT 'monthly',
        startDate TEXT, description TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');
    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now();
    final walletId = await db.insert('accounts', {
      'name': 'Cash', 'type': 'cash', 'balance': 765000,
      'icon': 'wallet', 'colorValue': 0xFFFF8A50,
    });
    final catFood = await db.insert('categories', {
      'name': 'makan n minum', 'icon': 'restaurant', 'colorValue': 0xFF10B981, 'type': 'expense',
    });
    final catIncome = await db.insert('categories', {
      'name': 'Sangu', 'icon': 'payments', 'colorValue': 0xFF10B981, 'type': 'income',
    });
    await db.insert('categories', {'name': 'Bensin', 'icon': 'directions_car', 'colorValue': 0xFF10B981, 'type': 'expense'});
    await db.insert('categories', {'name': 'seputar kuliah', 'icon': 'school', 'colorValue': 0xFF10B981, 'type': 'expense'});

    await db.insert('transactions', {
      'title': 'makan n minum', 'subtitle': 'minggu kmrn',
      'amount': -350000, 'type': 'expense',
      'categoryId': catFood, 'accountId': walletId,
      'date': now.toIso8601String(), 'isScheduled': 0, 'recurrence': 'none',
    });
    await db.insert('transactions', {
      'title': 'Sangu', 'subtitle': 'sangu',
      'amount': 255000, 'type': 'income',
      'categoryId': catIncome, 'accountId': walletId,
      'date': now.toIso8601String(), 'isScheduled': 0, 'recurrence': 'none',
    });
    // A monthly scheduled transaction as seed demo
    await db.insert('transactions', {
      'title': 'Sangu Bulanan', 'subtitle': 'sangu',
      'amount': 255000, 'type': 'income',
      'categoryId': catIncome, 'accountId': walletId,
      'date': now.toIso8601String(), 'isScheduled': 1, 'recurrence': 'monthly',
    });
    await db.insert('budgets', {
      'categoryId': catFood, 'label': 'makan n minum',
      'amount': 500000, 'period': 'monthly',
      'startDate': now.toIso8601String(), 'description': '',
    });
  }
}
