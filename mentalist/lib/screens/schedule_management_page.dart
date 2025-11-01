import 'package:flutter/material.dart';

class ScheduleManagementPage extends StatelessWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengelolaan Jadwal Konselor'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Halaman Pengelolaan Jadwal Konselor',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
