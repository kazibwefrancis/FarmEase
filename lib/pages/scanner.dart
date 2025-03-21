import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/cow_model.dart';
import '../pages/cow_form_page.dart';

class ScannerPage extends StatefulWidget {
  final Function(Cow) onCowScanned;

  const ScannerPage({Key? key, required this.onCowScanned}) : super(key: key);

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
        backgroundColor: Colors.green[300],
        iconTheme: IconThemeData(color: Colors.white),
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
      body: Stack(
        children: [
          // QR Scanner Feed
          MobileScanner(
            controller: controller,
            onDetect: _onQRDetected,
            fit: BoxFit.cover,
          ),
          // Scanning overlay
          _buildOverlay(),
          // Display scanned data (if any)
          if (scannedData.isNotEmpty)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Scanned Data: $scannedData',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    // Draws a centered square overlay to guide scanning.
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (!isScanning) return; // Prevent multiple detections
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          scannedData = barcode.rawValue!;
          isScanning = false;
        });
        _processScannedData(scannedData);
        break;
      }
    }
  }

  void _processScannedData(String data) {
    // For demonstration, the QR code is assumed to be the cow ID.
    final cowId = data;
    final box = Hive.box<Cow>('cows');
    Cow? foundCow;

    // Look for the cow with a matching identifier.
    for (final cow in box.values) {
      if (cow.imagePath == cowId) { // Adjust identification logic as needed.
        foundCow = cow;
        break;
      }
    }

    if (foundCow != null) {
      // Return the found cow to the calling page.
      Navigator.pop(context);
      widget.onCowScanned(foundCow);
    } else {
      // Inform the user and reset scanning.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cow not found in database')),
      );
      setState(() {
        isScanning = true;
        scannedData = '';
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}