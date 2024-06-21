import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:brandweer_qr_code_scanner/ml.dart';
import 'package:brandweer_qr_code_scanner/result.dart';

class PictureScreen extends StatelessWidget {
  final XFile picture;
  const PictureScreen(this.picture,{super.key});

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('Picture')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(picture.path),
          SizedBox(
            height: deviceHeight/1.5,
            child: Image.file(File(picture.path)),
          ),
          Row(children: [
            ElevatedButton(onPressed: (){
              final image = File(picture.path);
              MLHelper helper = MLHelper();
              helper.readBarcode(image).then((result){
                  Navigator.push(context,MaterialPageRoute(builder: (_)=>ResultScreen(result)));
              });
            }, child: const Text('Barcode Reader')),
          ],)
        ],),
    );
  }
}