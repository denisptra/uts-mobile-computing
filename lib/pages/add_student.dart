import 'package:flutter/material.dart';
import 'dart:math';
import '../models/student.dart';
import '../data/app_data.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  // Key untuk form validasi
  final _formKey = GlobalKey<FormState>();

  // Controller input (seperti mengambil value dari selector input di JS)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // State untuk form
  late String _selectedAvatar;
  String _selectedDomisili = domisiliList[0];
  bool _isConsentChecked = false;

  @override
  void initState() {
    super.initState();
    // Memilih avatar acak secara otomatis ketika form dibuka (syarat UTS)
    _selectedAvatar = avatarList[Random().nextInt(avatarList.length)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Aksi simpan data mahasiswa baru
  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final newStudent = Student(
        name: _nameController.text.trim(),
        avatar: _selectedAvatar,
        domisili: _selectedDomisili,
        phone: _phoneController.text.trim(),
      );
      Navigator.pop(context, newStudent); // Kembalikan data baru ke Halaman Home
    }
  }

  // Fungsi helper dekorasi input agar kode ringkas & seragam
  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[50], // Background abu-abu tipis
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih agar serasi
      appBar: AppBar(
        title: const Text('Tambah Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // PREVIEW AVATAR DENGAN BORDER TIPIS (Sama seperti Halaman Profil)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_selectedAvatar),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // INPUT NAMA
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nama Lengkap *', Icons.person_outline),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // INPUT DOMISILI (DROPDOWN)
              DropdownButtonFormField<String>(
                value: _selectedDomisili,
                decoration: _inputDecoration('Kota Asal / Domisili', Icons.location_on_outlined),
                items: domisiliList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDomisili = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // INPUT NOMOR HP (KEYBOARD ANGKA)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number, // Memunculkan keyboard angka saja (syarat UTS)
                decoration: _inputDecoration('Nomor HP *', Icons.phone_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor HP tidak boleh kosong';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Nomor HP hanya boleh berisi angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // CHECKBOX PERSETUJUAN (CONSENT)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isConsentChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isConsentChecked = newValue ?? false;
                      });
                    },
                    activeColor: Colors.indigo,
                  ),
                  const Expanded(
                    child: Text(
                      'Saya menyatakan bahwa data yang saya masukkan adalah benar.',
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // TOMBOL SIMPAN (FLAT INDIGO)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConsentChecked ? _submitData : null, // Disabled jika belum dicentang
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    disabledBackgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0, // Flat tanpa bayangan tebal
                  ),
                  child: Text(
                    'Simpan Mahasiswa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _isConsentChecked ? Colors.white : Colors.grey[400],
                    ),
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
