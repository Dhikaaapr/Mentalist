import 'package:flutter/material.dart';

class CounselorListPage extends StatelessWidget {
  const CounselorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Konselor'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text('Halaman Daftar Konselor', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
