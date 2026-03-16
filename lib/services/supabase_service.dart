import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pesawat.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // AUTH
  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => _client.auth.currentUser?.id;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // CRUD PESAWAT
  static Future<List<Pesawat>> getPesawat() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('pesawat')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Pesawat.fromJson(e)).toList();
  }

  static Future<void> addPesawat(Pesawat pesawat) async {
    await _client.from('pesawat').insert(pesawat.toJson());
  }

  static Future<void> updatePesawat(String id, Pesawat pesawat) async {
    await _client.from('pesawat').update(pesawat.toJson()).eq('id', id);
  }

  static Future<void> deletePesawat(String id) async {
    await _client.from('pesawat').delete().eq('id', id);
  }
}
