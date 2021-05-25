import 'package:flutter/material.dart';
import 'package:todo_app/constant.dart';

class NewTasks extends StatefulWidget {
  @override
  _NewTasksState createState() => _NewTasksState();
}

class _NewTasksState extends State<NewTasks> {
  @override
  Widget build(BuildContext context) {
    return tasks.length == 0
        ? CircularProgressIndicator.adaptive()
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(tasks[index]['time']),
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tasks[index]['title']),
                        Text(tasks[index]['date']),
                      ],
                    ),
                  ],
                ),
              );
            });
  }
}
