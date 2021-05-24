import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archive/archive_tasks.dart';
import 'package:todo_app/modules/done/done_tasks.dart';
import 'package:todo_app/modules/tasks/new_tasks.dart';

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
  bool isBottom = false;
  var titleController = TextEditingController();

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
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
          child: Icon(isBottom ? Icons.close : Icons.edit),
          onPressed: () {
            if (isBottom) {
              Navigator.pop(context);
              setState(() {
                isBottom = false;
              });
            } else {
              scaffoldKey.currentState.showBottomSheet(
                (context) => Container(
                  padding: EdgeInsets.all(15),
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                          hintText: 'title',
                        ),
                      ),
                    ],
                  ),
                ),
              );
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

  Future<String> getName() async {
    return 'Alamin Musa';
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

  void insertToDatabase() {
    database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("first task", "24/5/2021", "5", "completed")')
          .then((value) => print('$value  Insert Done!'))
          .catchError((error) => print('Insert Error: ${error.toString()}'));
      return null;
    });
  }
}
