import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'How to Use the Barcode Scanner',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            '1. Open Scanner: Tap the "Open Scanner" button from the home screen.',
          ),
          SizedBox(height: 8),
          Text(
            '2. Point Camera: Align the barcode or QR code within the scanning frame.',
          ),
          SizedBox(height: 8),
          Text(
            '3. Scan: The app will automatically detect and process the code.',
          ),
          SizedBox(height: 8),
          Text(
            '4. View Result: Review the scanned data and choose to save, copy, or share.',
          ),
          SizedBox(height: 24),
          Text(
            'Common QR Code Types',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('• URL: Opens websites'),
          Text('• Text: Plain text messages'),
          Text('• Contact: vCard information'),
          Text('• WiFi: Network credentials'),
          Text('• Email: Mailto links'),
          SizedBox(height: 24),
          Text(
            'Troubleshooting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Camera Permission: Ensure the app has camera access in device settings.',
          ),
          SizedBox(height: 8),
          Text(
            'Poor Lighting: Scan in well-lit areas for better detection.',
          ),
          SizedBox(height: 8),
          Text(
            'Blurry Codes: Hold the device steady and ensure the code is in focus.',
          ),
          SizedBox(height: 24),
          Text(
            'Contact Support',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('For additional help, please contact support@example.com'),
        ],
      ),
    );
  }
}
