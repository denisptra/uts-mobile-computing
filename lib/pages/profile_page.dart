import 'package:flutter/material.dart';
import '../models/student.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Fungsi helper untuk menampilkan Dialog Konfirmasi Hapus (Modal Pertanyaan)
  // Konsepnya mirip dialog window.confirm() di JavaScript
  void _showDeleteConfirmation(BuildContext context, String name) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mengharuskan pengguna untuk memilih opsi
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus data $name dari daftar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Menutup modal dialog (Batal)
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Menutup dialog konfirmasi
                Navigator.pop(context, 'delete'); // Mengembalikan hasil 'delete' ke Halaman Home
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Membaca arguments yang dikirim dari Home Page (seperti props di JS)
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Data profil tidak ditemukan.')),
      );
    }

    final student = arguments['student'] as Student;
    final totalStudents = arguments['totalStudents'] as int;

    // Tombol hapus dinonaktifkan jika jumlah mahasiswa saat ini <= 3 (syarat UTS)
    final bool isDeleteDisabled = totalStudents <= 3;

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Foto Profil Lingkaran dengan border tipis
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[200]!, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(student.avatar),
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nama Lengkap Mahasiswa
            Text(
              student.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Subtitle Domisili
            Text(
              'Mahasiswa dari ${student.domisili}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // DETAIL INFORMASI (TAMPILAN LIST DATAR / FLAT DENGAN DIVIDER)
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined, color: Colors.black54),
              title: const Text('Kota Asal', style: TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text(
                student.domisili,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_outlined, color: Colors.black54),
              title: const Text('Nomor HP', style: TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text(
                student.phone,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 48),

            // TOMBOL HAPUS AKUN INI (OUTLINE MERAH FLAT)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isDeleteDisabled
                    ? null
                    : () => _showDeleteConfirmation(context, student.name), // Panggil modal pertanyaan
                icon: const Icon(Icons.delete_outline),
                label: const Text(
                  'Hapus Akun Ini',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  disabledForegroundColor: Colors.grey[400],
                  side: BorderSide(
                    color: isDeleteDisabled ? Colors.grey[200]! : Colors.red,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Keterangan jika tombol hapus dinonaktifkan
            if (isDeleteDisabled)
              Text(
                'Tidak bisa menghapus karena batas minimal adalah 3 mahasiswa.',
                style: TextStyle(color: Colors.red[400], fontSize: 11),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
