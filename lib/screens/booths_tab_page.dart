import 'package:flutter/material.dart';

class BoothsTabPage extends StatefulWidget {
  const BoothsTabPage({super.key});

  @override
  State<BoothsTabPage> createState() => _BoothsTabPageState();
}

class _BoothsTabPageState extends State<BoothsTabPage> {
  String searchQuery = "";
  String filterStatus = "All";

  final List<Map<String, dynamic>> booths = [
    {
      "id": "BTH001",
      "name": "Central School",
      "address": "MG Road",
      "state": "Maharashtra",
      "district": "Nashik",
      "status": "Active",
      "voters": 850,
      "voted": 720,
      "staff": 6,
      "efficiency": 84.7,
    },
    {
      "id": "BTH002",
      "name": "Community Hall",
      "address": "College Road",
      "state": "Maharashtra",
      "district": "Nashik",
      "status": "Active",
      "voters": 650,
      "voted": 521,
      "staff": 5,
      "efficiency": 80.2,
    },
    {
      "id": "BTH003",
      "name": "Government College",
      "address": "Education Hub",
      "state": "Maharashtra",
      "district": "Nashik",
      "status": "Active",
      "voters": 920,
      "voted": 812,
      "staff": 7,
      "efficiency": 88.3,
    },
    {
      "id": "BTH004",
      "name": "City Library",
      "address": "Downtown",
      "state": "Maharashtra",
      "district": "Nashik",
      "status": "Inactive",
      "voters": 450,
      "voted": 0,
      "staff": 0,
      "efficiency": 0.0,
    },
    {
      "id": "BTH005",
      "name": "Sports Complex",
      "address": "Industrial Area",
      "state": "Maharashtra",
      "district": "Nashik",
      "status": "Active",
      "voters": 780,
      "voted": 689,
      "staff": 6,
      "efficiency": 88.3,
    },
  ];

  late List<Map<String, dynamic>> filteredBooths;

  @override
  void initState() {
    super.initState();
    filteredBooths = booths;
  }

  void updateFilter(String status) {
    setState(() {
      filterStatus = status;
      applyFilters();
    });
  }

  void applyFilters() {
    setState(() {
      filteredBooths = booths.where((booth) {
        final matchesStatus =
            filterStatus == "All" || booth["status"] == filterStatus;
        final matchesSearch =
            booth["name"].toLowerCase().contains(searchQuery.toLowerCase()) ||
            booth["id"].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalBooths = booths.length;
    int activeBooths = booths.where((e) => e["status"] == "Active").length;
    int totalVoters = booths.fold(0, (sum, e) => sum + (e["voters"] as int));
    int totalVoted = booths.fold(0, (sum, e) => sum + (e["voted"] as int));
    double averageEfficiency = booths.isEmpty
        ? 0
        : booths.fold(
                0.0,
                (sum, e) => sum + (e["efficiency"] as num).toDouble(),
              ) /
              booths.length;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            _buildHeader(),
            const SizedBox(height: 32),

            /// KPI CARDS ROW
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    "Total Booths",
                    totalBooths.toString(),
                    Icons.store,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _kpiCard(
                    "Active Booths",
                    activeBooths.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _kpiCard(
                    "Total Voters",
                    totalVoters.toString(),
                    Icons.people,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _kpiCard(
                    "Avg Efficiency",
                    "${averageEfficiency.toStringAsFixed(1)}%",
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// CHARTS SECTION
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildBoothStatusChart(
                    activeBooths,
                    totalBooths - activeBooths,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildVoterTurnoutChart(totalVoted, totalVoters),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildEfficiencyAnalysis()),
              ],
            ),

            const SizedBox(height: 32),

            /// ACTION BUTTONS
            _buildActionButtons(),

            const SizedBox(height: 32),

            /// SEARCH AND FILTER
            _buildSearchAndFilter(),

            const SizedBox(height: 24),

            /// TABLE SECTION
            _buildBoothTable(totalBooths),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Booth Management",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Monitor and manage election booths across all regions",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoothStatusChart(int active, int inactive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booth Status",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: PieChartPainter(active.toDouble(), inactive.toDouble()),
              size: const Size(double.infinity, 150),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendItem("Active", Colors.green, active.toString()),
              _legendItem("Inactive", Colors.red, inactive.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoterTurnoutChart(int voted, int total) {
    double turnoutPercent = total > 0 ? (voted / total * 100) : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Voter Turnout",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: CircleProgressPainter(turnoutPercent),
                    size: const Size(120, 120),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${turnoutPercent.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    "Voted",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    voted.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    total.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top Performing Booths",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          ...filteredBooths
              .where((b) => b["status"] == "Active")
              .toList()
              .asMap()
              .entries
              .take(3)
              .map((entry) {
                int index = entry.key;
                Map<String, dynamic> booth = entry.value;
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booth["name"],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Text(
                          "${booth['efficiency']}%",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (booth['efficiency'] as num).toDouble() / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(
                          booth['efficiency'] > 85
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                    if (index < 2) const SizedBox(height: 12),
                  ],
                );
              })
              .toList(),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, String value) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            "Add Booth",
            Icons.add_circle_outline,
            Colors.blue,
            () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            "Upload",
            Icons.upload_file,
            Colors.green,
            () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            "Download",
            Icons.download,
            Colors.orange,
            () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            "Export",
            Icons.file_download,
            Colors.purple,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by booth name or ID...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton(
            onSelected: updateFilter,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: "All", child: Text("All")),
              const PopupMenuItem(value: "Active", child: Text("Active")),
              const PopupMenuItem(value: "Inactive", child: Text("Inactive")),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    filterStatus,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoothTable(int totalBooths) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booth Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey[100]!,
              ),
              headingRowHeight: 48,
              dataRowHeight: 56,
              columns: const [
                DataColumn(
                  label: Text(
                    "ID",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "District",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Voters",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Voted",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Efficiency",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
              rows: List.generate(filteredBooths.length, (index) {
                final booth = filteredBooths[index];
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        booth["id"],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(booth["name"], style: const TextStyle(fontSize: 12)),
                    ),
                    DataCell(
                      Text(
                        booth["address"],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        booth["district"],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        booth["voters"].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        booth["voted"].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${booth['efficiency']}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: booth['efficiency'] > 85
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: booth["status"] == "Active"
                              ? Colors.green.withOpacity(.15)
                              : Colors.red.withOpacity(.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booth["status"],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: booth["status"] == "Active"
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${filteredBooths.length} of $totalBooths booths",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              Text(
                "Total Active: ${booths.where((e) => e['status'] == 'Active').length}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// CUSTOM PAINTERS FOR CHARTS
class PieChartPainter extends CustomPainter {
  final double activeValue;
  final double inactiveValue;

  PieChartPainter(this.activeValue, this.inactiveValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 - 10;

    final total = activeValue + inactiveValue;
    final activeAngle = (activeValue / total) * 2 * 3.14159;

    // Active (green)
    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      activeAngle,
      true,
      paint,
    );

    // Inactive (red)
    paint.color = Colors.red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708 + activeAngle,
      (inactiveValue / total) * 2 * 3.14159,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => false;
}

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      (progress / 100) * 2 * 3.14159,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
