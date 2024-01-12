import 'package:flutter/material.dart';
import 'package:unfuckyourlife/components/homePage/todoComponent/todoComponent.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/retrieve.dart';
import 'package:unfuckyourlife/model/todo/Todo.dart';
import 'package:unfuckyourlife/model/todo/mapToTodo.dart';
class TodoList extends StatefulWidget {
  final List<Todo> todos;
  final Channel channel;
  const TodoList({super.key, required this.todos, required this.channel});

  @override
  State<StatefulWidget> createState() => _TodoListState();

}
class _TodoListState extends State<TodoList> {
  late List<Todo> _todos;

  @override
  Widget build(BuildContext context) {
    _todos = widget.todos;
    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Todos:",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w100),
                  ),
                  FutureBuilder(
                    future: sortTodosAndMakeThemWidgets(),
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
              );
  } 

  Future<List<Widget>> sortTodosAndMakeThemWidgets() async {
    // Remove Todos that are not linked to this channel
    List<Todo> removedTodos = [];
    for (int x = 0; x < _todos.length; x++) {
      if (_todos[x].channel == widget.channel.id) {
        removedTodos.add(_todos[x]);
      }
    }

    _todos = removedTodos;
    
    // Todos:
    if (_todos.isEmpty) {
      _todos = [];
      return [const Text("Gay")];
    }

    // Sorting todos, this function will also filter channels
    await sortTodos(_todos);

    return await todosWidgets(_todos);
  }

  Future<void> sortTodos(List<Todo> _todos) async {
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

    // Divide Today and future.
    for (int i = 0; i < todoList.length; i++) {
      DateTime deadline = await todoList[i].getDeadline();
      print(deadline);
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

  Future<List<Channel>> getChannelsInChannelClassType() async {
    List<Map<String, dynamic>> channelsMap = await retrieveChannels();
    List<Channel> newChannels = [Channel(0, "Custom", 0, true)];
    for (final Map<String, dynamic> map in channelsMap) {
      // If the channel is custom, don't add it as every custom channel is special.
      if (map['isCustom'] != 1) {
        newChannels.add(Channel(map['id'], map['name'], map['notifier'], false));
      }
    }

    return newChannels;
  }

  void removeFromTodoList(int placeInList) {
    setState(() {
      _todos.removeAt(placeInList);
    });
  }
}