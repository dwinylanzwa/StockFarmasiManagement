import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../errors/obat_exception.dart';
import '../../models/bentuk_sediaan.dart';
import '../../models/obat.dart';
import '../../models/obat_draft.dart';
import '../../models/obat_golongan.dart';
import '../../navigation/route_paths.dart';
import '../../providers/obat_provider.dart';
import '../../utils/validators.dart';

/// Form tambah obat ([obatId] `null`) atau ubah obat.
class ObatFormScreen extends ConsumerWidget {
  const ObatFormScreen({this.obatId, super.key});

  final String? obatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = obatId;
    if (id == null) return const _ObatForm();

    return ref.watch(obatByIdProvider(id)).when(
          loading: () => const _FormShell(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const _FormShell(
            child: Center(child: Text('Gagal memuat data obat.')),
          ),
          data: (obat) => obat == null
              ? const _FormShell(
                  child: Center(child: Text('Obat tidak ditemukan.')),
                )
              : _ObatForm(initial: obat),
        );
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Ubah Obat')), body: child);
  }
}

class _ObatForm extends ConsumerStatefulWidget {
  const _ObatForm({this.initial});

  final Obat? initial;

  @override
  ConsumerState<_ObatForm> createState() => _ObatFormState();
}

class _ObatFormState extends ConsumerState<_ObatForm> {
  final _formKey = GlobalKey<FormState>();

  late final _namaController =
      TextEditingController(text: widget.initial?.nama);
  late final _generikController =
      TextEditingController(text: widget.initial?.namaGenerik);
  late final _kekuatanController =
      TextEditingController(text: widget.initial?.kekuatan);
  late final _produsenController =
      TextEditingController(text: widget.initial?.produsen);
  late final _deskripsiController =
      TextEditingController(text: widget.initial?.deskripsi);
  late final _indikasiController =
      TextEditingController(text: widget.initial?.indikasi);
  late final _peringatanController =
      TextEditingController(text: widget.initial?.peringatan);

  ObatGolongan? _golongan;
  BentukSediaan? _bentuk;
  late bool _isActive;

  bool _saving = false;
  String? _selectionError;
  String? _error;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _golongan = widget.initial?.golongan;
    _bentuk = widget.initial?.bentuk;
    _isActive = widget.initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _generikController.dispose();
    _kekuatanController.dispose();
    _produsenController.dispose();
    _deskripsiController.dispose();
    _indikasiController.dispose();
    _peringatanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    final formValid = _formKey.currentState?.validate() ?? false;
    final golongan = _golongan;
    final bentuk = _bentuk;
    final selectionValid = golongan != null && bentuk != null;
    setState(() {
      _selectionError =
          selectionValid ? null : 'Pilih golongan dan bentuk sediaan.';
    });
    if (!formValid || golongan == null || bentuk == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final controller = ref.read(obatControllerProvider);
    final initial = widget.initial;

    final draft = ObatDraft(
      nama: _namaController.text,
      namaGenerik: _generikController.text,
      golongan: golongan,
      bentuk: bentuk,
      kekuatan: _kekuatanController.text,
      produsen: _produsenController.text,
      deskripsi: _deskripsiController.text,
      indikasi: _indikasiController.text,
      peringatan: _peringatanController.text,
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
            _isEdit ? 'Data obat diperbarui.' : 'Obat berhasil ditambahkan.',
          ),
        ),
      );
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(RoutePaths.apotekerObat);
      }
    } on ObatActionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Obat' : 'Tambah Obat')),
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
                validator: Validators.namaObat,
                decoration: const InputDecoration(labelText: 'Nama obat *'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _generikController,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.optionalMaxLength(
                  ObatLimits.namaGenerik,
                  'Nama generik',
                ),
                decoration: const InputDecoration(labelText: 'Nama generik'),
              ),
              const SizedBox(height: 20),
              Text('Golongan *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final golongan in ObatGolongan.values)
                    ChoiceChip(
                      label: Text(golongan.label),
                      selected: _golongan == golongan,
                      onSelected: _saving
                          ? null
                          : (_) => setState(() => _golongan = golongan),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Bentuk sediaan *', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final bentuk in BentukSediaan.values)
                    ChoiceChip(
                      label: Text(bentuk.label),
                      selected: _bentuk == bentuk,
                      onSelected: _saving
                          ? null
                          : (_) => setState(() => _bentuk = bentuk),
                    ),
                ],
              ),
              if (_selectionError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectionError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: _kekuatanController,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                validator: Validators.optionalMaxLength(
                  ObatLimits.kekuatan,
                  'Kekuatan',
                ),
                decoration: const InputDecoration(
                  labelText: 'Kekuatan',
                  hintText: 'Contoh: 500 mg',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _produsenController,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.optionalMaxLength(
                  ObatLimits.produsen,
                  'Produsen',
                ),
                decoration: const InputDecoration(labelText: 'Produsen'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                enabled: !_saving,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.optionalMaxLength(
                  ObatLimits.deskripsi,
                  'Deskripsi',
                ),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _indikasiController,
                enabled: !_saving,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.optionalMaxLength(
                  ObatLimits.indikasi,
                  'Indikasi',
                ),
                decoration: const InputDecoration(
                  labelText: 'Indikasi',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _peringatanController,
                enabled: !_saving,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.optionalMaxLength(
                  ObatLimits.peringatan,
                  'Peringatan',
                ),
                decoration: const InputDecoration(
                  labelText: 'Peringatan',
                  alignLabelWithHint: true,
                ),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Obat aktif'),
                  subtitle: const Text(
                    'Obat nonaktif tidak tampil di katalog Pengguna.',
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