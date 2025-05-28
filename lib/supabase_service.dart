// supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart'; // Sudah diimport di main.dart
import 'main.dart';
import 'note_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Nama tabel di Supabase
  static const String notesTable =
      'notes'; // Ganti jika nama tabel Anda berbeda

  // Membuat catatan baru
  Future<void> createNote({required String title, String? content}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null && supabaseUrl != 'MASUKKAN_URL_SUPABASE_ANDA_DISINI') {
      // Cek juga agar tidak error saat placeholder belum diganti
      // Handle jika user tidak login, tergantung kebijakan aplikasi
      // Bisa throw error, atau simpan tanpa user_id jika tabel memperbolehkan
      // Untuk contoh ini, kita asumsikan user_id opsional atau RLS tidak ketat
      // print('User tidak login, catatan disimpan tanpa user_id');
    }

    final noteData = {
      'title': title,
      'content': content,
      'user_id':
          userId, // Uncomment jika Anda ingin mengaitkan catatan dengan pengguna
      // 'created_at' akan diisi otomatis oleh Supabase jika di-set default value now()
    };

    try {
      await _client.from(notesTable).insert(noteData);
    } catch (e) {
      // print('Error creating note: $e');
      // Anda bisa menambahkan logging atau menampilkan pesan error ke pengguna di sini
      // Misalnya, dengan menggunakan Fluttertoast atau SnackBar
      // throw Exception('Gagal membuat catatan: $e');
      rethrow; // Melempar kembali error agar bisa ditangani di UI
    }
  }

  // Mendapatkan semua catatan
  Future<List<Note>> getNotes() async {
    try {
      final response = await _client
          .from(notesTable)
          .select()
          .order('created_at', ascending: false); // Urutkan berdasarkan terbaru

      // print('Response from Supabase: $response'); // Untuk debugging

      if (response == null) {
        // print('No data received from Supabase or error occurred.');
        return []; // Kembalikan list kosong jika tidak ada data atau error
      }

      // Data dari Supabase adalah List<Map<String, dynamic>>
      // Casting eksplisit diperlukan
      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((item) => Note.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // print('Error fetching notes: $e');
      // throw Exception('Gagal mengambil catatan: $e');
      rethrow;
    }
  }

  // Memperbarui catatan
  Future<void> updateNote(
      {required int id, required String title, String? content}) async {
    final noteData = {
      'title': title,
      'content': content,
      // 'updated_at': DateTime.now().toIso8601String(), // Supabase bisa handle ini otomatis
    };
    try {
      await _client.from(notesTable).update(noteData).eq('id', id);
    } catch (e) {
      // print('Error updating note: $e');
      // throw Exception('Gagal memperbarui catatan: $e');
      rethrow;
    }
  }

  // Menghapus catatan
  Future<void> deleteNote(int id) async {
    try {
      await _client.from(notesTable).delete().eq('id', id);
    } catch (e) {
      // print('Error deleting note: $e');
      // throw Exception('Gagal menghapus catatan: $e');
      rethrow;
    }
  }
}
