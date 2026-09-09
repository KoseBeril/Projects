import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

// DatabaseHelper sınıfı, SQLite veritabanı işlemlerini yönetmek için kullanılan bir yardımcı sınıftır.,
// kullanıcı verilerini saklamak, sorgulamak ve silmek için gerekli yöntemleri içerir.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  Database? _database;

  DatabaseHelper._init();

  // Veritabanını açmak veya oluşturmak için kullanılan yöntem. Eğer veritabanı zaten açıksa, mevcut veritabanını döndürür. Aksi takdirde, yeni bir veritabanı oluşturur ve 'tasks' tablosunu oluşturur.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'plant_care.db'),
      version: 1,
      onCreate: (db, version) {
      db.execute('''
      CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      frequency TEXT,
      items TEXT,
      date TEXT,  
      done INTEGER
    )
  ''');
},
    );
    return _database!;
  }

 // Görevleri veritabanına eklemek için kullanılan yöntem. Görev bilgilerini bir Map olarak alır ve 'tasks' tablosuna ekler.
  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.insert('tasks', {
      'name': task['name'],
      'frequency': task['frequency'],
      'items': jsonEncode(task['items']),
      'date': task['date'], 
      'done': task['done'] ? 1 : 0
    });
  }
  
  // Belirli bir tarihe göre görevleri almak için kullanılan yöntem. Tarih parametresi ile eşleşen görevleri sorgular ve bir liste olarak döndürür.
  Future<List<Map<String, dynamic>>> getTasksByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks', 
      where: 'date = ?', 
      whereArgs: [date]
    );

    // JSON verisini geri çevirmek için map fonksiyonunu kullan

    return maps.map((m) => {
      'id': m['id'],
      'name': m['name'],
      'frequency': m['frequency'],
      'items': jsonDecode(m['items']), 
      'date': m['date'],
      'done': m['done'] == 1
    }).toList();
  }

  // Tüm görevleri almak için kullanılan yöntem. 'tasks' tablosundaki tüm kayıtları sorgular ve bir liste olarak döndürür.
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return maps.map((m) => {
      'id': m['id'],
      'name': m['name'],
      'frequency': m['frequency'],
      'items': jsonDecode(m['items']), // String'i tekrar listeye çevir
      'done': m['done'] == 1
    }).toList();
  }
 // Belirli bir görevi silmek için kullanılan yöntem. Görev ID'sini parametre olarak alır ve 'tasks' tablosundan ilgili kaydı siler.
  Future<void> deleteTask(int id) async {
  final db = await database;
  await db.delete(
    'tasks',
    where: 'id = ?',
    whereArgs: [id],
  );
  }

}