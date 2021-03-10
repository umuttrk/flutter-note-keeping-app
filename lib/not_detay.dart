import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/models/notlar.dart';
import 'package:not_sepeti/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  static var _oncelik = ['Düşük', 'Orta', 'Yüksek'];
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID;
  int secilenOncelik;

  String eklenecekBaslik;
  String eklenecekIcerik;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategoriIcerenMapListesi) {
      for (Map okunanMap in kategoriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      //  debugPrint(tumKategoriler.toString());
      }
      setState(() {});
      kategoriID=tumKategoriler[0].kategoriID;
    });

    if(widget.duzenlenecekNot!=null){
      kategoriID=widget.duzenlenecekNot.kategoriID;
      secilenOncelik=widget.duzenlenecekNot.notOncelik;
    }else{


      secilenOncelik=1;
    }


  }

  @override
  Widget build(BuildContext context) {
    //debugPrint(tumKategoriler.length.toString());
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(widget.baslik),
        ),
        body: tumKategoriler.length <= 0
            ? Center(
                child: Center(child: Text('Kategori yok lütfen kategori ekleyiniz'),),
              )
            : Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Kategoriyi seçiniz: '),
                          Container(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  items: kategoriItemlariOlustur(),
                                  value: kategoriID,
                                  onChanged: (girdi) {
                                    setState(() {
                                      kategoriID = girdi;
                                    });
                                  },
                                ),
                              ),
                              margin: EdgeInsets.all(12),
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 24),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.redAccent, width: 1),
                                  borderRadius: BorderRadius.circular(10)))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextFormField(
                          initialValue: widget.duzenlenecekNot != null
                              ? widget.duzenlenecekNot.notBaslik
                              : "",
                          validator: (girdi) {
                            if (girdi.length < 3) {
                              return 'başlık 3 harftan az olamaz';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (girdi) {
                            eklenecekBaslik = girdi;
                          },
                          decoration: InputDecoration(
                            hintText: 'Not başlığını giriniz',
                            labelText: 'Başlık',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextFormField(
                          initialValue: widget.duzenlenecekNot != null
                              ? widget.duzenlenecekNot.notIcerik
                              : "",
                          validator: (girdi) {
                            if (girdi.length < 5) {
                              return 'içerik 5 harftan az olamaz';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (girdi) {
                            eklenecekIcerik = girdi;
                          },
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Not içeriğini giriniz',
                            labelText: 'İçerik',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Önceliği seçiniz: '),
                          Container(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  items: _oncelik.map((e) {
                                    return DropdownMenuItem<int>(
                                      child: Text(e),
                                      value: _oncelik.indexOf(e),
                                    );
                                  }).toList(),
                                  value: secilenOncelik,
                                  onChanged: (girdi) {
                                    setState(() {
                                      secilenOncelik = girdi;
                                    });
                                  },
                                ),
                              ),
                              margin: EdgeInsets.all(12),
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 24),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.redAccent, width: 1),
                                  borderRadius: BorderRadius.circular(10)))
                        ],
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '       Vazgeç\nanasayfaya dön',
                            ),
                            color: Colors.grey,
                          ),
                          RaisedButton(
                            onPressed: () {
                              if (formKey.currentState.validate()) {
                                formKey.currentState.save();

                                if (widget.duzenlenecekNot == null) {
                                  _databaseyeNotlariEkle();
                                } else {
                                  _databasedekiNotlariGuncelle();
                                }
                              }
                            },
                            child: Text('Kaydet'),
                            color: Colors.green,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ));
  }

  List<DropdownMenuItem<int>> kategoriItemlariOlustur() {
    return tumKategoriler.map((kategori) {
      return DropdownMenuItem<int>(
        value: kategori.kategoriID,
        child: Text(kategori.kategoriBaslik),
      );
    }).toList();
  }

  void _databaseyeNotlariEkle() {
    var now = DateTime.now();
    databaseHelper
        .notEkle(Not(kategoriID, eklenecekBaslik, eklenecekIcerik,
            now.toString(), secilenOncelik))
        .then((value) {
      Navigator.pop(context);
    });
  }

  void _databasedekiNotlariGuncelle() {
    var now = DateTime.now();
    databaseHelper
        .notlariGuncelle(Not.withID(widget.duzenlenecekNot.notID, kategoriID,
            eklenecekBaslik, eklenecekIcerik, now.toString(), secilenOncelik))
        .then((value) => Navigator.pop(context));
  }
}
