import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE5E5E5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Report & analysis",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          children: [
            Row(
              children: const [
                _SummaryCard(
                  title: "Total Users",
                  value: "200",
                  subtitle: "From Last Years",
                ),
                SizedBox(width: 12),
                _SummaryCard(
                  title: "Total Therapy Session",
                  value: "200",
                  subtitle: "From Last Years",
                ),
              ],
            ),
            const SizedBox(height: 22),

            _chartCard(
              title: "Total users",
              subtitle: "200 Users",
              values: [10, 25, 32, 45, 60],
              months: ["Nov 3", "Dec 3", "Jan 3", "Feb 3", "...."],
              maxValue: 60,
            ),

            const SizedBox(height: 22),

            _chartCard(
              title: "Therapy Session",
              subtitle: "200 Session",
              values: [20, 30, 42, 55, 70],
              months: ["Nov 3", "Dec 3", "Jan 3", "Feb 3", "...."],
              maxValue: 70,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required List<double> values,
    required List<String> months,
    required double maxValue,
  }) {
    const double chartHeight = 150;
    const double monthHeight = 26;
    const int gridLines = 5;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
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

          /// ===== GRAPH AREA =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Y AXIS (TINGGI = CHART SAJA)
              SizedBox(
                height: chartHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(gridLines + 1, (i) {
                    final value = (maxValue / gridLines * (gridLines - i))
                        .toInt();
                    return Text(
                      value.toString(),
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
                      size: Size(double.infinity, chartHeight),
                      painter: GridPainter(gridLines: gridLines),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(values.length, (index) {
                          final barHeight =
                              (values[index] / maxValue) * chartHeight;
                          return Container(
                            width: 26,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F3D7D),
                              borderRadius: BorderRadius.circular(6),
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

          /// MONTH LABEL (TERPISAH)
          SizedBox(
            height: monthHeight,
            child: Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: months
                    .map(
                      (m) => Text(
                        m,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
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
          color: const Color(0xFF3F3D7D),
          borderRadius: BorderRadius.circular(16),
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
      ..color = Colors.black.withValues(alpha: 0.25)
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
