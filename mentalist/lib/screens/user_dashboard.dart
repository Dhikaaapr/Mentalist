import 'package:flutter/material.dart';
import 'login_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> counselors = [
    {
      'name': 'Dr. Ratna',
      'spec': 'Psikolog Klinis',
      'rating': 4.9,
      'online': true,
      'desc': 'Spesialis kecemasan & depresi',
    },
    {
      'name': 'Budi Putra, M.Psi',
      'spec': 'Psikolog',
      'rating': 4.7,
      'online': false,
      'desc': 'Hubungan & stress kerja',
    },
    {
      'name': 'Sinta',
      'spec': 'Konselor',
      'rating': 4.8,
      'online': true,
      'desc': 'Remaja & keluarga',
    },
  ];

  String? selectedCounselor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text(
          "MindCare Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 239, 115, 227),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardView(),
          _buildCounselorView(),
          _buildSessionView(),
          _buildProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 239, 115, 227),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Konselor"),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Sesi"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGreetingCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard("Sesi Terjadwal", "Tidak ada sesi"),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoCard("Mood Minggu Ini", "75%")),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationCard(),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Andhika 👋",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Bagaimana perasaanmu hari ini?",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rekomendasi Konselor",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Column(
            children: counselors.map((c) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 239, 115, 227),
                  child: Text(
                    c['name'][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(c['name']),
                subtitle: Text("${c['spec']} • ${c['rating']} ★"),
                trailing: c['online']
                    ? const Icon(Icons.circle, color: Colors.green, size: 14)
                    : const Icon(Icons.circle, color: Colors.grey, size: 14),
                onTap: () {
                  setState(() {
                    selectedCounselor = c['name'];
                    _selectedIndex = 1;
                  });
                },
              );
            }).toList(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 238, 125, 208),
            ),
            onPressed: () {},
            child: const Text("Minta Konseling"),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: counselors.length,
      itemBuilder: (context, index) {
        final c = counselors[index];
        return Card(
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                c['name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(c['name']),
            subtitle: Text("${c['spec']} • ${c['rating']} ★"),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Memulai chat dengan ${c['name']}')),
                );
              },
              child: const Text("Chat"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_note,
            size: 80,
            color: Color.fromARGB(255, 239, 115, 227),
          ),
          const SizedBox(height: 12),
          const Text(
            "Belum ada sesi aktif.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 239, 115, 227),
            ),
            onPressed: () {},
            child: const Text("Buat Sesi Baru"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color.fromARGB(255, 239, 115, 227),
                    child: Text("A"),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Andhika Presha",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "andhika@example.com",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Bio Singkat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tuliskan sesuatu tentang dirimu...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 239, 115, 227),
                ),
                onPressed: () {},
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
