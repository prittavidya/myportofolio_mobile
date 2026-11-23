import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller hanya dipakai untuk field tanggal, karena isinya diisi dari
  // date picker, bukan diketik langsung oleh pengguna.
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Nilai awal mengikuti default pada model Experience di Django.
  static const String _defaultCategory = 'full-time';

  String _title = "";
  String _description = "";
  String _category = _defaultCategory;
  String _thumbnail = "";
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isOngoing = false;

  // Sama dengan EXPERIENCE_CHOICES pada model Django: value -> label.
  static const Map<String, String> _categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      MaterialLocalizations.of(context).formatMediumDate(date);

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startedAt : _endedAt) ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startedAt = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endedAt = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _title = "";
      _description = "";
      _category = _defaultCategory;
      _thumbnail = "";
      _startedAt = null;
      _endedAt = null;
      _isOngoing = false;
    });
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName tidak boleh kosong!";
    }
    return null;
  }

  String? _validateTitle(String? value) {
    final requiredError = _validateRequired(value, "Judul pengalaman");
    if (requiredError != null) return requiredError;
    if (value!.trim().length > 255) {
      return "Judul pengalaman maksimal 255 karakter!";
    }
    return null;
  }

  String? _validateThumbnail(String? value) {
    // Thumbnail bersifat opsional (blank=True pada model).
    if (value == null || value.trim().isEmpty) return null;

    final uri = Uri.tryParse(value.trim());
    final isValid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) {
      return "Masukkan URL yang valid (diawali http:// atau https://)!";
    }
    return null;
  }

  String? _validateStartDate(String? _) {
    if (_startedAt == null) return "Tanggal mulai wajib dipilih!";
    return null;
  }

  String? _validateEndDate(String? _) {
    // ended_at bernilai null berarti pengalaman masih berlangsung.
    if (_isOngoing) return null;
    if (_endedAt == null) {
      return "Pilih tanggal selesai atau centang \"Masih berlangsung\"!";
    }
    if (_startedAt != null && _endedAt!.isBefore(_startedAt!)) {
      return "Tanggal selesai tidak boleh sebelum tanggal mulai!";
    }
    return null;
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengalaman berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryLine('Judul', _title.trim()),
                _summaryLine('Deskripsi', _description.trim()),
                _summaryLine('Kategori', _categories[_category]!),
                _summaryLine(
                  'Thumbnail',
                  _thumbnail.trim().isEmpty ? '-' : _thumbnail.trim(),
                ),
                _summaryLine('Tanggal Mulai', _formatDate(_startedAt!)),
                _summaryLine(
                  'Tanggal Selesai',
                  _isOngoing ? 'Masih berlangsung' : _formatDate(_endedAt!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _summaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView menjaga seluruh field dan tombol Simpan tetap
        // bisa dijangkau di layar sempit atau saat keyboard muncul.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === Title ===
              TextFormField(
                maxLength: 255,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                  "Judul Pengalaman",
                  hint: "Contoh: Software Engineer Intern",
                ),
                onChanged: (String value) {
                  setState(() {
                    _title = value;
                  });
                },
                validator: _validateTitle,
              ),
              const SizedBox(height: 8.0),

              // === Description ===
              TextFormField(
                minLines: 3,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: _decoration(
                  "Deskripsi",
                  hint: "Ceritakan peran dan kontribusimu",
                ),
                onChanged: (String value) {
                  setState(() {
                    _description = value;
                  });
                },
                validator: (value) => _validateRequired(value, "Deskripsi"),
              ),
              const SizedBox(height: 16.0),

              // === Category ===
              DropdownButtonFormField<String>(
                decoration: _decoration("Kategori"),
                initialValue: _category,
                items: _categories.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // === Thumbnail ===
              TextFormField(
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                decoration: _decoration(
                  "URL Thumbnail (opsional)",
                  hint: "https://example.com/gambar.png",
                ),
                onChanged: (String value) {
                  setState(() {
                    _thumbnail = value;
                  });
                },
                validator: _validateThumbnail,
              ),
              const SizedBox(height: 16.0),

              // === Started At ===
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: _decoration(
                  "Tanggal Mulai",
                  hint: "Pilih tanggal",
                  suffix: const Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(isStart: true),
                validator: _validateStartDate,
              ),
              const SizedBox(height: 8.0),

              // === Ongoing ===
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Masih berlangsung'),
                value: _isOngoing,
                onChanged: (bool? value) {
                  setState(() {
                    _isOngoing = value ?? false;
                    if (_isOngoing) {
                      _endedAt = null;
                      _endDateController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 8.0),

              // === Ended At ===
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                enabled: !_isOngoing,
                decoration: _decoration(
                  "Tanggal Selesai",
                  hint: "Pilih tanggal",
                  suffix: const Icon(Icons.event),
                ),
                onTap: () => _pickDate(isStart: false),
                validator: _validateEndDate,
              ),
              const SizedBox(height: 24.0),

              // === Tombol Simpan ===
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showSummaryDialog();
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
