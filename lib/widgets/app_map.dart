import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Konstanta tampilan peta.
abstract final class AppMapDefaults {
  /// Pusat peta awal saat belum ada lokasi terpilih (Medan).
  static const LatLng center = LatLng(3.5952, 98.6722);
  static const double cityZoom = 12;
  static const double pinZoom = 16;

  /// Tile OpenStreetMap. Ganti URL ini jika nanti memakai penyedia tile lain.
  static const String tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Wajib diisi sesuai kebijakan penggunaan tile OSM. Samakan dengan
  /// applicationId Android Anda.
  static const String userAgentPackage = 'com.halobat.halobat';
}

/// Lapisan tile OpenStreetMap.
class OsmTileLayer extends StatelessWidget {
  const OsmTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: AppMapDefaults.tileUrl,
      userAgentPackageName: AppMapDefaults.userAgentPackage,
    );
  }
}

/// Atribusi wajib OpenStreetMap.
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleAttributionWidget(
      source: Text('© OpenStreetMap contributors'),
    );
  }
}

/// Penanda lokasi berbentuk pin. Ujung bawah pin tepat di [point].
Marker buildPinMarker(BuildContext context, LatLng point) {
  return Marker(
    point: point,
    width: 44,
    height: 44,
    alignment: Alignment.topCenter,
    child: Icon(
      Icons.location_on,
      size: 44,
      color: Theme.of(context).colorScheme.error,
    ),
  );
}

/// Peta statis kecil dengan satu penanda (tanpa gestur).
class ApotekMapPreview extends StatelessWidget {
  const ApotekMapPreview({
    required this.latitude,
    required this.longitude,
    this.height = 180,
    super.key,
  });

  final double latitude;
  final double longitude;
  final double height;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          // Key baru agar peta dibuat ulang saat koordinat berubah.
          key: ValueKey('$latitude,$longitude'),
          options: MapOptions(
            initialCenter: position,
            initialZoom: AppMapDefaults.pinZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            const OsmTileLayer(),
            MarkerLayer(markers: [buildPinMarker(context, position)]),
            const OsmAttribution(),
          ],
        ),
      ),
    );
  }
}