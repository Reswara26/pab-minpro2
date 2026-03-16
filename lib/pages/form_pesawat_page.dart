import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pesawat.dart';
import '../services/supabase_service.dart';
import '../services/theme_provider.dart';

class FormPesawatPage extends StatefulWidget {
  final Pesawat? pesawat;
  const FormPesawatPage({super.key, this.pesawat});

  @override
  State<FormPesawatPage> createState() => _FormPesawatPageState();
}

class _FormPesawatPageState extends State<FormPesawatPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _maskapaiController;
  late TextEditingController _tahunController;
  late TextEditingController _tipeEngineController;
  late TextEditingController _kapasitasController;
  late TextEditingController _maxRangeController;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  bool get _isEditing => widget.pesawat != null;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.pesawat?.nama ?? '');
    _maskapaiController =
        TextEditingController(text: widget.pesawat?.maskapai ?? '');
    _tahunController =
        TextEditingController(text: widget.pesawat?.tahunProduksi ?? '');
    _tipeEngineController =
        TextEditingController(text: widget.pesawat?.tipeEngine ?? '');
    _kapasitasController =
        TextEditingController(text: widget.pesawat?.kapasitasPenumpang ?? '');
    _maxRangeController =
        TextEditingController(text: widget.pesawat?.maxRange ?? '');

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _maskapaiController.dispose();
    _tahunController.dispose();
    _tipeEngineController.dispose();
    _kapasitasController.dispose();
    _maxRangeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    final pesawat = Pesawat(
      id: widget.pesawat?.id,
      nama: _namaController.text.trim(),
      maskapai: _maskapaiController.text.trim(),
      tahunProduksi: _tahunController.text.trim(),
      tipeEngine: _tipeEngineController.text.trim(),
      kapasitasPenumpang: _kapasitasController.text.trim(),
      maxRange: _maxRangeController.text.trim(),
      userId: userId,
    );

    try {
      if (_isEditing) {
        await SupabaseService.updatePesawat(widget.pesawat!.id!, pesawat);
      } else {
        await SupabaseService.addPesawat(pesawat);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(_isEditing
                ? 'Pesawat berhasil diupdate!'
                : 'Pesawat berhasil ditambahkan!'),
          ]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'EDIT PESAWAT' : 'TAMBAH PESAWAT',
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontSize: 16),
        ),
      ),
      body: ScaleTransition(
        scale: _scaleAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x33000000),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.airplanemode_active,
                          color: AppColors.black, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing
                              ? 'Edit Data Pesawat'
                              : 'Data Pesawat Baru',
                          style: const TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 17),
                        ),
                        const Text('Isi semua field dengan benar',
                            style: TextStyle(
                                color: Color(0x99000000), fontSize: 12)),
                      ],
                    ),
                  ]),
                ),
                const SizedBox(height: 28),

                // Form fields
                _buildField(
                    ctrl: _namaController,
                    label: 'NAMA PESAWAT',
                    hint: 'Contoh: Airbus A350-1000',
                    icon: Icons.flight_rounded,
                    isDark: isDark),
                const SizedBox(height: 16),

                _buildField(
                    ctrl: _maskapaiController,
                    label: 'MASKAPAI',
                    hint: 'Contoh: STARLUX Airlines',
                    icon: Icons.business_rounded,
                    isDark: isDark),
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(
                    child: _buildField(
                        ctrl: _tahunController,
                        label: 'TAHUN PRODUKSI',
                        hint: '2018',
                        icon: Icons.calendar_today_rounded,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 4,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Wajib diisi';
                          final y = int.tryParse(val);
                          if (y == null || y < 1900 || y > 2100)
                            return 'Tahun tidak valid';
                          return null;
                        }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                        ctrl: _kapasitasController,
                        label: 'KAPASITAS (PAX)',
                        hint: '410',
                        icon: Icons.people_rounded,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Wajib diisi';
                          final c = int.tryParse(val);
                          if (c == null || c <= 0)
                            return 'Tidak valid';
                          return null;
                        }),
                  ),
                ]),
                const SizedBox(height: 16),

                _buildField(
                    ctrl: _tipeEngineController,
                    label: 'TIPE ENGINE',
                    hint: 'Contoh: Rolls-Royce Trent XWB',
                    icon: Icons.settings_rounded,
                    isDark: isDark),
                const SizedBox(height: 16),

                _buildField(
                    ctrl: _maxRangeController,
                    label: 'MAX RANGE (MILES)',
                    hint: 'Contoh: 9000',
                    icon: Icons.route_rounded,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Wajib diisi';
                      final r = int.tryParse(val);
                      if (r == null || r <= 0) return 'Range tidak valid';
                      return null;
                    }),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: AppColors.black, strokeWidth: 2.5))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  _isEditing
                                      ? Icons.save_rounded
                                      : Icons.add_rounded,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _isEditing
                                    ? 'SIMPAN PERUBAHAN'
                                    : 'TAMBAH PESAWAT',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: Color(0xFF2A2A2A)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: TextStyle(
              color: isDark ? Colors.white : AppColors.black,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 16),
          ),
          validator: validator ??
              (val) {
                if (val == null || val.trim().isEmpty)
                  return '$label tidak boleh kosong';
                return null;
              },
        ),
      ],
    );
  }
}
