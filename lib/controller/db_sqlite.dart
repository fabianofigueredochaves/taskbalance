/*
CRUD

  // Entrada de texto para gerar o hash
  String input = "Olá, mundo!";

  // Converte a entrada para bytes usando utf8
  List<int> bytes = utf8.encode(input);

  // Gera o hash MD5
  Digest md5Hash = md5.convert(bytes);

  // Exibe o hash em formato hexadecimal
  print("Hash MD5: ${md5Hash.toString()}");

*/

//import 'package:taskbalance/controller/api_sdm.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show ConflictAlgorithm, Database, getDatabasesPath, openDatabase;

//import 'dart:convert'; // Para usar utf8
// ignore: depend_on_referenced_packages
//import 'package:crypto/crypto.dart'; // Pacote que contém o MD5    

class db_sqlite {
  Future<Database> openMyDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), 'taskbalance.db'),
        version: 1, onCreate: (db, version) async {
      //return db.execute('''
      db.execute('''
            PRAGMA foreign_keys = ON;
            CREATE TABLE IF NOT EXISTS usuario (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              apiId TEXT,
              nome TEXT NOT NULL,
              email TEXT NOT NULL,
              senha TEXT NOT NULL,
              data TEXT
            );
            CREATE TABLE IF NOT EXISTS tarefa (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              usuarioId INTEGER,
              apiId TEXT,
              titulo TEXT NOT NULL,
              descricao TEXT,
              tempoTotalExec INTEGER,
              hash TEXT,
              FOREIGN KEY (usuarioId) REFERENCES usuario (id) ON DELETE CASCADE
           );
           CREATE TABLE IF NOT EXISTS tempo (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tarefaId INTEGER,
              apiId TEXT,              
              tempoExec INTEGER,
              hash TEXT,
              FOREIGN KEY (tarefaId) REFERENCES tarefa (id) ON DELETE CASCADE
           );  
           CREATE TABLE IF NOT EXISTS metadata (              
              name TEXT,
              ult_modif TEXT,
              hash_md5 TEXT              
           );          
           '''); 
           db.insert('metadata', {'name': 'bd', 'ult_modif': '', 'hash_md5': ''});
           db.insert('metadata', {'name': 'usuario', 'ult_modif': '', 'hash_md5': ''});
           db.insert('metadata', {'name': 'tarefa', 'ult_modif': '', 'hash_md5': ''});
           db.insert('metadata', {'name': 'tempo', 'ult_modif': '', 'hash_md5': ''});                     
    });
  }

  Future<void> insertUser(String nome, String email, String senha) async {
   
    final db = await openMyDatabase();
/*
    String input = nome + email + senha;
    List<int> bytes = utf8.encode(input);
    Digest md5Hash = md5.convert(bytes);
    String output = md5Hash.toString();
  */ 
    db.insert(
        'usuario',
        {
          'nome': nome,
          'email': email,
          'senha': senha,
         // 'hash': output,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);   
    
    db.update('metadata', {'ult_modif': DateTime.now().toString()}, 
        where: 'ROWID = ?', whereArgs: [2]);

       
   // cadUser(email, senha, nome);

  }

  Future<void> deleteUser(int id) async {
    final db = await openMyDatabase();

    db.delete('usuario', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateUser(int id, String nome, String email) async {
    final db = await openMyDatabase();

    db.update(
        'usuario',
        {
          'nome': nome,
          'email': email,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<String> searchUserByEmail(String email) async {
    final db = await openMyDatabase();

    List<Map<String, Object?>> usr = (await db.query('usuario',
            columns: ['id', 'senha'], where: 'email = ?', whereArgs: [email])); // as Future<List<Map<String, Object?>>>;

    var senhaRet = usr.firstWhere(
      (mapa) => mapa.containsKey('senha'),
      orElse: () => {},
    );

    Object? valor = senhaRet['senha'];
    
    return valor?.toString() ?? '';
  }

  Future<Map<String, Object?>> searchUserByEmail2(String email) async {
    final db = await openMyDatabase();

    List<Map<String, Object?>> usr = (await db.query('usuario',
            columns: ['id', 'senha'], where: 'email = ?', whereArgs: [email])); // as Future<List<Map<String, Object?>>>;

    return usr[0];
  }
    

  // CRUD para Tarefas

  Future<void> insertTask(int usuarioId, String titulo, String descricao, String dataInicial, String dataFinal, String categoria, String status) async {
    
    final db = await openMyDatabase();
/*
    String input = usuarioId.toString() + titulo + descricao + dataInicial + dataFinal + categoria + status;
    List<int> bytes = utf8.encode(input);
    Digest md5Hash = md5.convert(bytes);
    String output = md5Hash.toString();
*/
    await db.insert(
        'tarefa',
        {
          'usuarioId': usuarioId,
          'titulo': titulo,
          'descricao': descricao,
          'time': DateTime.now().toString(),
          'data_inicial': dataInicial,
          'data_final': dataFinal,
          'categoria': categoria,
          'status': status,
        //  'hash': output,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

        
  }

  Future<void> deleteTask(int id) async {
    final db = await openMyDatabase();

    db.delete('tarefa', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTask(int id, int usuarioId, String titulo, String descricao,
      String dataInicial, String dataFinal, String categoria, String status) async {
    final db = await openMyDatabase();
    print("sqlite update:");
    print(
    db.update(
        'tarefa',
        {
          'usuarioId': usuarioId,
          'titulo': titulo,
          'descricao': descricao,
          'data_inicial': dataInicial,
          'data_final': dataFinal,
          'categoria': categoria,
          'status': status,
        },
        where: 'id = ?',
        whereArgs: [id]
    )//;
    );

  }

  Future<List<Map<String, dynamic>>> getTasksByIdUser(int usuarioId) async {
    final db = await openMyDatabase();
    return await db.query('tarefa',
        columns: ['id', 'titulo', 'descricao', 'data_inicial', 'data_final', 'categoria', 'status'],
        where: 'usuarioId = ?',
        whereArgs: [usuarioId]);
  }

  Future<Map<String, Object?>> getTaskByIdTask(int id) async {
    final db = await openMyDatabase();

    List<Map<String, Object?>> tsk = await db.query('tarefa',
        columns: ['id', 'usuarioId', 'titulo', 'descricao', 'data_inicial', 'data_final', 'categoria', 'status'],
        where: 'id = ?',
        whereArgs: [id]);
 
    return tsk.firstWhere(
      (mapa) => mapa.containsKey('id'),
      orElse: () => {},
    );
 
  }

}
