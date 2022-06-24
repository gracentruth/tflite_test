
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

Future<void> convertYUV420toImageColor(CameraImage image) async {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;

    print("uvRowStride: " + uvRowStride.toString());
    print("uvPixelStride: " + uvPixelStride.toString());

    var img = imglib.Image(width, height);

    for(int x=0; x < width; x++) {
      for(int y=0; y < height; y++) {
        final int uvIndex = uvPixelStride! * (x/2).floor() + uvRowStride*(y/2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }
    imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
    List<int> png = pngEncoder.encodeImage(img);

    print("png---------------------->");
    print(png);
    print("----------------------------");
    print(Uint8List.fromList(png));

    //Image_upload(Uint8List.fromList(png));
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
}


imglib.Image convertYUV420(CameraImage image) {
  var img = imglib.Image(image.width, image.height); // Create Image buffer

  Plane plane = image.planes[0];
  const int shift = (0xFF << 24);

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < image.width; x++) {
    for (int planeOffset = 0;
    planeOffset < image.height * image.width;
    planeOffset += image.width) {
      final pixelColor = plane.bytes[planeOffset + x];
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      // Calculate pixel color
      var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

      img.data[planeOffset + x] = newVal;
    }
  }

  return img;
}

 Future<ui.Image> bytesToImage(Uint8List imgBytes) async{
ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
ui.FrameInfo frame = await codec.getNextFrame();
return frame.image;
}
// Future<ui.Image> convertCameraImageToUiImage(CameraImage image) async {
//   int startTime = DateTime.now().millisecondsSinceEpoch;
//   int time;
//   imglib.Image img = convertCameraImage(image);
//   time = DateTime.now().millisecondsSinceEpoch;
//   print("Converted in "+(time-startTime).toString()+"ms img "+img.toString()+" ("+img.width.toString()+","+img.height.toString()+")");
//   startTime=time;
//
//   ui.Image ret = await makeUiImage(img.getBytes(), image.width, image.height);
//   return ret;
// }



