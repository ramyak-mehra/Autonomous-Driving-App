import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'tflite_helper.dart';
import 'camera_helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List outputs;

  @override
  void initState() {
    super.initState();
    //Load TFLite Model
    TFLiteHelper.loadModel().then((value) {
      setState(() {
        TFLiteHelper.modelLoaded = true;
      });
    });
    //Setup camera
    CameraHelper.initializeCamera();

    TFLiteHelper.tfLiteResultsController.stream.listen((event) {
      event.forEach((element) {
        print(element);
      });
      outputs = event;

      setState(() {
        CameraHelper.isDetecting = false;
      });
    }, onDone: () {
      print('hopefully working');
    }, onError: (error) {
      print("Error on home screen $error");
    });
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    CameraHelper.camera.dispose();
    print('disposing');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Self Driving'),
      ),
      body: FutureBuilder<void>(
        future: CameraHelper.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(CameraHelper.camera),
                Center(
                    child: Text(
                  outputs.first.toString(),
                  style: TextStyle(fontSize: 24, color: Colors.red),
                )),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
