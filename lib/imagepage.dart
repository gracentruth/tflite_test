import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//MemoryImage memoryImage=MemoryImage(_Uint8ArrayView#855ea, scale: 1.0);

var memoryImage;
class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {


 // List<int> list =  ;
  Uint8List bytes =  Uint8List.fromList('_Uint8ArrayView#db075'.codeUnits);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
      Text('meta image'),

      ),
      body:Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          image: new DecorationImage(
              fit: BoxFit.cover, image: memoryImage,
        ),

      ),

    ),
    ) ;
  }
}
