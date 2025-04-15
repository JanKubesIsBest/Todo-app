import 'package:flutter/material.dart';
import 'package:unfuckyourlife/model/database/delete.dart';

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
                    await deleteTodo(todo);
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
