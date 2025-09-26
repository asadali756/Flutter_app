import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class Tasks extends StatefulWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  List<Map<String, dynamic>> tasks = [
    {
      "title": "PickUp Waste",
      "date": "12",
      "done": false,
      "rejected": false, // ✅ initialized
    },
  ];

  void markTaskAsDone(int index) {
    setState(() {
      tasks[index]['done'] = true;
      tasks[index]['rejected'] = false;
    });
  }

  void rejectTask(int index) {
    setState(() {
      tasks[index]['rejected'] = true;
      tasks[index]['done'] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          /// Task Table
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pending Task List",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.peach,
                  ),
                ),
                const SizedBox(height: 12),
                ...tasks.asMap().entries.map((entry) {
                  int index = entry.key;
                  var task = entry.value;

                  /// ✅ Safe bool checks (avoid null crash)
                  bool isDone = task['done'] == true;
                  bool isRejected = task['rejected'] == true;

                  Color tileColor = AppColors.softWhite;
                  if (isDone) {
                    tileColor = AppColors.cream;
                  } else if (isRejected) {
                    tileColor = Colors.red.shade50;
                  }

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ListTile(
                      tileColor: tileColor,
                      leading: Icon(
                        Icons.task_alt,
                        color: isDone
                            ? AppColors.paleGreen
                            : isRejected
                                ? AppColors.peach
                                : Colors.black87,
                      ),
                      title: Text(
                        task['title'],
                        style: GoogleFonts.spaceGrotesk(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Scheduled time: ${task['date']}",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: isDone || isRejected
                                ? null
                                : () => markTaskAsDone(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.paleGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(fontSize: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text("Mark as Done"),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: isDone || isRejected
                                ? null
                                : () => rejectTask(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.peach,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(fontSize: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
