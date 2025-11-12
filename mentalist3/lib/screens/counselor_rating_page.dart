import 'package:flutter/material.dart';

class CounselorRatingPage extends StatelessWidget {
  const CounselorRatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penilaian Konselor'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Halaman Penilaian Konselor',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
