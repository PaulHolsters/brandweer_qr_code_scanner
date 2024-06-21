import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  //List<Widget> cameraButtons = [];
  CameraController? cameraController;
  CameraDescription? activeCamera;
  CameraPreview? preview;
  String scannedQRCode = '';
  Size? imageSize; 

  @override
  void initState() {
    super.initState();
    listCameras().then((result) {
      setState(() {
        // cameraButtons = result;
        setCameraController();
      });
    });
  }

/*   Future scanQRCode() async {
    dynamic picture = await takePicture();
    while(picture==null){
      picture = await takePicture();
    }
    var image = File(picture.path);
    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    final InputImage inputImage = InputImage.fromFile(image);
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
    String? result;
    for (Barcode bc in barcodes) {
      if (bc.displayValue != null) {
        result = bc.displayValue;
      }
    }
    return result;
  } */

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    imageSize = size;
    print('building the camera');
    /*SchedulerBinding.instance.addPostFrameCallback((_){
      print('starting to scan');
      scan();});*/
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herlocatie'),
      ),
      body:Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ preview == null ? const Text('Building camera') : SizedBox(
                         width: size.width/1.2,
                            height: size.height/1.5,
                            child: preview,
                            ),
                            Text('gevonden tekst: $scannedQRCode'),
                            const Text('het doet moeilijk')
                            ]),
      )
      
      
      /*Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
/*             Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: cameraButtons.isEmpty ? [
                  const Text('No cameras available')
              ] : cameraButtons,
            ), */
            Text('gevonden tekst: $scannedQRCode')
/*             Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: (){
                  if(cameraController != null){
                    takePicture().then((dynamic picture){
                        Navigator.push(context, MaterialPageRoute(builder: (ctx)=>PictureScreen(picture)));
                    });
                  }
              }, child: const Text('Take Picture'))
            ],) */
          ],
        ),*/
    );
  }

  Future listCameras() async {
    //List<Widget> buttons = [];
    cameras = await availableCameras();
    if (cameras.isEmpty) return [];
    activeCamera ??= cameras.first;
/* 
    for (CameraDescription camera in cameras) {
      buttons.add(SizedBox(
        width: 80,
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                activeCamera = camera;
                setCameraController();
              });
            },
            child: const Row(
                children: [ Icon(Icons.camera_alt)],
              ),
            ),
      ));
    } */
    //return buttons;
  }

  Future setCameraController() async {
    if (activeCamera == null) return;
    if (cameraController != null) {
      await cameraController!.dispose();
    }

    cameraController = CameraController(activeCamera!, ResolutionPreset.high);
    //print(cameraController);
    try {
      await cameraController!.initialize();
    } catch (e) {
      print('Ccamera controller initialze error: $e');
      return;
    }

    setState(() {
      preview = CameraPreview(
        cameraController!,
      );
      print('preview ready');
      print(preview);
    });
          scan();
  }

  Future imageRound(CameraImage image) async {
    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    //print('length = ${image.planes.length}');
    Uint8List imageBytes = image.planes[0].bytes;
    if(image.planes.length != 1){
      final WriteBuffer allBytes = WriteBuffer();
      image.planes.forEach((Plane plane)=>allBytes.putUint8List(plane.bytes));
      imageBytes = allBytes.done().buffer.asUint8List();
    }
    final plane = image.planes[0];
    final sensorOrientation = activeCamera!.sensorOrientation;
    InputImageRotation? rotation;
    InputImageFormat? fm; 
/*     Map<DeviceOrientation,int> _orientations = {
      DeviceOrientation.portraitUp:0,
      DeviceOrientation.portraitDown:180,
      DeviceOrientation.landscapeLeft:90,
      DeviceOrientation.landscapeRight:270
    }; */
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      fm = InputImageFormat.bgra8888;
    } else if (Platform.isAndroid) {
/*       var rotationCompensation =
                _orientations[cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (activeCamera!.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      print('roratiecomp = $rotationCompensation');
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      print('rotatie = '+rotation.toString()); */
      rotation = InputImageRotation.rotation0deg;
      fm = InputImageFormat.nv21;
    }
    InputImage inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation!,
            format: fm!,
            bytesPerRow: plane.bytesPerRow));
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
        print('i am working');
    String? result;
    for (Barcode bc in barcodes) {
      if (bc.displayValue != null) {
        result = bc.displayValue;
      }
    }
    return result;
  }

  Future scanQRCode(CameraImage image) async {
    var result = await imageRound(image);
/*     while (result == null) {
      result = await imageRound(image);
    } */
    if (result != null) {
      setState(() {
        scannedQRCode = result;
        cameraController!.stopImageStream();
      });
    }
  }

  /*   Future scan() async {
    var result = await scanQRCode();
    while (result == null) {
      result = await scanQRCode();
    }
    setState(() {
      scannedQRCode = result;
    });
    // todo het resultaat
  } */

  Future scan() async {
    if (cameraController == null) return;
    if (!cameraController!.value.isInitialized) return;
    if (cameraController!.value.isTakingPicture) return;
    await cameraController!.setFlashMode(FlashMode.off);
    await cameraController!.startImageStream(scanQRCode);
    //while(scannedQRCode == ''){}
    //cameraController!.stopImageStream();
    print('stopped!');
  }
}
