import 'package:flutter/material.dart';
import 'package:taskbalance/controller/db_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactory, databaseFactoryFfi, sqfliteFfiInit;

import 'package:taskbalance/view/home.dart';    

void main() async {


  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  db_sqlite().openMyDatabase();

  //db_sqlite().insertUser('FFC', 'fabiano@figueredo', '12345');

  runApp(MainApp());

}

class MainApp extends StatelessWidget {
 // const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskBalance',
      theme: _buildTheme(),
      home: Home(),
    );
  }

  _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF212121),
     // accentColor: Colors.deepOrange,
    //  primarySwatch: Colors.deepOrange,
    );
  }

}
