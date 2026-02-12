import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CandidateProfilePage extends StatefulWidget {
  final int candidateId;

  const CandidateProfilePage({Key? key, required this.candidateId})
      : super(key: key);

  @override
  State<CandidateProfilePage> createState() => _CandidateProfilePageState();
}

class _CandidateProfilePageState extends State<CandidateProfilePage> {
  Map<String, dynamic>? candidate;
  bool isLoading = true;

  final String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";

  @override
  void initState() {
    super.initState();
    _loadCandidateDetails();
  }

  Future<void> _loadCandidateDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/candidate/details/${widget.candidateId}"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          candidate = jsonDecode(response.body);
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
        Uri.parse("$baseUrl/candidate/update/${widget.candidateId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nomination_status": status,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Candidate $status successfully"),
            backgroundColor: Colors.green,
          ),
        );

        _loadCandidateDetails(); // 🔥 refresh UI
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
        body: Center(
          child: CircularProgressIndicator(color: themeColor),
        ),
      );
    }

    if (candidate == null) {
      return const Scaffold(
        body: Center(child: Text("Candidate not found")),
      );
    }

    final profileImage = candidate!['candidate_photo_url'] != null
        ? NetworkImage(candidate!['candidate_photo_url'])
        : null;

    final symbolImage = candidate!['party_symbol_url'] != null
        ? NetworkImage(candidate!['party_symbol_url'])
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
              background: _buildTricolorHeader(profileImage, symbolImage, themeColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildSectionTitle("Personal Information"),
                  _buildInfoCard(Icons.person, "Name",
                      "${candidate!['first_name']} ${candidate!['last_name'] ?? ''}",
                      themeColor),
                  _buildInfoCard(Icons.wc, "Gender",
                      candidate!['gender'], themeColor),
                  _buildInfoCard(Icons.cake, "Age",
                      candidate!['age'], themeColor),

                  const SizedBox(height: 20),

                  _buildSectionTitle("Contact Information"),
                  _buildInfoCard(Icons.phone_android, "Phone",
                      candidate!['phone'], themeColor),
                  _buildInfoCard(Icons.email, "Email",
                      candidate!['email'], themeColor),

                  const SizedBox(height: 20),

                  _buildSectionTitle("Political Information"),
                  _buildInfoCard(Icons.flag, "Party",
                      candidate!['party'], themeColor),

                  const SizedBox(height: 12),

                  Center(
                    child: _buildStatusBadge(candidate!['nomination_status']),
                  ),
                  const SizedBox(height: 20),

                  if (candidate!['nomination_status'] != "approved")
                    _buildActionButton(
                      text: "Approve Candidate",
                      color: Colors.green,
                      onPressed: () => _updateNominationStatus("approved"),
                    ),

                  const SizedBox(height: 12),

                  if (candidate!['nomination_status'] != "rejected")
                    _buildActionButton(
                      text: "Reject Candidate",
                      color: Colors.red,
                      onPressed: () => _updateNominationStatus("rejected"),
                    ),

                  const SizedBox(height: 12),

                  if (candidate!['nomination_status'] == "approved") ...[
                    _buildInfoCard(
                      Icons.verified,
                      "Approved By",
                      "${candidate!['approved_by_name'] ?? ''} ${candidate!['approved_by_last'] ?? ''}",
                      themeColor,
                    ),
                    _buildInfoCard(
                      Icons.schedule,
                      "Approved At",
                      candidate!['approved_at'],
                      themeColor,
                    ),
                  ],
                  if (candidate!['nomination_status'] == "rejected") ...[
                    _buildInfoCard(
                      Icons.cancel,
                      "Rejected By",
                      "${candidate!['rejected_by_name'] ?? ''} ${candidate!['rejected_by_last'] ?? ''}",
                      themeColor,
                    ),
                    _buildInfoCard(
                      Icons.schedule,
                      "Rejected At",
                      candidate!['rejected_at'],
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 🇮🇳 Tricolor Header
  Widget _buildTricolorHeader(
      ImageProvider? profileImage,
      ImageProvider? symbolImage,
      Color themeColor,
      ) {
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
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Candidate photo
                Hero(
                  tag: "candidate_${candidate!['id']}",
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

                // Candidate name
                Text(
                  "${candidate!['first_name']} ${candidate!['last_name'] ?? ''}",
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

                const SizedBox(height: 25),

                // Party symbol
                if (symbolImage != null)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 3),
                      image: DecorationImage(
                        image: symbolImage,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.flag, color: Colors.white, size: 45),
                  ),

                const SizedBox(height: 10),

                // Party name
                Text(
                  candidate!['party'] ?? "Party Name",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
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
          border: Border.all(
            color: themeColor.withOpacity(0.1),
            width: 1,
          ),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
