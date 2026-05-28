import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import '../camera/camera_screen.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isScanning = true;
  final ApiService _apiService = ApiService();

  Future<void> _verifyUser(String qrData) async {
    setState(() {
      isScanning = false;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.currentUser?.email;

    try {
      final response = await _apiService.post(
        '/iot/verify-user',
        {
          'qr_data': qrData,
          'user_email': userEmail,
        },
        authenticated: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Verified! Bin Opening...'),
              backgroundColor: Colors.green,
            ),
          );
          final cameras = await availableCameras();
          // Small delay to allow the QR scanner to release camera resources
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CameraScreen(cameras: cameras),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification Failed. Access Denied.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isScanning = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() {
          isScanning = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Bin QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _verifyUser(code);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.limeAccent, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point camera at Bin QR Code',
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
