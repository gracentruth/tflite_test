import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as imglib;
import 'camera.dart';


var memoryImage2;

class ImagePage extends StatefulWidget {
  const ImagePage(CameraImage? img, {Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {

  Uint8List imageData=Uint8List(100000000);
  Uint8List imageData2=Uint8List(100000000);

  @override
  void initState() {
    super.initState();

  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('meta image'),
      ),
      body: Center(child: _ImageWrapper()),
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
      child:  Container(
          width: 150,
          height: 150,
          child : Column(
            children: [
             // convertYUV420toImage(result!)
              Container(),
            ],
          )
      ),
    );
  }

  // Widget convertYUV420toImage(CameraImage image) {
  //   try {
  //     final int width = image.width;
  //     final int height = image.height;
  //     final int uvRowStride = image.planes[1].bytesPerRow;
  //     final int uvPixelStride = image.planes[1].bytesPerPixel!;
  //     print("uvRowStride: " + uvRowStride.toString());
  //     print("uvPixelStride: " + uvPixelStride.toString());
  //
  //     // imgLib -> Image package from https://pub.dartlang.org/packages/image
  //     var img = imglib.Image(width, height); // Create Image buffer
  //
  //     // Fill image buffer with plane[0] from YUV420_888
  //     for(int x=0; x < width; x++) {
  //       for(int y=0; y < height; y++) {
  //         final int uvIndex = uvPixelStride * (x/2).floor() + uvRowStride*(y/2).floor();
  //         final int index = y * width + x;
  //
  //         final yp = image.planes[0].bytes[index];
  //         final up = image.planes[1].bytes[uvIndex];
  //         final vp = image.planes[2].bytes[uvIndex];
  //         // Calculate pixel color
  //         int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
  //         int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
  //         int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
  //         // color: 0x FF  FF  FF  FF
  //         //           A   B   G   R
  //         img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
  //       }
  //     }
  //
  //     imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
  //     List<int> png = pngEncoder.encodeImage(img);
  //     print('*********print Uint8List**********');
  //     print(Uint8List.fromList(png));
  //
  //
  //     return Image.memory(Uint8List.fromList(png));
  //
  //
  //
  //   } catch (e) {
  //     print(">>>>>>>>>>>> ERROR:" + e.toString());
  //   }
  //   return Container();
  // }
}