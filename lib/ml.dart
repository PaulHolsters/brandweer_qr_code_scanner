import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class MLHelper{

  Future<String> readBarcode(File image) async{
    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    final InputImage inputImage = InputImage.fromFile(image);
    String result = '';
    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
    for (Barcode bc in barcodes){
      final String displayValue = bc.displayValue ?? '';
      result += '$displayValue\n';
    }
    return result;
  }
}