import 'dart:io';

import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/utils/database_helper.dart';

class Kategoriler extends StatefulWidget {
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  var guncellenecekBaslik;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    tumKategoriler = List<Kategori>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('kategoriler'),
      ),
      body: Center(
        child: FutureBuilder(
          future: databaseHelper.kategoriListesiniGetir(),
          builder: (context, snapShot) {
            tumKategoriler = snapShot.data;
            if (snapShot.hasData) {
              sleep(Duration(milliseconds: 500));
              return ListView.builder(
                  itemCount: tumKategoriler.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(tumKategoriler[index].kategoriBaslik),
                        leading: Icon(Icons.category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                iconSize: 30,
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              Text('Kategori adını güncelle'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Form(
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          'kategori adı giriniz',
                                                      labelText: 'kategori',
                                                      border:
                                                          OutlineInputBorder()),
                                                  validator: (girdi) {
                                                    if (girdi.length < 3) {
                                                      return "başlık 3 karakter düşük olmasın";
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                  onSaved: (girdi) {
                                                    guncellenecekBaslik = girdi;
                                                  },
                                                ),
                                                key: formKey,
                                              ),
                                              Row(
                                                children: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Vazgeç')),
                                                  FlatButton(
                                                      onPressed: () {
                                                        _kategoriyiGuncelle(
                                                            tumKategoriler[
                                                                index]);
                                                      },
                                                      child: Text('Kaydet')),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                }),
                            SizedBox(
                              width: 20,
                            ),
                            IconButton(
                                iconSize: 30,
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  _kategoriyiSil(
                                      tumKategoriler[index].kategoriID);
                                }),
                          ],
                        ));
                  });
            } else {
              return Text('yükleniyor..');
            }
          },
        ),
      ),
    );
  }

  void _kategoriyiGuncelle(Kategori kategori) {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      databaseHelper
          .kategoriGuncelle(
              Kategori.withID(kategori.kategoriID, guncellenecekBaslik))
          .then((value) {
        Navigator.pop(context);
        setState(() {});
      });
    }
  }

  void _kategoriyiSil(int kategoriID) {
    databaseHelper.kategoriSil(kategoriID).then((value) => setState(() {}));
  }
}
