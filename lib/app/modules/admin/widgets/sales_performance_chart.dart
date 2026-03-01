import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';

class SalesPerformanceChart extends StatefulWidget {
  /// Raw orders list from dashboard: each item has 'total', 'estado', 'fecha_creacion'
  final List<dynamic> rawOrders;

  const SalesPerformanceChart({super.key, required this.rawOrders});

  @override
  State<SalesPerformanceChart> createState() => _SalesPerformanceChartState();
}

class _SalesPerformanceChartState extends State<SalesPerformanceChart> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day);
    _startDate = _endDate.subtract(const Duration(days: 9));
  }

  Map<String, double> _computeDailySales() {
    final sales = <String, double>{};

    // Initialize all days in range
    for (var d = _startDate;
        !d.isAfter(_endDate);
        d = d.add(const Duration(days: 1))) {
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      sales[key] = 0;
    }

    // Aggregate from orders
    for (final o in widget.rawOrders) {
      final estado = o['estado'] as String? ?? '';
      if (estado == 'Cancelado') continue;

      final totalRaw = o['total'];
      final total = (totalRaw is int)
          ? totalRaw / 100.0
          : (totalRaw is num)
              ? totalRaw.toDouble() / 100.0
              : 0.0;

      final fechaStr = o['fecha_creacion'] as String? ?? '';
      final fechaOrden = DateTime.tryParse(fechaStr)?.toLocal();
      if (fechaOrden == null) continue;

      final key =
          '${fechaOrden.year}-${fechaOrden.month.toString().padLeft(2, '0')}-${fechaOrden.day.toString().padLeft(2, '0')}';

      if (sales.containsKey(key)) {
        if (estado == 'Reembolsada') {
          sales[key] = (sales[key] ?? 0) - total;
        } else {
          sales[key] = (sales[key] ?? 0) + total;
        }
      }
    }

    return sales;
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: today,
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) _startDate = _endDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailySales = _computeDailySales();
    final entries = dailySales.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxVal =
        entries.fold<double>(0, (prev, e) => e.value > prev ? e.value : prev);
    final yMax = maxVal == 0 ? 100.0 : (maxVal * 1.2);

    final spots = entries.asMap().entries.map((e) {
      final val = e.value.value < 0 ? 0.0 : e.value.value;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    final euroFormatter = NumberFormat('#,##0', 'es_ES');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.show_chart_rounded,
                  color: AppColors.navy, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Rendimiento de Ventas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Date subtitle
          Text(
            'Del ${dateFormatter.format(_startDate)} al ${dateFormatter.format(_endDate)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),

          // Date pickers row
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: dateFormatter.format(_startDate),
                  onTap: () => _pickDate(true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward,
                    size: 14, color: Colors.grey.shade400),
              ),
              Expanded(
                child: _buildDateButton(
                  label: dateFormatter.format(_endDate),
                  onTap: () => _pickDate(false),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  final now = DateTime.now();
                  setState(() {
                    _endDate = DateTime(now.year, now.month, now.day);
                    _startDate = _endDate.subtract(const Duration(days: 9));
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.refresh,
                      size: 14, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yMax / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF0F0F0),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,
                      interval: yMax / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${euroFormatter.format(value)}€',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        final totalDays = entries.length;
                        int step = 1;

                        // Max ~6 labels fit comfortably on mobile width
                        if (totalDays > 120) {
                          step = 30; // Show one label per ~month
                        } else if (totalDays > 60) {
                          step = 15; // Show one label per ~2 weeks
                        } else if (totalDays > 30) {
                          step = 7; // Show one label per week
                        } else if (totalDays > 14) {
                          step = 4;
                        } else if (totalDays > 7) {
                          step = 2;
                        }

                        // Always show the first and last label if possible,
                        // and space the rest according to the step
                        if (idx != 0 &&
                            idx != entries.length - 1 &&
                            idx % step != 0) {
                          return const SizedBox.shrink();
                        }
                        final dateStr = entries[idx].key;
                        final date = DateTime.tryParse(dateStr);
                        final label = date != null
                            ? '${date.day}/${date.month}'
                            : dateStr;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (entries.length - 1).toDouble(),
                minY: 0,
                maxY: yMax,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final idx = spot.x.toInt();
                        final dateStr =
                            idx < entries.length ? entries[idx].key : '';
                        final date = DateTime.tryParse(dateStr);
                        final dateLabel = date != null
                            ? '${date.day}/${date.month}/${date.year}'
                            : dateStr;
                        return LineTooltipItem(
                          '$dateLabel\n${euroFormatter.format(spot.y)}€',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.navy,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: entries.length <= 15,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.navy,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.navy.withValues(alpha: 0.15),
                          AppColors.navy.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
      {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
