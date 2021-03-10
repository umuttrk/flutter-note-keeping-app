import 'dart:io';

import 'package:flutter/services.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/models/notlar.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDataBase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  _initializeDatabase() async {
    var lock = Lock();
    Database _db;
    //assetsin içindeki databaseyi uygulamanın pathinde yeni bir database oluşturup içine yazıyoruz.
    if (_db == null) {
      await lock.synchronized(() async {

          var databasesPath = await getDatabasesPath();
         // print(databasesPath);
          var path = join(databasesPath, "appDB.db");
          var file = new File(path);

          // check if file exists
          if (!await file.exists()) {
            // Copy from asset
            ByteData data = await rootBundle.load(join("assets", "notlar.db"));
            List<int> bytes =
                data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            await new File(path).writeAsBytes(bytes);
          }
          // open the database
          _db = await openDatabase(path);

      });
    }

    return _db;
  }

 Future<List<Map<String,dynamic>>> kategorileriGetir() async{
    var db=await _getDataBase();
    var sonuc=await db.query('kategori');
    return sonuc;
  }
  Future<List<Kategori>> kategoriListesiniGetir() async{
    var kategoriMapListesi=await kategorileriGetir();
    var kategoriListesi=List<Kategori>();
    for(Map map in kategoriMapListesi){
      kategoriListesi.add(Kategori.fromMap(map));
    }

    return kategoriListesi;
  }

  Future<int> kategoriEkle(Kategori kategori) async{
    var db=await _getDataBase();
    var sonuc=await db.insert('kategori', kategori.toMap());
    return sonuc;
  }

  Future<int> kategoriGuncelle(Kategori kategori) async{
    var db=await _getDataBase();
    var sonuc=await db.update('kategori', kategori.toMap(),where: 'kategoriID = ?',whereArgs:[kategori.kategoriID]);
    return sonuc;
  }
  Future<int> kategoriSil(int kategoriID) async{
    var db=await _getDataBase();
    var sonuc=await db.delete('kategori',where: 'kategoriID = ?',whereArgs: [kategoriID]);
    return sonuc;
  }






  Future<List<Map<String,dynamic>>> notlariGetir() async{
    var db=await _getDataBase();
    var sonuc = await db.rawQuery('select * from "not" inner join kategori on kategori.kategoriID = "not".kategoriID order by notID Desc;');
    return sonuc;
  }

  Future<List<Not>> notListesiniGetir() async{
    var notlarMapListesi=await notlariGetir();
    var notListesi=List<Not>();
    for(Map map in notlarMapListesi){
      notListesi.add(Not.fromMap(map));
    }

    return notListesi;
  }

  Future<int> notlariGuncelle(Not not) async{
    var db=await _getDataBase();
    var sonuc=await db.update('not', not.toMap(),where: 'notID = ?',whereArgs:[not.notID]);
    return sonuc;
  }
  Future<int> notSil(int notID) async{
    var db=await _getDataBase();
    var sonuc=await db.delete('not',where: 'notID = ?',whereArgs: [notID]);
    return sonuc;
  }
  Future<int> notEkle(Not not) async{
    var db=await _getDataBase();
    var sonuc=await db.insert('not', not.toMap());
    return sonuc;
  }
}
