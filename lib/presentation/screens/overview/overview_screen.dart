import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/constants/liquid_glass.dart';
import '../../providers/app_providers.dart';
import '../../widgets/cards/period_chips.dart';
import '../../widgets/cards/transaction_item.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_scaffold.dart';
import '../../widgets/orbital/orbital_icon.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  int _periodIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appDataProvider);

    if (data.isLoading) {
      return const GlassScaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Aggregate expenses per category for the donut chart.
    final Map<int, double> expenseByCategory = {};
    for (final t in data.nonScheduled.where((t) => t.isExpense && !data.isTransfer(t))) {
      if (t.categoryId != null) {
        expenseByCategory[t.categoryId!] =
            (expenseByCategory[t.categoryId!] ?? 0) + t.amount.abs();
      }
    }
    final topCategoryId = expenseByCategory.isEmpty
        ? null
        : expenseByCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final topCategory = data.categoryFor(topCategoryId);

    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
        children: [
          Text('Overview', style: AppTypography.displayMedium),
          const SizedBox(height: 12),
          PeriodChips(
            periods: const ['This month', 'Last month'],
            selectedIndex: _periodIndex,
            onSelected: (i) => setState(() => _periodIndex = i),
          ),
          const SizedBox(height: 16),

          // Expenses donut
          GlassContainer(
            borderRadius: 24,
            depthLayer: 2,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expenses', style: AppTypography.bodyMedium),
                Text('-${formatIdr(data.monthExpense)}', style: AppTypography.displayMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: expenseByCategory.isEmpty
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    color: Colors.white.withValues(alpha: 0.1),
                                    showTitle: false,
                                    radius: 40,
                                  ),
                                ]
                              : expenseByCategory.entries.map((entry) {
                                  final cat = data.categoryFor(entry.key);
                                  return PieChartSectionData(
                                    value: entry.value,
                                    color: Color(cat?.colorValue ?? 0xFF10B981),
                                    showTitle: false,
                                    radius: 40,
                                  );
                                }).toList(),
                        ),
                      ),
                      if (topCategory != null)
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (topCategory != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(topCategory.colorValue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(topCategory.name, style: AppTypography.bodyMedium),
                    ],
                  ),
              ],
            ),
          ),

          // Cash flow bar chart
          GlassContainer(
            borderRadius: 24,
            depthLayer: 2,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cash Flow', style: AppTypography.bodyMedium),
                Text(formatIdr(data.cashFlow), style: AppTypography.displayMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _bar(0, data.monthIncome, AppColors.emeraldSoft),
                        _bar(1, data.monthExpense, AppColors.coral),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(AppColors.emeraldSoft, 'Income'),
                    const SizedBox(width: 16),
                    _legendDot(AppColors.coral, 'Expenses'),
                  ],
                ),
              ],
            ),
          ),

          // Income trend
          GlassContainer(
            borderRadius: 24,
            depthLayer: 2,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Income', style: AppTypography.bodyMedium),
                Text(formatIdr(data.monthIncome), style: AppTypography.displayMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 0.1),
                            FlSpot(1, 0.12),
                            FlSpot(2, 0.15),
                            FlSpot(3, 0.2),
                            FlSpot(4, 1.0),
                          ],
                          isCurved: true,
                          color: AppColors.chartLine,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.chartLine.withValues(alpha: 0.25),
                                AppColors.chartLine.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scheduled
          if (data.scheduled.isNotEmpty)
            GlassContainer(
              borderRadius: 24,
              depthLayer: 2,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scheduled', style: AppTypography.bodyMedium),
                  Text(
                    formatIdr(data.scheduled.fold(0.0, (s, t) => s + t.amount.abs())),
                    style: AppTypography.displayMedium,
                  ),
                  Text('${data.scheduled.length} transactions', style: AppTypography.bodySmall),
                  const SizedBox(height: 12),
                  for (final t in data.scheduled)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          OrbitalIcon(
                            icon: iconForKey(data.categoryFor(t.categoryId)?.icon ?? 'payments'),
                            size: 32,
                            color: Color(data.categoryFor(t.categoryId)?.colorValue ?? 0xFF10B981),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(t.title, style: AppTypography.bodyLarge)),
                          Text(formatIdr(t.amount), style: AppTypography.amountMedium()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double value, Color color) {
    const maxVal = 1000000.0;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value == 0 ? 4 : value,
          color: color,
          width: 40,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxVal, color: Colors.white.withValues(alpha: 0.05)),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}
