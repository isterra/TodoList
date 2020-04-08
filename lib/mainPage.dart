import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'toDoPage.dart';
import 'widgets.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _newList = [];

  final _list = TextEditingController();
  // ignore: non_constant_identifier_names
  Map<String, dynamic> _Removed;
  // ignore: non_constant_identifier_names
  int _RemovedPosition;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _newList = json.decode(data);
        print(_newList);
      });
    });
  }

  void _addNewList() {
    setState(() {
      Map<String, dynamic> list = Map();
      list["title"] = _list.text;
      _list.text = "";
      list["toDo"] = [];
      _newList.add(list);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar("To Do!"),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _inputText),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _newList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          shape: BoxShape.rectangle,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                child: ListTile(
                                  title: Text(_newList[index]["title"]),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              SecondPage(
                                                  list: _newList,
                                                  index: index)));
                                },
                              ),
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.delete,
                              ),
                              onTap: () {
                                setState(() {
                                  _Removed = Map.from(_newList[index]);
                                  _RemovedPosition = index;
                                  _newList.removeAt(index);
                                  _saveData();
                                  final snack = SnackBar(
                                    content: Text(
                                        "Lista \"${_Removed["title"]}\" removida!"),
                                    action: SnackBarAction(
                                        label: "Desfazer",
                                        onPressed: () {
                                          setState(() {
                                            _newList.insert(
                                                _RemovedPosition, _Removed);
                                            _saveData();
                                          });
                                        }),
                                    duration: Duration(seconds: 2),
                                  );
                                  Scaffold.of(context).showSnackBar(snack);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      )
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_newList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<void> _inputText() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Digite uma nova lista"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _list,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(
                    color: Colors.green,
                  )),
                )
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('Sair'),
                    textColor: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _list.text="";
                    },
                  ),
                  FlatButton(
                    child: Text('Salvar'),
                    onPressed: () {
                      _addNewList();
                      Navigator.of(context).pop();
                      _list.text="";
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
