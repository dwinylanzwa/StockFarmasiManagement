import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../errors/admin_exception.dart';
import '../../models/apotek.dart';
import '../../models/apotek_draft.dart';
import '../../models/hari.dart';
import '../../models/jadwal_operasional.dart';
import '../../navigation/route_paths.dart';
import '../../providers/apotek_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/app_map.dart';
import 'location_picker_screen.dart';

/// Form tambah apotek ([apotekId] `null`) atau ubah apotek.
class ApotekFormScreen extends ConsumerWidget {
  const ApotekFormScreen({this.apotekId, super.key});

  final String? apotekId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = apotekId;
    if (id == null) return const _ApotekForm();

    return ref.watch(apotekByIdProvider(id)).when(
          loading: () => const _FormShell(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const _FormShell(
            child: Center(child: Text('Gagal memuat data apotek.')),
          ),
          data: (apotek) => apotek == null
              ? const _FormShell(
                  child: Center(child: Text('Apotek tidak ditemukan.')),
                )
              : _ApotekForm(initial: apotek),
        );
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Apotek')),
      body: child,
    );
  }
}

class _ApotekForm extends ConsumerStatefulWidget {
  const _ApotekForm({this.initial});

  final Apotek? initial;

  @override
  ConsumerState<_ApotekForm> createState() => _ApotekFormState();
}

class _ApotekFormState extends ConsumerState<_ApotekForm> {
  final _formKey = GlobalKey<FormState>();

  late final _namaController =
      TextEditingController(text: widget.initial?.nama);
  late final _alamatController =
      TextEditingController(text: widget.initial?.alamat);
  late final _teleponController =
      TextEditingController(text: widget.initial?.telepon);

  LatLng? _location;
  late Set<Hari> _hari;
  late bool _buka24Jam;
  late TimeOfDay _buka;
  late TimeOfDay _tutup;
  late bool _isActive;

  bool _saving = false;
  String? _locationError;
  String? _jadwalError;
  String? _error;

  bool get _isEdit => widget.initial != null;

  static TimeOfDay _fromMinutes(int menit) =>
      TimeOfDay(hour: menit ~/ 60, minute: menit % 60);

  static int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static String _format(TimeOfDay time) =>
      JadwalOperasional.formatMenit(_toMinutes(time));

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _location = LatLng(initial.latitude, initial.longitude);
    }
    final jadwal = initial?.jadwal ?? JadwalOperasional.standar;
    _hari = {...jadwal.hari};
    _buka24Jam = jadwal.buka24Jam;
    _buka = _fromMinutes(jadwal.bukaMenit);
    _tutup = _fromMinutes(jadwal.tutupMenit);
    _isActive = initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final picked = await Navigator.of(context, rootNavigator: true).push<LatLng>(
      MaterialPageRoute<LatLng>(
        fullscreenDialog: true,
        builder: (_) => LocationPickerScreen(initial: _location),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _location = picked;
        _locationError = null;
      });
    }
  }

  Future<void> _pickTime({required bool isBuka}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBuka ? _buka : _tutup,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isBuka) {
        _buka = picked;
      } else {
        _tutup = picked;
      }
      _jadwalError = null;
    });
  }

  void _toggleHari(Hari hari, {required bool selected}) {
    setState(() {
      if (selected) {
        _hari.add(hari);
      } else {
        _hari.remove(hari);
      }
      _jadwalError = null;
    });
  }

  Future<void> _submit() async {
    if (_saving) return;

    final jadwal = JadwalOperasional(
      hari: {..._hari},
      buka24Jam: _buka24Jam,
      bukaMenit: _toMinutes(_buka),
      tutupMenit: _toMinutes(_tutup),
    );
    final jadwalError = jadwal.validate();

    final formValid = _formKey.currentState?.validate() ?? false;
    final location = _location;
    setState(() {
      _locationError =
          location == null ? 'Pilih lokasi apotek di peta.' : null;
      _jadwalError = jadwalError;
    });
    if (!formValid || location == null || jadwalError != null) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final controller = ref.read(apotekControllerProvider);
    final initial = widget.initial;

    final draft = ApotekDraft(
      nama: _namaController.text,
      alamat: _alamatController.text,
      latitude: location.latitude,
      longitude: location.longitude,
      jadwal: jadwal,
      telepon: _teleponController.text,
    );

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (initial == null) {
        await controller.create(draft);
      } else {
        await controller.update(initial.id, draft);
        if (_isActive != initial.isActive) {
          await controller.setActive(initial.id, isActive: _isActive);
        }
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Data apotek diperbarui.' : 'Apotek berhasil ditambahkan.',
          ),
        ),
      );
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(RoutePaths.superadminApotek);
      }
    } on AdminActionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = _location;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Apotek' : 'Tambah Apotek')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _namaController,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.namaApotek,
                decoration: const InputDecoration(labelText: 'Nama apotek *'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                enabled: !_saving,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.alamatApotek,
                decoration: const InputDecoration(
                  labelText: 'Alamat *',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teleponController,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: Validators.optionalMaxLength(
                  ApotekLimits.telepon,
                  'Telepon',
                ),
                decoration: const InputDecoration(labelText: 'Telepon'),
              ),
              const SizedBox(height: 24),
              Text('Hari buka *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final hari in Hari.values)
                    FilterChip(
                      label: Text(hari.label),
                      selected: _hari.contains(hari),
                      onSelected: _saving
                          ? null
                          : (selected) => _toggleHari(hari, selected: selected),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Jam operasional *', style: theme.textTheme.titleSmall),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Buka 24 jam'),
                value: _buka24Jam,
                onChanged: _saving
                    ? null
                    : (value) => setState(() {
                          _buka24Jam = value;
                          _jadwalError = null;
                        }),
              ),
              if (!_buka24Jam)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _saving ? null : () => _pickTime(isBuka: true),
                        icon: const Icon(Icons.schedule),
                        label: Text('Buka ${_format(_buka)}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _saving ? null : () => _pickTime(isBuka: false),
                        icon: const Icon(Icons.schedule),
                        label: Text('Tutup ${_format(_tutup)}'),
                      ),
                    ),
                  ],
                ),
              if (_jadwalError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _jadwalError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              Text('Lokasi di peta *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              if (location != null) ...[
                ApotekMapPreview(
                  latitude: location.latitude,
                  longitude: location.longitude,
                ),
                const SizedBox(height: 4),
                Text(
                  '${location.latitude.toStringAsFixed(6)}, '
                  '${location.longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickLocation,
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  location == null ? 'Pilih lokasi di peta' : 'Ubah lokasi',
                ),
              ),
              if (_locationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _locationError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              if (_isEdit) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Apotek aktif'),
                  subtitle: const Text(
                    'Apotek nonaktif tidak tampil untuk Pengguna.',
                  ),
                  value: _isActive,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _isActive = value),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Simpan perubahan' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}