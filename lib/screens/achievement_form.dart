import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/achievement.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class AchievementFormPage extends StatefulWidget {
  const AchievementFormPage({super.key});

  @override
  State<AchievementFormPage> createState() => _AchievementFormPageState();
}

class _AchievementFormPageState extends State<AchievementFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _issuer = "";
  String _year = "";
  String _description = "";
  bool _isSubmitting = false;

  // Batas panjang mengikuti CharField(max_length=255) pada model Django.
  static const int _maxTextLength = 255;

  String? _validateRequiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName tidak boleh kosong!";
    }
    if (value.trim().length > _maxTextLength) {
      return "$fieldName maksimal $_maxTextLength karakter!";
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Tahun tidak boleh kosong!";
    }
    final year = int.tryParse(value.trim());
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear) {
      return "Tahun harus antara 1900 dan $currentYear!";
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Dependensi diambil sebelum await agar context tidak dipakai setelah
    // jeda async.
    final apiClient = context.read<ApiClient>();
    final authState = context.read<AuthState>();

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final newAchievement = Achievement(
      name: _name.trim(),
      issuer: _issuer.trim(),
      year: int.parse(_year.trim()),
      description: _description.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });

    Achievement? created;
    try {
      created = await apiClient.createAchievement(
        newAchievement,
        token: authState.token!,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token tidak berlaku lagi: hapus sesi lokal lalu minta login ulang.
        await authState.logout();
        if (!mounted) return;
        _showSnackBar('Sesi berakhir, silakan login kembali.');
        await ensureLoggedIn(context);
      } else if (e.statusCode == 403) {
        _showSnackBar(
          'Hanya pemilik portofolio (superuser) yang bisa menambah achievement.',
        );
      } else {
        _showSnackBar('Gagal menyimpan: ${e.friendlyMessage}');
      }
    } on http.ClientException {
      if (!mounted) return;
      _showSnackBar('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    // Dialog ditampilkan setelah _isSubmitting dimatikan, agar spinner tombol
    // Save tidak terus berputar di belakang dialog.
    if (created != null && mounted) await _showSuccessDialog(created);
  }

  Future<void> _showSuccessDialog(Achievement created) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Achievement berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${created.name}'),
                Text('Penyelenggara: ${created.issuer}'),
                Text('Tahun: ${created.year}'),
                Text(
                  'Deskripsi: '
                  '${created.description.isEmpty ? '-' : created.description}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
                _name = "";
                _issuer = "";
                _year = "";
                _description = "";
              },
            ),
          ],
        );
      },
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      hintText: hint ?? label,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Achievement Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === Name ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    "Nama Achievement",
                    hint: "Contoh: Juara 1 Hackathon",
                  ),
                  onChanged: (value) => _name = value,
                  validator: (value) =>
                      _validateRequiredText(value, "Nama achievement"),
                ),
              ),

              // === Issuer ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    "Penyelenggara",
                    hint: "Contoh: Fasilkom UI",
                  ),
                  onChanged: (value) => _issuer = value,
                  validator: (value) =>
                      _validateRequiredText(value, "Penyelenggara"),
                ),
              ),

              // === Year ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: _decoration("Tahun", hint: "Contoh: 2026"),
                  onChanged: (value) => _year = value,
                  validator: _validateYear,
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: _decoration("Deskripsi (opsional)"),
                  onChanged: (value) => _description = value,
                ),
              ),

              // === Tombol Simpan ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
