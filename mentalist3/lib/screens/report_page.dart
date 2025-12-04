import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            const SizedBox(height: 5),

            const Text(
              "Report & analysis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            _chartCard(title: "Total users", values: [35, 60, 90, 120, 150]),

            const SizedBox(height: 28),

            _chartCard(
              title: "Therapy session",
              values: [20, 50, 80, 110, 140],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({required String title, required List<double> values}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              children: [
                /// === GARIS CHART ===
                Positioned(
                  left: 35,
                  bottom: 20,
                  child: CustomPaint(
                    size: const Size(240, 160),
                    painter: AxisPainter(),
                  ),
                ),

                /// === BAR UNGU ===
                Positioned(
                  left: 55,
                  bottom: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: values.map((height) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// === PAINTER UNTUK SUMBU CHART ===
class AxisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.2;

    final tickPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..strokeWidth = 1.4;

    // ------- GARIS VERTIKAL -------
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    // ------- GARIS HORIZONTAL -------
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    // ------- TICK MARKS (garis kecil indikator) -------
    const tickCount = 5;
    double gap = size.height / (tickCount + 1);

    for (int i = 1; i <= tickCount; i++) {
      final y = size.height - gap * i;

      canvas.drawLine(Offset(-8, y), Offset(8, y), tickPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
