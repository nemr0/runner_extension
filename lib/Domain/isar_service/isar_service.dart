import 'dart:async';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:runner_extension/Data/models/project.dart';


final IsarService isarService = IsarService();


class IsarService {
  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    _isar = await Isar.open(
      [ProjectSchema],
      directory: dir.path,
    );
  }
   Isar? _isar;
  Isar get isar{
    if(_isar == null) throw('Isar is not initialized!');
    return _isar!;
  }

  List<T> get<T>() {
    return isar.collection<T>().where().findAllSync();
  }

  Id write<T>(T collection) {
    return isar.writeTxnSync(() => isar.collection<T>().putSync(collection));
  }

  bool delete<T>(Id id) {
    return isar.writeTxnSync(() => isar.collection<T>().deleteSync(id));
  }
}


