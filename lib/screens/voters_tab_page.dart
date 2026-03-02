import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VotersTabPage extends StatefulWidget {
  const VotersTabPage({Key? key}) : super(key: key);

  @override
  State<VotersTabPage> createState() => _VotersTabPageState();
}

class _VotersTabPageState extends State<VotersTabPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _statusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> allVoters = [
    {
      'id': 'V001',
      'name': 'Rajesh Kumar',
      'email': 'rajesh.kumar@email.com',
      'phone': '+91-9876543210',
      'booth': 'Booth A-01',
      'verified': true,
      'hasVoted': true,
      'registrationDate': '2024-01-15',
      'lastActive': '2024-02-28 10:30',
      'status': 'Verified',
    },
    {
      'id': 'V002',
      'name': 'Priya Sharma',
      'email': 'priya.sharma@email.com',
      'phone': '+91-9876543211',
      'booth': 'Booth B-02',
      'verified': true,
      'hasVoted': false,
      'registrationDate': '2024-01-20',
      'lastActive': '2024-02-27 14:15',
      'status': 'Verified',
    },
    {
      'id': 'V003',
      'name': 'Amit Patel',
      'email': 'amit.patel@email.com',
      'phone': '+91-9876543212',
      'booth': 'Booth C-03',
      'verified': false,
      'hasVoted': false,
      'registrationDate': '2024-02-01',
      'lastActive': '2024-02-25 09:45',
      'status': 'Unverified',
    },
    {
      'id': 'V004',
      'name': 'Neha Singh',
      'email': 'neha.singh@email.com',
      'phone': '+91-9876543213',
      'booth': 'Booth D-04',
      'verified': true,
      'hasVoted': true,
      'registrationDate': '2024-01-10',
      'lastActive': '2024-02-28 11:20',
      'status': 'Verified',
    },
    {
      'id': 'V005',
      'name': 'Rohan Desai',
      'email': 'rohan.desai@email.com',
      'phone': '+91-9876543214',
      'booth': 'Booth A-02',
      'verified': false,
      'hasVoted': true,
      'registrationDate': '2024-02-05',
      'lastActive': '2024-02-28 13:00',
      'status': 'Unverified',
    },
    {
      'id': 'V006',
      'name': 'Anjali Verma',
      'email': 'anjali.verma@email.com',
      'phone': '+91-9876543215',
      'booth': 'Booth E-05',
      'verified': true,
      'hasVoted': true,
      'registrationDate': '2024-01-25',
      'lastActive': '2024-02-28 15:30',
      'status': 'Verified',
    },
    {
      'id': 'V007',
      'name': 'Vikram Singh',
      'email': 'vikram.singh@email.com',
      'phone': '+91-9876543216',
      'booth': 'Booth B-03',
      'verified': true,
      'hasVoted': false,
      'registrationDate': '2024-02-10',
      'lastActive': '2024-02-26 08:15',
      'status': 'Verified',
    },
    {
      'id': 'V008',
      'name': 'Deepa Nair',
      'email': 'deepa.nair@email.com',
      'phone': '+91-9876543217',
      'booth': 'Booth C-04',
      'verified': false,
      'hasVoted': false,
      'registrationDate': '2024-02-12',
      'lastActive': '2024-02-24 16:45',
      'status': 'Unverified',
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
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredVoters() {
    List<Map<String, dynamic>> filtered = allVoters;

    // Filter by tab
    if (_tabController.index == 0) {
      filtered = filtered.where((v) => v['verified'] == true).toList();
    } else {
      filtered = filtered.where((v) => v['verified'] == false).toList();
    }

    // Filter by status
    if (_statusFilter != 'All') {
      if (_statusFilter == 'Voted') {
        filtered = filtered.where((v) => v['hasVoted'] == true).toList();
      } else if (_statusFilter == 'Not Voted') {
        filtered = filtered.where((v) => v['hasVoted'] == false).toList();
      }
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (v) =>
                v['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v['email'].toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  int getTotalVoters() => allVoters.length;
  int getVerifiedVoters() =>
      allVoters.where((v) => v['verified'] == true).length;
  int getUnverifiedVoters() =>
      allVoters.where((v) => v['verified'] == false).length;
  int getVotedVoters() => allVoters.where((v) => v['hasVoted'] == true).length;

  double getVerificationRate() =>
      (getVerifiedVoters() / getTotalVoters() * 100).roundToDouble();
  double getVoterTurnout() =>
      (getVotedVoters() / getTotalVoters() * 100).roundToDouble();

  @override
  Widget build(BuildContext context) {
    final filteredVoters = getFilteredVoters();

    return Container(
      color: const Color(0xFFF8FAFB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voter Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor and manage all registered voters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Stats cards
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 1200
                        ? 4
                        : MediaQuery.of(context).size.width > 800
                        ? 2
                        : 1,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatsCard(
                        title: 'Total Voters',
                        value: getTotalVoters().toString(),
                        icon: Icons.people,
                        color: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFEFF6FF),
                      ),
                      _buildStatsCard(
                        title: 'Verified Voters',
                        value: getVerifiedVoters().toString(),
                        icon: Icons.verified_user,
                        color: const Color(0xFF10B981),
                        backgroundColor: const Color(0xFFECFDF5),
                      ),
                      _buildStatsCard(
                        title: 'Unverified',
                        value: getUnverifiedVoters().toString(),
                        icon: Icons.person_off,
                        color: const Color(0xFFF59E0B),
                        backgroundColor: const Color(0xFFFEF3C7),
                      ),
                      _buildStatsCard(
                        title: 'Voter Turnout',
                        value: '${getVoterTurnout().toStringAsFixed(1)}%',
                        icon: Icons.how_to_vote,
                        color: const Color(0xFF8B5CF6),
                        backgroundColor: const Color(0xFFF3E8FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Charts Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildVerificationChart()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildVoterStatusChart()),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildVerificationChart(),
                            const SizedBox(height: 20),
                            _buildVoterStatusChart(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            // Search and Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by name, ID, or email...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF6B7280),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          underline: const SizedBox(),
                          items: ['All', 'Voted', 'Not Voted']
                              .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              })
                              .toList()
                              .cast<DropdownMenuItem<String>>(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _statusFilter = newValue ?? 'All';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) {
                        setState(() {});
                      },
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF6B7280),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF2563EB),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Verified Voters'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Unverified Voters'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Voters Table
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: filteredVoters.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No voters found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 20,
                        columns: [
                          DataColumn(
                            label: Text(
                              'ID',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Name',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Phone',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Booth',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Voted',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Last Active',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: filteredVoters.map((voter) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  voter['id'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                              DataCell(Text(voter['name'])),
                              DataCell(Text(voter['email'])),
                              DataCell(Text(voter['phone'])),
                              DataCell(Text(voter['booth'])),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: voter['hasVoted']
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    voter['hasVoted'] ? 'Yes' : 'No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: voter['hasVoted']
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFDC2626),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(voter['lastActive'])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voter Verification Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: PieChartPainter(
                  values: [
                    getVerifiedVoters().toDouble(),
                    getUnverifiedVoters().toDouble(),
                  ],
                  colors: [const Color(0xFF10B981), const Color(0xFFF59E0B)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verified',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    '${getVerifiedVoters()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unverified',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    '${getUnverifiedVoters()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildVoterStatusChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voting Status Distribution',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: PieChartPainter(
                  values: [
                    getVotedVoters().toDouble(),
                    (getTotalVoters() - getVotedVoters()).toDouble(),
                  ],
                  colors: [const Color(0xFF8B5CF6), const Color(0xFFDEDEDE)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Voted', style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    '${getVotedVoters()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Not Voted',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    '${getTotalVoters() - getVotedVoters()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double currentAngle = -90;

    final total = values.isEmpty ? 1 : values.reduce((a, b) => a + b);

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 360;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _degreesToRadians(currentAngle),
        _degreesToRadians(sweepAngle),
        true,
        paint,
      );

      currentAngle += sweepAngle;
    }
  }

  double _degreesToRadians(double degrees) {
    return (degrees * 3.14159265359) / 180;
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
