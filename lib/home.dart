// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dbhelper.dart';
import 'entryform.dart';
import 'item.dart';

//pendukung program asinkron
// ignore: use_key_in_widget_constructors
class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Item> itemList;
  @override
  Widget build(BuildContext context) {
    // ignore: prefer_conditional_assignment
    if (itemList == null) {
      // ignore: prefer_collection_literals
      itemList = List<Item>();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Item -> Dimas Fendra Sumarno, 2031710126'),
      ),
      body: Column(children: [
        Expanded(
          child: createListView(),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: const Text("Tambah Item"),
              onPressed: () async {
                var item = await navigateToEntryForm(context, null);
                if (item != null) {
                  // ignore: todo
                  //TODO 2 Panggil Fungsi untuk Insert ke DB
                  int result = await dbHelper.insert(item);
                  if (result > 0) {
                    updateListView();
                  }
                }
              },
            ),
          ),
        ),
      ]),
    );
  }

  Future<Item> navigateToEntryForm(BuildContext context, Item item) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return EntryForm(item);
    }));
    return result;
  }

  ListView createListView() {
    TextStyle textStyle = Theme.of(context).textTheme.headline5;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.ad_units),
            ),
            title: Text(
              itemList[index].name,
              style: textStyle,
            ),
            // ignore: unnecessary_this
            subtitle: Text(this.itemList[index].price.toString()),
            trailing: GestureDetector(
              child: const Icon(Icons.delete),
              onTap: () async {
                // ignore: todo
                //TODO 3 Panggil Fungsi untuk Delete dari DB berdasarkan Item
                deleteItem(itemList[index]);
              },
            ),
            onTap: () async {
              // ignore: unused_local_variable
              var item = await navigateToEntryForm(context, itemList[index]);
              // ignore: todo
              //TODO 4 Panggil Fungsi untuk Edit data
              editItem(itemList[index]);
            },
          ),
        );
      },
    );
  }

  //update List item
  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      // ignore: todo
      //TODO 1 Select data dari DB
      Future<List<Item>> itemListFuture = dbHelper.getItemList();
      itemListFuture.then((itemList) {
        setState(() {
          this.itemList = itemList;
          count = itemList.length;
        });
      });
    });
  }

  void deleteItem(Item object) async {
    int result = await dbHelper.delete(object.id);
    if (result > 0) {
      updateListView();
    }
  }

  void editItem(Item object) async {
    int result = await dbHelper.update(object);
    if (result > 0) {
      updateListView();
    }
  }
}
