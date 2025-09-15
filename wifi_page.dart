import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/api_service.dart';

class WifiPage extends StatefulWidget {
  const WifiPage({super.key});

  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  List<WiFiAccessPoint> nearbyWifis = [];
  Map<String, int> trustScores = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _scanNearbyWifi();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission required")),
      );
    }
  }

  Future<void> _scanNearbyWifi() async {
    final can = await WiFiScan.instance.canStartScan();

    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      setState(() {
        nearbyWifis = results;
      });

      // API руу оноо хүсэх
      for (var wifi in results) {
        final score = await getTrustScore(
          wifi.level,          // signal
          wifi.capabilities,   // encryption
          "2.4GHz",            // жишээ band
        );
        setState(() {
          trustScores[wifi.ssid] = score ?? 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trusted WiFi Finder")),
      body: ListView.builder(
        itemCount: nearbyWifis.length,
        itemBuilder: (context, index) {
          final wifi = nearbyWifis[index];
          final trust = trustScores[wifi.ssid] ?? 0;

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(
                Icons.wifi,
                color: _getColorForTrust(trust),
              ),
              title: Text(wifi.ssid),
              subtitle: Text("Trust: $trust"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanNearbyWifi,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

Color _getColorForTrust(int trust) {
  if (trust >= 70) return Colors.green;
  if (trust >= 40) return Colors.orange;
  return Colors.red;
}
