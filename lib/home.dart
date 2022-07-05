import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'imagepage.dart';
import 'models.dart';

import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

var globalKey = new GlobalKey();

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String? res;
    switch (_model) {
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;

      case mobilenet:
        res = await Tflite.loadModel(
            model: "assets/mobilenet_v1_1.0_224.tflite",
            labels: "assets/mobilenet_v1_1.0_224.txt");
        break;

      case posenet:
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt");
    }
    //print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  void _capture() async {
    print("START CAPTURE");
    var renderObject = globalKey.currentContext?.findRenderObject();
    if (renderObject is RenderRepaintBoundary) {
      var boundary = renderObject;
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();
      //print(pngBytes);

      File imgFile = new File('$directory/screenshot.png');
      print('********$imgFile*********');
      imgFile.writeAsBytes(pngBytes!);

      await storage.ref('image3.png').putFile(
            imgFile,
            SettableMetadata(customMetadata: {
              'num': 'hello',
            }),
          );
      print('storageeee');
      setState(() {});

      print("-----------------FINISH CAPTURE ${imgFile.path}------------");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    print(imagelist);
    return Scaffold(
        body: _model == ""
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: const Text(ssd),
                      onPressed: () => onSelect(ssd),
                    ),
                    // RaisedButton(
                    //   child: const Text(yolo),
                    //   onPressed: () => onSelect(yolo),
                    // ),
                    // RaisedButton(
                    //   child: const Text(mobilenet),
                    //   onPressed: () => onSelect(mobilenet),
                    // ),
                    // RaisedButton(
                    //   child: const Text(posenet),
                    //   onPressed: () => onSelect(posenet),
                    // ),
                    RaisedButton(
                        child: const Text('meta image'),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ImagePage();
                          }));
                        }),
                  ],
                ),
              )
            : Column(
                children: [
                  Container(
                    height: 300,
                    child: Camera(
                      widget.cameras,
                      _model,
                      setRecognitions,
                    ),
                    // Stack(
                    //   children: [
                    //     Camera(
                    //       widget.cameras,
                    //       _model,
                    //       setRecognitions,
                    //     ),
                    //     // BndBox(
                    //     //     _recognitions == null ? [] : _recognitions,
                    //     //     math.max(_imageHeight, _imageWidth),
                    //     //     math.min(_imageHeight, _imageWidth),
                    //     //     screen.height,
                    //     //     screen.width,
                    //     //     _model),
                    //
                    //   ],
                    // ),
                  ),
                  Container(
                    height:100,
                    child: Image.memory(
                      imagelist2.first,
                      fit: BoxFit.cover,
                    )
                  ),

                  Container(
                    height: 100,
                    child: TextButton(
                      onPressed: () {
                        //  _capture();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ImagePage();
                        }));
                      },
                      child: Text('capture'),
                    ),
                  )
                ],
              ));
  }
}
