
import 'dart:typed_data';
import 'dart:ui' as ui;
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

        int a=0;

        controller.startImageStream((CameraImage img) async {

          if (!isDetecting) {
            isDetecting = true;
            print(img);
            a=a+1;

            Uint8List? pngBytes =img.planes[0].bytes;

            String dir = (await getApplicationDocumentsDirectory()).path;
            String currentdir = (await getApplicationDocumentsDirectory()).path;
            print('currentdir: $currentdir');
            String fullPath = '$dir/abc.png';
            print("local file full path ${fullPath}");
            File file = await File(fullPath);
            await file.writeAsBytes(pngBytes);
            print('*****file $file');


            await storage.ref('newfile').putFile(
              file,
              SettableMetadata(customMetadata: {
                'num': 'hello',
              }),
            );
            print('storageeee');
            setState(() {});

            // final result = await ImageGallerySaver.saveImage(pngBytes);
            // print('result: $result');


            //File file=File.fromRawPath(pngBytes);

           // print(file);

          // print(Image.memory(pngBytes).image);
          //  var i =Image.memory(pngBytes).image; //MemoryImage(_Uint8ArrayView#855ea, scale: 1.0)
          //   memoryImage=i;
          //   Uint8List bytes =  Uint8List.fromList('_Uint8ArrayView#8c4bc'.codeUnits);
          //   //print(bytes);
          //  // print('++++');
          //   //print(pngBytes);
          //  // final data = await readExifFromBytes(pngBytes);
          //  // print('data${readExifFromBytes(pngBytes)}');
          //
          // await storage.ref('metadata$a').putString(
          //     Image.memory(pngBytes).toString(),
          //   metadata: SettableMetadata(customMetadata: {
          //     'image_meta': Image.memory(pngBytes).toString()
          //   }
          //   ),
          //     //SettableMetadata(contentType:)
          // );



            // await storage.ref('image7.png').putFile(
            //     imgFile,
            //
            //     SettableMetadata(customMetadata: {
            //       'num':pngBytes.toString(),
            //     },
            //       contentType: "image/png",
            //     ));
            print('storageeee');
            setState(() {});

            //File imageFile = File(image2!.path);

           //print(image2.image);

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
        child:  CameraPreview(controller),

      ),


    );
  }
}
