import 'package:flutter/material.dart';
import 'package:unfuckyourlife/components/homePage/todoComponent/todoComponent.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/todo/Todo.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Channel channel;
  final Function uiUpdateTodos;

  final bool showAll;
  const TodoList(
      {super.key,
      required this.todos,
      required this.channel,
      required this.uiUpdateTodos,
      required this.showAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showAll ? "All: " :  "${channel.name}: ",
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w100),
        ),
        FutureBuilder(
          future: sortTodosAndMakeThemWidgets(todos),
          builder:
              (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            if (snapshot.hasData) {
              List<Widget> widgets = snapshot.data as List<Widget>;

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widgets.length,
                  itemBuilder: (BuildContext context, int index) {
                    return widgets[index];
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
    );
  }

  Future<List<Widget>> sortTodosAndMakeThemWidgets(List<Todo> _todos) async {
    // Remove Todos that are not linked to this channel
    List<Todo> removedTodosAndSortedTodos = [];

    // First remove all todos that don't match the channel id
    // If you are supposed to show all don't remove anything
    if (!showAll) {
      for (int x = 0; x < _todos.length; x++) {
        if (_todos[x].channel == channel.id) {
          removedTodosAndSortedTodos.add(_todos[x]);
        }
      }
    } else {
      // Just add everything
      removedTodosAndSortedTodos = _todos;
    }

    // If the list is empty, return nothing
    if (removedTodosAndSortedTodos.isEmpty) {
      return [const Text("Gay")];
    }

    // Sorting todos
    removedTodosAndSortedTodos = await sortTodos(removedTodosAndSortedTodos);

    return await todosWidgets(removedTodosAndSortedTodos);
  }

  Future<List<Todo>> sortTodos(List<Todo> todos) async {
    List<Todo> sortedTodos = todos;
    bool runAgain = true;
    if (sortedTodos.length > 1) {
      while (runAgain) {
        runAgain = false;
        for (var i = 1; i < sortedTodos.length; i++) {
          DateTime deadlineOne = await sortedTodos[i].getDeadline();
          DateTime deadlineTwo = await sortedTodos[i - 1].getDeadline();

          int dayX = deadlineOne.millisecondsSinceEpoch;
          int dayY = deadlineTwo.millisecondsSinceEpoch;

          // Compare todos by how far are they from now.
          if (dayX.compareTo(dayY) < 0) {
            sortedTodos.insert(i - 1, sortedTodos[i]);
            sortedTodos.removeAt(i + 1);
            runAgain = true;
          }
        }
      }
    }

    return sortedTodos;
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

      // Check if the Todo is for today
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
          uiUpdateTodos: uiUpdateTodos));
    }
    return widgets;
  }
}
