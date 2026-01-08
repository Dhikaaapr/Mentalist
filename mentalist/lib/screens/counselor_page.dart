import 'package:flutter/material.dart';
import 'counselor_detail_page.dart';
import '../services/counselor_api_service.dart';

class CounselorPage extends StatefulWidget {
  const CounselorPage({super.key});

  @override
  State<CounselorPage> createState() => _CounselorPageState();
}

class _CounselorPageState extends State<CounselorPage> {
  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> counselors = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCounselors() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await CounselorApiService.getAvailableCounselors();

    if (result != null && result['success'] == true) {
      final data = result['data'] as List;
      setState(() {
        counselors = data.map((e) => Map<String, dynamic>.from(e)).toList();
        filteredList = counselors;
      });
    } else {
      setState(() {
        errorMessage = result?['message'] ?? 'Gagal memuat daftar konselor';
      });
    }

    setState(() => isLoading = false);
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = counselors;
      } else {
        filteredList = counselors
            .where((c) =>
                (c['name'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
                (c['specialization'] ?? '')
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// TOP BAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
          color: Colors.black87,
        ),
        title: const Text(
          "Find Counselor",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadCounselors,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            /// 🔍 SEARCH TEXTFIELD
            TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Search counselor...",
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📍 LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? _buildErrorState()
                      : filteredList.isEmpty
                          ? _buildEmptyState()
                          : _buildCounselorList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadCounselors,
            icon: const Icon(Icons.refresh),
            label: const Text("Coba Lagi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6b38f0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            searchController.text.isNotEmpty
                ? "Tidak ada konselor yang cocok"
                : "Belum ada konselor tersedia",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorList() {
    return RefreshIndicator(
      onRefresh: _loadCounselors,
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (_, i) {
          final c = filteredList[i];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CounselorDetailPage(data: c),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  /// 👤 Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xff6b38f0),
                    backgroundImage: c['picture'] != null
                        ? NetworkImage(c['picture'])
                        : null,
                    child: c['picture'] == null
                        ? Text(
                            (c['name'] ?? 'C')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 18),

                  /// 📌 Detail
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c['specialization'] ?? 'Konselor',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  /// Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
