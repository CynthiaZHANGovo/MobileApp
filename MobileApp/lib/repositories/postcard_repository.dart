
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:environmental_postcard/models/postcard.dart';

class PostcardRepository {
  static const String _directoryName = 'environmental_postcards';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$_directoryName';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<File> _getLocalFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<Postcard> savePostcard(Postcard postcard) async {
    final filename = 'postcard_${postcard.date.millisecondsSinceEpoch}.json';
    final file = await _getLocalFile(filename);
    final jsonString = json.encode(postcard.toJson());
    await file.writeAsString(jsonString);
    return postcard;
  }

  Future<List<Postcard>> loadPostcards() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      final List<FileSystemEntity> files = directory.listSync(recursive: true, followLinks: false);

      List<Postcard> postcards = [];
      for (final fileSystemEntity in files) {
        if (fileSystemEntity is File && fileSystemEntity.path.endsWith('.json')) {
          final file = File(fileSystemEntity.path);
          final contents = await file.readAsString();
          final Map<String, dynamic> json = json.decode(contents);
          postcards.add(Postcard.fromJson(json));
        }
      }
      // Sort postcards by date, newest first
      postcards.sort((a, b) => b.date.compareTo(a.date));
      return postcards;
    } catch (e) {
      print('Error loading postcards: $e');
      return [];
    }
  }
}
