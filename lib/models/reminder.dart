class Reminder {
  final String id;
  final String medicineName;
  final String time;
  final String
      repeatType; // 'never', 'everyday', 'weekdays', 'weekends', 'custom'
  final List<int>? customDays; // 0=Monday, 1=Tuesday, ..., 6=Sunday
  final String? photoPath; // Path to medicine photo
  final String mealTiming; // 'none', 'before' (食前), 'after' (食後)
  final int dosesPerDay; // Number of times per day: 1, 2, 3, or 4
  final List<String>
      doseTimes; // Times for each dose: ['08:00', '12:00', '18:00']
  List<bool>
      takenToday; // Track if each dose is taken today: [true, false, false]
  bool isEnabled;

  Reminder({
    required this.id,
    required this.medicineName,
    required this.time,
    this.repeatType = 'never',
    this.customDays,
    this.photoPath,
    this.mealTiming = 'none',
    this.dosesPerDay = 1,
    List<String>? doseTimes,
    List<bool>? takenToday,
    this.isEnabled = true,
  })  : doseTimes = doseTimes ?? [time],
        takenToday = takenToday ?? List.filled(dosesPerDay, false);

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
    switch (mealTiming) {
      case 'before':
        return '食前';
      case 'after':
        return '食後';
      default:
        return '';
    }
  }

  bool get isAfterMeal => mealTiming == 'after';
  bool get isBeforeMeal => mealTiming == 'before';

  // Get completion status
  int get takenCount => takenToday.where((taken) => taken).length;
  String get completionText => '$takenCount/$dosesPerDay';
  double get completionPercentage => takenCount / dosesPerDay;

  // Get dose time label
  String getDoseLabel(int index) {
    if (dosesPerDay == 1) return '';
    if (dosesPerDay == 2) return index == 0 ? '朝' : '夜';
    if (dosesPerDay == 3) return ['朝', '昼', '夜'][index];
    if (dosesPerDay == 4) return ['朝', '昼', '夕', '夜'][index];
    return '${index + 1}回目';
  }
}
