import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AgentProfilePage extends StatefulWidget {
  final dynamic agentId;

  const AgentProfilePage({super.key, required this.agentId});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  Map<String, dynamic>? agent;
  bool isLoading = true;

  final String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";

  @override
  void initState() {
    super.initState();
    _loadAgentDetails();
  }

  Future<void> _loadAgentDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/agent/${widget.agentId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          agent = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateNominationStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.put(
        Uri.parse("$baseUrl/agent/update/${widget.agentId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"nomination_status": status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Agent $status successfully"),
            backgroundColor: Colors.green,
          ),
        );

        _loadAgentDetails(); // 🔥 refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Update failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade700;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: themeColor)),
      );
    }

    if (agent == null) {
      return const Scaffold(body: Center(child: Text("Agent not found")));
    }

    final profileImage =
        agent!['profile_photo'] != null &&
            agent!['profile_photo'].toString().isNotEmpty
        ? NetworkImage(
            agent!['profile_photo'].toString().startsWith("http")
                ? agent!['profile_photo']
                : "$baseUrl/${agent!['profile_photo']}",
          )
        : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: Colors.blue.shade700,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildTricolorHeader(profileImage, themeColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Personal Information"),
                  _buildInfoCard(
                    Icons.person,
                    "Name",
                    "${agent!['first_name']} ${agent!['last_name'] ?? ''}",
                    themeColor,
                  ),
                  _buildInfoCard(
                    Icons.wc,
                    "Gender",
                    agent!['gender'],
                    themeColor,
                  ),

                  _buildInfoCard(
                    Icons.calendar_today,
                    "Date of Birth",
                    _formatDOB(agent!['date_of_birth']),
                    themeColor,
                  ),

                  _buildInfoCard(
                    Icons.how_to_vote,
                    "Voter ID",
                    agent!['voter_id'],
                    themeColor,
                  ),

                  _buildInfoCard(
                    Icons.credit_card,
                    "Aadhaar Number",
                    agent!['gov_id_no'],
                    themeColor,
                  ),

                  _buildInfoCard(
                    Icons.home,
                    "Personal Address",
                    agent!['address'],
                    themeColor,
                  ),

                  const SizedBox(height: 20),

                  _buildSectionTitle("Contact Information"),
                  _buildInfoCard(
                    Icons.phone_android,
                    "Phone",
                    agent!['phone'],
                    themeColor,
                  ),
                  _buildInfoCard(
                    Icons.email,
                    "Email",
                    agent!['email'],
                    themeColor,
                  ),

                  const SizedBox(height: 12),

                  _buildSectionTitle("Election & Booth Details"),

                  _buildInfoCard(
                    Icons.how_to_vote,
                    "Election",
                    agent!['election_name'],
                    themeColor,
                  ),

                  if (agent!['area_type'] == "WARD")
                    _buildInfoCard(
                      Icons.location_city,
                      "Ward",
                      agent!['ward_name'],
                      themeColor,
                    ),

                  if (agent!['area_type'] == "AC")
                    _buildInfoCard(
                      Icons.account_balance,
                      "Assembly Constituency",
                      agent!['assembly_name'],
                      themeColor,
                    ),

                  _buildInfoCard(
                    Icons.store,
                    "Booth",
                    agent!['booth_name'],
                    themeColor,
                  ),

                  _buildInfoCard(
                    Icons.location_on,
                    "Booth Address",
                    agent!['booth_address'],
                    themeColor,
                  ),

                  const SizedBox(height: 20),

                  Center(child: _buildStatusBadge(agent!['nomination_status'])),
                  const SizedBox(height: 20),

                  if (agent!['nomination_status'] != "approved")
                    _buildActionButton(
                      text: "Approve Agent",
                      color: Colors.green,
                      onPressed: () => _updateNominationStatus("approved"),
                    ),

                  const SizedBox(height: 12),

                  if (agent!['nomination_status'] != "rejected")
                    _buildActionButton(
                      text: "Reject Agent",
                      color: Colors.red,
                      onPressed: () => _updateNominationStatus("rejected"),
                    ),

                  const SizedBox(height: 12),

                  if (agent!['nomination_status'] == "approved") ...[
                    _buildInfoCard(
                      Icons.verified,
                      "Approved By",
                      "${agent!['approved_by_name'] ?? ''} ${agent!['approved_by_last'] ?? ''}",
                      themeColor,
                    ),
                    _buildInfoCard(
                      Icons.schedule,
                      "Approved At",
                      agent!['approved_at'],
                      themeColor,
                    ),
                  ],
                  if (agent!['nomination_status'] == "rejected") ...[
                    _buildInfoCard(
                      Icons.cancel,
                      "Rejected By",
                      "${agent!['rejected_by_name'] ?? ''} ${agent!['rejected_by_last'] ?? ''}",
                      themeColor,
                    ),
                    _buildInfoCard(
                      Icons.schedule,
                      "Rejected At",
                      agent!['rejected_at'],
                      themeColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDOB(dynamic dob) {
    if (dob == null) return "Not provided";

    try {
      DateTime date = DateTime.parse(dob.toString());

      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year}";
    } catch (e) {
      return dob.toString().split(" ").first;
    }
  }

  Widget _buildStatusBadge(String? status) {
    Color badgeColor;
    String displayText;

    switch (status?.toLowerCase()) {
      case "approved":
        badgeColor = Colors.green;
        displayText = "APPROVED";
        break;
      case "rejected":
        badgeColor = Colors.red;
        displayText = "REJECTED";
        break;
      default:
        badgeColor = Colors.orange;
        displayText = "PENDING";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 🇮🇳 Tricolor Header
  Widget _buildTricolorHeader(ImageProvider? profileImage, Color themeColor) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/india_flag.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Optional dark overlay for readability (you can remove if not needed)
          Container(color: Colors.black.withOpacity(0.25)),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Agent photo
                Hero(
                  tag: "agent_${agent!['id']}",
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage,
                    child: profileImage == null
                        ? Icon(Icons.person, size: 80, color: themeColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),

                // Agent name
                Text(
                  "${agent!['first_name']} ${agent!['last_name'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    dynamic value,
    Color themeColor,
  ) {
    final displayValue = value != null && value.toString().trim().isNotEmpty
        ? value.toString()
        : "Not provided";

    return Card(
      elevation: 2,
      shadowColor: themeColor.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeColor.withOpacity(0.1), width: 1),
        ),
        child: ListTile(
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: themeColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          subtitle: Text(
            displayValue,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              height: 1.4,
            ),
            maxLines: null,
          ),
        ),
      ),
    );
  }
}
