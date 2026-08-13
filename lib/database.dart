import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/native.dart';
import 'package:sqlite_async/sqlite_async.dart';

abstract class DbConnection {
  static Future<SqliteDatabase> getConnection() async {
    final databasesDirectory = Platform.isIOS
        ? (await getLibraryDirectory()).path
        : path.join(
            (await getApplicationDocumentsDirectory()).path,
            'databases',
          );
    final databasePath = path.join(databasesDirectory, 'dictionary.db');
    final databaseFile = File(databasePath);

    // TODO: Rewrite the database everytime is not a good idea. Implement a verification to check if there is a new version
    await databaseFile.parent.create(recursive: true);
    final asset = await rootBundle.load('db/dictionary.db');
    await databaseFile.writeAsBytes(
      asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes),
      flush: true,
    );

    return SqliteDatabase.withFactory(CustomFactory(path: databasePath));
  }
}

// Enable extensions in the future
final class CustomFactory extends NativeSqliteOpenFactory {
  CustomFactory({required super.path, super.sqliteOptions});
}
