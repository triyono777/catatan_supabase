import 'package:catatan_supabase/login_page.dart';
import 'package:catatan_supabase/note_list_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Halaman Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Tunggu sebentar untuk simulasi loading atau inisialisasi
    await Future.delayed(const Duration(seconds: 2));

    // Mendengarkan perubahan status autentikasi Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.initialSession ||
          event == AuthChangeEvent.signedIn) {
        if (session != null) {
          // Jika ada sesi aktif, navigasi ke halaman utama
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteListPage(),
            ),
          );
        } else {
          // Jika tidak ada sesi, navigasi ke halaman login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // Jika pengguna logout, navigasi ke halaman login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat sesi...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
