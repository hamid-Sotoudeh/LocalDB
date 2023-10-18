// @dart=2.12
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(SqliteApp());
}

class SqliteApp extends StatefulWidget {
  const SqliteApp({Key? key}) : super(key: key);

  @override
  State<SqliteApp> createState() => _SqliteAppState();
}

class _SqliteAppState extends State<SqliteApp> {

  int selectedId=4;
  final textcontroller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
       appBar: AppBar(
         title: TextField(controller: textcontroller, style: TextStyle(fontSize: 30),),
       ),

        body: Center(
          child: FutureBuilder<List<Person>>(
            future: DatabaseHelper.instance.getStudents(),
            builder: (BuildContext context , AsyncSnapshot<List<Person>> snapshot){

if (!snapshot.hasData){
  return Center(child: Text("Loading ...",style: TextStyle(fontSize: 26)),);
}
if (snapshot.data!.isEmpty) {
  return Center(child: Text("No Student in list ...", style: TextStyle(fontSize: 26)),);
} else {
  return ListView(
  children: [snapshot.data.map((Person)  {
return Center(
  child: Card(
    color: Colors.white,
    child: ListTile(
      title: Text(Person.name, style: TextStyle(fontSize: 22,color: Colors.black)),
      onTap: (){

      },
      onLongPress: (){

      },
    ),
  ),
);

  }).toList(),],
);
}
            },



          ),






        ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {

             await DatabaseHelper.instance.add(Person(id:1 ,name: textcontroller.text));

             setState(() {
               textcontroller.clear();
             });

        },
        ),

      ),
    );
  }

}
class Person{
  final int id;
  final String name;

  Person({required this.id, required this.name});


  factory Person.fromMap(Map<String,dynamic> json) => new Person(
      id: json['id'],
      name: json['name'],


  );

  Map<String , dynamic> toMap(){
  return{
    'id':id,
    'name':name,
  };


  }



}

class DatabaseHelper{
 DatabaseHelper._privateConstructor();
 static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

 static Database? _database;
 Future<Database> get database async => _database ??= await _initDatabase();

 Future<Database> _initDatabase() async {
   Directory documentDirectory = await getApplicationDocumentsDirectory();
   String path = join(documentDirectory.path , 'students.db');

   return await openDatabase(
     path,
     version: 1,
     onCreate: _onCreat,
   );


 }

 Future _onCreat(Database db,int version) async {
   await db.execute(
     '''
     CREATE TABLE students(
     id INTEGER PRIMARY KEY,
     name TEXT
     )
     '''

   );


 }

 Future<int> add(Person Person) async {
   Database db = await instance.database;
   return await db.insert('students', Person.toMap());


 }


 Future<int> remove(int id) async {
   Database db = await instance.database;
   return await db.delete('students' , where: 'id = ?' , whereArgs: [id]);

 }


 Future<int> update(Person Person) async {
   Database db = await instance.database;
   return await db.update('students', Person.toMap() , where: "id = ?" , whereArgs: [Person.id]);


 }

 Future<List<Person>> getStudents() async {
   Database db = await instance.database;

   var students = await db.query('students' , orderBy: 'name');
   List<Person> PersonList = students.isNotEmpty
   ? students.map((e) => Person.fromMap(e)).toList()
   : [];

   return PersonList;



 }




}

