// note_model.dart
class Note {
  final int? id; // ID bisa null jika catatan belum disimpan ke Supabase
  final String title;
  final String? content; // Konten bisa null
  final DateTime createdAt;
  final String? userId; // Untuk menyimpan user_id jika menggunakan RLS

  Note({
    this.id,
    required this.title,
    this.content,
    required this.createdAt,
    this.userId,
  });

  // Konversi dari Map (data JSON dari Supabase) ke objek Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String?,
    );
  }

  // Konversi dari objek Note ke Map (untuk dikirim ke Supabase)
  Map<String, dynamic> toMap() {
    return {
      // 'id' tidak disertakan karena biasanya auto-increment atau di-handle Supabase
      'title': title,
      'content': content,
      // 'created_at' biasanya di-handle oleh Supabase (default value now())
      // 'user_id' akan diisi otomatis jika RLS diaktifkan dan user login
    };
  }
}
