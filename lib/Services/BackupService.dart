import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timecountdown/Providers/PremiumProvider.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Model/UserData.dart';
import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';

class BackupService {
  static const String backupVersion = "1.0";
  static const String appName = "TimeCountdown";

  /// Check if user has premium access
  static Future<bool> _isPremiumUser(BuildContext context) async {
    return Provider.of<PremiumProvider>(context, listen: false).isPremium;
  }

  /// Show premium required dialog
  static void _showPremiumRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber),
              SizedBox(width: 8),
              Text('Premium Feature'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Backup and Import features are available for Premium users only.'),
              SizedBox(height: 16),
              Text('Upgrade to Premium to:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.backup, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(child: Text('Create backups of your countdown data')),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.restore, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(child: Text('Import backups to restore your data')),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.all_inclusive, size: 16, color: Colors.purple),
                  SizedBox(width: 8),
                  Expanded(child: Text('Access unlimited countdowns')),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(child: Text('Unlock premium templates')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PremiumPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Upgrade to Premium'),
            ),
          ],
        );
      },
    );
  }

  /// Creates a backup of all app data and allows user to share/save it
  static Future<void> createBackup(BuildContext context) async {
    // Check if user is premium
    if (!await _isPremiumUser(context)) {
      _showPremiumRequiredDialog(context);
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Collect all data
      final userData = await LocalStorageService.getCurrentUserData();
      final countdowns = await LocalStorageService.getCountdowns();

      // Create backup object
      final backupData = {
        'app_name': appName,
        'backup_version': backupVersion,
        'backup_date': DateTime.now().toIso8601String(),
        'user_data': userData != null ? _userDataToMap(userData) : null,
        'countdowns': countdowns.map((countdown) => _countdownToMap(countdown)).toList(),
        'total_countdowns': countdowns.length,
      };

      // Convert to JSON
      final jsonString = json.encode(backupData);

      // Create filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'TimeCountdown_Backup_$timestamp.json';

      // Save to device and share
      await _saveAndShareBackup(context, jsonString, fileName);

    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Converts UserData to Map for JSON serialization
  static Map<String, dynamic> _userDataToMap(UserData userData) {
    return {
      'uid': userData.uid,
      'name': userData.name,
      'email': userData.email,
      'account_created': userData.account_created,
      'last_app_opened': userData.last_app_opened,
      'isPurchased': userData.isPurchased,
      'countdownCount': userData.countdownCount,
    };
  }

  /// Converts CountDownData to Map for JSON serialization
  static Map<String, dynamic> _countdownToMap(CountDownData countdown) {
    return {
      'countDownId': countdown.countDownId,
      'countDownTempId': countdown.countDownTempId,
      'countDownTitle': countdown.countDownTitle,
      'countDownTargetDate': countdown.countDownTargetDate.millisecondsSinceEpoch,
      'countDownDim': countdown.countDownDim,
      'countDownCreatedDate': countdown.countDownCreatedDate.millisecondsSinceEpoch,
      'countDownImage': countdown.countDownImage,
    };
  }

  /// Saves backup to device storage and provides sharing options
  static Future<void> _saveAndShareBackup(BuildContext context, String jsonString, String fileName) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      
      // Write backup data to file
      await file.writeAsString(jsonString);

      // Hide loading dialog
      Navigator.of(context).pop();

      // Show success message and share options
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Backup Created Successfully'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Backup file created: $fileName'),
                const SizedBox(height: 10),
                const Text('Choose how to save your backup:'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Share the file
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: 'Time Countdown App Backup - $fileName',
                  );
                },
                child: const Text('Share'),
              ),
            ],
          );
        },
      );

    } catch (e) {
      // Hide loading dialog if still showing
      Navigator.of(context).pop();
      
      throw Exception('Failed to save backup: ${e.toString()}');
    }
  }

  /// Validates if a backup file is valid
  static Future<bool> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final jsonString = await file.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;

      // Check required fields
      return backupData.containsKey('app_name') &&
             backupData.containsKey('backup_version') &&
             backupData.containsKey('countdowns') &&
             backupData['app_name'] == appName;
    } catch (e) {
      return false;
    }
  }

  /// Gets backup file info without importing
  static Future<Map<String, dynamic>?> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;

      return {
        'backup_date': backupData['backup_date'],
        'backup_version': backupData['backup_version'],
        'total_countdowns': backupData['total_countdowns'],
        'app_name': backupData['app_name'],
      };
    } catch (e) {
      return null;
    }
  }

  /// Import backup data from a file
  static Future<void> importBackup(BuildContext context) async {
    // Check if user is premium
    if (!await _isPremiumUser(context)) {
      _showPremiumRequiredDialog(context);
      return;
    }

    try {
      // Pick backup file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final file = File(result.files.single.path!);
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Validating backup file...'),
              ],
            ),
          );
        },
      );

      // Validate backup file
      if (!await validateBackupFile(file.path)) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog(context, 'Invalid backup file. Please select a valid Time Countdown backup file.');
        return;
      }

      // Get backup info
      final backupInfo = await getBackupInfo(file.path);
      Navigator.of(context).pop(); // Close loading dialog

      if (backupInfo == null) {
        _showErrorDialog(context, 'Unable to read backup file information.');
        return;
      }

      // Show confirmation dialog with backup info
      final shouldImport = await _showImportConfirmationDialog(context, backupInfo);
      if (!shouldImport) {
        return;
      }

      // Show loading dialog for import
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Importing backup...'),
              ],
            ),
          );
        },
      );

      // Import the backup
      await _performImport(file.path);
      
      Navigator.of(context).pop(); // Close loading dialog

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Import Successful'),
            content: Text('Backup imported successfully!\n\nTotal countdowns restored: ${backupInfo['total_countdowns']}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

    } catch (e) {
      // Hide loading dialog if showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      _showErrorDialog(context, 'Import failed: ${e.toString()}');
    }
  }

  /// Shows confirmation dialog with backup information
  static Future<bool> _showImportConfirmationDialog(BuildContext context, Map<String, dynamic> backupInfo) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final backupDate = DateTime.parse(backupInfo['backup_date']);
        return AlertDialog(
          title: const Text('Confirm Import'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to import this backup?'),
              const SizedBox(height: 16),
              Text('Backup Date: ${backupDate.day}/${backupDate.month}/${backupDate.year}'),
              Text('Countdowns: ${backupInfo['total_countdowns']}'),
              Text('Version: ${backupInfo['backup_version']}'),
              const SizedBox(height: 16),
              const Text(
                'Warning: This will replace all your current countdown data!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Import'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Performs the actual import operation
  static Future<void> _performImport(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final backupData = json.decode(jsonString) as Map<String, dynamic>;

    // Clear existing data
    await LocalStorageService.clearAllCountdowns();

    // Import countdowns
    final countdownsData = backupData['countdowns'] as List<dynamic>;
    for (final countdownMap in countdownsData) {
      final countdown = _mapToCountdown(countdownMap as Map<String, dynamic>);
      await LocalStorageService.addCountdown(countdown);
    }

    // Import user data if available
    if (backupData['user_data'] != null) {
      final userData = _mapToUserData(backupData['user_data'] as Map<String, dynamic>);
      await LocalStorageService.updateCurrentUserData(userData);
    }
  }

  /// Converts Map to CountDownData
  static CountDownData _mapToCountdown(Map<String, dynamic> map) {
    return CountDownData(
      countDownId: map['countDownId'] as String,
      countDownTempId: map['countDownTempId'] as String,
      countDownTitle: map['countDownTitle'] as String,
      countDownTargetDate: DateTime.fromMillisecondsSinceEpoch(map['countDownTargetDate'] as int),
      countDownDim: map['countDownDim'] as double,
      countDownCreatedDate: DateTime.fromMillisecondsSinceEpoch(map['countDownCreatedDate'] as int),
      countDownImage: map['countDownImage'] as String,
    );
  }

  /// Converts Map to UserData
  static UserData _mapToUserData(Map<String, dynamic> map) {
    return UserData(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      account_created: map['account_created'] as String,
      last_app_opened: map['last_app_opened'] as String,
      isPurchased: map['isPurchased'] as bool,
      countdownCount: map['countdownCount'] as int,
    );
  }

  /// Shows error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
