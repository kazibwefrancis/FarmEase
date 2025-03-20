import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/cow_model.dart';
import '../pages/cow_form_page.dart';

class ScannerPage extends StatefulWidget {
  final Function(Cow) onCowScanned;

  const ScannerPage({super.key, required this.onCowScanned});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  String scannedData = '';
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Cow QR Tag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on),
            onPressed: () => controller.toggleTorch(),
            iconSize: 24.0,
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => controller.switchCamera(),
            iconSize: 24.0,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: _onQRDetected,
              fit: BoxFit.cover,
            ),
          ),
          if (scannedData.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Scanned Data: $scannedData',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
        ],
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          scannedData = barcode.rawValue!;
        });
        _processScannedData(scannedData);
      }
    }
  }

  void _processScannedData(String data) {
    // Here you would typically:
    // 1. Validate the scanned data format
    // 2. Lookup the cow in your database
    // 3. Navigate to the cow details screen
    
    // For demonstration, let's assume the QR code contains a cow ID
    // In a real application, you would fetch the cow data from your database
    final cowId = data;
    final box = Hive.box<Cow>('cows');
    
    // Find the cow with matching ID
    Cow? foundCow;
    for (final cow in box.values) {
      if (cow.imagePath == cowId) { // Adjust this based on your actual cow identification method
        foundCow = cow;
        break;
      }
    }
    
    if (foundCow != null) {
      Navigator.pop(context);
      widget.onCowScanned(foundCow);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cow not found in database')),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}