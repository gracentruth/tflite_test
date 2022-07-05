import 'dart:async';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'camera.dart';


String base64string='';
class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  Uint8List imageData = Uint8List(100000000);


  @override
  void initState() {
    super.initState();
    // loadAsset();
    // getImage1();
  }

  Future<Uint8List> getImage1() async {
    final storageRef = FirebaseStorage.instance.ref();
    imageData = await storageRef.listAll().then((value) {
      for (var item in value.items) {
        item.getData().then((value2) {
          imageData = value2!;
           base64string = base64.encode(imageData);
          if (kDebugMode) {
            print(base64string);
          }
        });
      }

      return imageData;
    });
    return imageData;
  }

  static Uint8List getImage(String btyeFile){
    var byteImage = Base64Decoder().convert(btyeFile);
    String stringImage = String.fromCharCodes(byteImage);
    return Uint8List.fromList(stringImage.codeUnits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('meta image'),
      ),
      body: Center(
          child:Container(
            width: 900,
            height: 550,
            //color: Colors.purple,
            child: Image.memory(
              imagelist,
              fit: BoxFit.cover,
            )
          ),
      ),
    );
  }
}
