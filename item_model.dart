import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserAccount {
  final String username;
  final String password;
  final String role;
  String status;

  UserAccount({
    required this.username,
    required this.password,
    required this.role,
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
        'status': status,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      status: json['status'] as String? ?? 'Active',
    );
  }
}

class ItemModel {
  final String id;
  final String title;
  final String category;
  String status;
  final String createdBy;

  ItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'status': status,
        'createdBy': createdBy,
      };

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      createdBy: json['createdBy'] as String,
    );
  }
}

// DATA AWAL
final List<UserAccount> registeredUsers = [
  UserAccount(
    username: 'user1',
    password: 'password',
    role: 'User',
    status: 'Active',
  ),
  UserAccount(
    username: 'admin1',
    password: '12345678',
    role: 'Admin',
    status: 'Active',
  ),
];

final List<ItemModel> globalItemList = [
  ItemModel(
    id: '1',
    title: 'Perbaikan PC Lab 1',
    category: 'Inventaris',
    status: 'Pending',
    createdBy: 'user1',
  ),
  ItemModel(
    id: '2',
    title: 'Update Module Flutter',
    category: 'Task',
    status: 'Proses',
    createdBy: 'user1',
  ),
];

class LocalStorage {
  LocalStorage._();

  static File? _file;

  static Future<File> _getFile() async {
    if (_file != null) return _file!;

    // Mengambil direktori dokumen aplikasi yang aman untuk Android, iOS, maupun Windows
    final directory = await getApplicationDocumentsDirectory();

    final dir = Directory(
      '${directory.path}${Platform.pathSeparator}TaskInventoryManager',
    );

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    _file = File(
      '${dir.path}${Platform.pathSeparator}task_inventory_data.json',
    );

    return _file!;
  }

  static Future<void> initialize() async {
    final file = await _getFile();

    if (!await file.exists()) {
      await saveData();
      return;
    }

    try {
      final contents = await file.readAsString();

      if (contents.trim().isEmpty) return;

      final decoded = jsonDecode(contents) as Map<String, dynamic>;

      final usersJson = decoded['users'] as List<dynamic>? ?? [];
      final itemsJson = decoded['items'] as List<dynamic>? ?? [];

      final users = usersJson.map((entry) {
        return UserAccount.fromJson(
          Map<String, dynamic>.from(entry as Map),
        );
      }).toList();

      final items = itemsJson.map((entry) {
        return ItemModel.fromJson(
          Map<String, dynamic>.from(entry as Map),
        );
      }).toList();

      registeredUsers
        ..clear()
        ..addAll(users);

      globalItemList
        ..clear()
        ..addAll(items);
    } on FormatException {
      throw const FormatException(
        'File data aplikasi tidak valid. Data awal tidak dimuat ulang agar data lama tidak tertimpa.',
      );
    }
  }

  static Future<void> saveData() async {
    final file = await _getFile();

    final data = {
      'users': registeredUsers.map((user) => user.toJson()).toList(),
      'items': globalItemList.map((item) => item.toJson()).toList(),
    };

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
      flush: true,
    );
  }
}