import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'toDoPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _controller;
  Container container;
  List _checked = [];
  List _noChecked = [];
  List _data = [];
  final _list = TextEditingController();
  Map<String, dynamic> _removedInData;
  int _removedPosition;
  int _positionRemovedInData;

  void refreshList(){
    _checked.clear();
    _noChecked.clear();
    for (int i = 0; i < _data.length; i++) {
      if (_data[i]["value"] == true) {
        setState(() {
          _checked.add(_data[i]);
        });
      } else {
        setState(() {
          _noChecked.add(_data[i]);
        });
      }
    }
  }

  void setLists() {
    for (int i = 0; i < _data.length; i++) {
      if (_data[i]["value"] == true) {
        setState(() {
          _checked.add(_data[i]);
        });
      } else {
        setState(() {
          _noChecked.add(_data[i]);
        });
      }
    }
  }

  int findInData(String title){
    for(int i=0;i<_data.length;i++){
      if(_data[i]["title"]==title)
        return i;
    }
    return -1;
  }

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _data = json.decode(data);
        setLists();
      });
    });
    _controller = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addNewList() {
    setState(() {
      Map<String, dynamic> list = Map();
      list["title"] = _list.text;
      list["toDo"] = [];
      list["value"] = false;
      _noChecked.add(list);
      _data.add(list);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Row(
            children: [
              Image(
                image: (AssetImage('images/logo.png')),
                fit: BoxFit.cover,
                width: 50,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 100),
                child: Text("To Do!"),
              ),
            ],
          ),
          bottom: TabBar(
            labelStyle: TextStyle(
              fontSize: 20,
            ),
            labelColor: Colors.lightBlue ,
            unselectedLabelColor: Colors.white,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.white,
            ),
            controller: _controller,
            tabs: <Widget>[
              Tab(
                text: "Pendente",
              ),
              Tab(
                text: "Completo",
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: () => _inputText(0, 0)),
        body: TabBarView(
          controller: _controller,
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: _noChecked.length,
                      itemBuilder: (context, index) {
                        return (Column(
                          children: <Widget>[
                            Dismissible(
                              key: Key(DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString()),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment(-0.9, 0.0),
                                child: Icon(Icons.check),
                              ),
                              movementDuration: Duration(seconds: 1),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.cyan,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                        child: ListTile(
                                          title: Text(
                                              _noChecked[index]["title"]),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          SecondPage(
                                                              list:
                                                                  _noChecked,
                                                              index: index)));
                                        },
                                        onLongPress: (){
                                          setState(() {
                                            _list.text=_noChecked[index]["title"];
                                            _removedPosition=findInData(_noChecked[index]["title"]);
                                            _inputText(_removedPosition, 1);
                                          });
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.delete,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _positionRemovedInData=findInData(_noChecked[index]["title"]);
                                          _removedInData=Map.from(_data[_positionRemovedInData]);
                                          _data.removeAt(_positionRemovedInData);
                                          _saveData();
                                          refreshList();
                                          final snack = SnackBar(
                                            content: Text(
                                                "Lista \"${_removedInData["title"]}\" removida!"),
                                            action: SnackBarAction(
                                                label: "Desfazer",
                                                onPressed: () {
                                                  setState(() {
                                                    _data.add(_removedInData);
                                                    _saveData();
                                                    refreshList();
                                                  });
                                                }),
                                            duration: Duration(seconds: 2),
                                          );
                                          Scaffold.of(context)
                                              .showSnackBar(snack);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (direction) {
                                setState(() {
                                  _positionRemovedInData=findInData(_noChecked[index]["title"]);
                                  _data[_positionRemovedInData]["value"]=true;
                                  _saveData();
                                  refreshList();
                                });

                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                            )
                          ],
                        ));
                      }),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child:  ListView.builder(
                  itemCount: _checked.length,
                  itemBuilder: (context,index){
                    return(
                    Padding( padding: EdgeInsets.only(bottom: 10),
                    child:  Dismissible(
                      key: Key(DateTime.now()
                          .millisecondsSinceEpoch
                          .toString()),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.amberAccent,
                        alignment: Alignment(-0.9, 0.0),
                        child: Icon(Icons.settings_backup_restore),
                      ),
                      movementDuration: Duration(seconds: 1),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10)),
                          color: Colors.cyan,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child:
                              ListTile(
                                title: Text(
                                    _checked[index]["title"]),
                              ),
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.delete,
                              ),
                              onTap: () {
                                setState(() {
                                  _positionRemovedInData=findInData(_checked[index]["title"]);
                                  _removedInData=Map.from(_data[_positionRemovedInData]);
                                  _data.removeAt(_positionRemovedInData);
                                  _saveData();
                                  refreshList();
                                  final snack = SnackBar(
                                    content: Text(
                                        "Lista \"${_removedInData["title"]}\" removida!"),
                                    action: SnackBarAction(
                                        label: "Desfazer",
                                        onPressed: () {
                                          _data.add(_removedInData);
                                          _saveData();
                                          refreshList();
                                        }),
                                    duration: Duration(seconds: 2),
                                  );
                                  Scaffold.of(context)
                                      .showSnackBar(snack);
                                });
                              },
                            ),
                          ],
                        ),
                      ) ,
                      onDismissed: (direction){
                        setState(() {
                          _removedPosition = findInData(_checked[index]["title"]);
                          _data[_removedPosition]["value"]=false;
                          _saveData();
                          refreshList();
                        });
                      },
                    ),));
                  }
              ),
            ),
          ],
        ));
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_data);
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

  Future<void> _inputText(int index, int opcao) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: opcao == 0
              ? Text("Digite uma nova lista")
              : Text("Edite o titulo"),
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
                      _list.text = "";
                    },
                  ),
                  FlatButton(
                    child: Text('Salvar'),
                    onPressed: () {
                      opcaoSalvarAlert(opcao, index);
                      _list.text = "";
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

  void opcaoSalvarAlert(int opcao, int index) {
    if (opcao == 0) {
      setState(() {
        _addNewList();
        Navigator.of(context).pop();
      });
    } else {
      setState(() {
        _data[index]["title"] = _list.text;
        _saveData();
        refreshList();
        _list.text = "";
        Navigator.of(context).pop();
      });
    }
  }
}
