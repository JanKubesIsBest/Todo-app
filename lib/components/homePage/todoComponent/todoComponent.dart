import 'package:flutter/material.dart';
import 'package:unfuckyourlife/model/database/delete.dart';

import '../../../model/todo/Todo.dart';

class TodoComponent extends StatelessWidget {
  final Todo todo;
  final int placeInTheTodosList;

  final Function(int placeInTheTodosList) removeTodoInUi;
  const TodoComponent({super.key, required this.todo, required this.placeInTheTodosList, required this.removeTodoInUi});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      // TODO: Make better design, remember, design is one of the main things of this app.
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 1, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    todo.name,
                    style: const TextStyle(fontSize: 20),
                  ),
                  IconButton(onPressed: () => {
                    deleteTodo(todo.id as int),
                    removeTodoInUi(placeInTheTodosList),
                  }, icon: const Icon(Icons.delete),),
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
