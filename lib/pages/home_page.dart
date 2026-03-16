import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pesawat.dart';
import '../services/supabase_service.dart';
import '../services/theme_provider.dart';
import 'form_pesawat_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Pesawat> _allPesawat = [];
  List<Pesawat> _filteredPesawat = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _loadPesawat();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredPesawat = q.isEmpty
          ? List.from(_allPesawat)
          : _allPesawat
              .where((p) =>
                  p.nama.toLowerCase().contains(q) ||
                  p.maskapai.toLowerCase().contains(q) ||
                  p.tipeEngine.toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _loadPesawat() async {
    setState(() => _isLoading = true);
    _fadeController.reset();
    try {
      final data = await SupabaseService.getPesawat();
      if (mounted) {
        setState(() {
          _allPesawat = data;
          _filteredPesawat = List.from(data);
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePesawat(Pesawat pesawat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
          SizedBox(width: 8),
          Text('Hapus Pesawat',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ]),
        content: Text('Hapus "${pesawat.nama}" dari daftar?',
            style: const TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true && pesawat.id != null) {
      try {
        await SupabaseService.deletePesawat(pesawat.id!);
        await _loadPesawat();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Pesawat berhasil dihapus'),
              backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal: $e'),
              backgroundColor: Colors.redAccent));
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar',
            style: TextStyle(color: Colors.white)),
        content: const Text('Yakin ingin keluar?',
            style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Keluar',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false);
      }
    }
  }

  // Hitung jumlah maskapai unik
  int get _uniqueMaskapai =>
      _allPesawat.map((p) => p.maskapai).toSet().length;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(isDark, themeProvider, innerBoxIsScrolled),
        ],
        body: _isLoading
            ? _buildSkeletonList(isDark)
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadPesawat,
                child: CustomScrollView(
                  slivers: [
                    // Stats banner
                    SliverToBoxAdapter(
                        child: _buildStatsBanner(isDark)),
                    // Search bar
                    SliverToBoxAdapter(
                        child: _buildSearchBar(isDark)),
                    // Results label
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          _searchController.text.isEmpty
                              ? '${_allPesawat.length} pesawat terdaftar'
                              : '${_filteredPesawat.length} hasil ditemukan',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ),
                    ),
                    // List or empty
                    _filteredPesawat.isEmpty
                        ? SliverFillRemaining(
                            child: _buildEmptyState(isDark))
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildPesawatCard(
                                    _filteredPesawat[index], isDark, index),
                              ),
                              childCount: _filteredPesawat.length,
                            ),
                          ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, a, b) => const FormPesawatPage(),
                transitionsBuilder: (_, a, b, child) => SlideTransition(
                  position: Tween(
                          begin: const Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: a, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ));
          await _loadPesawat();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Tambah',
            style:
                TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildSliverAppBar(
      bool isDark, ThemeProvider themeProvider, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: AppColors.black,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.airplanemode_active,
                  color: AppColors.black, size: 14),
            ),
            const SizedBox(width: 8),
            const Text('DAFTAR PESAWAT',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 14)),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x18FFD600)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: AppColors.primary,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded,
              color: AppColors.primary),
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildStatsBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          _statItem('${_allPesawat.length}', 'Total\nPesawat',
              Icons.airplanemode_active),
          _statDivider(),
          _statItem('$_uniqueMaskapai', 'Total\nMaskapai',
              Icons.business_rounded),
          _statDivider(),
          _statItem(
              _allPesawat.isEmpty
                  ? '-'
                  : _allPesawat.first.tahunProduksi,
              'Terbaru\nDitambah',
              Icons.access_time_rounded),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.black, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0x99000000),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
        height: 50,
        width: 1,
        color: const Color(0x33000000));
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
            color: isDark ? Colors.white : AppColors.black),
        decoration: InputDecoration(
          hintText: 'Cari pesawat, maskapai, engine...',
          hintStyle:
              const TextStyle(color: AppColors.textMuted, fontSize: 14),
          filled: true,
          fillColor:
              isDark ? AppColors.darkCard : Colors.white,
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFEEEEEE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFEEEEEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPesawatCard(Pesawat pesawat, bool isDark, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFF9F9F9),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Icon pesawat
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.airplanemode_active,
                      color: AppColors.black, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pesawat.nama,
                          style: TextStyle(
                              color:
                                  isDark ? Colors.white : AppColors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.business_rounded,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(pesawat.maskapai,
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13)),
                      ]),
                    ],
                  ),
                ),
                // Action buttons
                Column(
                  children: [
                    _iconBtn(Icons.edit_outlined, AppColors.primary,
                        const Color(0x22FFD600), () async {
                      await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a, b) =>
                                FormPesawatPage(pesawat: pesawat),
                            transitionsBuilder: (_, a, b, child) =>
                                SlideTransition(
                              position: Tween(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: a,
                                      curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                          ));
                      await _loadPesawat();
                    }),
                    const SizedBox(height: 6),
                    _iconBtn(
                        Icons.delete_outline_rounded,
                        Colors.redAccent,
                        const Color(0x22FF4444),
                        () => _deletePesawat(pesawat)),
                  ],
                ),
              ],
            ),
          ),
          // Detail section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _detailTile(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tahun Produksi',
                            value: pesawat.tahunProduksi,
                            isDark: isDark)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _detailTile(
                            icon: Icons.people_rounded,
                            label: 'Kapasitas',
                            value: '${pesawat.kapasitasPenumpang} pax',
                            isDark: isDark)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _detailTile(
                            icon: Icons.settings_rounded,
                            label: 'Tipe Engine',
                            value: pesawat.tipeEngine,
                            isDark: isDark)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _detailTile(
                            icon: Icons.route_rounded,
                            label: 'Max Range',
                            value: '${pesawat.maxRange} mi',
                            isDark: isDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF222222)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0x22FFD600),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                Text(value,
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C1C)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.airplanemode_inactive,
                size: 52, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isEmpty
                ? 'Belum ada pesawat'
                : 'Tidak ada hasil',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _searchController.text.isEmpty
                ? 'Tekan tombol + untuk menambahkan'
                : 'Coba kata kunci lain',
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Skeleton loading
  Widget _buildSkeletonList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) => _buildSkeletonCard(isDark),
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    final shimmer =
        isDark ? const Color(0xFF1C1C1C) : const Color(0xFFEEEEEE);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Row(children: [
          Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(14))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 14,
                      width: 140,
                      decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  Container(
                      height: 10,
                      width: 90,
                      decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(6))),
                ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(width: 10),
          Expanded(
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(12)))),
        ]),
      ]),
    );
  }
}
