import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";

  @override
  void initState() {
    super.initState();
    getName();
  }

  void getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("name") != null) {
      setState(() {
        name = prefs.getString("name")!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    addNewTodoToDatabase();
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Hello $name",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.w100),
                  ),
                  const Text(
                    "Todos:",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w100),
                  ),
                  FutureBuilder(future: retrieveTodos(), builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.data);
                      return Text("Data");
                    } else {
                      return  Text("loading");
                    }
                  }),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.grey,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    addNewTodoToDatabase();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addNewTodoToDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final database = await openDatabase(
      join(await getDatabasesPath(), 'to_do_test.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id INTEGER PRIMARY KEY, name TEXT,)',
        );
      },
      version: 1,
    );
    insertTodo(database);
  }

  // Define a function that inserts dogs into the database
  Future<void> insertTodo(database) async {
    // Get a reference to the database.
    var db = await database;
    await db.insert(
      'todos',
      {'name': "muffins1"},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future retrieveTodos() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'to_do_test.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
      version: 1,
    );
    final List<Map<String, dynamic>> maps = await database.query('todos');
    return maps;
  }
}
