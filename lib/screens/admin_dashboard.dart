import 'package:flutter/material.dart';
import 'login_page.dart';
import 'add_polling_booth_page.dart';
import 'view_all_booth.dart';
import 'add_agent_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'view_all_agents.dart';
import 'all_voting_status_page.dart';
import 'admin_profile_page.dart';
import 'admin_message_center_page.dart';
import 'view_all_voters.dart';
import 'view_candidate.dart';
import 'admin_actions_page.dart';
import 'election_declaration_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

/// Utility to format large numbers
String formatNumber(int number) {
  if (number >= 1000000000) {
    return '${(number / 1000000000).toStringAsFixed(2)}B';
  } else if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(2)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  } else {
    return number.toString();
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int polls = 0;
  int agents = 0;
  int voters = 0;
  int reports = 0;
  int votesCasted = 0;
  int votesPending = 0;

  bool isLoading = true;

  int _currentIndex = 0; // For bottom navigation

  String adminName = '';
  String adminEmail = '';
  String adminPhoto = '';

  DateTime electionStartTime = DateTime.now().subtract(Duration(hours: 3));

  // ===== Election analytics =====
  String? selectedElection;

  int electionTotalVoters = 0;
  int electionVotesCasted = 0;
  int electionOurVoters = 0;

  // Enhanced graph data with real-time updates
  late List<double> _totalVotersTrend = [
    5000,
    12000,
    18500,
    26000,
    34500,
    43000,
    52000,
    61000,
    69000,
    75000,
  ];

  late List<double> _votesCastedTrend = [
    3000,
    8000,
    14000,
    21000,
    29500,
    37000,
    45500,
    54000,
    62000,
    70000,
  ];

  late List<double> _ourVotersTrend = [
    1800,
    4200,
    7500,
    11000,
    16500,
    21500,
    26500,
    31500,
    36000,
    40500,
  ];

  // Graph interaction & zoom variables
  double _graphScale = 1.0;
  Offset _graphOffset = Offset.zero;
  FlSpot? _selectedSpot;
  Timer? _realtimeUpdateTimer;
  bool isGraphRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
    loadAdminInfo();
  }

  @override
  void dispose() {
    _realtimeUpdateTimer?.cancel();
    super.dispose();
  }

  double get winningPercentage {
    if (electionVotesCasted == 0) return 0;
    return (electionOurVoters / electionVotesCasted) * 100;
  }

  Future<void> loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('admin_name') ?? '';
      adminEmail = prefs.getString('admin_email') ?? '';
      adminPhoto = prefs.getString('admin_photo') ?? '';
    });

    print("👤 Admin Name Loaded: $adminName");
    print("📧 Admin Email Loaded: $adminEmail");
  }

  Widget _electionAnalyticsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== SELECT ELECTION =====
            DropdownButtonFormField<String>(
              value: selectedElection,
              hint: const Text("Select Election"),
              items: const [
                DropdownMenuItem(value: "e1", child: Text("Election 2026")),
                DropdownMenuItem(value: "e2", child: Text("By Election 2025")),
              ],
              onChanged: (v) {
                setState(() {
                  selectedElection = v;

                  // TEMP values – later replace with API
                  electionTotalVoters = 125000;
                  electionVotesCasted = 78300;
                  electionOurVoters = 61200;
                  _selectedSpot = null;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            if (selectedElection != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _simpleKpi("Total Voters", electionTotalVoters),
                  _simpleKpi("Votes Casted", electionVotesCasted),
                  _simpleKpi("Our Voters", electionOurVoters),
                ],
              ),
            ] else
              const Center(
                child: Text(
                  "Select an election to view analytics",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            const SizedBox(height: 24),

            // ===== GRAPH CONTROLS (Zoom, Reset, Refresh) =====
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGraphButton(
                    icon: Icons.zoom_in,
                    label: "Zoom In",
                    onPressed: () {
                      setState(() {
                        _graphScale = (_graphScale + 0.2).clamp(1.0, 3.0);
                      });
                    },
                  ),
                  _buildGraphButton(
                    icon: Icons.zoom_out,
                    label: "Zoom Out",
                    onPressed: () {
                      setState(() {
                        _graphScale = (_graphScale - 0.2).clamp(1.0, 3.0);
                      });
                    },
                  ),
                  _buildGraphButton(
                    icon: Icons.restore,
                    label: "Reset",
                    onPressed: () {
                      setState(() {
                        _graphScale = 1.0;
                        _graphOffset = Offset.zero;
                        _selectedSpot = null;
                      });
                    },
                  ),
                  _buildGraphButton(
                    icon: Icons.refresh,
                    label: "Refresh",
                    isLoading: isGraphRefreshing,
                    onPressed: _refreshGraphData,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== ENHANCED LINE GRAPH WITH ZOOM & TOUCH INTERACTION =====
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _graphOffset += details.delta;
                        });
                      },
                      child: LineChart(_buildEnhancedLineChartData()),
                    ),
                  ),
                  if (_selectedSpot != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Text(
                          "📊 Point: (${_selectedSpot!.x.toStringAsFixed(1)}, ${_selectedSpot!.y.toStringAsFixed(2)})",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== GRAPH LEGEND =====
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _legendItem(
                    "Total Voters",
                    Colors.blue,
                    _totalVotersTrend.last.toInt(),
                  ),

                  _legendItem(
                    "Votes Casted",
                    Colors.green,
                    _votesCastedTrend.last.toInt(),
                  ),

                  _legendItem(
                    "Our Voters",
                    Colors.orange,
                    _ourVotersTrend.last.toInt(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== WINNING PERCENTAGE =====
            Center(
              child: Column(
                children: [
                  const Text(
                    "Chances of Winning",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${winningPercentage.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Last updated: Real-time",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced line chart data with better styling and interactivity
  LineChartData _buildEnhancedLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey[200]!, strokeWidth: 0.8);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.grey[200]!, strokeWidth: 0.8);
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!, width: 1.2),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              final time = electionStartTime.add(
                Duration(minutes: value.toInt()),
              );

              final formatted =
                  "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

              return Text(
                formatted,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                formatNumber(value.toInt()),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              );
            },

            reservedSize: 42,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        _buildEnhancedLine(_totalVotersTrend, Colors.blue, 2),
        _buildEnhancedLine(_votesCastedTrend, Colors.green, 2),
        _buildEnhancedLine(_ourVotersTrend, Colors.orange, 2),
      ],
      minX: 0,
      maxX: (_totalVotersTrend.length - 1).toDouble() * _graphScale,
      minY: 0,
      maxY: _votesCastedTrend.reduce((a, b) => a > b ? a : b) + 500,

      clipData: const FlClipData.all(),
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              return LineTooltipItem(
                lineBarSpot.y.toStringAsFixed(2),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
        ),

        touchCallback: (event, response) {
          if (response != null &&
              response.lineBarSpots != null &&
              response.lineBarSpots!.isNotEmpty) {
            setState(() {
              final spot = response.lineBarSpots!.first;
              _selectedSpot = FlSpot(spot.x, spot.y);
            });
          }
        },
      ),
    );
  }

  // Enhanced line with better styling
  LineChartBarData _buildEnhancedLine(
    List<double> data,
    Color color,
    double width,
  ) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) {
        final time = electionStartTime.add(Duration(minutes: e.key * 15));

        final minutesSinceStart = time
            .difference(electionStartTime)
            .inMinutes
            .toDouble();

        return FlSpot(minutesSinceStart, e.value);
      }).toList(),

      isCurved: false,
      barWidth: width,
      color: color,
      dotData: FlDotData(
        show: false,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  // Graph control buttons
  Widget _buildGraphButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[700]!,
                    ),
                  ),
                )
              : Icon(icon, size: 16),
          label: Text(
            label,
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[700],
            side: BorderSide(color: Colors.blue[300]!, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // Legend item for graph
  Widget _legendItem(String label, Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),

        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),

        const SizedBox(width: 8),

        Text(
          formatNumber(value),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Refresh graph data with real-time simulation
  Future<void> _refreshGraphData() async {
    setState(() {
      isGraphRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      // Simulate real-time data update by adding new values
      _totalVotersTrend.add(_totalVotersTrend.last + 600);
      _votesCastedTrend.add(
        _votesCastedTrend.last + (500 + (DateTime.now().second * 3)),
      );
      _ourVotersTrend.add(_ourVotersTrend.last + 350);

      // Keep only last 10 data points for performance
      if (_totalVotersTrend.length > 10) {
        _totalVotersTrend.removeAt(0);
        _votesCastedTrend.removeAt(0);
        _ourVotersTrend.removeAt(0);
      }

      _selectedSpot = null;
      isGraphRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📊 Graph data refreshed successfully!'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _simpleKpi(String title, int value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          formatNumber(value),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> fetchDashboardStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(
          'https://voting-backend-6px8.onrender.com/api/admin/dashboard',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📊 Raw Dashboard Response: ${response.body}");

      final resBody = jsonDecode(response.body);

      setState(() {
        if (response.statusCode == 200 && resBody['success'] == true) {
          final data = resBody['data'] ?? {};

          polls = int.tryParse(data['polls']?.toString() ?? '0') ?? 0;
          agents = int.tryParse(data['agents']?.toString() ?? '0') ?? 0;
          voters = int.tryParse(data['voters']?.toString() ?? '0') ?? 0;
          reports = int.tryParse(data['reports']?.toString() ?? '0') ?? 0;

          votesCasted =
              int.tryParse(data['votesCasted']?.toString() ?? '0') ?? 0;

          votesPending =
              int.tryParse(data['votesPending']?.toString() ?? '0') ?? 0;
        } else {
          print("⚠ API error or success=false");

          // Safe fallback (NO dummy data)
          polls = 0;
          agents = 0;
          voters = 0;
          reports = 0;
          votesCasted = 0;
          votesPending = 0;
        }

        isLoading = false;
      });
    } catch (e) {
      print("❌ ERROR in fetchDashboardStats(): $e");

      setState(() {
        polls = 0;
        agents = 0;
        voters = 0;
        reports = 0;
        votesCasted = 0;
        votesPending = 0;
        isLoading = false;
      });
    }
  }

  AppBar _buildAppBar() {
    String title;
    switch (_currentIndex) {
      case 0:
        title = 'Admin Dashboard';
        break;
      case 1:
        title = 'Admin Actions';
        break;
      case 2:
        title = 'Update Center';
        break;
      default:
        title = 'Admin Dashboard';
    }

    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue,
      centerTitle: true,
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _dashboardBody();
      case 1:
        return const AdminActionsPage(); // NEW PAGE
      case 2:
        return const AdminMessageCenterPage();
      default:
        return _dashboardBody();
    }
  }

  Widget _dashboardBody() {
    final Color primary = Theme.of(context).primaryColor;

    final Color foreground = Colors.black87;
    final Color cardBg = Colors.white;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 1200
                  ? 4
                  : constraints.maxWidth >= 900
                  ? 3
                  : 2;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== ELECTION ANALYTICS (NEW) =====
                    _electionAnalyticsSection(),

                    const SizedBox(height: 24),
                    // Header
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // KPI Grid
                    GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: constraints.maxWidth < 400 ? 150 : 170,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: 'Polling Booths',
                          value: polls.toString(),
                          icon: Icons.how_to_vote,
                          color: primary,
                          background: cardBg,
                        ),
                        StatCard(
                          title: 'Agents',
                          value: agents.toString(),
                          icon: Icons.group,
                          color: Colors.teal,
                          background: cardBg,
                        ),
                        StatCard(
                          title: 'Voters',
                          value: voters.toString(),
                          icon: Icons.people,
                          color: Colors.orange,
                          background: cardBg,
                        ),
                        StatCard(
                          title: 'Reports',
                          value: reports.toString(),
                          icon: Icons.bar_chart,
                          color: Colors.blueGrey,
                          background: cardBg,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Voting Status Card with progress bars
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.how_to_reg,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Voting Status",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AllVotingStatusPage(
                                            statusType: "casted",
                                          ),
                                        ),
                                      );
                                    },
                                    child: _VotingStatusCard(
                                      title: "Votes Casted",
                                      value: formatNumber(votesCasted),
                                      color: Colors.green,
                                      icon: Icons.done_all,
                                      progress: (votesCasted + votesPending) > 0
                                          ? votesCasted /
                                                (votesCasted + votesPending)
                                          : 0.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AllVotingStatusPage(
                                            statusType: "pending",
                                          ),
                                        ),
                                      );
                                    },
                                    child: _VotingStatusCard(
                                      title: "Votes Pending",
                                      value: formatNumber(votesPending),
                                      color: Colors.redAccent,
                                      icon: Icons.pending_actions,
                                      progress: (votesCasted + votesPending) > 0
                                          ? votesPending /
                                                (votesCasted + votesPending)
                                          : 0.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Actions'),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Update Center',
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: adminPhoto.isNotEmpty
                      ? NetworkImage(adminPhoto)
                      : const AssetImage('assets/admin_avatar.png')
                            as ImageProvider,
                ),

                SizedBox(height: 10),
                Text(
                  adminName.isNotEmpty ? adminName : 'Admin',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adminEmail.isNotEmpty ? adminEmail : '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('View Profile'),
            onTap: () async {
              Navigator.pop(context);

              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfilePage()),
              );

              // 🔄 refresh drawer data
              loadAdminInfo();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blue),
            title: const Text('Settings'),
            onTap: () {},
          ),

          const Divider(thickness: 1),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Admin Actions',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black, // 🔥 CHANGE HERE
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.how_to_vote_outlined, color: Colors.blue),
            title: const Text('Election Declaration'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ElectionDeclarationPage(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.how_to_vote, color: Colors.blue),
            title: const Text('View Candidates'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminCandidatesPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.add_location_alt, color: Colors.blue),
            title: const Text('Add Polling Booth'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddPollingBoothPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: const Text('View Booths'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewAllBoothsPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            title: const Text('Add Agent'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAgentPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.group, color: Colors.blue),
            title: const Text('View Agents'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewAllAgentsPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.people_alt, color: Colors.blue),
            title: const Text('View Voters'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewAllVotersPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// 🎯 Voting Status Subcards with progress bars
class _VotingStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final double progress;

  const _VotingStatusCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

// KPI Card
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final bool isSmall = MediaQuery.of(context).size.width < 380;

    return Card(
      color: background,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _IconBadge(icon: icon, color: color),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Rounded icon chip
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

// Optional: simple profile screen
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(radius: 50, child: Icon(Icons.person, size: 48)),
            SizedBox(height: 16),
            Text(
              'Admin Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'admin@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
