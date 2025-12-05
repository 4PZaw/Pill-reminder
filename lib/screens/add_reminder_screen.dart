import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({Key? key}) : super(key: key);

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _medicineController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedRepeat = 'never';
  List<int> _selectedDays = [];
  String? _photoPath;
  bool _isAfterMeal = false;

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveReminder() {
    if (_medicineController.text.trim().isEmpty) {
      return;
    }

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineName: _medicineController.text.trim(),
      time: _selectedTime.format(context),
      repeatType: _selectedRepeat,
      customDays: _selectedRepeat == 'custom' ? _selectedDays : null,
      photoPath: _photoPath,
      isAfterMeal: _isAfterMeal,
    );

    Navigator.pop(context, reminder);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photoPath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('写真の取得に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '写真を追加',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: Colors.green, size: 28),
              title: const Text(
                'カメラで撮影',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Colors.blue, size: 28),
              title: const Text(
                'ギャラリーから選択',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red, size: 28),
                title: const Text(
                  '写真を削除',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photoPath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRepeatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: _buildRepeatOptionsSheet(),
      ),
    );
  }

  Widget _buildRepeatOptionsSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '繰り返し設定',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 20),
                _buildRepeatOption('繰り返しなし', 'never', setModalState),
                _buildRepeatOption('毎日', 'everyday', setModalState),
                _buildRepeatOption('平日のみ', 'weekdays', setModalState),
                _buildRepeatOption('週末のみ', 'weekends', setModalState),
                _buildRepeatOption('カスタム...', 'custom', setModalState),
                if (_selectedRepeat == 'custom') ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDaySelector(setModalState),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Update main state
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '完了',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRepeatOption(
      String label, String value, StateSetter setModalState) {
    final isSelected = _selectedRepeat == value;
    return InkWell(
      onTap: () {
        setModalState(() {
          _selectedRepeat = value;
          if (value == 'weekdays') {
            _selectedDays = [0, 1, 2, 3, 4]; // Mon-Fri
          } else if (value == 'weekends') {
            _selectedDays = [5, 6]; // Sat-Sun
          } else if (value != 'custom') {
            _selectedDays = [];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(StateSetter setModalState) {
    final dayNames = ['月', '火', '水', '木', '金', '土', '日'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '曜日を選択',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF66BB6A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index);
            return InkWell(
              onTap: () {
                setModalState(() {
                  if (isSelected) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                  _selectedDays.sort();
                });
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getRepeatText() {
    switch (_selectedRepeat) {
      case 'everyday':
        return '毎日';
      case 'weekdays':
        return '平日のみ';
      case 'weekends':
        return '週末のみ';
      case 'custom':
        if (_selectedDays.isEmpty) return '曜日を選択';
        final dayNames = ['月', '火', '水', '木', '金', '土', '日'];
        final days = _selectedDays.map((i) => dayNames[i]).join('、');
        return '毎週 $days';
      case 'never':
      default:
        return '繰り返しなし';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'リマインダーを追加',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Medicine name input
              Row(
                children: [
                  const Icon(Icons.medication, color: Colors.pink, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'お薬の名前',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _medicineController,
                decoration: InputDecoration(
                  hintText: '例: ビタミンC、アスピリン',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFE8F5E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Photo section
              Row(
                children: [
                  const Icon(Icons.camera_alt, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'お薬の写真',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '(任意)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _photoPath != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_photoPath!),
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.green, size: 20),
                                  onPressed: _showImageSourceDialog,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Colors.green.shade300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '写真を追加',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Time input
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '時間',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Repeat input
              Row(
                children: [
                  const Icon(Icons.repeat, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '繰り返し',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _showRepeatOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getRepeatText(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Meal timing checkbox
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAfterMeal,
                      onChanged: (value) {
                        setState(() {
                          _isAfterMeal = value ?? false;
                        });
                      },
                      activeColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '食後のお薬',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'アラーム時に食事確認をします',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.green, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '追加',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
