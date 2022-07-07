import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as imglib;
import 'home.dart';
import 'models.dart';

typedef void Callback(List<dynamic> list, int h, int w);

late dynamic memoryImage;
Uint8List imagelist=Uint8List(10000000);
CameraImage? result;
int a=0;

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

        controller.startImageStream((CameraImage image) async {
          if (!isDetecting) {
            isDetecting = true;
            setState(() {
              result = image;
            });

            try {
              final int width = image.width;
              final int height = image.height;
              final int uvRowStride = image.planes[1].bytesPerRow;
              final int uvPixelStride = image.planes[1].bytesPerPixel!;
              print("uvRowStride: " + uvRowStride.toString());
              print("uvPixelStride: " + uvPixelStride.toString());

              // imgLib -> Image package from https://pub.dartlang.org/packages/image
              var img = imglib.Image(width, height); // Create Image buffer

              // Fill image buffer with plane[0] from YUV420_888
              for(int x=0; x < width; x++) {
                for(int y=0; y < height; y++) {
                  final int uvIndex = uvPixelStride * (x/2).floor() + uvRowStride*(y/2).floor();
                  final int index = y * width + x;

                  final yp = image.planes[0].bytes[index];
                  final up = image.planes[1].bytes[uvIndex];
                  final vp = image.planes[2].bytes[uvIndex];
                  // Calculate pixel color
                  int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
                  int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
                  int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
                  // color: 0x FF  FF  FF  FF
                  //           A   B   G   R
                  img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
                }
              }

              imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
              List<int> png = pngEncoder.encodeImage(img);

              print('*********print Uint8L ist**********');
              print(Uint8List.fromList(png));
              a=a+1;

             // firebase storeage 에 넣기
              await storage.ref('imagelist$a').putData(
                  Uint8List.fromList(png)
                // Uint8List.fromList(stringImage.codeUnits),
              );

              // FirebaseFirestore.instance.collection('image').doc().set({
              //   'uint8list':'test' //Uint8List.fromList(png).toString()
              // });


              return Image.memory(Uint8List.fromList(png));


            } catch (e) {
              print(">>>>>>>>>>>> ERROR:" + e.toString());
            }

            FirebaseFirestore.instance.collection('image').doc().set({
              'uint8list':'test' //Uint8List.fromList(png).toString()
            });








            if (widget.model == mobilenet) {
              Tflite.runModelOnFrame(
                bytesList: image.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: image.height,
                imageWidth: image.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                //   print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, image.height, image.width);

                isDetecting = false;
              });
            } else if (widget.model == posenet) {
              Tflite.runPoseNetOnFrame(
                bytesList: image.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: image.height,
                imageWidth: image.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                //   print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, image.height, image.width);
m
                isDetecting = false;
              });


            } else {
              Tflite.detectObjectOnFrame(
                bytesList: image.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
                imageHeight: image.height,
                imageWidth: image.width,
                imageMean: widget.model == yolo ? 0 : 127.5,
                imageStd: widget.model == yolo ? 255.0 : 127.5,
                numResultsPerClass: 1,
                threshold: widget.model == yolo ? 0.2 : 0.4,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                //   print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, image.height, image.width);

                isDetecting = false;///
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