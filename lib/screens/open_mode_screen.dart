import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum PoiType {
  fuel,
  restaurant,
  cafe,
  hospital,
  police,
  bank,
  supermarket,
  pharmacy,
  parking,
}

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

  /// 🎮 GAME STATS
  double health = 0.75;
  int coins = 120;
  int level = 3;
  double xpProgress = 0.4;

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
  node(around:10000,$lat,$lon)["amenity"="fuel"];
  node(around:10000,$lat,$lon)["amenity"="restaurant"];
  node(around:10000,$lat,$lon)["amenity"="cafe"];
  node(around:10000,$lat,$lon)["amenity"="hospital"];
  node(around:10000,$lat,$lon)["amenity"="police"];
  node(around:10000,$lat,$lon)["amenity"="bank"];
  node(around:10000,$lat,$lon)["shop"="supermarket"];
  node(around:10000,$lat,$lon)["amenity"="pharmacy"];
  node(around:10000,$lat,$lon)["amenity"="parking"];
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

      final amenity = tags["amenity"];
      final shop = tags["shop"];

      PoiType? type;

      if (amenity == "fuel")
        type = PoiType.fuel;
      else if (amenity == "restaurant")
        type = PoiType.restaurant;
      else if (amenity == "cafe")
        type = PoiType.cafe;
      else if (amenity == "hospital")
        type = PoiType.hospital;
      else if (amenity == "police")
        type = PoiType.police;
      else if (amenity == "bank")
        type = PoiType.bank;
      else if (amenity == "pharmacy")
        type = PoiType.pharmacy;
      else if (amenity == "parking")
        type = PoiType.parking;
      else if (shop == "supermarket")
        type = PoiType.supermarket;

      if (type != null) {
        parsed.add(Poi(type: type, point: LatLng(lat, lon)));
      }
    }

    setState(() {
      pois = parsed;
    });
  }

  IconData _getIcon(PoiType type) {
    switch (type) {
      case PoiType.fuel:
        return Icons.local_gas_station;
      case PoiType.restaurant:
        return Icons.restaurant;
      case PoiType.cafe:
        return Icons.local_cafe;
      case PoiType.hospital:
        return Icons.local_hospital;
      case PoiType.police:
        return Icons.local_police;
      case PoiType.bank:
        return Icons.account_balance;
      case PoiType.supermarket:
        return Icons.shopping_cart;
      case PoiType.pharmacy:
        return Icons.medical_services;
      case PoiType.parking:
        return Icons.local_parking;
    }
  }

  Color _getColor(PoiType type) {
    switch (type) {
      case PoiType.fuel:
        return Colors.orange;
      case PoiType.restaurant:
        return Colors.redAccent;
      case PoiType.cafe:
        return Colors.brown;
      case PoiType.hospital:
        return Colors.red;
      case PoiType.police:
        return Colors.blue;
      case PoiType.bank:
        return Colors.green;
      case PoiType.supermarket:
        return Colors.teal;
      case PoiType.pharmacy:
        return Colors.pink;
      case PoiType.parking:
        return Colors.indigo;
    }
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final markers = [
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

      ...pois.map((p) {
        return Marker(
          point: p.point,
          width: 40,
          height: 40,
          child: Icon(_getIcon(p.type), color: _getColor(p.type)),
        );
      }),
    ];

    return Scaffold(
      body: Stack(
        children: [
          /// 🗺️ MAP
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

          /// 🌑 OVERLAY (FIXED)
          IgnorePointer(child: Container(color: Colors.black.withOpacity(0.4))),

          /// 🎮 HUD
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBar("HP", health, Colors.red),
                const SizedBox(height: 8),
                _buildBar("LVL $level", xpProgress, neonBlue),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      "$coins",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
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
