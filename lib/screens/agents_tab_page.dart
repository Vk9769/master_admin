import 'package:flutter/material.dart';
import 'dart:math';

class AgentsTabPage extends StatefulWidget {
  const AgentsTabPage({super.key});

  @override
  State<AgentsTabPage> createState() => _AgentsTabPageState();
}

class _AgentsTabPageState extends State<AgentsTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  String _statusFilter = "All";

  final List<Map<String, dynamic>> superAgents = [
    {
      "id": "SGA001",
      "name": "Michael Torres",
      "contact": "9876543210",
      "email": "michael@agent.com",
      "status": "Active",
      "joinDate": "2023-01-15",
      "lastActive": "1 min ago",
      "permissions": ["Full Access", "Agent Management", "Report Access"],
      "campaignsManaged": "12",
      "effectiveness": "95%",
    },
    {
      "id": "SGA002",
      "name": "Alexandra Kumar",
      "contact": "9876543211",
      "email": "alexandra@agent.com",
      "status": "Active",
      "joinDate": "2023-02-20",
      "lastActive": "5 mins ago",
      "permissions": ["Full Access", "Audit Logs"],
      "campaignsManaged": "18",
      "effectiveness": "98%",
    },
  ];

  final List<Map<String, dynamic>> masterAgents = [
    {
      "id": "MA101",
      "name": "David Johnson",
      "contact": "9876501234",
      "email": "david@agent.com",
      "status": "Active",
      "joinDate": "2023-03-10",
      "lastActive": "3 mins ago",
      "permissions": ["Agent Management", "Report View", "Campaign Tracking"],
      "campaignsManaged": "8",
      "effectiveness": "92%",
    },
    {
      "id": "MA102",
      "name": "Elena Rodriguez",
      "contact": "9876511111",
      "email": "elena@agent.com",
      "status": "Active",
      "joinDate": "2023-04-05",
      "lastActive": "12 mins ago",
      "permissions": ["Report View", "Campaign Tracking"],
      "campaignsManaged": "5",
      "effectiveness": "88%",
    },
  ];

  final List<Map<String, dynamic>> agents = [
    {
      "id": "AG101",
      "name": "Rajesh Kumar",
      "contact": "9876522222",
      "email": "rajesh@agent.com",
      "status": "Active",
      "joinDate": "2023-05-12",
      "lastActive": "2 mins ago",
      "permissions": ["Report View", "Campaign Tracking"],
      "campaignsManaged": "3",
      "effectiveness": "85%",
    },
    {
      "id": "AG102",
      "name": "Ananya Singh",
      "contact": "9876533333",
      "email": "ananya@agent.com",
      "status": "Active",
      "joinDate": "2023-06-18",
      "lastActive": "8 mins ago",
      "permissions": ["Report View"],
      "campaignsManaged": "2",
      "effectiveness": "80%",
    },
    {
      "id": "AG103",
      "name": "Vikram Patel",
      "contact": "9876544444",
      "email": "vikram@agent.com",
      "status": "Inactive",
      "joinDate": "2023-07-22",
      "lastActive": "3 days ago",
      "permissions": ["Report View"],
      "campaignsManaged": "1",
      "effectiveness": "65%",
    },
    {
      "id": "AG104",
      "name": "Priya Sharma",
      "contact": "9876555555",
      "email": "priya@agent.com",
      "status": "Active",
      "joinDate": "2023-08-10",
      "lastActive": "1 min ago",
      "permissions": ["Report View", "Campaign Tracking"],
      "campaignsManaged": "4",
      "effectiveness": "89%",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get currentList {
    if (_tabController.index == 0) return superAgents;
    if (_tabController.index == 1) return masterAgents;
    return agents;
  }

  List<Map<String, dynamic>> get filteredList {
    return currentList.where((agent) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          agent["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          agent["id"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          agent["email"].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _statusFilter == "All" || agent["status"] == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String get roleLabel {
    if (_tabController.index == 0) return "Super Agent";
    if (_tabController.index == 1) return "Master Agent";
    return "Agent";
  }

  @override
  Widget build(BuildContext context) {
    int totalAgents = currentList.length;
    int activeAgents = currentList.where((e) => e["status"] == "Active").length;
    int inactiveAgents = totalAgents - activeAgents;
    double avgEffectiveness = currentList.isEmpty
        ? 0
        : currentList.fold<double>(
                0,
                (sum, agent) =>
                    sum +
                    double.parse(agent["effectiveness"].replaceAll("%", "")),
              ) /
              currentList.length;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER SECTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$roleLabel Management",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage campaign $roleLabel accounts and their activities",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                /// FIXED TAB BAR
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 420,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF6B7280),
                        indicator: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tabs: const [
                          Tab(text: "Super Agent"),
                          Tab(text: "Master Agent"),
                          Tab(text: "Agent"),
                        ],
                        onTap: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// KPI CARDS SECTION
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    title: "Total $roleLabel",
                    value: totalAgents.toString(),
                    icon: Icons.person_pin,
                    color: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFEFF6FF),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _kpiCard(
                    title: "Active $roleLabel",
                    value: activeAgents.toString(),
                    icon: Icons.check_circle,
                    color: const Color(0xFF10B981),
                    backgroundColor: const Color(0xFFF0FDF4),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _kpiCard(
                    title: "Inactive $roleLabel",
                    value: inactiveAgents.toString(),
                    icon: Icons.block,
                    color: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _kpiCard(
                    title: "Avg Effectiveness",
                    value: "${avgEffectiveness.toStringAsFixed(1)}%",
                    icon: Icons.trending_up,
                    color: const Color(0xFF8B5CF6),
                    backgroundColor: const Color(0xFFFAF5FF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// ANALYTICS SECTION
            Row(
              children: [
                /// Agent Distribution Chart
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Agent Hierarchy Distribution",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 180,
                          child: CustomPaint(
                            painter: AgentDistributionPainter(
                              superAgentCount: superAgents.length,
                              masterAgentCount: masterAgents.length,
                              agentCount: agents.length,
                            ),
                            size: const Size(double.infinity, 180),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                /// Status Breakdown
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$roleLabel Status Breakdown",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 20),
                        _statusBadge(
                          "Active",
                          activeAgents,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 12),
                        _statusBadge(
                          "Inactive",
                          inactiveAgents,
                          const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// SEARCH AND FILTER SECTION
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search by name, ID, or email...",
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6B7280),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      onChanged: (value) =>
                          setState(() => _statusFilter = value ?? "All"),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: "All",
                          child: Text("All Status"),
                        ),
                        DropdownMenuItem(
                          value: "Active",
                          child: Text("Active"),
                        ),
                        DropdownMenuItem(
                          value: "Inactive",
                          child: Text("Inactive"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// DATA TABLE
            _buildAgentTable(filteredList),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: backgroundColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _statusBadge(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentTable(List<Map<String, dynamic>> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF9FAFB),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    "Sr.No",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Agent ID",
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
                    "Contact",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Campaigns",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Effectiveness",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Last Active",
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
              rows: List.generate(data.length, (index) {
                final agent = data[index];
                return DataRow(
                  color: MaterialStateProperty.all(
                    index.isEven ? Colors.white : const Color(0xFFFAFAFA),
                  ),
                  cells: [
                    DataCell(Text("${index + 1}")),
                    DataCell(
                      Text(
                        agent["id"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(agent["name"])),
                    DataCell(Text(agent["contact"])),
                    DataCell(
                      Text(
                        agent["email"],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          agent["campaignsManaged"],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getEffectivenessColor(
                            agent["effectiveness"],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          agent["effectiveness"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getEffectivenessColor(
                              agent["effectiveness"],
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        agent["lastActive"],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: agent["status"] == "Active"
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          agent["status"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: agent["status"] == "Active"
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEffectivenessColor(String effectiveness) {
    final value = double.parse(effectiveness.replaceAll("%", ""));
    if (value >= 90) return const Color(0xFF10B981);
    if (value >= 80) return const Color(0xFF3B82F6);
    if (value >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// CUSTOM PAINTER FOR AGENT DISTRIBUTION
class AgentDistributionPainter extends CustomPainter {
  final int superAgentCount;
  final int masterAgentCount;
  final int agentCount;

  AgentDistributionPainter({
    required this.superAgentCount,
    required this.masterAgentCount,
    required this.agentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2.2;

    final total = superAgentCount + masterAgentCount + agentCount;
    if (total == 0) return;

    final superAgentAngle = (superAgentCount / total) * 2 * pi;
    final masterAgentAngle = (masterAgentCount / total) * 2 * pi;
    final agentAngle = (agentCount / total) * 2 * pi;

    // Super Agent Arc
    _drawPieSlice(
      canvas,
      center,
      radius,
      0,
      superAgentAngle,
      const Color(0xFF2563EB),
    );

    // Master Agent Arc
    _drawPieSlice(
      canvas,
      center,
      radius,
      superAgentAngle,
      superAgentAngle + masterAgentAngle,
      const Color(0xFF10B981),
    );

    // Agent Arc
    _drawPieSlice(
      canvas,
      center,
      radius,
      superAgentAngle + masterAgentAngle,
      2 * pi,
      const Color(0xFFF59E0B),
    );

    // Center circle for donut effect
    canvas.drawCircle(center, radius * 0.6, Paint()..color = Colors.white);

    // Legend
    _drawLegend(canvas, size);
  }

  void _drawPieSlice(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double endAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      true,
      paint,
    );
  }

  void _drawLegend(Canvas canvas, Size size) {
    final total = superAgentCount + masterAgentCount + agentCount;
    final textPaint = TextPainter(textDirection: TextDirection.ltr);

    final legendItems = [
      ("Super Agent: $superAgentCount", const Color(0xFF2563EB)),
      ("Master Agent: $masterAgentCount", const Color(0xFF10B981)),
      ("Agent: $agentCount", const Color(0xFFF59E0B)),
    ];

    double yOffset = 10;
    for (var item in legendItems) {
      // Color box
      canvas.drawRect(
        Rect.fromLTWH(10, yOffset, 12, 12),
        Paint()..color = item.$2,
      );

      // Text
      textPaint.text = TextSpan(
        text: item.$1,
        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 12),
      );
      textPaint.layout();
      textPaint.paint(canvas, Offset(28, yOffset - 2));

      yOffset += 20;
    }
  }

  @override
  bool shouldRepaint(AgentDistributionPainter oldDelegate) {
    return oldDelegate.superAgentCount != superAgentCount ||
        oldDelegate.masterAgentCount != masterAgentCount ||
        oldDelegate.agentCount != agentCount;
  }
}
