class Reminder {
  final String id;
  final String medicineName;
  final String time;
  final String
      repeatType; // 'never', 'everyday', 'weekdays', 'weekends', 'custom'
  final List<int>? customDays; // 0=Monday, 1=Tuesday, ..., 6=Sunday
  final String? photoPath; // Path to medicine photo
  final bool isAfterMeal; // true = 食後, false = 食前/any time
  bool isEnabled;

  Reminder({
    required this.id,
    required this.medicineName,
    required this.time,
    this.repeatType = 'never',
    this.customDays,
    this.photoPath,
    this.isAfterMeal = false,
    this.isEnabled = true,
  });

  String getRepeatText() {
    switch (repeatType) {
      case 'everyday':
        return '毎日';
      case 'weekdays':
        return '平日のみ';
      case 'weekends':
        return '週末のみ';
      case 'custom':
        if (customDays == null || customDays!.isEmpty) return '繰り返しなし';
        final dayNames = ['月', '火', '水', '木', '金', '土', '日'];
        final days = customDays!.map((i) => dayNames[i]).join('、');
        return '毎週 $days';
      case 'never':
      default:
        return '繰り返しなし';
    }
  }

  String getMealTimingText() {
    return isAfterMeal ? '食後' : '';
  }
}
