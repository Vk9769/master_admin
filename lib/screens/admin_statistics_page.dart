import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatisticsContent extends StatefulWidget {
  const AdminStatisticsContent({super.key});

  @override
  State<AdminStatisticsContent> createState() => _AdminStatisticsContentState();
}

class _AdminStatisticsContentState extends State<AdminStatisticsContent> {
  // Color Scheme
  static const primaryColor = Color(0xFF2563EB);
  static const secondaryColor = Color(0xFF1E40AF);
  static const successColor = Color(0xFF10B981);
  static const warningColor = Color(0xFFF59E0B);
  static const dangerColor = Color(0xFFEF4444);
  static const indigoColor = Color(0xFF6366F1);
  static const violetColor = Color(0xFFA78BFA);
  static const tealColor = Color(0xFF14B8A6);
  static const bgColor = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);

  // Voting Trend Data
  final List<FlSpot> votingTrend = [
    FlSpot(0, 400),
    FlSpot(1, 900),
    FlSpot(2, 1500),
    FlSpot(3, 2100),
    FlSpot(4, 2700),
    FlSpot(5, 3100),
    FlSpot(6, 3500),
  ];

  // Booth Performance Data
  final List<BarChartGroupData> boothPerformance = [
    BarChartGroupData(
      x: 0,
      barRods: [BarChartRodData(toY: 1200, color: primaryColor)],
    ),
    BarChartGroupData(
      x: 1,
      barRods: [BarChartRodData(toY: 1800, color: successColor)],
    ),
    BarChartGroupData(
      x: 2,
      barRods: [BarChartRodData(toY: 900, color: warningColor)],
    ),
    BarChartGroupData(
      x: 3,
      barRods: [BarChartRodData(toY: 1500, color: indigoColor)],
    ),
  ];

  // Candidate Performance Data
  final List<BarChartGroupData> candidatePerformance = [
    BarChartGroupData(
      x: 0,
      barRods: [BarChartRodData(toY: 2800, color: primaryColor, width: 16)],
    ),
    BarChartGroupData(
      x: 1,
      barRods: [BarChartRodData(toY: 2400, color: successColor, width: 16)],
    ),
    BarChartGroupData(
      x: 2,
      barRods: [BarChartRodData(toY: 1900, color: warningColor, width: 16)],
    ),
    BarChartGroupData(
      x: 3,
      barRods: [BarChartRodData(toY: 1500, color: indigoColor, width: 16)],
    ),
    BarChartGroupData(
      x: 4,
      barRods: [BarChartRodData(toY: 900, color: dangerColor, width: 16)],
    ),
  ];

  // Voter Turnout Sections
  final List<PieChartSectionData> turnoutSections = [
    PieChartSectionData(value: 65, color: successColor, title: "65%"),
    PieChartSectionData(value: 35, color: dangerColor, title: "35%"),
  ];

  // Regional Distribution
  final List<PieChartSectionData> regionalSections = [
    PieChartSectionData(value: 28, color: primaryColor, title: "28%"),
    PieChartSectionData(value: 24, color: indigoColor, title: "24%"),
    PieChartSectionData(value: 22, color: tealColor, title: "22%"),
    PieChartSectionData(value: 26, color: warningColor, title: "26%"),
  ];

  // Time-based Distribution
  final List<FlSpot> timeBasedData = [
    FlSpot(0, 200),
    FlSpot(1, 450),
    FlSpot(2, 800),
    FlSpot(3, 1200),
    FlSpot(4, 1800),
    FlSpot(5, 2200),
    FlSpot(6, 2600),
    FlSpot(7, 3000),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 1400
            ? 4
            : constraints.maxWidth > 1000
            ? 2
            : 1;

        return Container(
          color: bgColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),
                const SizedBox(height: 32),

                // KPI Cards
                _buildKPISection(columns),
                const SizedBox(height: 32),

                // Charts Section
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _buildCard(
                      "Live Voting Trend",
                      _lineChart(),
                      columns,
                      icon: Icons.trending_up,
                    ),
                    _buildCard(
                      "Candidate Performance",
                      _candidateBarChart(),
                      columns,
                      icon: Icons.person,
                    ),
                    _buildCard(
                      "Booth Performance",
                      _barChart(),
                      columns,
                      icon: Icons.location_on,
                    ),
                    _buildCard(
                      "Voter Turnout Analysis",
                      _pieChart(),
                      columns,
                      icon: Icons.pie_chart,
                    ),
                    _buildCard(
                      "Regional Distribution",
                      _regionalPieChart(),
                      columns,
                      icon: Icons.map,
                    ),
                    _buildCard(
                      "Time-Based Voting",
                      _timeBasedChart(),
                      columns,
                      icon: Icons.schedule,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Election Statistics Dashboard',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time voting analytics and performance metrics',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildKPISection(int columns) {
    final kpis = [
      {
        'title': 'Total Votes',
        'value': '35,400',
        'icon': Icons.how_to_vote,
        'color': primaryColor,
      },
      {
        'title': 'Voter Turnout',
        'value': '65%',
        'icon': Icons.people,
        'color': successColor,
      },
      {
        'title': 'Active Booths',
        'value': '124',
        'icon': Icons.store,
        'color': warningColor,
      },
      {
        'title': 'Processing Time',
        'value': '2.5s',
        'icon': Icons.speed,
        'color': indigoColor,
      },
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: kpis.map((kpi) => _buildKPICard(kpi)).toList(),
    );
  }

  Widget _buildKPICard(Map<String, dynamic> kpi) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (kpi['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              kpi['icon'] as IconData,
              color: kpi['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            kpi['title'] as String,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            kpi['value'] as String,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    Widget chart,
    int columns, {
    required IconData icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        double spacing = 24;
        double cardWidth = (totalWidth - (spacing * (columns - 1))) / columns;

        return SizedBox(
          width: cardWidth,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(height: 280, child: chart),
              ],
            ),
          ),
        );
      },
    );
  }

  // Line Chart - Voting Trend
  Widget _lineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.08), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                return Text(
                  titles[value.toInt()],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: votingTrend,
            isCurved: true,
            color: primaryColor,
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bar Chart - Booth Performance
  Widget _barChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.08), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: boothPerformance,
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Booth A', 'Booth B', 'Booth C', 'Booth D'];
                return Text(
                  titles[value.toInt()],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Bar Chart - Candidate Performance
  Widget _candidateBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.08), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: candidatePerformance,
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Alice', 'Bob', 'Carol', 'David', 'Emma'];
                return Text(
                  titles[value.toInt()],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Pie Chart - Voter Turnout
  Widget _pieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 6,
        centerSpaceRadius: 50,
        sections: turnoutSections
            .map(
              (e) => PieChartSectionData(
                value: e.value,
                color: e.color,
                radius: 70,
                title: e.title,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // Pie Chart - Regional Distribution
  Widget _regionalPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: regionalSections
            .map(
              (e) => PieChartSectionData(
                value: e.value,
                color: e.color,
                radius: 65,
                title: e.title,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // Line Chart - Time-Based Distribution
  Widget _timeBasedChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.08), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = [
                  '8AM',
                  '10AM',
                  '12PM',
                  '2PM',
                  '4PM',
                  '6PM',
                  '8PM',
                  '10PM',
                ];
                return Text(
                  titles[value.toInt()],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: timeBasedData,
            isCurved: true,
            color: tealColor,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  tealColor.withOpacity(0.25),
                  tealColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
