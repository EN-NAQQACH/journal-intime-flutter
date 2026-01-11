import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await moodProvider.loadMoodStats(authProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: Consumer<MoodProvider>(
          builder: (context, moodProvider, child) {
            if (moodProvider.moodCounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Aucune donnée', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text('Commencez à écrire pour voir vos statistiques', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCards(moodProvider),
                const SizedBox(height: 24),
                _buildMoodDistributionChart(moodProvider),
                const SizedBox(height: 24),
                _buildWeeklyChart(moodProvider),
                const SizedBox(height: 24),
                _buildMoodBreakdown(moodProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(MoodProvider moodProvider) {
    final totalEntries = moodProvider.getTotalEntriesCount();
    final happyDays = moodProvider.getHappyDaysCount();

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Entrées',
            totalEntries.toString(),
            Icons.edit_note,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Jours Heureux',
            happyDays.toString(),
            Icons.mood,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistributionChart(MoodProvider moodProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribution des humeurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(moodProvider),
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(MoodProvider moodProvider) {
    return moodProvider.moodCounts.entries.map((entry) {
      final color = moodProvider.getMoodColor(entry.key);
      final percentage = (entry.value / moodProvider.getTotalEntriesCount() * 100).toStringAsFixed(1);
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: color,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildWeeklyChart(MoodProvider moodProvider) {
    if (moodProvider.weeklyData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Évolution hebdomadaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: moodProvider.weeklyData.map((e) => (e['count'] as int).toDouble()).reduce((a, b) => a > b ? a : b) + 2,
                  barGroups: _buildBarGroups(moodProvider),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < moodProvider.weeklyData.length) {
                            final mood = moodProvider.weeklyData[value.toInt()]['mood'] as String;
                            return Text(moodProvider.getMoodEmoji(mood), style: const TextStyle(fontSize: 16));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(MoodProvider moodProvider) {
    return List.generate(moodProvider.weeklyData.length, (index) {
      final data = moodProvider.weeklyData[index];
      final mood = data['mood'] as String;
      final count = (data['count'] as int).toDouble();
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count,
            color: moodProvider.getMoodColor(mood),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  Widget _buildMoodBreakdown(MoodProvider moodProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Détails par humeur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...moodProvider.moodCounts.entries.map((entry) {
              final percentage = (entry.value / moodProvider.getTotalEntriesCount() * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(moodProvider.getMoodEmoji(entry.key), style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            moodProvider.getMoodLabel(entry.key),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${entry.value} entrées',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: moodProvider.getMoodColor(entry.key),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}