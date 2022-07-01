

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera.dart';
import 'dart:ui' as ui;


//MemoryImage memoryImage=MemoryImage(_Uint8ArrayView#855ea, scale: 1.0);

var memoryImage2;

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {

  FirebaseStorage storage = FirebaseStorage.instance;

  Uint8List imageData=Uint8List(100000000);
  Uint8List imageData2=Uint8List(100000000);
 // Uint8List? data=Uint8List(100000000);
  late Image img;
  String str='nonononono';


  @override
  void initState() {

    super.initState();
    loadAsset();
  }

  void loadAsset() async {

    Uint8List data2 = (await rootBundle.load('assets/eunjin.png')).buffer.asUint8List();


    //print('ddataaaaaaaa');
    //print(data2);

    // await storage.ref('test_Uint8List').putData(
    //   data2,);

   // print('data2$data2');


    setState(() => this.imageData2 = data2);
    print('-------------asset_image-----------');
    print(imageData2.length);
    print(imageData2);


    final storageRef = FirebaseStorage.instance.ref();
    final listResult = await storageRef.listAll();

    for (var item in listResult.items) {
      //print(item.name);
      item.getData().then((value) {

        setState(() => this.imageData = value!);
        print('--------------- firebase storage image -----------');
        print(imageData.length);
        print(imageData);
      });
    }
    // -- decodeImage
    // dynamic decodeImage=await decodeImageFromList(
    //     imageData
    // );
    ui.Image? img;
    Uint8List pixels = imageData; //external data
    ui.decodeImageFromPixels(pixels, 100, 100, ui.PixelFormat.rgba8888, (i) {
    img = i;
    setState(() {});
    });




    // await storage.ref('storage_Uint8List').putData(
    //   imageData,);
    // img = new Image.memory(
    //   data!,
    //   width: 640,
    //   height: 480,
    //   scale: 1,
    //   fit: BoxFit.contain,
    // );
  }
  // List<int> list =  ;
  // Uint8List bytes =  Uint8List.fromList('_Uint8ArrayView#db075'.codeUnits);
  @override
  Widget build(BuildContext context) {

    // print('---------type check-------------');
    // print('imageData is Uint8List');
    // print(imageData is Uint8List);
    //
    // print('imageData2 is Uint8List');
    // print(imageData2 is Uint8List);

    return Scaffold(


        appBar: AppBar(
        title: Text('meta image'),
      ),
      body: Center(child: _ImageWrapper() ),
    );

  }
  Widget _ImageWrapper() {
    if (imageData == null) {
      return Container(
        child:Text('this is null'),

      );
    }
    return Container(
      width: 900,
      height: 550,
      //color: Colors.purple,
      child:Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            image: new DecorationImage(
                fit: BoxFit.cover, image: MemoryImage(imageData, scale: 0.5)),
          ),
      ),


      // Image.memory(
      //     Uint8List.view(imageData.buffer)
      // ),
      //drawImage(img!, Offset.zero, Paint())



    //   Image.fromBytes(
    //
    // );
      //Image.memory(imageData);
    //   Container(
    //   width: 150,
    //   height: 150,
    //   decoration: BoxDecoration(
    //     image: new DecorationImage(
    //         fit: BoxFit.cover, image: MemoryImage(imageData2, scale: 0.5)),
    //   ),
     );
  }
}
