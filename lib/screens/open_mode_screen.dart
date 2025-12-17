import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum PoiType { worship, school, grocery, hospital, fuel }

class Poi {
  final PoiType type;
  final LatLng point;
  final String name;

  Poi({required this.type, required this.point, required this.name});
}

class OpenModeScreen extends StatefulWidget {
  const OpenModeScreen({super.key});

  @override
  State<OpenModeScreen> createState() => _OpenModeScreenState();
}

class _OpenModeScreenState extends State<OpenModeScreen> {
  final mapController = MapController();
  LatLng? me;

  bool loading = false;
  String? error;
  List<Poi> pois = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      setState(() => error = "Location services disabled");
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      setState(() => error = "Location permission denied");
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      me = LatLng(pos.latitude, pos.longitude);
      error = null;
    });

    await _fetchPois();
  }

  Future<void> _fetchPois() async {
    if (me == null) return;

    setState(() {
      loading = true;
      error = null;
    });

    final lat = me!.latitude;
    final lon = me!.longitude;
    const radiusMeters = 1200;

    final query = """
[out:json][timeout:25];
(
  node(around:$radiusMeters,$lat,$lon)["amenity"="place_of_worship"];
  node(around:$radiusMeters,$lat,$lon)["amenity"="school"];
  node(around:$radiusMeters,$lat,$lon)["shop"="supermarket"];
  node(around:$radiusMeters,$lat,$lon)["shop"="convenience"];
  node(around:$radiusMeters,$lat,$lon)["amenity"="hospital"];
  node(around:$radiusMeters,$lat,$lon)["amenity"="fuel"];
);
out center tags;
""";

    try {
      final uri = Uri.parse("https://overpass-api.de/api/interpreter");
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"data": query},
      );

      if (resp.statusCode != 200) {
        throw Exception("Overpass error: HTTP ${resp.statusCode}");
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final elements = (data["elements"] as List).cast<Map<String, dynamic>>();

      final List<Poi> parsed = [];

      for (final el in elements) {
        final elLat = el["lat"] as num?;
        final elLon = el["lon"] as num?;
        if (elLat == null || elLon == null) continue;

        final tags = (el["tags"] as Map?)?.cast<String, dynamic>() ?? {};
        final name = (tags["name"] as String?)?.trim();
        final amenity = tags["amenity"] as String?;
        final shop = tags["shop"] as String?;

        PoiType? type;
        if (amenity == "place_of_worship") type = PoiType.worship;
        if (amenity == "school") type = PoiType.school;
        if (amenity == "hospital") type = PoiType.hospital;
        if (amenity == "fuel") type = PoiType.fuel;
        if (shop == "supermarket" || shop == "convenience") type = PoiType.grocery;

        if (type == null) continue;

        parsed.add(
          Poi(
            type: type,
            point: LatLng(elLat.toDouble(), elLon.toDouble()),
            name: name ?? _defaultName(type),
          ),
        );
      }

      setState(() {
        pois = parsed;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  String _defaultName(PoiType t) {
    switch (t) {
      case PoiType.worship:
        return "Church / Worship";
      case PoiType.school:
        return "School";
      case PoiType.grocery:
        return "Grocery";
      case PoiType.hospital:
        return "Hospital";
      case PoiType.fuel:
        return "Gas Station";
    }
  }

  IconData _iconFor(PoiType t) {
    switch (t) {
      case PoiType.worship:
        return Icons.account_balance;
      case PoiType.school:
        return Icons.school;
      case PoiType.grocery:
        return Icons.local_grocery_store;
      case PoiType.hospital:
        return Icons.local_hospital;
      case PoiType.fuel:
        return Icons.local_gas_station;
    }
  }

  Color _colorFor(PoiType t) {
    switch (t) {
      case PoiType.worship:
        return Colors.purpleAccent;
      case PoiType.school:
        return Colors.lightBlueAccent;
      case PoiType.grocery:
        return Colors.greenAccent;
      case PoiType.hospital:
        return Colors.redAccent;
      case PoiType.fuel:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = me ?? const LatLng(59.9139, 10.7522);

    final markers = <Marker>[
      // Me
      Marker(
        point: center,
        width: 44,
        height: 44,
        child: const Icon(Icons.my_location, color: Colors.cyanAccent, size: 30),
      ),
      // POIs
      ...pois.map((p) {
        return Marker(
          point: p.point,
          width: 46,
          height: 46,
          child: Tooltip(
            message: p.name,
            child: Icon(_iconFor(p.type), color: _colorFor(p.type), size: 30),
          ),
        );
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Mode'),
        actions: [
          IconButton(
            onPressed: loading ? null : _fetchPois,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh POIs",
          ),
        ],
      ),
      body: Stack(
        children: [
          // MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.spy_game",
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // STATUS CHIP (top-left)
          Positioned(
            left: 12,
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  loading
                      ? "Scanning nearby…"
                      : error != null
                          ? "Error: $error"
                          : "POIs: ${pois.length}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          // BOTTOM MAP COVER PANEL (like your sketch)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0F14).withOpacity(0.92),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      spreadRadius: 2,
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Map",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loading
                          ? "Scanning nearby locations…"
                          : "Nearby: ${pois.length} points",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _LegendRow(
                              icon: Icons.account_balance,
                              label: "Church / Worship",
                              color: Colors.purpleAccent),
                          _LegendRow(
                              icon: Icons.school,
                              label: "School",
                              color: Colors.lightBlueAccent),
                          _LegendRow(
                              icon: Icons.local_grocery_store,
                              label: "Grocery",
                              color: Colors.greenAccent),
                          _LegendRow(
                              icon: Icons.local_hospital,
                              label: "Hospital",
                              color: Colors.redAccent),
                          _LegendRow(
                              icon: Icons.local_gas_station,
                              label: "Gas Station",
                              color: Colors.orangeAccent),
                          const SizedBox(height: 12),
                          if (error != null)
                            Text(
                              error!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
