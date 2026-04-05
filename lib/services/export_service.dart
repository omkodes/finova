import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/datasources/sqflite_database_service.dart';

class ExportService {
  Future<bool> exportDataToExcel() async {
    try {
      final db = await SqfliteDatabaseService.database;

      // Initialize Excel workbook
      var excel = Excel.createExcel();
      
      // We start with a default "Sheet1", we can rename or delete later.
      final defaultSheet = excel.getDefaultSheet();

      // 1. Export Users
      final users = await db.query('users');
      if (users.isNotEmpty) {
        var userSheet = excel['Users'];
        // Write headers
        userSheet.appendRow(users.first.keys.map((k) => TextCellValue(k)).toList());
        // Write data
        for (var row in users) {
          userSheet.appendRow(row.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // 2. Export Transactions
      final transactions = await db.query('transactions');
      if (transactions.isNotEmpty) {
        var txSheet = excel['Transactions'];
        txSheet.appendRow(transactions.first.keys.map((k) => TextCellValue(k)).toList());
        for (var row in transactions) {
          txSheet.appendRow(row.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // 3. Export Goals
      final goals = await db.query('goals');
      if (goals.isNotEmpty) {
        var goalsSheet = excel['Goals'];
        goalsSheet.appendRow(goals.first.keys.map((k) => TextCellValue(k)).toList());
        for (var row in goals) {
          goalsSheet.appendRow(row.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // 4. Export Challenges
      final challenges = await db.query('challenges');
      if (challenges.isNotEmpty) {
        var challengeSheet = excel['Challenges'];
        challengeSheet.appendRow(challenges.first.keys.map((k) => TextCellValue(k)).toList());
        for (var row in challenges) {
          challengeSheet.appendRow(row.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // 5. Export Notifications
      final notifications = await db.query('notifications');
      if (notifications.isNotEmpty) {
        var notifSheet = excel['Notifications'];
        notifSheet.appendRow(notifications.first.keys.map((k) => TextCellValue(k)).toList());
        for (var row in notifications) {
          notifSheet.appendRow(row.values.map((v) => TextCellValue(v?.toString() ?? '')).toList());
        }
      }

      // Remove the default sheet if it wasn't used and we have other sheets
      if (defaultSheet != null && excel.sheets.keys.length > 1 && excel.sheets[defaultSheet]?.maxRows == 0) {
        excel.delete(defaultSheet);
      }

      // Encode Excel Data
      var fileBytes = excel.save();

      if (fileBytes != null) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        
        // Define file path
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${tempDir.path}/Finova_Data_$timestamp.xlsx');
        
        // Write the data to a local file
        await file.writeAsBytes(fileBytes);

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Here is my exported Finova data!',
          subject: 'Finova Data Export',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return false;
    }
  }
}
