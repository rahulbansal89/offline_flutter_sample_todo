// ignore_for_file: constant_identifier_names
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  late Box box;
  String boxName = 'testBox';

  factory HiveService() {
    return _instance;
  }

  Box getBox() {
    return box;
  }

  dynamic putData({
    required String key,
    dynamic value,
  }) {
    return box.put(key, value);
  }

  void init() async {
    await Hive.initFlutter();
    box = await Hive.openBox(boxName);
  }

  HiveService._internal();
}
