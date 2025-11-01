import 'package:flutter/material.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text('Halaman Daftar User', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
