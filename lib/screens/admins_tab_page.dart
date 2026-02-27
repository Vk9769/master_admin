import 'package:flutter/material.dart';
import 'dart:math';

class AdminsTabPage extends StatefulWidget {
  const AdminsTabPage({super.key});

  @override
  State<AdminsTabPage> createState() => _AdminsTabPageState();
}

class _AdminsTabPageState extends State<AdminsTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  String _statusFilter = "All";

  final List<Map<String, dynamic>> superAdmins = [
    {
      "id": "SA001",
      "name": "John Carter",
      "contact": "9876543210",
      "email": "john@admin.com",
      "status": "Active",
      "joinDate": "2023-01-15",
      "lastActive": "2 mins ago",
      "permissions": ["Full Access", "User Management", "Report Access"],
    },
    {
      "id": "SA002",
      "name": "Sarah Mitchell",
      "contact": "9876543211",
      "email": "sarah@admin.com",
      "status": "Active",
      "joinDate": "2023-02-20",
      "lastActive": "10 mins ago",
      "permissions": ["Full Access", "Audit Logs"],
    },
  ];

  final List<Map<String, dynamic>> admins = [
    {
      "id": "A101",
      "name": "Rahul Sharma",
      "contact": "9876501234",
      "email": "rahul@admin.com",
      "status": "Active",
      "joinDate": "2023-03-10",
      "lastActive": "5 mins ago",
      "permissions": ["User Management", "Report View"],
    },
    {
      "id": "A102",
      "name": "Amit Verma",
      "contact": "9876511111",
      "email": "amit@admin.com",
      "status": "Inactive",
      "joinDate": "2023-04-05",
      "lastActive": "2 days ago",
      "permissions": ["Report View"],
    },
    {
      "id": "A103",
      "name": "Priya Patel",
      "contact": "9876522222",
      "email": "priya@admin.com",
      "status": "Active",
      "joinDate": "2023-05-12",
      "lastActive": "1 min ago",
      "permissions": ["User Management", "Report View", "Booth Access"],
    },
    {
      "id": "A104",
      "name": "Vikram Singh",
      "contact": "9876533333",
      "email": "vikram@admin.com",
      "status": "Active",
      "joinDate": "2023-06-18",
      "lastActive": "15 mins ago",
      "permissions": ["Report View"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get currentList =>
      _tabController.index == 0 ? superAdmins : admins;

  List<Map<String, dynamic>> get filteredList {
    return currentList.where((admin) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          admin["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          admin["id"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          admin["email"].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _statusFilter == "All" || admin["status"] == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String get roleLabel => _tabController.index == 0 ? "Super Admin" : "Admin";

  @override
  Widget build(BuildContext context) {
    int totalAdmins = currentList.length;
    int activeAdmins = currentList.where((e) => e["status"] == "Active").length;
    int inactiveAdmins = totalAdmins - activeAdmins;

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
                  "Manage system $roleLabel accounts and their permissions",
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
                    width: 320, // IMPORTANT: gives TabBar fixed width
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
                          Tab(text: "Super Admin"),
                          Tab(text: "Admin"),
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
                    value: totalAdmins.toString(),
                    icon: Icons.admin_panel_settings,
                    color: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFEFF6FF),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _kpiCard(
                    title: "Active $roleLabel",
                    value: activeAdmins.toString(),
                    icon: Icons.check_circle,
                    color: const Color(0xFF10B981),
                    backgroundColor: const Color(0xFFF0FDF4),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _kpiCard(
                    title: "Inactive $roleLabel",
                    value: inactiveAdmins.toString(),
                    icon: Icons.block,
                    color: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFFFEF3C7),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _kpiCard(
                    title: "Activity Rate",
                    value: totalAdmins == 0
                        ? "0%"
                        : "${((activeAdmins / totalAdmins) * 100).toStringAsFixed(0)}%",
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
                /// Admin Distribution Chart
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
                          "All Admins Distribution",
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
                            painter: AdminDistributionPainter(
                              superAdminCount: superAdmins.length,
                              adminCount: admins.length,
                            ),
                            size: const Size(double.infinity, 180),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                /// Activity Timeline
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
                          activeAdmins,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 12),
                        _statusBadge(
                          "Inactive",
                          inactiveAdmins,
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
            _buildAdminTable(filteredList),
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

  Widget _buildAdminTable(List<Map<String, dynamic>> data) {
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
                    "$roleLabel ID",
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
                DataColumn(
                  label: Text(
                    "Permissions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
              rows: List.generate(data.length, (index) {
                final admin = data[index];
                return DataRow(
                  color: MaterialStateProperty.all(
                    index.isEven ? Colors.white : const Color(0xFFFAFAFA),
                  ),
                  cells: [
                    DataCell(Text("${index + 1}")),
                    DataCell(
                      Text(
                        admin["id"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(admin["name"])),
                    DataCell(Text(admin["contact"])),
                    DataCell(
                      Text(
                        admin["email"],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        admin["lastActive"],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: admin["status"] == "Active"
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          admin["status"],
                          style: TextStyle(
                            color: admin["status"] == "Active"
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Tooltip(
                        message: (admin["permissions"] as List).join(", "),
                        child: Chip(
                          label: Text(
                            "${(admin["permissions"] as List).length} permissions",
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: const Color(0xFFEFF6FF),
                          labelStyle: const TextStyle(color: Color(0xFF2563EB)),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Showing ${data.length} of ${currentList.length} $roleLabel accounts",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Paint for Admin Distribution Chart
class AdminDistributionPainter extends CustomPainter {
  final int superAdminCount;
  final int adminCount;

  AdminDistributionPainter({
    required this.superAdminCount,
    required this.adminCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalCount = superAdminCount + adminCount;
    if (totalCount == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 60.0;

    double currentAngle = -pi / 2;

    // Super Admin segment
    final superAdminAngle = (superAdminCount / totalCount) * 2 * pi;
    _drawPieSegment(
      canvas,
      center,
      radius,
      currentAngle,
      currentAngle + superAdminAngle,
      const Color(0xFF2563EB),
    );
    currentAngle += superAdminAngle;

    // Admin segment
    final adminAngle = (adminCount / totalCount) * 2 * pi;
    _drawPieSegment(
      canvas,
      center,
      radius,
      currentAngle,
      currentAngle + adminAngle,
      const Color(0xFF10B981),
    );

    // Add labels
    _drawLabel(
      canvas,
      center,
      radius,
      -pi / 2 + superAdminAngle / 2,
      "Super Admin\n$superAdminCount",
      Colors.white,
    );
    _drawLabel(
      canvas,
      center,
      radius,
      currentAngle + adminAngle / 2,
      "Admin\n$adminCount",
      Colors.white,
    );
  }

  void _drawPieSegment(
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

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
    Color color,
  ) {
    final labelRadius = radius * 0.6;
    final labelOffset = Offset(
      center.dx + labelRadius * cos(angle),
      center.dy + labelRadius * sin(angle),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(AdminDistributionPainter oldDelegate) =>
      oldDelegate.superAdminCount != superAdminCount ||
      oldDelegate.adminCount != adminCount;
}
