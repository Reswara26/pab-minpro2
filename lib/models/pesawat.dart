class Pesawat {
  final String? id;
  final String nama;
  final String maskapai;
  final String tahunProduksi;
  final String tipeEngine;
  final String kapasitasPenumpang;
  final String maxRange;
  final String userId;

  Pesawat({
    this.id,
    required this.nama,
    required this.maskapai,
    required this.tahunProduksi,
    required this.tipeEngine,
    required this.kapasitasPenumpang,
    required this.maxRange,
    required this.userId,
  });

  factory Pesawat.fromJson(Map<String, dynamic> json) {
    return Pesawat(
      id: json['id']?.toString(),
      nama: json['nama'] ?? '',
      maskapai: json['maskapai'] ?? '',
      tahunProduksi: json['tahun_produksi']?.toString() ?? '',
      tipeEngine: json['tipe_engine'] ?? '',
      kapasitasPenumpang: json['kapasitas_penumpang']?.toString() ?? '',
      maxRange: json['max_range']?.toString() ?? '',
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'maskapai': maskapai,
      'tahun_produksi': tahunProduksi,
      'tipe_engine': tipeEngine,
      'kapasitas_penumpang': kapasitasPenumpang,
      'max_range': maxRange,
      'user_id': userId,
    };
  }
}
