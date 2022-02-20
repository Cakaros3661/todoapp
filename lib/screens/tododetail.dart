// ignore_for_file: prefer_const_declarations, unnecessary_this, prefer_const_constructors, unnecessary_null_comparison, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, no_logic_in_create_state, prefer_final_fields, unused_field, sized_box_for_whitespace, avoid_unnecessary_containers, avoid_print, prefer_collection_literals

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/model/todo.dart';
import 'package:todoapp/utils/dbhelper.dart';
import 'package:intl/intl.dart';

final List<String> choices = const <String>[menuSave, menuDelete];

const menuSave = "Save Todo & Back";
const menuDelete = "Delete Todo";

class TodoDetail extends StatefulWidget {
  final Todo todo;
  TodoDetail(this.todo);
  @override
  State<StatefulWidget> createState() => TodoDetailState();
}

class TodoDetailState extends State<TodoDetail>
    with SingleTickerProviderStateMixin {
  final _priorities = ["High", "Medium", "Low"];
  Map<String, dynamic> index = Map<String, dynamic>();
  final _formDistance = 5.0;
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String title = "";

  int _angle = 90;
  bool _isRotated = true;

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animation2;

  @override
  void initState() {
    titleController.text = widget.todo.title;
    descController.text = widget.todo.description;
    title = widget.todo.title == "" ? "Todo" : widget.todo.title;
    index["Priority"] = widget.todo.priority != 0 ? widget.todo.priority : null;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 1.0, curve: Curves.linear),
    );

    _animation2 = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.linear),
    );

    _controller.reverse();
    super.initState();
  }

  void _rotate() {
    setState(() {
      if (_isRotated) {
        _angle = 45;
        _isRotated = false;
        _controller.forward();
      } else {
        _angle = 90;
        _isRotated = true;
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: [textField(), multiTextField(), priority()],
              ),
            ),
            floatingButton(
              menuSave,
              widget.todo.id != null ? 128.0 : 78.0,
              20.0,
              _animation,
              Colors.green,
              Icon(Icons.save, color: Color(0xFFFFFFFF), size: 18.0),
            ),
            if (widget.todo.id != null)
              floatingButton(
                menuDelete,
                78.0,
                20.0,
                _animation2,
                Colors.red,
                Icon(Icons.delete_forever,
                    color: Color(0xFFFFFFFF), size: 22.0),
              ),
            floatinActionButton()
          ],
        ),
      ),
    );
  }

  void updatePriority(String value) {
    int priority = 0;
    switch (value) {
      case "High":
        priority = 1;
        break;
      case "Medium":
        priority = 2;
        break;
      case "Low":
        priority = 3;
        break;
      default:
    }
    setState(() {
      this.widget.todo.priority = priority;
    });
  }

  void select(String value) async {
    switch (value) {
      case menuSave:
        save();
        break;
      case menuDelete:
        delete();
        break;
      default:
    }
  }

  void delete() async {
    Navigator.pop(context, true);
    if (widget.todo.id == null) {
      return;
    }
    int result;
    result = await DbHelper.instance.deleteTodo(widget.todo.id!);
    if (result != 0) {
      AlertDialog alertDialog = AlertDialog(
        title: Text("Delete Todo"),
        content: Text("The Todo has been deleted"),
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }
  }

  void save() {
    widget.todo.title = titleController.text;
    widget.todo.description = descController.text;
    widget.todo.date = DateFormat.yMd().format(DateTime.now());
    if (widget.todo.id != null) {
      DbHelper.instance.updateTodo(widget.todo);
    } else {
      DbHelper.instance.insertTodo(widget.todo);
    }
    Navigator.pop(context, true);
    showAlert(widget.todo.id != null);
  }

  void showAlert(bool isUpdate) {
    AlertDialog alertDialog;
    if (isUpdate) {
      alertDialog = AlertDialog(
        title: Text("Update Todo"),
        content: Text("The Todo has been updated"),
      );
    } else {
      alertDialog = AlertDialog(
        title: Text("Insert Todo"),
        content: Text("The Todo has been inserted"),
      );
    }
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Widget floatingButton(String label, double bottom, double right,
      Animation<double> animation, Color color, Widget icon) {
    return Positioned(
      bottom: bottom,
      right: right,
      child: Container(
        child: Row(
          children: <Widget>[
            ScaleTransition(
              scale: animation,
              alignment: FractionalOffset.center,
              child: Container(
                margin: EdgeInsets.only(right: 16.0),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Roboto',
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ScaleTransition(
              scale: animation,
              alignment: FractionalOffset.center,
              child: Material(
                color: color, // Color(0xFF9E9E9E),
                type: MaterialType.circle,
                elevation: 6.0,
                child: GestureDetector(
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    child: InkWell(
                      onTap: () {
                        if (_angle == 45.0) {
                          if (label == menuSave) {
                            save();
                          } else if (label == menuDelete) {
                            delete();
                          }
                        }
                      },
                      child: Center(
                        child: icon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget floatinActionButton() {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: Material(
        color: Colors.blue,
        type: MaterialType.circle,
        elevation: 6.0,
        child: GestureDetector(
          child: Container(
            width: 50.0,
            height: 50.00,
            child: InkWell(
              onTap: _rotate,
              child: Center(
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(_angle / 360),
                  child: Icon(
                    Icons.add,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget priority() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Padding(
        padding: EdgeInsets.only(top: _formDistance, bottom: _formDistance),
        child: Container(
          height: 48,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(1.0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(
                  left: 15.0, top: 12.0, bottom: 5.0, right: 5.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                hint: Text(
                  "Priority",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                value: index["Priority"] != null
                    ? this._priorities[index["Priority"]]
                    : null, // this._priorities[index],
                items: _priorities.map((String str) {
                  return DropdownMenuItem<String>(
                    value: str,
                    child: Text(
                      str,
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (String? str) {
                  setState(() {
                    index["Priority"] = this._priorities.indexOf(str!);
                    updatePriority(str);
                  });
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget textField() {
    return Padding(
      padding: EdgeInsets.only(top: _formDistance, bottom: _formDistance),
      child: Container(
        height: 48.0,
        child: TextField(
          textCapitalization: TextCapitalization.none,
          controller: titleController,
          style: TextStyle(color: Colors.black, fontSize: 12, height: 1.3),
          maxLines: 1,
          decoration: InputDecoration(
            labelText: "Title",
            labelStyle: TextStyle(color: Colors.black, fontSize: 12),
            contentPadding: EdgeInsets.only(left: 15.0, top: 12.0, bottom: 5.0),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  Widget multiTextField() {
    return Padding(
      padding: EdgeInsets.only(top: _formDistance, bottom: _formDistance),
      child: Container(
        height: 100.0,
        child: TextField(
          textCapitalization: TextCapitalization.none,
          controller: descController,
          style: TextStyle(color: Colors.black, fontSize: 12, height: 1.3),
          maxLines: 6,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: "Description",
            labelStyle: TextStyle(color: Colors.black, fontSize: 12),
            contentPadding: EdgeInsets.only(left: 15.0, top: 12.0, bottom: 5.0),
            counterStyle: TextStyle(
              color: Colors.black,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}
