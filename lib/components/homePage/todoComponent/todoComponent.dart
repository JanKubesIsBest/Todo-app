import 'package:flutter/material.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/delete.dart';
import 'package:unfuckyourlife/model/database/update.dart';

import '../../../model/todo/Todo.dart';

class TodoComponent extends StatelessWidget {
  final Todo todo;
  final int placeInTheTodosList;

  final Function uiUpdateTodos;
  const TodoComponent({super.key, required this.todo, required this.placeInTheTodosList, required this.uiUpdateTodos});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Card(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 1, bottom: 10),
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
                  IconButton(onPressed: () async {
                    print("Delete button was pressed");
                    // If is recuring, don't delete it, just update it.
                    if (todo.isRecuring){
                      print("Updated recuring todo");
                      // Make done true, everything else will be same
                      final Todo newTodo = Todo(id: todo.id, done: true, durationOfRecuring: todo.durationOfRecuring, isRecuring: todo.isRecuring, channel: todo.channel, created: todo.created, name: todo.name, description: todo.description + " ", deadline: todo.deadline);

                      await updateTodoById(newTodo, Channel(todo.channel, "Does not matter", 0, false));
                    } else {
                      await deleteTodo(todo);
                    }
                    uiUpdateTodos();
                  }, icon: const Icon(Icons.delete), color: const Color.fromARGB(255, 183, 14, 14),),
                ],
              ),
              Text(todo.description,style: const TextStyle(fontSize: 15,),),
            ],
          ),
        ),
      ),
    );
  }
}
