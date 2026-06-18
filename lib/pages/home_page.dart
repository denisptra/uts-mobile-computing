import 'package:flutter/material.dart';
import '../models/student.dart';
import '../data/app_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Array untuk menampung data mahasiswa
  late List<Student> _students;

  @override
  void initState() {
    super.initState();
    // Membaca data awal mahasiswa saat pertama kali dibuka
    _students = initialStudentsData.map((data) => Student.fromMap(data)).toList();
  }

  // Fungsi berpindah ke halaman Tambah Mahasiswa
  Future<void> _navigateToAddStudent() async {
    final result = await Navigator.pushNamed(context, '/add');

    if (result != null && result is Student) {
      setState(() {
        _students.add(result); // Menambah mahasiswa baru ke list
      });
    }
  }

  // Fungsi berpindah ke halaman Profile
  Future<void> _navigateToProfile(Student student) async {
    final result = await Navigator.pushNamed(
      context,
      '/profile',
      arguments: {
        'student': student,
        'totalStudents': _students.length, // Mengirimkan total data mahasiswa
      },
    );

    // Hapus dari list jika aksi yang dikembalikan adalah 'delete'
    if (result == 'delete') {
      setState(() {
        _students.remove(student);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih khas Gopay
      body: Column(
        children: [
          // HEADER GRADIENT: Full screen atas (melewati status bar)
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF009688), Color(0xFF3F51B5)], // Perpaduan warna Teal & Indigo
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Directory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_students.length} Mahasiswa terdaftar',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // LIST MAHASISWA VERTIKAL (Menyusun ke bawah ala Gopay)
          Expanded(
            child: _students.isEmpty
                ? const Center(child: Text('Tidak ada mahasiswa.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          // Border tipis dengan shadow yang sangat tipis agar terlihat flat & rapi
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          // Avatar berbentuk lingkaran tanpa tulisan inisial huruf
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(student.avatar),
                            backgroundColor: Colors.grey[200],
                          ),
                          title: Text(
                            student.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            student.domisili,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          // Ikon panah penunjuk detail di kanan tile
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onTap: () => _navigateToProfile(student), // Klik baris membuka Profile
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Tombol Tambah Mahasiswa (FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStudent,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
