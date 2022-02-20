// ignore_for_file: use_key_in_widget_constructors, unnecessary_null_comparison, prefer_const_constructors, unnecessary_this

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/model/todo.dart';
import 'package:todoapp/screens/tododetail.dart';
import 'package:todoapp/utils/dbhelper.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State {
  List<Todo> todos = <Todo>[];
  int count = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: todoListItems(),
        appBar: AppBar(
          title: Text("Todos"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetail(Todo("", 0, "", ""));
          },
          tooltip: 'Add New Todo',
          child: Icon(Icons.add),
        ));
  }

  Widget todoListItems() {
    return count != 0
        ? ListView.builder(
            itemCount: count,
            itemBuilder: (BuildContext context, int position) => Card(
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: getColor(this.todos[position].priority),
                    child: Text(
                      this.todos[position].id.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(this.todos[position].title),
                  subtitle: Text(this.todos[position].description),
                  onTap: () {
                    navigateToDetail(this.todos[position]);
                  },
                )))
        : Center(child: Text("No Records Found"));
  }

  void navigateToDetail(Todo todo) async {
    bool result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodoDetail(todo)));
    if (result == true) {
      getData();
    }
  }

  void getData() {
    final todosFuture = DbHelper.instance.getTodos();
    todosFuture.then((result) => {
          setState(() {
            todos = result;
            count = todos.length;
          })
        });
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.green;
    }
  }
}
