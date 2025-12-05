import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../widgets/reminder_card.dart';
import 'add_reminder_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reminder> reminders = [];

  void _addReminder(Reminder reminder) {
    setState(() {
      reminders.add(reminder);
    });
  }

  void _deleteReminder(String id) {
    setState(() {
      reminders.removeWhere((reminder) => reminder.id == id);
    });
  }

  void _toggleReminder(String id) {
    setState(() {
      final index = reminders.indexWhere((reminder) => reminder.id == id);
      if (index != -1) {
        reminders[index].isEnabled = !reminders[index].isEnabled;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFC8E6C9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Icon(
                        Icons.medication_outlined,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    const Text(
                      'お薬リマインダー',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    const Text(
                      'お薬の飲み忘れを防ぎます',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF66BB6A),
                      ),
                    ),
                  ],
                ),
              ),

              // Reminder List
              Expanded(
                child: reminders.isEmpty
                    ? _buildEmptyState()
                    : _buildReminderList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newReminder = await showModalBottomSheet<Reminder>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddReminderScreen(),
          );
          if (newReminder != null) {
            _addReminder(newReminder);
          }
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pill icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF9A56)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.medication,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'リマインダーがありません',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF66BB6A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '+ ボタンでリマインダーを追加',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF81C784),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        return ReminderCard(
          reminder: reminders[index],
          onToggle: () => _toggleReminder(reminders[index].id),
          onDelete: () => _deleteReminder(reminders[index].id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationScreen(
                  reminder: reminders[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
