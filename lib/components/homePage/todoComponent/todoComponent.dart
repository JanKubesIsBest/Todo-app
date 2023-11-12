import 'package:flutter/material.dart';

class TodoComponent extends StatelessWidget {
  final String name_of_a_todo;

  const TodoComponent({super.key, required this.name_of_a_todo});

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
                name_of_a_todo,
                style: const TextStyle(fontSize: 20),
              ),
              IconButton(onPressed: () => {

              }, icon: const Icon(Icons.delete))
            ],
          ),
        ),
      ),
    );
  }
}
