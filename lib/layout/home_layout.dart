import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archive/archive_tasks.dart';
import 'package:todo_app/modules/done/done_tasks.dart';
import 'package:todo_app/modules/tasks/new_tasks.dart';

import '../constant.dart';

class HomeLayout extends StatefulWidget {
  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  List<Widget> _screens = [NewTasks(), DoneTasks(), ArchiveTasks()];
  List<String> _titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];
  Database database;
  int _currentIndex = 0;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formdKey = GlobalKey<FormState>();
  bool isBottom = false;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: ConditionalBuilder(
        builder: (ctx) => _screens[_currentIndex],
        condition: tasks.length > 0,
        fallback: (ctx) => Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
          mini: isBottom,
          child: Icon(isBottom ? Icons.close : Icons.edit),
          onPressed: () {
            if (isBottom) {
              if (formdKey.currentState.validate()) {
                insertToDatabase(
                  title: titleController.text,
                  date: dateController.text,
                  time: timeController.text,
                ).then((value) {
                  getDataFromDatabase(database).then((value) {
                    Navigator.pop(context);
                    setState(() {
                      tasks = value;
                      isBottom = false;
                    });
                    print(tasks);
                  });
                });
              }
            } else {
              scaffoldKey.currentState
                  .showBottomSheet(
                    (context) => Container(
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Form(
                        key: formdKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 20),
                            TextFormField(
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'title is empty';
                                }
                                ;
                                return null;
                              },
                              controller: titleController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.title),
                                border: OutlineInputBorder(),
                                hintText: 'title',
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'time is empty';
                                }

                                return null;
                              },
                              onTap: () {
                                showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now())
                                    .then((value) {
                                  setState(() {
                                    timeController.text = value.format(context);
                                  });
                                });
                              },
                              controller: timeController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.watch_later_outlined),
                                border: OutlineInputBorder(),
                                hintText: 'Time',
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'date is empty';
                                }
                                return null;
                              },
                              controller: dateController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                                hintText: 'Date',
                              ),
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2023-05-03'),
                                ).then((value) => dateController.text =
                                    DateFormat.yMMMd().format(value));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .closed
                  .then((value) {
                setState(() {
                  isBottom = false;
                });
              });
              setState(() {
                isBottom = true;
              });
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          print(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Done',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Archived',
          ),
        ],
      ),
    );
  }

  void createDatabase() async {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (databse, version) {
        databse
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) => print('table created'))
            .catchError((error) =>
                print('error when created table ${error.toString()}'));
        print('database created');
      },
      onOpen: (database) {
        print('database opened');
      },
    );
  }

  Future insertToDatabase(
      {@required String title,
      @required String time,
      @required String date}) async {
    return await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) => print('$value  Insert Done!'))
          .catchError((error) => print('Insert Error: ${error.toString()}'));
      return null;
    });
  }

  Future<List<Map>> getDataFromDatabase(database) async {
    return await database.rawQuery('SELECT * FROM tasks');
  }
}
