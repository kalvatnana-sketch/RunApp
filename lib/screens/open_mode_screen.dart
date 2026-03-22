import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum PoiType { fuel, restaurant }

class Poi {
  final PoiType type;
  final LatLng point;

  Poi({required this.type, required this.point});
}

class OpenModeScreen extends StatefulWidget {
  const OpenModeScreen({super.key});

  @override
  State<OpenModeScreen> createState() => _OpenModeScreenState();
}

class _OpenModeScreenState extends State<OpenModeScreen>
    with TickerProviderStateMixin {
  final mapController = MapController();
  LatLng? me;

  final Color neonGreen = const Color(0xFF00C98D);
  final Color neonBlue = const Color(0xFF00E5FF);

  List<Poi> pois = [];

  late AnimationController _scanController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initLocation();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      me = LatLng(pos.latitude, pos.longitude);
    });

    await _fetchPois();
  }

  Future<void> _fetchPois() async {
    if (me == null) return;

    final lat = me!.latitude;
    final lon = me!.longitude;

    final query =
        """
[out:json];
(
  node(around:1000,$lat,$lon)["amenity"="fuel"];
  node(around:1000,$lat,$lon)["amenity"="restaurant"];
);
out;
""";

    final resp = await http.post(
      Uri.parse("https://overpass-api.de/api/interpreter"),
      body: {"data": query},
    );

    final data = jsonDecode(resp.body);
    final elements = data["elements"] as List;

    final List<Poi> parsed = [];

    for (final el in elements) {
      final lat = el["lat"];
      final lon = el["lon"];
      final tags = el["tags"] ?? {};

      if (tags["amenity"] == "fuel") {
        parsed.add(Poi(type: PoiType.fuel, point: LatLng(lat, lon)));
      }

      if (tags["amenity"] == "restaurant") {
        parsed.add(Poi(type: PoiType.restaurant, point: LatLng(lat, lon)));
      }
    }

    setState(() {
      pois = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final markers = [
      // Player
      Marker(
        point: me!,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: neonGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: neonGreen.withOpacity(0.8),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),

      // POIs
      ...pois.map((p) {
        return Marker(
          point: p.point,
          width: 40,
          height: 40,
          child: Icon(
            p.type == PoiType.fuel ? Icons.local_gas_station : Icons.restaurant,
            color: p.type == PoiType.fuel ? Colors.orange : Colors.redAccent,
          ),
        );
      }),
    ];

    return Scaffold(
      body: Stack(
        children: [
          /// 🗺️ DARK MAP TILE
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: me!,
              initialZoom: 16,
              minZoom: 5,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: "com.example.spy_game",
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          /// 🌑 DARK OVERLAY
          Container(color: Colors.black.withOpacity(0.4)),

          /// 📡 SCAN LINES
          Opacity(
            opacity: 0.08,
            child: AnimatedBuilder(
              animation: _scanController,
              builder: (_, __) {
                return CustomPaint(
                  painter: _ScanLinePainter(_scanController.value),
                  size: Size.infinite,
                );
              },
            ),
          ),

          /// 🎯 RADAR PULSE
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                double scale = 1 + _pulseController.value * 2;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: neonGreen.withOpacity(
                          1 - _pulseController.value,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔍 ZOOM BUTTONS
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: Colors.black,
                  onPressed: () {
                    final z = mapController.camera.zoom;
                    mapController.move(mapController.camera.center, z + 1);
                  },
                  child: Icon(Icons.add, color: neonBlue),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.black,
                  onPressed: () {
                    final z = mapController.camera.zoom;
                    mapController.move(mapController.camera.center, z - 1);
                  },
                  child: Icon(Icons.remove, color: neonBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y + progress * 4),
        Offset(size.width, y + progress * 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
