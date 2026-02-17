import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_agent_page.dart';
import 'edit_agent_page.dart';
import 'agent_profile_page.dart';

class AdminAgentsPage extends StatefulWidget {
  const AdminAgentsPage({Key? key}) : super(key: key);

  @override
  State<AdminAgentsPage> createState() => _AdminAgentsPageState();
}

class _AdminAgentsPageState extends State<AdminAgentsPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _agents = [];
  String? _adminName;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";
  List<Map<String, dynamic>> _elections = [];
  int? _selectedElectionId;

  int _totalCount = 0;
  int _approvedCount = 0;
  int _pendingCount = 0;
  int _rejectedCount = 0;

  String _selectedFilter = "all";
  List<Map<String, dynamic>> _filteredAgents = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadAdminData();
    _loadElections();

    _isLoading = false; // 🔥 Important
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _adminName = prefs.getString('admin_name') ?? 'Admin';
      });
    } catch (e) {
      debugPrint('Error loading admin data: $e');
    }
  }

  Future<void> _loadElections() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/masteradmin/elections"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      setState(() {
        _elections = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<void> _loadAgents() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      // 🔥 Replace with selected election id
      if (_selectedElectionId == null) return;
      setState(() {
        _isLoading = true;
      });
      int electionId = _selectedElectionId!;

      final response = await http.get(
        Uri.parse("$baseUrl/agent/list/$electionId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          _agents = List<Map<String, dynamic>>.from(data);
          _applyFilter();
          _isLoading = false;
        });

        await _loadCounts(); // 🔥 ADD THIS
        _fadeController.forward(from: 0);
        _slideController.forward(from: 0);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading agents: $e");
    }
  }

  Future<void> _loadCounts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (_selectedElectionId == null) return;

      final response = await http.get(
        Uri.parse("$baseUrl/agent/counts/$_selectedElectionId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          _totalCount = data['total'] ?? 0;
          _approvedCount = data['approved'] ?? 0;
          _pendingCount = data['pending'] ?? 0;
          _rejectedCount = data['rejected'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Count load error: $e");
    }
  }

  void _applyFilter() {
    if (_selectedFilter == "all") {
      _filteredAgents = _agents;
    } else {
      _filteredAgents = _agents.where((c) {
        return (c['nomination_status'] ?? "pending").toString().toLowerCase() ==
            _selectedFilter;
      }).toList();
    }
  }

  Future<void> _saveAgents() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('agents_list', json.encode(_agents));
    } catch (e) {
      debugPrint('Error saving agents: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error saving agent'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _addAgent(Map<String, dynamic> newAgent) {
    setState(() {
      _agents.add(newAgent);
    });
    _saveAgents();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Agent added successfully'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editAgent(int index, Map<String, dynamic> updatedAgent) {
    setState(() {
      _agents[index] = updatedAgent;
    });
    _saveAgents();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Agent updated successfully'),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteAgent(int index) async {
    final agent = _agents[index];
    final agentId = agent['id'];
    final agentName = "${agent['first_name']} ${agent['last_name'] ?? ''}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever,
                        color: Colors.red.shade700,
                        size: 45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete Agent?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to remove $agentName?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          try {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            final token = prefs.getString("token");

                            final response = await http.delete(
                              Uri.parse("$baseUrl/agent/delete/$agentId"),
                              headers: {"Authorization": "Bearer $token"},
                            );

                            if (response.statusCode == 200) {
                              setState(() {
                                _agents.removeAt(index);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "$agentName deleted successfully",
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Delete failed"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Server error"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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

  void _navigateToAddAgent() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddAgentPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
      ),
    );

    _loadAgents(); // 🔥 Refresh from backend
  }

  void _navigateToEditAgent(Map<String, dynamic> agent, int index) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditAgentPage(agentId: agent['id']),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
      ),
    );
    _loadAgents(); // 🔥 Refresh
  }

  void _viewAgentDetails(Map<String, dynamic> agent) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AgentProfilePage(agentId: agent['id']),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOutCubic)),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent, int index) {
    ImageProvider? displayImage;

    if (agent['agent_photo_url'] != null) {
      displayImage = NetworkImage(agent['agent_photo_url']);
    } else if (agent['image'] != null && agent['image'].isNotEmpty) {
      displayImage = MemoryImage(base64Decode(agent['image']));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        leading: Hero(
          tag: "agent_${agent['id']}",
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: displayImage,
            child: displayImage == null
                ? Icon(Icons.flag, color: Colors.blue.shade700, size: 30)
                : null,
          ),
        ),
        title: Text(
          "${agent['first_name']} ${agent['last_name'] ?? ''}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Party: ${agent['party'] ?? 'N/A'}',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            Text(
              'Age: ${agent['age'] ?? 'N/A'}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: () => _viewAgentDetails(agent),
        trailing: PopupMenuButton<String>(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Icon(Icons.more_vert, color: Colors.blue.shade700),
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToEditAgent(agent, index);
            } else if (value == 'delete') {
              _deleteAgent(index);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count, Color color) {
    final bool isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 10,
              backgroundColor: isSelected ? Colors.white : color,
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 3,
        centerTitle: true,
        title: Text(
          'Welcome, $_adminName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔥 ELECTION DROPDOWN SECTION
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: DropdownButtonFormField<int>(
              value: _selectedElectionId,
              items: _elections.map((e) {
                return DropdownMenuItem<int>(
                  value: e['id'],
                  child: Text(e['election_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedElectionId = value;
                });
                _loadAgents(); // 🔥 Load agents when election changes
              },
              decoration: InputDecoration(
                labelText: "Select Election",
                prefixIcon: Icon(
                  Icons.how_to_vote,
                  color: Colors.blue.shade700,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
            ),
          ),
          if (_selectedElectionId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterChip("All", "all", _totalCount, Colors.blue),
                  _buildFilterChip(
                    "Approved",
                    "approved",
                    _approvedCount,
                    Colors.green,
                  ),
                  _buildFilterChip(
                    "Pending",
                    "pending",
                    _pendingCount,
                    Colors.orange,
                  ),
                  _buildFilterChip(
                    "Rejected",
                    "rejected",
                    _rejectedCount,
                    Colors.red,
                  ),
                ],
              ),
            ),

          // 🔥 MAIN CONTENT
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade700,
                    ),
                  )
                : _selectedElectionId == null
                ? Center(
                    child: Text(
                      "Please select an election",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : _agents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Agents Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first agent to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position: _slideController.drive(
                        Tween(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
                      ),
                      child: RefreshIndicator(
                        onRefresh: _loadAgents,
                        backgroundColor: Colors.white,
                        color: Colors.blue.shade700,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredAgents.length,
                          itemBuilder: (context, index) =>
                              _buildAgentCard(_filteredAgents[index], index),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        elevation: 5,
        onPressed: _selectedElectionId == null ? null : _navigateToAddAgent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Agent',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
