import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfuckyourlife/components/homePage/todoComponent/todoComponent.dart';
import 'package:unfuckyourlife/model/todo/Todo.dart';
import 'package:unfuckyourlife/model/todo/mapToTodo.dart';

import '../../model/database/insert_and_create.dart';
import '../../model/database/retrieve.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";
  List<Todo> _todos = [];

  final newTodoNameController = TextEditingController();
  final newTodoDescriptionController = TextEditingController();

  late DateTime selectedDateForDeadline = getTomorrow();

  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    newTodoNameController.dispose();
    newTodoDescriptionController.dispose();

    super.dispose();
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
                  FutureBuilder(
                      future: retrieveTodos(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            _todos = [];
                            return const Text("Gay");
                          } else {
                            for (var i = 0; i < snapshot.data!.length; i++) {
                              _todos.add(mapToTodo(snapshot.data![i]));
                            }
                          }
                          bool runAgain = true;
                          if (_todos.length > 1) {
                            while (runAgain) {
                              runAgain = false;
                              for (var i = 1; i < _todos.length; i++) {
                                int dayX = _todos[i]
                                    .deadline
                                    .millisecondsSinceEpoch;
                                int dayY = _todos[i - 1]
                                    .deadline
                                    .millisecondsSinceEpoch;

                                if (dayX.compareTo(dayY) < 0) {
                                  _todos.insert(i - 1, _todos[i]);
                                  _todos.removeAt(i + 1);
                                  runAgain = true;
                                }
                              }
                            }
                          }
                          print(_todos);
                          return Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(0),
                              shrinkWrap: true,
                              itemCount: _todos.length,
                              itemBuilder: (context, index) {
                                return TodoComponent(
                                  todo: _todos[index],
                                  id: _todos[index].id as int,
                                  placeInTheTodosList: index,
                                  removeTodoInUi: removeFromTodoList,
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                  ),
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
                  onPressed: () async {
                    // Doing it before so it is reset even when you close dialog
                    // by taping outside of it.
                    resetControllers();
                    await _showMyDialog();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void removeFromTodoList(int placeInList) {
    setState(() {
      _todos.removeAt(placeInList);
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> selectDate(BuildContext context) async {
              final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDateForDeadline,
                  firstDate: DateTime(2015, 8),
                  lastDate: DateTime(2101));
              if (picked != null && picked != selectedDateForDeadline) {
                setState(() {
                  selectedDateForDeadline = picked;
                });
              }
            }

            return Theme(
              data: ThemeData(
                dialogBackgroundColor: const Color.fromARGB(250, 22, 22, 23),
                inputDecorationTheme: InputDecorationTheme(
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
              child: AlertDialog(
                title: const Text(
                  'New Todo',
                  style: TextStyle(color: Colors.white),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text(
                        'Add new todo:',
                        style: TextStyle(color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Enter todo name',
                          ),
                          controller: newTodoNameController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Description',
                          ),
                          controller: newTodoDescriptionController,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => selectDate(context),
                        child: Text(
                            '${selectedDateForDeadline.day.toString()}.${selectedDateForDeadline.month.toString()}.${selectedDateForDeadline.year.toString()}'),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      final newTodo = Todo(
                        name: newTodoNameController.value.text,
                        description: newTodoDescriptionController.value.text,
                        created: DateTime.now(),
                        deadline: selectedDateForDeadline,
                      );
                      addNewTodoToDatabase(newTodo);
                      uiUpdateTodos(newTodo);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void uiUpdateTodos(Todo newTodo) {
    setState(() {
      _todos.add(newTodo);
    });
  }

  void resetControllers() {
    newTodoNameController.clear();
    newTodoDescriptionController.clear();
    selectedDateForDeadline = getTomorrow();
  }

  DateTime getTomorrow() {
    return DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  }
}
