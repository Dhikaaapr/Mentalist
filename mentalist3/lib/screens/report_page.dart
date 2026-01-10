import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_api_services.dart';
import '../utils/logger.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool isLoading = true;
  String? errorMessage;
  
  // Data variables
  int totalUsers = 0;
  int totalSessions = 0;
  List<Map<String, dynamic>> registrationTrend = [];
  List<Map<String, dynamic>> counselorStats = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await AdminApiService.getReportStats();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          totalUsers = result['summary']['total_users'] ?? 0;
          totalSessions = result['summary']['total_sessions'] ?? 0;
          
          // Process registrations (limit to 5 points for UI compatibility)
          final List<dynamic> regData = result['registration_trend'] ?? [];
          registrationTrend = regData.map((e) => {
            'label': _formatDateLabel(e['date']),
            'value': (e['count'] as num).toDouble(),
          }).toList();
          
          if (registrationTrend.length > 5) {
            registrationTrend = registrationTrend.sublist(registrationTrend.length - 5);
          }

          // Process counselor stats (limit to 5 counselors)
          final List<dynamic> consData = result['counselor_stats'] ?? [];
          counselorStats = consData.map((e) => {
            'label': (e['counselor']?['name'] ?? 'Unknown').split(' ')[0], // Short name
            'value': (e['count'] as num).toDouble(),
          }).toList();

          if (counselorStats.length > 5) {
            counselorStats = counselorStats.sublist(0, 5);
          }

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Gagal memuat data laporan';
          isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('[REPORT_PAGE] Error: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Terjadi kesalahan tidak terduga';
          isLoading = false;
        });
      }
    }
  }

  String _formatDateLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6A1B9A), // Consistent with Admin theme
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Report & analysis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(errorMessage!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReportData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReportData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _SummaryCard(
                              title: "Total Users",
                              value: totalUsers.toString(),
                              subtitle: "Registered Users",
                            ),
                            const SizedBox(width: 12),
                            _SummaryCard(
                              title: "Total Session",
                              value: totalSessions.toString(),
                              subtitle: "Confirmed Bookings",
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Chart 1: User Registrations
                        _chartCard(
                          title: "Registration Trend",
                          subtitle: "User registrations in last 30 days",
                          data: registrationTrend,
                          emptyPlaceholder: "Belum ada data registrasi 30 hari terakhir",
                        ),

                        const SizedBox(height: 22),

                        // Chart 2: Counselor Bookings
                        _chartCard(
                          title: "Counselor Performance",
                          subtitle: "Total sessions per counselor",
                          data: counselorStats,
                          emptyPlaceholder: "Belum ada data sesi terapi",
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> data,
    required String emptyPlaceholder,
  }) {
    const double chartHeight = 150;
    const double monthHeight = 26;
    const int gridLines = 5;

    // Get max value for scaling
    double maxValue = 5; // Default min max
    for (var item in data) {
      if (item['value'] > maxValue) {
        maxValue = item['value'];
      }
    }
    // Round up maxValue to nearest 5 or 10
    maxValue = (maxValue / 5).ceil() * 5.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F3D7D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 18),

          if (data.isEmpty)
            SizedBox(
              height: chartHeight + monthHeight,
              child: Center(
                child: Text(
                  emptyPlaceholder,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
          else ...[
            /// ===== GRAPH AREA =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Y AXIS
                SizedBox(
                  height: chartHeight,
                  width: 25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(gridLines + 1, (i) {
                      final val = (maxValue / gridLines * (gridLines - i)).toInt();
                      return Text(
                        val.toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    }),
                  ),
                ),

                const SizedBox(width: 8),

                /// BAR + GRID
                Expanded(
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, chartHeight),
                        painter: GridPainter(gridLines: gridLines),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(data.length, (index) {
                            final barHeight = (data[index]['value'] / maxValue) * chartHeight;
                            return Tooltip(
                              message: '${data[index]['label']}: ${data[index]['value'].toInt()}',
                              child: Container(
                                width: 30,
                                height: barHeight > 0 ? barHeight : 2, // At least 2px to show something
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3F3D7D),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// X AXIS LABELS
            SizedBox(
              height: monthHeight,
              child: Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: data
                      .map((d) => Expanded(
                            child: Text(
                              d['label'],
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9, color: Colors.black54),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value, subtitle;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF6A1B9A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int gridLines;
  GridPainter({required this.gridLines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    final gap = size.height / gridLines;

    for (int i = 0; i <= gridLines; i++) {
      final y = size.height - gap * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
