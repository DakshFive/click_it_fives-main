import 'package:click_it_app/data/models/photo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;
  static const String ID = 'id';
  static const String GTIN = 'gtin';
  static const String MATCH = 'match';
  static const String LATITUDE = 'latitude';
  static const String LONGITUDE = 'longitude';
  static const String UID = 'uid';
  static const String IMEI = 'imei';
  static const String SOURCE = 'source';
  static const String ROLEID = 'roleId';
  static const String FRONTIMAGE = 'frontImage';

  static const String BACKIMAGE = 'backImage';
  static const String LEFTIMAGE = 'leftImage';
  static const String RIGHTIMAGE = 'rightImage';

  static const String TABLE = 'PhotosTable';
  static const String DB_NAME = 'photos.db';

  Future<Database?> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
//    await db.execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY AUTOINCREMENT, $FRONTIMAGE TEXT,$BACKIMAGE TEXT,$LEFTIMAGE TEXT,$RIGHTIMAGE TEXT)");

    await db.execute('''
 
        CREATE TABLE $TABLE (
          $GTIN TEXT,
          $MATCH TEXT,
          $UID TEXT,
          $IMEI TEXT,
          $SOURCE TEXT,
          $ROLEID TEXT,
          $LONGITUDE TEXT,
          $LATITUDE TEXT,
          $FRONTIMAGE TEXT,
          $BACKIMAGE TEXT,
          $LEFTIMAGE TEXT,
          $RIGHTIMAGE TEXT
        )
 
        ''');
  }

  Future<Photo> save(Photo photos) async {
    var dbClient = await db;
    photos.id = await dbClient!.insert(TABLE, photos.toMap());
    return photos;
  }

  Future<int> insert(Map<String, dynamic> row) async {
    var dbClient = await db;
    return await dbClient!.insert(TABLE, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    var dbClient = await db;
    return await dbClient!.query(TABLE);
  }

  Future<List<Photo>> getPhotos() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient!.query(TABLE,
        columns: [ID, FRONTIMAGE, BACKIMAGE, LEFTIMAGE, RIGHTIMAGE]);
    List<Photo> photos = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        photos.add(Photo.fromMap(maps[i]));
      }
    }
    return photos;
  }

  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }

  Future<int> delete(String id) async {
    var dbClient = await db;

    return await dbClient!.delete(TABLE, where: '$GTIN = ?', whereArgs: [id]);
  }
}
