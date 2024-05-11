import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/delete.dart';
import 'package:unfuckyourlife/model/database/update.dart';

import '../../../model/todo/Todo.dart';

class TodoComponent extends StatefulWidget {
  final Todo todo;
  final int placeInTheTodosList;

  final Function uiUpdateTodos;
  const TodoComponent(
      {super.key,
      required this.todo,
      required this.placeInTheTodosList,
      required this.uiUpdateTodos});

  @override
  State<StatefulWidget> createState() => _todoComponentState();
}

class _todoComponentState extends State<TodoComponent> {
  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;

    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Card(
        color: Colors.grey,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 1, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      todo.name,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      print("Delete button was pressed");
                      // If is recuring, don't delete it, just update it.
                      if (todo.isRecuring) {
                        print("Updated recuring todo");
                        // Make done true, everything else will be same
                        final Todo newTodo = Todo(
                            id: todo.id,
                            done: true,
                            durationOfRecuring: todo.durationOfRecuring,
                            isRecuring: todo.isRecuring,
                            channel: todo.channel,
                            created: todo.created,
                            name: todo.name,
                            description: "${todo.description} ",
                            deadline: todo.deadline);

                        await updateTodoById(newTodo,
                            Channel(todo.channel, "Does not matter", false, 0, 0));
                      } else {
                        await deleteTodo(todo);
                      }
                      widget.uiUpdateTodos();
                    },
                    icon: const Icon(Icons.delete),
                    color: const Color.fromARGB(255, 183, 14, 14),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    todo.description,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  )),
                  todo.isRecuring
                      ? IconButton(
                          onPressed: () => {_showMyDialog()},
                          icon: const Icon(Icons.recycling))
                      : const SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete recuring todo?"),
          actions: [
            ElevatedButton(
              onPressed: () => {
                // Abort
                Navigator.of(context).pop(),
              },
              child: const Text("Abort"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Delete
                // Cancel timer
                AndroidAlarmManager.cancel(widget.todo.id as int);
                // Detele from database
                await deleteTodo(widget.todo);
                widget.uiUpdateTodos();
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            )
          ],
        );
      },
    );
  }
}
