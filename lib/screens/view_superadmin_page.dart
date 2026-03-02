import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_super_admin_page.dart';
import 'edit_super_admin_page.dart';
import 'super_admin_profile_page.dart';

class ViewSuperAdminPage extends StatefulWidget {
  const ViewSuperAdminPage({Key? key}) : super(key: key);

  @override
  State<ViewSuperAdminPage> createState() => _ViewSuperAdminPageState();
}

class _ViewSuperAdminPageState extends State<ViewSuperAdminPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _superAdmins = [];
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
  List<Map<String, dynamic>> _filteredSuperAdmins = [];

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

  String? _selectedState;
  List<String> _states = [];

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

  Future<void> _fetchStatesByElection(int electionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/common/election-states?election_id=$electionId",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          _states = List<String>.from(data);
          _selectedState = null;
        });
      }
    } catch (e) {
      debugPrint("State fetch error: $e");
    }
  }

  Future<void> _loadSuperAdmins() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      if (_selectedElectionId == null || _selectedState == null) return;

      setState(() {
        _isLoading = true;
      });

      int electionId = _selectedElectionId!;

      // ✅ ADD HERE
      String url =
          "$baseUrl/super-admin/list?election_id=$electionId&state=$_selectedState";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          _superAdmins = List<Map<String, dynamic>>.from(data);
          _applyFilter();
          _isLoading = false;
        });

        await _loadCounts();
        _fadeController.forward(from: 0);
        _slideController.forward(from: 0);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading super admins: $e");
    }
  }

  Future<void> _loadCounts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (_selectedElectionId == null || _selectedState == null) return;
      print("COUNT API → election=$_selectedElectionId state=$_selectedState");
      final response = await http.get(
        Uri.parse(
          "$baseUrl/super-admin/counts?election_id=$_selectedElectionId&state=$_selectedState",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;
        print("COUNT RESPONSE => ${response.body}");
        setState(() {
          _totalCount = int.parse(data['total'].toString());
          _approvedCount = int.parse(data['approved'].toString());
          _pendingCount = int.parse(data['pending'].toString());
          _rejectedCount = int.parse(data['rejected'].toString());
        });
      }
    } catch (e) {
      debugPrint("Count load error: $e");
    }
  }

  void _applyFilter() {
    if (_selectedFilter == "all") {
      _filteredSuperAdmins = _superAdmins;
    } else {
      _filteredSuperAdmins = _superAdmins.where((c) {
        return (c['nomination_status'] ?? "pending").toString().toLowerCase() ==
            _selectedFilter;
      }).toList();
    }
  }

  Future<void> _saveSuperAdmins() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('super_admins_list', json.encode(_superAdmins));
    } catch (e) {
      debugPrint('Error saving super admins: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error saving super admin'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _addSuperAdmin(Map<String, dynamic> newSuperAdmin) {
    setState(() {
      _superAdmins.add(newSuperAdmin);
    });
    _saveSuperAdmins();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Super Admin added successfully'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editSuperAdmin(int index, Map<String, dynamic> updatedSuperAdmin) {
    setState(() {
      _superAdmins[index] = updatedSuperAdmin;
    });
    _saveSuperAdmins();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Super Admin updated successfully'),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteSuperAdmin(int index) async {
    final superAdmin = _superAdmins[index];
    final superAdminId = superAdmin['id'];
    final superAdminName =
        "${superAdmin['first_name']} ${superAdmin['last_name'] ?? ''}";

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
                  'Delete Super Admin?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to remove $superAdminName?',
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
                              Uri.parse(
                                "$baseUrl/super-admin/delete/$superAdminId",
                              ),
                              headers: {"Authorization": "Bearer $token"},
                            );

                            if (response.statusCode == 200) {
                              setState(() {
                                _superAdmins.removeAt(index);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "$superAdminName deleted successfully",
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

  void _navigateToAddSuperAdmin() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddSuperAdminPage(),
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

    _loadSuperAdmins(); // 🔥 Refresh from backend
  }

  void _navigateToEditSuperAdmin(
    Map<String, dynamic> superAdmin,
    int index,
  ) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditSuperAdminPage(superAdminId: superAdmin['id'].toString()),
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
    _loadSuperAdmins(); // 🔥 Refresh
  }

  void _viewSuperAdminDetails(Map<String, dynamic> superAdmin) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SuperAdminProfilePage(superadminId: superAdmin['id']),
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

  Widget _buildSuperAdminCard(Map<String, dynamic> superAdmin, int index) {
    ImageProvider? displayImage;

    if (superAdmin['profile_photo'] != null) {
      displayImage = NetworkImage(superAdmin['profile_photo']);
    } else if (superAdmin['image'] != null && superAdmin['image'].isNotEmpty) {
      displayImage = MemoryImage(base64Decode(superAdmin['image']));
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
          tag: "superAdmin${superAdmin['id']}",
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
          "${superAdmin['first_name']} ${superAdmin['last_name'] ?? ''}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Show selected State
            Text(
              'State: ${_selectedState ?? "N/A"}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 4),
          ],
        ),
        onTap: () => _viewSuperAdminDetails(superAdmin),
        trailing: PopupMenuButton<String>(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Icon(Icons.more_vert, color: Colors.blue.shade700),
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToEditSuperAdmin(superAdmin, index);
            } else if (value == 'delete') {
              _deleteSuperAdmin(index);
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
          'Super Admin Management',
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
                  _selectedState = null;
                  _states = [];
                });

                if (value != null) {
                  _fetchStatesByElection(value);
                }
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: DropdownButtonFormField<String>(
                value: _selectedState,
                items: _states.map((state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });

                  _loadSuperAdmins();
                },
                decoration: InputDecoration(
                  labelText: "Select State",
                  prefixIcon: Icon(Icons.map, color: Colors.blue.shade700),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),
            ),

          if (_selectedElectionId != null && _selectedState != null)
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
                : _superAdmins.isEmpty
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
                          'No Super Admins Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first super admin to get started',
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
                        onRefresh: _loadSuperAdmins,
                        backgroundColor: Colors.white,
                        color: Colors.blue.shade700,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredSuperAdmins.length,
                          itemBuilder: (context, index) => _buildSuperAdminCard(
                            _filteredSuperAdmins[index],
                            index,
                          ),
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
        onPressed: _navigateToAddSuperAdmin,

        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Super Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
