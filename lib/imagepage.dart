import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera.dart';

//MemoryImage memoryImage=MemoryImage(_Uint8ArrayView#855ea, scale: 1.0);

var memoryImage2;

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {

  Uint8List imageData=Uint8List(10000);
  Uint8List imageData2=Uint8List(10000);


  @override
  void initState() {

    super.initState();
    loadAsset();
  }

  void loadAsset() async {

    Uint8List data2 = (await rootBundle.load('assets/eunjin.png')).buffer.asUint8List();

    setState(() => this.imageData2 = data2);
    print('---------------eunjin-----------');
    print(imageData2);


    final storageRef = FirebaseStorage.instance.ref();
    final listResult = await storageRef.listAll();

    // for (var prefix in listResult.prefixes) {
    // //  print('prefix$prefix');
    //   // The prefixes under storageRef.
    //   // You can call listAll() recursively on them.
    // }

    for (var item in listResult.items) {
      item.getData().then((value) {
        Uint8List? data=value;

        setState(() => this.imageData = data!);
        print('---------------firebase-----------');


        print(imageData);
      });
    }
  }

  // List<int> list =  ;
  // Uint8List bytes =  Uint8List.fromList('_Uint8ArrayView#db075'.codeUnits);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('meta image'),
      ),
      body: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          image: new DecorationImage(
              fit: BoxFit.cover, image: MemoryImage(imageData, scale: 0.5)),
        ),
      ),
    );
  }
}
