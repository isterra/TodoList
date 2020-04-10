import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SecondPage extends StatefulWidget {
  final List list;
  final int index;
  SecondPage({Key key, @required this.list,@required this.index}) :super(key:key);
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // ignore: non_constant_identifier_names
  Map<String, dynamic> _Removed;
  // ignore: non_constant_identifier_names
  int _RemovedPosition;

  final _toDo=TextEditingController();

  void _addNewList() {
    setState(() {
      Map<String, dynamic> list = Map();
      list["title"] =_toDo.text;
      _toDo.text= "";
      list["value"] = false;
      widget.list[widget.index]["toDo"].add(list);
      print(widget.list);
     _saveData();
    });
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list[widget.index]["title"]),
        centerTitle: true,
      ),
      body:Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                        controller: _toDo,
                        decoration: InputDecoration(
                        labelText: "Novo To Do",
                        labelStyle: TextStyle(color:Colors.blueAccent),
                      ),
                    )
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Icon(
                      Icons.add
                  ),
                  shape: RoundedRectangleBorder(borderRadius:(BorderRadius.circular(50))),
                  onPressed: _addNewList,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:widget.list[widget.index]["toDo"].length,
              itemBuilder: (context,index){
                return (
                Dismissible(
                  key:Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  direction: DismissDirection.startToEnd,
                  background: Container(color:Colors.red,
                    alignment: Alignment(-0.9,0.0),
                    child: Icon(Icons.delete_outline),
                  ),
                  child: CheckboxListTile(
                    title: Text(widget.list[widget.index]["toDo"][index]["title"]),
                    value: widget.list[widget.index]["toDo"][index]["value"],
                    onChanged: (status){
                      setState(() {
                        widget.list[widget.index]["toDo"][index]["value"]=status;
                        _saveData();
                      });
                    },
                  ),
                  onDismissed: (direction){
                    _Removed = Map.from(widget.list[widget.index]["toDo"][index]);
                    _RemovedPosition = index;
                    widget.list[widget.index]["toDo"].removeAt(index);
                    _saveData();
                    final snack = SnackBar(
                      content: Text(
                          "Lista \"${_Removed["title"]}\" removida!"),
                      action: SnackBarAction(
                          label: "Desfazer",
                          onPressed: () {
                            setState(() {
                              widget.list[widget.index]["toDo"].insert(
                                  _RemovedPosition, _Removed);
                              _saveData();
                            });
                          }),
                      duration: Duration(seconds: 2),
                    );
                    Scaffold.of(context).showSnackBar(snack);
                  },
                )
                );
              }
            ),
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
    String data = json.encode(widget.list);
    final file = await _getFile();
    return file.writeAsString(data);
  }

}


