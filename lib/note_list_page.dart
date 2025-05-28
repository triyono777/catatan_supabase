import 'package:flutter/material.dart';

import 'note_form_page.dart';
import 'note_model.dart';
import 'supabase_service.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Note>> _notesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notesFuture = _supabaseService.getNotes();
    });
  }

  void _navigateToNoteForm({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormPage(note: note),
      ),
    );

    if (result == true) {
      _loadNotes(); // Muat ulang catatan jika ada perubahan
    }
  }

  void _deleteNote(int id) async {
    // Tampilkan dialog konfirmasi sebelum menghapus
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content:
                  const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Hapus'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Default ke false jika dialog ditutup tanpa pilihan

    if (confirmDelete) {
      try {
        await _supabaseService.deleteNote(id);
        _loadNotes(); // Muat ulang setelah berhasil menghapus
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus catatan: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Pribadi Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
            tooltip: 'Muat Ulang Catatan',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada catatan.',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Ketuk tombol + untuk membuat catatan baru.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final notes = snapshot.data!
                    .where((note) =>
                        note.title.toLowerCase().contains(_searchQuery) ||
                        (note.content?.toLowerCase().contains(_searchQuery) ??
                            false))
                    .toList();

                if (notes.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada catatan yang cocok dengan "$_searchQuery".',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (notes.isEmpty &&
                    _searchQuery.isEmpty &&
                    snapshot.data!.isNotEmpty) {
                  // This case should ideally not be hit if snapshot.data is not empty,
                  // but as a fallback or if filtering results in empty for other reasons.
                  return const Center(
                    child: Text(
                      'Tidak ada catatan ditemukan.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          note.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          note.content ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToNoteForm(note: note);
                            } else if (value == 'delete') {
                              _deleteNote(note.id!);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit')),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Hapus',
                                      style: TextStyle(color: Colors.red))),
                            ),
                          ],
                        ),
                        onTap: () {
                          _navigateToNoteForm(
                              note: note); // Atau tampilkan detail
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNoteForm(),
        tooltip: 'Tambah Catatan Baru',
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
