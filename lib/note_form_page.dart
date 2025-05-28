import 'package:flutter/material.dart';

import 'note_model.dart';
import 'supabase_service.dart';

class NoteFormPage extends StatefulWidget {
  final Note? note; // Jika null, berarti membuat catatan baru

  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final title = _titleController.text;
        final content = _contentController.text;

        if (widget.note == null) {
          // Buat catatan baru
          await _supabaseService.createNote(title: title, content: content);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Catatan berhasil disimpan!'),
                  backgroundColor: Colors.green),
            );
          }
        } else {
          // Update catatan yang ada
          await _supabaseService.updateNote(
              id: widget.note!.id!, title: title, content: content);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Catatan berhasil diperbarui!'),
                  backgroundColor: Colors.green),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context, true); // Kembali dan indikasikan ada perubahan
        }
      } catch (e) {
        if (mounted) {
          print('Error saving note: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menyimpan catatan: ${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.note == null ? 'Tambah Catatan Baru' : 'Edit Catatan'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: 'Simpan Catatan',
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Menggunakan ListView agar bisa scroll jika konten panjang
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Catatan',
                  hintText: 'Masukkan judul catatan Anda',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  hintText: 'Tulis isi catatan Anda di sini...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint:
                      true, // Agar label sejajar dengan hint saat multiline
                ),
                maxLines: 10, // Izinkan beberapa baris untuk isi catatan
                minLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction:
                    TextInputAction.newline, // Atau TextInputAction.done
                validator: (value) {
                  // Isi boleh kosong jika diinginkan
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(
                      widget.note == null
                          ? 'Simpan Catatan'
                          : 'Perbarui Catatan',
                      style: const TextStyle(fontSize: 16)),
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
