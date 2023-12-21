import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfuckyourlife/components/homePage/todoComponent/todoComponent.dart';
import 'package:unfuckyourlife/model/todo/Todo.dart';
import 'package:unfuckyourlife/model/todo/mapToTodo.dart';

import '../../model/database/insert_and_create.dart';
import '../../model/database/retrieve.dart';
import '../../model/notification/notifications.dart';

import "package:timezone/data/latest.dart" as tz;

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
  late TimeOfDay defaultNotifyingTime;
  late TimeOfDay notifyAt;

  @override
  void initState() {
    super.initState();
    NotificationService().initNotification();
    tz.initializeTimeZones();

    WidgetsFlutterBinding.ensureInitialized();
    asynchronusStartFunctions();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    newTodoNameController.dispose();
    newTodoDescriptionController.dispose();

    super.dispose();
  }

  void asynchronusStartFunctions() async {
    print(NotificationService().getActiveNotifications());

    askForPermissions();

    getName();
    getDefaultNotifyingTime();

    checkIfTheNotifyingIsSet();

    print(await retrieveNotifications());
  }

  void getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("name") != null) {
      setState(() {
        name = prefs.getString("name")!;
      });
    }
  }

  void checkIfTheNotifyingIsSet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("notifying") != true) {
      DateTime startNotifyingAt = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        17,
        45,
      );

      if (startNotifyingAt.difference(DateTime.now()).inDays < 0) {
        // I plan to return id of the notifier
        Timer(
            startNotifyingAt
                .add(const Duration(days: 1))
                .difference(DateTime.now()), () {
          NotificationService().showDailyAtTime(startNotifyingAt);
        });
      } else {
        Timer(startNotifyingAt.difference(DateTime.now()), () {
          NotificationService().showDailyAtTime(startNotifyingAt);
        });
      }
      prefs.setBool("notifying", true);
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
                    future: retrieveTodosAndSortThem(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Widget>> snapshot) {
                      if (snapshot.hasData) {
                        List<Widget> widgets = snapshot.data as List<Widget>;

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: widgets.length,
                          itemBuilder: (BuildContext context, int index) {
                            return widgets[index];
                          },
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

            Future<void> selectTime(BuildContext context) async {
              final TimeOfDay? pickedS = await showTimePicker(
                context: context,
                initialTime: notifyAt,
              );

              if (pickedS != null && pickedS != defaultNotifyingTime) {
                setState(() {
                  notifyAt = pickedS;
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
                      ),
                      ElevatedButton(
                        onPressed: () => selectTime(context),
                        child: Text(notifyAt.format(context)),
                      ),
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
                    onPressed: () async {
                      // If the notification notifying time will be different from the time that all notifications are
                      // are reminded ("Check all your tasks" after school day or something like that), add the notification time.

                      // The default notifying time will always be 1
                      int deadline_id = 1;

                      if (notifyAt != defaultNotifyingTime) {
                        DateTime date = DateTime(
                            selectedDateForDeadline.year,
                            selectedDateForDeadline.month,
                            selectedDateForDeadline.day,
                            notifyAt.hour,
                            notifyAt.minute);
                        deadline_id = await NotificationService()
                            .scheduleNotification(
                                scheduledNotificationDateTime: date);
                      }

                      final newTodo = Todo(
                        name: newTodoNameController.value.text,
                        description: newTodoDescriptionController.value.text,
                        created: DateTime.now(),
                        deadline: deadline_id,
                      );
                      addNewTodoToDatabase(newTodo);
                      uiUpdateTodos();

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

  void uiUpdateTodos() async {
    List<Map<String, dynamic>> retrievedTodos = await retrieveTodos();
    retrieveTodosSorted(retrievedTodos);
    setState(() {
      _todos = _todos;
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

  void getDefaultNotifyingTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timeInString = prefs.getString("defaultNotifyingTime");
    // Should never happen
    if (timeInString != null) {
      // timeInString.split("/") => [hours, minutes
      setState(() {
        defaultNotifyingTime = TimeOfDay(
            hour: int.parse(timeInString.split("/")[0]),
            minute: int.parse(timeInString.split("/")[0]));
        notifyAt = defaultNotifyingTime;
      });
    }
    // Default
    defaultNotifyingTime = const TimeOfDay(hour: 12, minute: 0);

    // TODO: remove
    print(await NotificationService().getActiveNotifications());
  }

  Future<List<Widget>> retrieveTodosAndSortThem() async {
    List<Map<String, dynamic>> todos = await retrieveTodos();

    if (todos.isEmpty) {
      _todos = [];
      return [const Text("Gay")];
    }
    await retrieveTodosSorted(todos);
    return await todosWidgets(_todos);
  }

  Future<void> retrieveTodosSorted(List<Map<String, dynamic>> map) async {
    _todos = [];
    for (var i = 0; i < map.length; i++) {
      _todos.add(mapToTodo(map[i]));
    }
    bool runAgain = true;
    if (_todos.length > 1) {
      while (runAgain) {
        runAgain = false;
        for (var i = 1; i < _todos.length; i++) {
          DateTime deadlineOne = await _todos[i].getDeadline();
          DateTime deadlineTwo = await _todos[i - 1].getDeadline();

          int dayX = deadlineOne.millisecondsSinceEpoch;
          int dayY = deadlineTwo.millisecondsSinceEpoch;

          if (dayX.compareTo(dayY) < 0) {
            print(_todos);

            _todos.insert(i - 1, _todos[i]);
            _todos.removeAt(i + 1);
            runAgain = true;
          }
        }
      }
    }
  }

  Future<List<Widget>> todosWidgets(List<Todo> todoList) async {
    List<Widget> widgets = [];

    bool isToday = false;

    bool addedToday = false;
    bool addedOther = false;

    print(todoList);

    for (int i = 0; i < todoList.length; i++) {
      DateTime deadline = await todoList[i].getDeadline();
      if (deadline.year == DateTime.now().year &&
          deadline.day == DateTime.now().day &&
          deadline.month == DateTime.now().month) {
        isToday = true;
      } else {
        isToday = false;
      }

      if (isToday && !addedToday) {
        widgets.add(const Text("Today"));
        widgets.add(const Divider());
        addedToday = true;
      }
      if (!isToday && !addedOther) {
        widgets.add(const Text("Other"));
        widgets.add(const Divider());
        addedOther = true;
      }

      widgets.add(TodoComponent(
          todo: todoList[i],
          placeInTheTodosList: i,
          removeTodoInUi: removeFromTodoList));
    }
    return widgets;
  }
}

void askForPermissions() async {
  var status = await Permission.notification.status;
  print(status);
  if (status.isDenied) {
    Permission.notification.request();
  }
  /*/
  DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second + 10);

  NotificationService().scheduleNotification(
      title: 'Scheduled Notification',
      body: 'Zkouska',
      scheduledNotificationDateTime: date);

   */
}
