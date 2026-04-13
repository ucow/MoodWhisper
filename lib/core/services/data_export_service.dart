import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:mood_whisper/data/models/mood_record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportFormat { csv, json }

class DataExportService {
  Future<String> exportToCsv(List<MoodRecord> records) async {
    final List<List<dynamic>> rows = [
      ['uuid', 'moodType', 'intensity', 'note', 'recordedAt'],
    ];

    for (final record in records) {
      rows.add([
        record.uuid,
        record.moodType.key,
        record.intensity,
        record.note ?? '',
        record.recordedAt.toIso8601String(),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final filePath = await _saveToFile(csvData, 'mood_export.csv');
    return filePath;
  }

  Future<String> exportToJson(List<MoodRecord> records) async {
    final List<Map<String, dynamic>> jsonData = records.map((record) {
      return {
        'uuid': record.uuid,
        'moodType': record.moodType.key,
        'intensity': record.intensity,
        'note': record.note,
        'recordedAt': record.recordedAt.toIso8601String(),
      };
    }).toList();

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    final filePath = await _saveToFile(jsonString, 'mood_export.json');
    return filePath;
  }

  Future<String> _saveToFile(String data, String fileName) async {
    final directory = await _getExportDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fullFileName = '${timestamp}_$fileName';
    final file = File('${directory.path}/$fullFileName');
    await file.writeAsString(data);
    return file.path;
  }

  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir != null) return dir;
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
}