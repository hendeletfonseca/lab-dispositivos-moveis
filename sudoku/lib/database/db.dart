import 'package:sqflite/sqflite.dart';

Future<void> _createDatabase(Database db, int version) async {
  return await db.execute('''
        CREATE TABLE sudoku(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR NOT NULL,
          result INTEGER,
          date VARCHAR NOT NULL,
          level INTEGER
        )
      ''');
}

class SudokuSchema {
  final int? id; // Agora o id é opcional
  final String name;
  final int result;
  final String date;
  final int level;

  SudokuSchema({
    this.id,
    required this.name,
    required this.result,
    required this.date,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'result': result,
      'date': date,
      'level': level,
    };
  }


  factory SudokuSchema.fromJson(Map<String, dynamic> json) {
    return SudokuSchema(
      id: json['id'],
      name: json['name'],
      result: json['result'],
      date: json['date'],
      level: json['level'],
    );
  }

  SudokuSchema copy({
    int? id,
    String? name,
    int? result,
    String? date,
    int? level,
  }) {
    return SudokuSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      result: result ?? this.result,
      date: date ?? this.date,
      level: level ?? this.level,
    );
  }

  @override
  String toString() {
    return 'SudokuSchema{id: $id, name: $name, result: $result, date: $date, level: $level}';
  }
}

class SudokuDatabase {
  static final SudokuDatabase instance = SudokuDatabase._internal();

  static Database? _database;

  SudokuDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/notes.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<SudokuSchema> insert(SudokuSchema sudoku) async {
    final db = await instance.database;
    final id = await db.insert('sudoku', sudoku.toJson());
    return sudoku.copy(id: id);
  }


  Future<List<SudokuSchema>> getAll() async {
    final db = await instance.database;
    final result = await db.query('sudoku');
    return result.map((json) => SudokuSchema.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}