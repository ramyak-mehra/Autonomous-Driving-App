import 'dart:async';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';

class TFLiteHelper {
  static StreamController<List> tfLiteResultsController =
      StreamController.broadcast();
  static List _outputs = List();
  static var modelLoaded = false;

  static Future<String> loadModel() async {
    print('Loading model...');
    return Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        useGpuDelegate: true);
  }

  static classifyImage(CameraImage image) async {
    await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            numResults: 5)
        .then((value) {
      if (value.isNotEmpty) {
        print('results loaded');

        //Clear previous results
        _outputs.clear();

        value.forEach((element) {
          _outputs.add(element);

          print(element);
        });
      }
      //Send results
      tfLiteResultsController.add(_outputs);
    });
  }

  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
