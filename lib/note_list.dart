import 'dart:io';

import 'package:flutter/material.dart';
import 'package:not_sepeti/kategori_islemleri.dart';
import 'package:not_sepeti/utils/database_helper.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/not_detay.dart';

import 'models/notlar.dart';

class NotListesi extends StatefulWidget {
  @override
  _NotListesiState createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(child: Text('Notlar')),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Kategoriler'),
                  contentPadding: EdgeInsets.all(-20),
                  onTap: _kategorilerSayfasinaGit,
                ),
              ),
            ];
          })
        ],
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          heroTag: "btn1",
          onPressed: () {
            kategoriEkleDialog(context);
          },
          child: Icon(Icons.add_to_photos),
          mini: true,
        ),
        FloatingActionButton(
          heroTag: "btn2",
          onPressed: () {
            _notDetayaGit(context);
          },
          child: Icon(Icons.add),
        )
      ]),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            title: Center(
                child: Text(
              'Kategori Ekle',
              style: TextStyle(fontSize: 24),
            )),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    onSaved: (girdi) {
                      yeniKategoriAdi = girdi;
                      databaseHelper
                          .kategoriEkle(Kategori(yeniKategoriAdi))
                          .then((kategoriID) {
                        if (kategoriID > 0) {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 3),
                              content: Text(
                                'Kategori eklendi',
                              ),
                            ),
                          );
                          debugPrint(
                              'kategori başarılı bir şekilde eklendi kategoriID: $kategoriID');
                        }
                        Navigator.pop(context);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      labelText: 'kategori adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    validator: (girdi) {
                      if (girdi.length < 3) {
                        return 'kategori adı 3 karakterden az olamazzz';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  ButtonBar(
                    children: [
                      RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.blue,
                        child: Text('VAZGEÇ'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                          }
                        },
                        color: Colors.red,
                        child: Text('KAYDET'),
                      ),
                    ],
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          );
        });
  }

  void _notDetayaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: 'yeni not',
                ))).then((value) => setState(() {}));
  }

  void _kategorilerSayfasinaGit() {
     Navigator.push(context, MaterialPageRoute(builder: (context)=>Kategoriler())).then((value) => setState((){}));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseHelper.notListesiniGetir(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            tumNotlar = snapShot.data;
            sleep(Duration(milliseconds: 500));
            return ListView.builder(
                itemCount: tumNotlar.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    backgroundColor: Colors.grey.shade200,
                    leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'kategori: ',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                Text(tumNotlar[index].kategoriBaslik)
                              ],
                            ),
                            Text(tumNotlar[index].notIcerik),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                FlatButton(
                                  onPressed: () {
                                    _notDuzenleEkrani(
                                        context, tumNotlar[index]);
                                  },
                                  child: Text(
                                    'güncelle',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () =>
                                      _notSil(tumNotlar[index].notID),
                                  child: Text(
                                    'sil',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        padding: EdgeInsets.all(4),
                      )
                    ],
                    title: Text(tumNotlar[index].notBaslik),
                  );
                });
          } else {
            return Center(
              child: Text('yükleniyor'),
            );
          }
        });
  }

  void _notDuzenleEkrani(BuildContext context, Not not) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: 'notu duzenle',
                  duzenlenecekNot: not,
                ))).then((value) => setState(() {}));
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text('AZ'),
          backgroundColor: Colors.green.shade100,
        );

      case 1:
        return CircleAvatar(
          child: Text('ORTA'),
          backgroundColor: Colors.yellow.shade100,
        );
      case 2:
        return CircleAvatar(
          child: Text('ACİL'),
          backgroundColor: Colors.red.shade100,
        );
    }
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((value) {
      if (value != 0) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('not silindi'),
          duration: Duration(seconds: 1),
        ));
        setState(() {});
      }
    });
  }
}
