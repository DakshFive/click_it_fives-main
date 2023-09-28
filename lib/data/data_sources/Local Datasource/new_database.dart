import 'package:click_it_app/data/models/photo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

class NewDatabaseHelper {
  static Database? _db;
  static const String ID = 'id';
  static const String COMPANYID = 'companyid';
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
  static const String TOPIMAGE = 'topImage';
  static const String BOTTOMIMAGE = 'bottomImage';
  static const String RESOLUTIONFRONTIMAGE = 'resolutionfrontImage';
  static const String RESOLUTIONBACKIMAGE = 'resolutionbackImage';
  static const String RESOLUTIONLEFTIMAGE = 'resolutionleftImage';
  static const String RESOLUTIONRIGHTIMAGE = 'resolutionrightImage';
  static const String RESOLUTIONTOPIMAGE = 'resolutiontopImage';
  static const String RESOLUTIONBOTTOMIMAGE = 'resolutionbottomImage';
  static const String NUTRIENTSIMAGE = 'nutrientsImage';
  static const String INGREDIENTSIMAGE = 'ingredientsImage';
  static const String EDITEDFRONTIMAGE = 'editedfrontImage';
  static const String EDITEDBACKIMAGE = 'editedbackImage';
  static const String EDITEDLEFTIMAGE = 'editedleftImage';
  static const String EDITEDRIGHTIMAGE = 'editedrightImage';
  static const String EDITEDTOPIMAGE = 'editedtopImage';
  static const String EDITEDBOTTOMIMAGE = 'editedbottomImage';
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
    String path = join(await documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $TABLE (
            $GTIN TEXT PRIMARY KEY NOT NULL,
            $COMPANYID TEXT,
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
            $RIGHTIMAGE TEXT,
            $TOPIMAGE TEXT,
            $BOTTOMIMAGE TEXT,
            $NUTRIENTSIMAGE TEXT,
            $INGREDIENTSIMAGE TEXT,
            $EDITEDFRONTIMAGE TEXT,
            $EDITEDBACKIMAGE TEXT,
            $EDITEDLEFTIMAGE TEXT,
            $EDITEDRIGHTIMAGE TEXT,
            $EDITEDTOPIMAGE TEXT,
            $EDITEDBOTTOMIMAGE TEXT,
            $RESOLUTIONFRONTIMAGE TEXT,
            $RESOLUTIONBACKIMAGE TEXT,
            $RESOLUTIONLEFTIMAGE TEXT,
            $RESOLUTIONRIGHTIMAGE TEXT,
            $RESOLUTIONTOPIMAGE TEXT,
            $RESOLUTIONBOTTOMIMAGE TEXT
          )''',);
  }

  Future<Photo> save(Photo photos) async {
    var dbClient = await db;
    photos.id = await dbClient!.insert(TABLE, photos.toMap());
    return photos;
  }

  // Future<int> insert(Map<String, dynamic> row) async {
  //   var dbClient = await db;
  //   return await dbClient!.insert(TABLE, row);
  // }
  Future<int> insertOrUpdate(Map<String, dynamic> row) async {
    var dbClient = await db;

    final String gtin = row[GTIN];
    final existingRows = await dbClient!.query(
      TABLE,
      where: '$GTIN = ?',
      whereArgs: [gtin],
    );

    final oldRows = await dbClient.query(TABLE);
    print('${oldRows}');

    print('the existing rows: $existingRows');

    if (existingRows.isNotEmpty) {
      return await dbClient.update(
        TABLE,
        row,
        where: '$GTIN = ?',
        whereArgs: [gtin],
      );
    } else {
      return await dbClient.insert(TABLE, row,conflictAlgorithm: ConflictAlgorithm.replace);
   }
  }

  Future<String?> queryImageByGTIN(String gtin, String imageType) async {
    var dbClient = await db;

    List<Map<String, dynamic>> rows = await dbClient!.query(
      TABLE,
      where: '$GTIN = ?',
      whereArgs: [gtin],
      columns: [imageType],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return rows.first[imageType] as String?;
    }

    return null;
  }

  Future<int> insertOrUpdateorAbort(Map<String, dynamic> row) async {
    var dbClient = await db;

    final String gtin = row[GTIN];
    final existingRows = await dbClient!.query(
      TABLE,
      where: '$GTIN = ?',
      whereArgs: [gtin],
    );

    if (existingRows.isEmpty) {
      return await dbClient.insert(TABLE, row);
    } else {
      return 0; // Indicate that no action was taken
    }
  }

  Future<void> clearTable() async {
    var dbClient = await db;

    await dbClient!.delete(TABLE);
  }

  Future<void> updateRowByGTIN(
      String gtin, Map<String, dynamic> updatedData) async {
    var dbClient = await db;

    await dbClient!.update(
      TABLE,
      updatedData,
      where: '$GTIN = ?',
      whereArgs: [gtin],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final dbClient = await db;
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
