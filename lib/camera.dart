import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as imglib;
import 'package:exif/exif.dart';

import 'home.dart';
import 'imageConvert.dart';
import 'imagepage.dart';
import 'models.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_gallery_saver/image_gallery_saver.dart';



typedef void Callback(List<dynamic> list, int h, int w);

late dynamic memoryImage;
Uint8List imagelist=Uint8List(10000000);
List<Uint8List> imagelist2=[];

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool isDetecting = false;

  FirebaseStorage storage = FirebaseStorage.instance;
  //final CollectionReference _p = FirebaseFirestore.instance.collection('image');

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        int a = 0;

        controller.startImageStream((CameraImage img) async {
          if (!isDetecting) {
            isDetecting = true;
          //
          //  Uint8List? pngBytes = img.planes[0].bytes;
          // // print(pngBytes);
          //
          //   FirebaseFirestore.instance.
          //   collection('image2').
          //   add({
          //     'name': 'datata',
          //   });
          //  // print('finish database upload');
          //
          //   a=a+1;
          //   await storage.ref('meta').putData(
          //     pngBytes,);
          //
          //   //final path = await  getApplicationDocumentsDirectory();;
          //   //File file1 =File.fromRawPath(pngBytes);
          //  //print('dir: ${path.path}');
          //
          //  // File imgFile = new File('/Users/gracentruth0103/Desktop/22_Sum/Flutter Advanced Camp/tflite_test/assets/screenshot.png');
          //
          // // print(Image.memory(pngBytes).image);
          // // memoryImage= Image.memory(pngBytes).image;
          //
          //
          //   setState(() {});
          //
          //   //imgFile.writeAsBytes(pngBytes!);
          //
          //
          //
          //
          //
          //  // print('file1_2: $file1');
          //   // await storage.ref('file2').putFile(
          //   //   file1,
          //   //   SettableMetadata(customMetadata: {
          //   //     'num': 'hello',
          //   //   }),
          //   // );
          //
          //
          //
          //
          //   // await storage.ref('eunjin$a').putString(
          //   //       Image.memory(pngBytes).toString(),
          //   //       metadata: SettableMetadata(customMetadata: {
          //   //         'image_meta': Image.memory(pngBytes).toString()
          //   //       }),
          //   //     );

            final int numBytes =
            img.planes.fold(0, (count, plane) => count += plane.bytes.length);
            final Uint8List allBytes = Uint8List(numBytes);

            int nextIndex = 0;
            for (int i = 0; i < img.planes.length; i++) {
              allBytes.setRange(nextIndex, nextIndex + img.planes[i].bytes.length,
                  img.planes[i].bytes);
              nextIndex += img.planes[i].bytes.length;
            }

            // Convert as done previously
            String base64Image = base64Encode(allBytes);

            var byteImage = Base64Decoder().convert(base64Image);
            String stringImage = String.fromCharCodes(byteImage);


            print('*****');

            print(Uint8List.fromList(stringImage.codeUnits));
           // imagelist=Uint8List.fromList(stringImage.codeUnits);
            imagelist2= img.planes.map((plane) {
              return plane.bytes;

            }).toList();



               await storage.ref('meta2').putString(
                   stringImage
                // Uint8List.fromList(stringImage.codeUnits),

               );




            int startTime = new DateTime.now().millisecondsSinceEpoch;






            if (widget.model == mobilenet) {
              Tflite.runModelOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                //   print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            } else if (widget.model == posenet) {
              Tflite.runPoseNetOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                //   print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            } else {
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: widget.model == yolo ? 0 : 127.5,
                imageStd: widget.model == yolo ? 255.0 : 127.5,
                numResultsPerClass: 1,
                threshold: widget.model == yolo ? 0.2 : 0.4,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                //   print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: RepaintBoundary(
        key: globalKey,
        child: CameraPreview(controller),
      ),
    );
  }
}
