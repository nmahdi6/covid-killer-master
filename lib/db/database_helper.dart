import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/levels_manager.dart';

class DatabaseHelper {
  static const _databaseName = "covidkiller.db";
  static const _databaseVersion = 2;
  static String? currentLoggedInEmail;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onDowngrade);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE users (
            email TEXT PRIMARY KEY NOT NULL,
            password TEXT NOT NULL,
            firstName TEXT NOT NULL,
            lastName TEXT NOT NULL,
            loggedIn INTEGER,
            image TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE levels (
            levelNum INTEGER PRIMARY KEY NOT NULL,
            onLevel INTEGER,
            redCovid INTEGER NOT NULL,
            greenCovid INTEGER NOT NULL,
            spray INTEGER NOT NULL,
            mapID INTEGER NOT NULL,
            secs INTEGER NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE userLevels (
            email TEXT NOT NULL,
            levelNum INTEGER NOT NULL,
            star INTEGER NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE maps (
            mapID INTEGER PRIMARY KEY,
            rows INTEGER,
            columns INTEGER,
            doctorX INTEGER,
            doctorY INTEGER
          )
          ''');

    await db.execute('''
          CREATE TABLE walls (
            mapID INTEGER,
            posX INTEGER,
            posY INTEGER
          )
          ''');



    // await db.insert(
    //     'users',
    //     {"email": "miratameydani@gmail.com", "password": "12345678", "firstName": "Ata", "lastName": "M", "loggedIn": 1, "image": null});

    await db.insert("maps", {"mapID": 1, "rows": 9, "columns": 9, "doctorX": 7, "doctorY": 7});

    await db.insert("levels", {"levelNum": 1, "onLevel": 1, "redCovid": 2, "greenCovid": 1, "spray": 1, "mapID": 1, "secs": 120});
    await db.insert("levels", {"levelNum": 2, "onLevel": 0, "redCovid": 3, "greenCovid": 2, "spray": 1, "mapID": 1, "secs": 120});

    await db.insert("walls", {"mapID": 1, "posX": 2, "posY": 2});
    await db.insert("walls", {"mapID": 1, "posX": 2, "posY": 3});
    await db.insert("walls", {"mapID": 1, "posX": 2, "posY": 4});

    await db.insert("maps", {"mapID": 2, "rows": 9, "columns": 9, "doctorX": 7, "doctorY": 7});

    await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 2});
    await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 3});
    await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 4});
    await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 5});
    await db.insert("walls", {"mapID": 2, "posX": 3, "posY": 5});
    await db.insert("walls", {"mapID": 2, "posX": 4, "posY": 5});

    await db.insert("levels", {"levelNum": 3, "onLevel": 0, "redCovid": 4, "greenCovid": 3, "spray": 1, "mapID": 2, "secs": 120});
  }

  Future _onDowngrade(Database db, int oldVersion, int newVersion) async{
    if(oldVersion == 2 && newVersion == 1){
      await db.delete("maps", where: 'mapID=?', whereArgs: [2]);
      await db.delete("walls", where: 'mapID=?', whereArgs: [2]);
      await db.delete("levels", where: 'levelNum=?', whereArgs: [3]);
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async{
    if(oldVersion == 1){
      await db.insert("maps", {"mapID": 2, "rows": 9, "columns": 9, "doctorX": 7, "doctorY": 7});

      await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 2});
      await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 3});
      await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 4});
      await db.insert("walls", {"mapID": 2, "posX": 2, "posY": 5});
      await db.insert("walls", {"mapID": 2, "posX": 3, "posY": 5});
      await db.insert("walls", {"mapID": 2, "posX": 4, "posY": 5});

      await db.insert("levels", {"levelNum": 3, "onLevel": 0, "redCovid": 4, "greenCovid": 3, "spray": 1, "mapID": 2, "secs": 120});
    }
  }


  // All of the rows are returned as a list of maps, where each map is a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query('users');
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String email = row["email"];

    return await db.update('users', row, where: 'email = ?', whereArgs: [email]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String email) async {
    Database db = await instance.database;
    return await db.delete('users', where: 'email=?', whereArgs: [email]);
  }

  Future<Map?> select(String email, String password) async {
    // get a reference to the database
    Database db = await instance.database;

    // raw query
    List<Map> result = await db.rawQuery('SELECT * FROM users WHERE email=? AND password=?', [email, password]);

    return result.isEmpty ? null : result[0];
  }

  Future<Map?> selectUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM users WHERE email=?', [email]);
    return result.isEmpty ? null : result[0];
  }

  Future<bool> emailExist(String email) async{
    // get a reference to the database
    Database db = await instance.database;

    // raw query
    List<Map> result = await db.rawQuery('SELECT * FROM users WHERE email=?', [email]);

    return result.isEmpty ? false : true;
  }

  Future updateLoggedInUser(int loggedIn) async {
    Database db = await instance.database;
    await db.update('users', {'loggedIn': loggedIn}, where: 'email=?', whereArgs: [DatabaseHelper.currentLoggedInEmail]);
    if(loggedIn == 0){
      DatabaseHelper.currentLoggedInEmail = null;
    }
  }


  // MY METHODS
  setCurrentUser(String? email, context) {
    DatabaseHelper.currentLoggedInEmail = email;
    Provider.of<LevelsManager>(context, listen: false).levelSetUp();
  }

  Future<int?> getNumOfLevels() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM levels'));
  }

  Future<int> getLevelStar(int levelNum) async{
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT star FROM userLevels WHERE email=? AND levelNum=?', [currentLoggedInEmail, levelNum]);
    return result.isEmpty ? 0 : result[0]["star"];
  }

  Future<int> insert({required tableName, required Map<String, dynamic> record}) async {
    Database db = await instance.database;
    return await db.insert(tableName, record);
  }

  Future<List<Map>> getUserLevels() async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM userLevels WHERE email=?', [currentLoggedInEmail]);
    return result;
  }

  Future<List<Map>> getLevelFromUserLevels(levelNum) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM userLevels WHERE email=?AND levelNUm=?', [currentLoggedInEmail, levelNum]);
    return result;
  }

  Future<int> updateUserLevels(int levelNum, Map<String, dynamic> record) async {
    Database db = await instance.database;
    return await db.update('userLevels', record, where: 'email=? AND levelNum=?', whereArgs: [currentLoggedInEmail, levelNum]);
  }

  Future<Map?> getLoggedInUser() async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM users WHERE loggedIn=?', [1]);
    return result.isEmpty ? null : result[0];
  }

  Future<Map?> getStage(int levelNum) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM levels WHERE levelNum=?', [levelNum]);
    return result.isEmpty ? null : result[0];
  }

  Future<Map?> getMap(int mapID) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM maps WHERE mapID=?', [mapID]);
    return result.isEmpty ? null : result[0];
  }

  Future<List<Map>?> getWalls(int mapID) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM walls WHERE mapID=?', [mapID]);
    return result.isEmpty ? null : result;
  }

}
