import 'package:flutter/material.dart';
import 'package:unfuckyourlife/model/database/delete.dart';

class TodoComponent extends StatelessWidget {
  final String nameOfATodo;
  final int id;
  const TodoComponent({super.key, required this.nameOfATodo, required this.id});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nameOfATodo,
                style: const TextStyle(fontSize: 20),
              ),
              IconButton(onPressed: () => {
                deleteTodo(id),
              }, icon: const Icon(Icons.delete))
            ],
          ),
        ),
      ),
    );
  }
}
