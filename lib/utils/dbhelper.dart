// ignore_for_file: avoid_function_literals_in_foreach_calls, unnecessary_null_comparison, prefer_conditional_assignment, unnecessary_this

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:todoapp/model/todo.dart';
import 'package:path/path.dart';

class DbHelper {
  String tblTodo = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  static final DbHelper instance = DbHelper._init();

  static Database? _db;

  DbHelper._init();

  Future<Database?> get database async {
    if (_db == null) {
      _db = await _initDB('todo.db');
    }
    return _db;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath = "";
    if (Platform.isAndroid) {
      Directory directory =
          await path_provider.getApplicationDocumentsDirectory();
      dbPath = directory.path;
    } else if (Platform.isIOS) {
      dbPath = await getDatabasesPath();
    }

    String path = join(dbPath, filePath);
    return await openDatabase(path,
        onCreate: _craeteDB, onUpgrade: _onUpgrade, version: 15);
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS $tblTodo;");
    // then create again
    await db.execute(
        "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  void _craeteDB(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  Future<int> insertTodo(Todo todo) async {
    Database? db = await this.database;
    var result = await db!.insert(tblTodo, todo.toMap());
    return result;
  }

  Future<List<Todo>> getTodos() async {
    List<Todo> todoList = <Todo>[];
    Database? db = await this.database;
    var result =
        await db!.rawQuery("SELECT * FROM $tblTodo ORDER BY $colPriority ASC");
    result.forEach((element) {
      todoList.add(Todo.fromObject(element));
    });
    return todoList;
  }

  Future<int?> getCount() async {
    Database? db = await this.database;
    var result = Sqflite.firstIntValue(
        await db!.rawQuery("SELECT COUNT(*) FROM $tblTodo"));

    return result;
  }

  Future<int> updateTodo(Todo todo) async {
    Database? db = await this.database;
    var result = await db!.update(tblTodo, todo.toMap(),
        where: "$colId = ?", whereArgs: [todo.id]);
    return result;
  }

  Future<int> deleteTodo(int id) async {
    Database? db = await this.database;
    var result =
        await db!.delete(tblTodo, where: "$colId = ?", whereArgs: [id]);
    return result;
  }
}
