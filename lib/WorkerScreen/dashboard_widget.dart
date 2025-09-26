import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';
import 'package:project/WorkerScreen/AnimatedChart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  int _counter = 1;
  double _progress = 0;

  // 🔹 Worker info from SharedPreferences
  String workerName = "";
  String email = "";
  String imageUrl = "";
  String availability = "";
  String startTime = "";
  String endTime = "";
  String workingHours = "";

  final List<Map<String, dynamic>> tasks = [
    {"title": "PickUp Waste", "time": "12 pm", "done": false},
  ];

  final int _maxCounter = 70; // 70/87 ≈ 80%

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
    animateCounter();
  }

  Future<void> _loadWorkerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      workerName = prefs.getString("WorkerName") ?? "";
      email = prefs.getString("email") ?? "";
      imageUrl = prefs.getString("image_url") ?? "";
      availability = prefs.getString("availability") ?? ""; 
      startTime = prefs.getString("start_time") ?? "";
      endTime = prefs.getString("end_time") ?? "";
      workingHours = prefs.getString("working_hours") ?? "";
    });
  }

  void animateCounter() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_counter >= _maxCounter) {
        timer.cancel();
      } else {
        setState(() {
          _counter++;
          _progress = _counter / 87;
        });
      }
    });
  }

  void markTaskAsDone(int index) {
    setState(() {
      tasks[index]['done'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          /// 🔹 Profile Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? Icon(Icons.person, size: 40, color: Colors.grey.shade600)
                      : null,
                ),
                const SizedBox(width: 16),

                // Name & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workerName.isNotEmpty ? workerName : "Worker",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.isNotEmpty ? email : "No email",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 🔹 Top Info Section (Tasks, Days, Hours)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                /// Pending Tasks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pending Tasks",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          )),
                      const SizedBox(height: 8),
                      Text(
                        "${tasks.where((t) => !t['done']).length}",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.peach,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Divider
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),

                /// Duty Days
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 18, color: AppColors.paleGreen),
                          const SizedBox(width: 6),
                          Text("Duty Days",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: availability.isNotEmpty
                            ? availability
                                .split(",")
                                .map((day) => Text(
                                      day.trim(),
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500),
                                    ))
                                .toList()
                            : [
                                Text("No schedule",
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500)),
                              ],
                      ),
                    ],
                  ),
                ),

                /// Divider
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),

                /// Duty Hours
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.access_time_filled_outlined,
                              size: 18, color: AppColors.paleGreen),
                          const SizedBox(width: 6),
                          Text("Duty Hours",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        startTime.isNotEmpty && endTime.isNotEmpty
                            ? "$startTime - $endTime"
                            : "Not set",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
   const SizedBox(height: 6),

          /// Pending Task List
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
                Text("Pending Task List",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.peach,
                    )),
                const SizedBox(height: 12),
                ...tasks.asMap().entries.map((entry) {
                  int index = entry.key;
                  var task = entry.value;
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ListTile(
                      tileColor: task['done']
                          ? AppColors.cream
                          : AppColors.softWhite,
                      leading:
                          const Icon(Icons.task_alt, color: Colors.black87),
                      title: Text(
                        task['title'],
                        style: GoogleFonts.spaceGrotesk(
                          decoration: task['done']
                              ? TextDecoration.lineThrough
                              : null,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text("Scheduled time: ${task['tate']}",
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 13, color: Colors.black54)),
                      trailing: ElevatedButton(
                        onPressed: task['done']
                            ? null
                            : () => markTaskAsDone(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.paleGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        child: const Text("Mark as Done"),
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
