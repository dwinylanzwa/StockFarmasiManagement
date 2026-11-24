import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../widgets/app_map.dart';

/// Layar penuh untuk memilih lokasi dengan mengetuk peta.
///
/// Dibuka dengan `Navigator.push<LatLng>` dan mengembalikan [LatLng]
/// terpilih, atau `null` jika dibatalkan.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({this.initial, super.key});

  final LatLng? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi Apotek')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.initial ?? AppMapDefaults.center,
              initialZoom: widget.initial == null
                  ? AppMapDefaults.cityZoom
                  : AppMapDefaults.pinZoom,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              const OsmTileLayer(),
              if (selected != null)
                MarkerLayer(markers: [buildPinMarker(context, selected)]),
              const OsmAttribution(),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        selected == null
                            ? 'Ketuk peta untuk menandai lokasi apotek.'
                            : 'Koordinat: ${selected.latitude.toStringAsFixed(6)}, '
                                '${selected.longitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: selected == null
                            ? null
                            : () => Navigator.of(context).pop(selected),
                        child: const Text('Pilih lokasi ini'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}