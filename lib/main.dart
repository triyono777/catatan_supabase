// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'note_list_page.dart';
import 'note_model.dart';
import 'supabase_service.dart';

// TODO: Ganti dengan URL dan Anon Key Supabase Anda
const String supabaseUrl = 'https://dkpqmldazfdaazawojsi.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrcHFtbGRhemZkYWF6YXdvanNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg0MDUzMjQsImV4cCI6MjA2Mzk4MTMyNH0.PJMPyHFuR0mOBbA-yHkt9OY7Hxl71yQhimiIUBwceA8';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Pribadi',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      home: const NoteListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
