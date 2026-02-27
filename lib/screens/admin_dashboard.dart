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

  late TransformationController _transformationController;
  bool _isPanEnabled = true;
  bool _isScaleEnabled = true;

  double minX = 0;
  double maxX = 6;
  double minY = 0;
  double maxY = 4000;

  int totalVoters = 5000;
  int ourVotesCasted = 0;

  final List<FlSpot> totalVotingData = [
    FlSpot(0, 400),
    FlSpot(1, 900),
    FlSpot(2, 1500),
    FlSpot(3, 2100),
    FlSpot(4, 2700),
    FlSpot(5, 3100),
    FlSpot(6, 3500),
  ];

  final List<FlSpot> ourVotingData = [
    FlSpot(0, 200),
    FlSpot(1, 450),
    FlSpot(2, 900),
    FlSpot(3, 1300),
    FlSpot(4, 1700),
    FlSpot(5, 2100),
    FlSpot(6, 2500),
  ];

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
    loadAdminInfo();

    _transformationController = TransformationController();
    _transformationController.addListener(_updateYAxis);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  double _getNiceInterval(double range) {
    double roughStep = range / 5;

    if (roughStep <= 10) return 10;
    if (roughStep <= 50) return 50;
    if (roughStep <= 100) return 100;
    if (roughStep <= 250) return 250;
    if (roughStep <= 500) return 500;
    if (roughStep <= 1000) return 1000;
    if (roughStep <= 2500) return 2500;
    if (roughStep <= 5000) return 5000;

    return (roughStep / 1000).ceil() * 1000;
  }

  void _updateYAxis() {
    final matrix = _transformationController.value;

    final scaleX = matrix.getMaxScaleOnAxis();

    final translationX = matrix.row0[3]; // REAL PAN POSITION

    // Total range
    const double totalRange = 6;

    // Visible range after zoom
    double visibleRange = totalRange / scaleX;

    // Calculate left boundary from translation
    double newMinX = (-translationX / scaleX).clamp(
      0.0,
      totalRange - visibleRange,
    );

    double newMaxX = newMinX + visibleRange;

    final visibleSpots = [
      ...totalVotingData,
      ...ourVotingData,
    ].where((e) => e.x >= newMinX && e.x <= newMaxX);

    if (visibleSpots.isEmpty) return;

    double localMinY = visibleSpots
        .map((e) => e.y)
        .reduce((a, b) => a < b ? a : b);

    double localMaxY = visibleSpots
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);

    if (newMinX == minX &&
        newMaxX == maxX &&
        localMinY == minY &&
        localMaxY == maxY) {
      return;
    }

    setState(() {
      minX = newMinX;
      maxX = newMaxX;

      double padding = (localMaxY - localMinY) * 0.1;

      double interval = _getNiceInterval(localMaxY - localMinY);

      minY = ((localMinY - padding) / interval).floor() * interval;
      minY = minY < 0 ? 0 : minY;

      maxY = ((localMaxY + padding) / interval).ceil() * interval;
    });
  }

  Widget _buildVotingGraph() {
    final Color accent = Colors.blue;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 18),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ⭐ PRO HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.trending_up, color: accent),
                ),

                const SizedBox(width: 12),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Live Voting Trend",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B2C5D),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Votes received every 5 minutes",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 26),

            AspectRatio(
              aspectRatio: 1.4,
              child: LineChart(
                transformationConfig: FlTransformationConfig(
                  scaleAxis: FlScaleAxis.horizontal,
                  minScale: 1.0,
                  maxScale: 20,
                  panEnabled: _isPanEnabled,
                  scaleEnabled: _isScaleEnabled,
                  transformationController: _transformationController,
                ),
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.25),

                        strokeWidth: 1,
                        dashArray: [6, 6],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.25),

                        strokeWidth: 1,
                        dashArray: [6, 6],
                      );
                    },
                  ),

                  borderData: FlBorderData(show: false),

                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots.map((e) {
                          return LineTooltipItem(
                            "${e.y.toInt()} votes",
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  titlesData: FlTitlesData(
                    show: true,

                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    leftTitles: AxisTitles(
                      drawBelowEverything: true,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _getNiceInterval(maxY - minY),

                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const times = [
                            "10:00",
                            "10:05",
                            "10:10",
                            "10:15",
                            "10:20",
                            "10:25",
                            "10:30",
                          ];

                          if (value.toInt() < times.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                times[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),

                  lineBarsData: [
                    /// TOTAL VOTES (AUTO GREEN INTENSITY)
                    LineChartBarData(
                      spots: totalVotingData,
                      isCurved: true,
                      barWidth: 3,

                      /// COLOR BASED ON TOTAL VOTES VALUE
                      color: votesCasted >= ourVotesCasted
                          ? Colors.green
                          : Colors.green.shade300,

                      dotData: const FlDotData(show: false),

                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.25),
                            Colors.green.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    /// OUR VOTES (AUTO ORANGE INTENSITY)
                    LineChartBarData(
                      spots: ourVotingData,
                      isCurved: true,
                      barWidth: 3,

                      /// COLOR BASED ON PERFORMANCE
                      color: ourVotesCasted >= (votesCasted * 0.5)
                          ? Colors.orange
                          : Colors.orange.shade300,

                      dotData: const FlDotData(show: false),

                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.25),
                            Colors.orange.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
                duration: Duration.zero,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                /// TOTAL VOTERS
                Expanded(
                  child: _graphStat(
                    "Total Voters",
                    formatNumber(totalVoters),
                    Colors.blue,
                    Icons.people,
                  ),
                ),

                const SizedBox(width: 12),

                /// TOTAL VOTES CASTED
                Expanded(
                  child: _graphStat(
                    "Votes Casted",
                    formatNumber(votesCasted),
                    Colors.green,
                    Icons.done_all,
                  ),
                ),

                const SizedBox(width: 12),

                /// OUR VOTES
                Expanded(
                  child: _graphStat(
                    "Our Votes",
                    formatNumber(ourVotesCasted),
                    Colors.orange,
                    Icons.how_to_vote,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// ⭐ WINNING CHANCE ANALYTICS
            Center(child: _buildWinningChance()),
          ],
        ),
      ),
    );
  }

  Widget _buildWinningChance() {
    /// 🔥 CALCULATE WINNING %
    double winningPercent = 0;

    if (votesCasted > 0) {
      winningPercent = (ourVotesCasted / votesCasted) * 100;
    }

    /// COLOR LOGIC (Election style)
    Color indicatorColor;

    if (winningPercent >= 60) {
      indicatorColor = Colors.green;
    } else if (winningPercent >= 40) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.red;
    }

    return Column(
      children: [
        const Text(
          "Chance of Winning",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B2C5D),
          ),
        ),

        const SizedBox(height: 12),

        /// 🔥 PROGRESS INDICATOR (Professional look)
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: winningPercent / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.withOpacity(.2),
                color: indicatorColor,
              ),
            ),

            Text(
              "${winningPercent.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: indicatorColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          winningPercent >= 60
              ? "Strong Lead"
              : winningPercent >= 40
              ? "Competitive"
              : "Needs Push",
          style: TextStyle(fontWeight: FontWeight.w600, color: indicatorColor),
        ),
      ],
    );
  }

  Widget _graphStat(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
          ourVotesCasted = votesCasted ~/ 2; // temporary logic
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

                    _buildVotingGraph(),
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
                MaterialPageRoute(builder: (_) => const AdminAgentsPage()),
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
