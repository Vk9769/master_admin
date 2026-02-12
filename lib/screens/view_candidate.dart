import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_candidate_page.dart';
import 'edit_candidate_page.dart';
import 'candidate_profile_page.dart';

class AdminCandidatesPage extends StatefulWidget {
  const AdminCandidatesPage({Key? key}) : super(key: key);

  @override
  State<AdminCandidatesPage> createState() => _AdminCandidatesPageState();
}

class _AdminCandidatesPageState extends State<AdminCandidatesPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _candidates = [];
  String? _adminName;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";
  List<Map<String, dynamic>> _elections = [];
  int? _selectedElectionId;

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
    _loadCandidates();
    _loadElections();
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

  Future<void> _loadCandidates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return;

      // 🔥 Replace with selected election id
      if (_selectedElectionId == null) return;

      int electionId = _selectedElectionId!;



      final response = await http.get(
        Uri.parse("$baseUrl/candidate/list/$electionId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          _candidates = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });

        _fadeController.forward();
        _slideController.forward();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading candidates: $e");
    }
  }


  Future<void> _saveCandidates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('candidates_list', json.encode(_candidates));
    } catch (e) {
      debugPrint('Error saving candidates: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error saving candidate'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _addCandidate(Map<String, dynamic> newCandidate) {
    setState(() {
      _candidates.add(newCandidate);
    });
    _saveCandidates();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Candidate added successfully'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editCandidate(int index, Map<String, dynamic> updatedCandidate) {
    setState(() {
      _candidates[index] = updatedCandidate;
    });
    _saveCandidates();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Candidate updated successfully'),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteCandidate(int index) async {
    final candidate = _candidates[index];
    final candidateId = candidate['id'];
    final candidateName =
        "${candidate['first_name']} ${candidate['last_name'] ?? ''}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
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
                      child: Icon(Icons.delete_forever,
                          color: Colors.red.shade700, size: 45),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete Candidate?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to remove $candidateName?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          try {
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            final token = prefs.getString("token");

                            final response = await http.delete(
                              Uri.parse(
                                  "$baseUrl/candidate/delete/$candidateId"),
                              headers: {
                                "Authorization": "Bearer $token",
                              },
                            );

                            if (response.statusCode == 200) {
                              setState(() {
                                _candidates.removeAt(index);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "$candidateName deleted successfully"),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                  const Text("Delete failed"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                const Text("Server error"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
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


  void _navigateToAddCandidate() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const AddCandidatePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
      ),
    );

    _loadCandidates(); // 🔥 Refresh from backend
  }

  void _navigateToEditCandidate(Map<String, dynamic> candidate, int index) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditCandidatePage(candidateId: candidate['id']),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
      ),
    );
    _loadCandidates(); // 🔥 Refresh
  }

  void _viewCandidateDetails(Map<String, dynamic> candidate) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CandidateProfilePage(candidateId: candidate['id']),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOutCubic)),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCandidateCard(
      Map<String, dynamic> candidate, int index) {
    ImageProvider? displayImage;

    if (candidate['candidate_photo_url'] != null) {
      displayImage = NetworkImage(candidate['candidate_photo_url']);
    }
    else if (candidate['image'] != null && candidate['image'].isNotEmpty) {
      displayImage = MemoryImage(base64Decode(candidate['image']));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Hero(
          tag: "candidate_${candidate['id']}",
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
          "${candidate['first_name']} ${candidate['last_name'] ?? ''}",
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
              'Party: ${candidate['party'] ?? 'N/A'}',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            Text(
              'Age: ${candidate['age'] ?? 'N/A'}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: () => _viewCandidateDetails(candidate),
        trailing: PopupMenuButton<String>(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: Icon(Icons.more_vert, color: Colors.blue.shade700),
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToEditCandidate(candidate, index);
            } else if (value == 'delete') {
              _deleteCandidate(index);
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
                _loadCandidates(); // 🔥 Load candidates when election changes
              },
              decoration: InputDecoration(
                labelText: "Select Election",
                prefixIcon: Icon(Icons.how_to_vote, color: Colors.blue.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
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
                : _candidates.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80,
                      color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Candidates Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first candidate to get started',
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
                  ).chain(
                    CurveTween(
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: _loadCandidates,
                  backgroundColor: Colors.white,
                  color: Colors.blue.shade700,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _candidates.length,
                    itemBuilder: (context, index) =>
                        _buildCandidateCard(
                            _candidates[index], index),
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
        onPressed: _selectedElectionId == null
            ? null
            : _navigateToAddCandidate,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Candidate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
