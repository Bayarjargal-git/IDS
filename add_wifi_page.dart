import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class AddWifiPage extends StatefulWidget {
  @override
  _AddWifiPageState createState() => _AddWifiPageState();
}

class _AddWifiPageState extends State<AddWifiPage> {
  final _formKey = GlobalKey<FormState>();
  String _ssid = '';
  String _description = '';
  Position? _position;

  final List<String> _wifiNames = [
    'Asan City Free WiFi',
    'KT WiFi',
    'SK WiFi',
    'LG U+',
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _position = pos;
    });
  }

  Future<void> _saveWifi() async {
    if (_formKey.currentState!.validate() && _position != null) {
      await FirebaseFirestore.instance.collection("wifi_hotspots").add({
        'ssid': _ssid,
        'description': _description,
        'lat': _position!.latitude,
        'lon': _position!.longitude,
        'created_at': Timestamp.now(),
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add WiFi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _ssid.isNotEmpty ? _ssid : null,
                hint: const Text("Select WiFi name"),
                onChanged: (value) => setState(() => _ssid = value ?? ''),
                items: _wifiNames.map((ssid) {
                  return DropdownMenuItem<String>(
                    value: ssid,
                    child: Text(ssid),
                  );
                }).toList(),
                validator: (value) => value == null || value.isEmpty ? 'Please select WiFi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _description = value,
                validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveWifi,
                child: const Text("Save WiFi Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
