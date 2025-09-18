// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui_web' as ui; // ✅ ЭНЭ ЧУХАЛ

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      final IFrameElement _iframeElement = IFrameElement()
        ..width = '100%'
        ..height = '100%'
            ..src =
                'https://www.google.com/maps/embed/v1/view?key=AIzaSyB7aODhKokUpz7hdxTC7129TKtl_df6E1g&center=37.7749,-122.4194&zoom=14'// 🟡 Энд та API key-ээ оруулна
        ..style.border = 'none';

      ui.platformViewRegistry.registerViewFactory(
        'map-html',
            (int viewId) => _iframeElement,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WiFi Map')),
      body: HtmlElementView(viewType: 'map-html'),
    );
  }
}
