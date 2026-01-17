import 'package:flutter/material.dart';
import '../services/counselor_api_service.dart';

class WeeklyScheduleSetupPage extends StatefulWidget {
  const WeeklyScheduleSetupPage({super.key});

  @override
  State<WeeklyScheduleSetupPage> createState() => _WeeklyScheduleSetupPageState();
}

class _WeeklyScheduleSetupPageState extends State<WeeklyScheduleSetupPage> {
  bool isLoading = false;

  // Day schedule data: day_of_week => {enabled, start_time, end_time}
  final Map<int, Map<String, dynamic>> scheduleData = {
    1: {'enabled': false, 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
    2: {'enabled': false, 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
    3: {'enabled': false, 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
    4: {'enabled': false, 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
    5: {'enabled': false, 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
    6: {'enabled': false, 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 12, minute: 0)},
    0: {'enabled': false, 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 12, minute: 0)},
  };

  final List<String> dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  final List<int> dayOrder = [1, 2, 3, 4, 5, 6, 0]; // Mon-Sat, then Sun

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(int dayOfWeek, bool isStart) async {
    final currentTime = isStart
        ? scheduleData[dayOfWeek]!['start'] as TimeOfDay
        : scheduleData[dayOfWeek]!['end'] as TimeOfDay;

    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          scheduleData[dayOfWeek]!['start'] = picked;
        } else {
          scheduleData[dayOfWeek]!['end'] = picked;
        }
      });
    }
  }

  bool _hasAtLeastOneEnabled() {
    return scheduleData.values.any((data) => data['enabled'] == true);
  }

  Future<void> _submitSchedule() async {
    if (!_hasAtLeastOneEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 hari')),
      );
      return;
    }

    // Validate times
    for (var entry in scheduleData.entries) {
      if (entry.value['enabled'] == true) {
        final start = entry.value['start'] as TimeOfDay;
        final end = entry.value['end'] as TimeOfDay;
        final startMinutes = start.hour * 60 + start.minute;
        final endMinutes = end.hour * 60 + end.minute;

        if (endMinutes <= startMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jam selesai harus lebih dari jam mulai (${dayNames[entry.key]})')),
          );
          return;
        }
      }
    }

    setState(() => isLoading = true);

    // Build schedules array
    final schedules = <Map<String, dynamic>>[];
    for (var entry in scheduleData.entries) {
      if (entry.value['enabled'] == true) {
        schedules.add({
          'day_of_week': entry.key,
          'start_time': _formatTime(entry.value['start'] as TimeOfDay),
          'end_time': _formatTime(entry.value['end'] as TimeOfDay),
        });
      }
    }

    final result = await CounselorApiService.saveWeeklyAvailability(schedules);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green.shade400, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                "Jadwal Terkirim!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Jadwal Anda sedang menunggu persetujuan admin.",
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to dashboard with success
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan jadwal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 110, 16, 183);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Atur Jadwal Mingguan"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Icon(Icons.calendar_month, size: 48, color: Colors.white.withValues(alpha: 0.9)),
                const SizedBox(height: 12),
                const Text(
                  "Selamat Datang!",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pilih hari dan jam ketersediaan Anda untuk konseling.\nJadwal akan aktif setelah disetujui admin.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Schedule list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dayOrder.length,
              itemBuilder: (context, index) {
                final dayOfWeek = dayOrder[index];
                final data = scheduleData[dayOfWeek]!;
                final isEnabled = data['enabled'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isEnabled ? primaryColor.withValues(alpha: 0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isEnabled ? primaryColor.withValues(alpha: 0.3) : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Checkbox
                          Checkbox(
                            value: isEnabled,
                            activeColor: primaryColor,
                            onChanged: (val) {
                              setState(() {
                                scheduleData[dayOfWeek]!['enabled'] = val ?? false;
                              });
                            },
                          ),

                          // Day name
                          Expanded(
                            child: Text(
                              dayNames[dayOfWeek],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                                color: isEnabled ? Colors.black87 : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Time pickers (visible when enabled)
                      if (isEnabled) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(width: 48),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickTime(dayOfWeek, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatTime(data['start'] as TimeOfDay),
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("-", style: TextStyle(color: Colors.grey.shade600)),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickTime(dayOfWeek, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatTime(data['end'] as TimeOfDay),
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Submit button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Simpan Jadwal",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
