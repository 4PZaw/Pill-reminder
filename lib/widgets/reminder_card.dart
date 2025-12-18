import 'package:flutter/material.dart';
import 'dart:io';
import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit; // Added edit callback

  const ReminderCard({
    Key? key,
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    required this.onEdit, // Required edit parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Toggle switch
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: reminder.isEnabled,
                    onChanged: (_) => onToggle(),
                    activeColor: Colors.green,
                    activeTrackColor: Colors.green.withOpacity(0.5),
                  ),
                ),

                const SizedBox(width: 8),

                // Pill icon or photo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: reminder.photoPath == null
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B9D), Color(0xFFFF9A56)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    image: reminder.photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(reminder.photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: reminder.photoPath == null
                      ? const Icon(
                          Icons.medication,
                          color: Colors.white,
                          size: 28,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Medicine info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicineName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: reminder.isEnabled
                              ? const Color(0xFF2E7D32)
                              : Colors.grey,
                          decoration: reminder.isEnabled
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: reminder.isEnabled
                                ? const Color(0xFF66BB6A)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '午前${reminder.time}',
                              style: TextStyle(
                                fontSize: 14,
                                color: reminder.isEnabled
                                    ? const Color(0xFF66BB6A)
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (reminder.repeatType != 'never') ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 14,
                              color: reminder.isEnabled
                                  ? Colors.blue.shade300
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                reminder.getRepeatText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: reminder.isEnabled
                                      ? Colors.blue.shade300
                                      : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (reminder.mealTiming != 'none') ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              reminder.isBeforeMeal
                                  ? Icons.restaurant_menu
                                  : Icons.restaurant,
                              size: 14,
                              color: reminder.isEnabled
                                  ? Colors.orange.shade400
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.getMealTimingText(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: reminder.isEnabled
                                    ? Colors.orange.shade600
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bell icon
                    IconButton(
                      onPressed: onTap,
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.orange,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),

                    // Edit icon - Now functional!
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.green,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),

                    // Delete icon
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
