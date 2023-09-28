import 'package:click_it_app/data/models/local_sync_images_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database?> get db async {
    if (_database != null) {
      return _database;
    }

    //if the database is null
    //initialize and create the database

    _database = await initDatabase();

    return _database;
  }

  //initialize the database

  initDatabase() async {
    //create a local directory
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'images.db');

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);

    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT,frontImage TEXT NOT NULL,backImage TEXT NOT NULL,leftImage TEXT NOT NULL,rightImage TEXT NOT NULL) ",

   
    );
  }

  //insert function

  Future<LocalSyncImagesModel> insert(
      LocalSyncImagesModel localSyncImagesModel) async {
    var dbClient = await db;

    await dbClient!.insert('images', localSyncImagesModel.toMap());

    return localSyncImagesModel;
  }

 



  Future<List<LocalSyncImagesModel>> getImagesList() async {
    var dbClient = await db;

    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('images');

    return queryResult.map((e) => LocalSyncImagesModel.fromMap(e)).toList();
  }


  Future close() async{

    var dbClient= await db;

    dbClient?.close();


    
  }
}
