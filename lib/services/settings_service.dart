// ignore_for_file: constant_identifier_names
import 'dart:io';

class Settings {
  static final Settings _instance = Settings._internal();

  Directory? directory;

  factory Settings() {
    return _instance;
  }

  Directory? getDirectory() {
    return directory;
  }

  void setDirectory(Directory directory) {
    this.directory = directory;
  }

  Settings._internal();
}
