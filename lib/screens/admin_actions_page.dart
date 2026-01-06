import 'package:flutter/material.dart';
import 'add_polling_booth_page.dart';
import 'view_all_booth.dart';
import 'add_agent_page.dart';
import 'view_all_agents.dart';
import 'view_all_voters.dart';
import 'view_candidate.dart';
import 'view_election_page.dart';
import 'election_declaration_page.dart';


class AdminActionsPage extends StatefulWidget {
  const AdminActionsPage({super.key});

  @override
  State<AdminActionsPage> createState() => _AdminActionsPageState();
}

class _AdminActionsPageState extends State<AdminActionsPage> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F9FF), // very light blue
              Color(0xFFEAF2FF), // soft white-blue
            ],
          ),
        ),

        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 40 : 24,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // <CHANGE> Enhanced header with gradient and description
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: wide ? 36 : 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B2C5D), // dark blue
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your voting system with ease',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // <CHANGE> Organized action cards in responsive grid with sections
              if (wide)
                Column(
                  children: [
                    // Candidate & Polling Section
                    _buildSectionHeader('Electoral Management'),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        // 🔹 NEW: Election Declaration (FULL WIDTH)
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                context,
                                0,
                                Icons.how_to_vote_outlined,
                                'Election Declaration',
                                'Declare election and publish schedule',
                                Colors.indigo,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ElectionDeclarationPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                7, // NEW INDEX
                                Icons.visibility_outlined,
                                'View Elections',
                                'View declared elections and schedules',
                                Colors.deepPurple,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewElectionsPage(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 16),

                        // Existing row shifted DOWN
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                context,
                                1,
                                Icons.how_to_vote,
                                'View Candidates',
                                'Manage candidate information',
                                Colors.blue,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminCandidatesPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                2,
                                Icons.add_location_alt,
                                'Add Polling Booth',
                                'Create new polling location',
                                Colors.orange,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddPollingBoothPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                3,
                                Icons.location_on,
                                'View Booths',
                                'View all polling locations',
                                Colors.teal,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewAllBoothsPage(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Agents & Voters Section
                    _buildSectionHeader('Personnel & Voters'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            4,
                            Icons.person_add,
                            'Add Agent',
                            'Register new polling agent',
                            Colors.purple,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddAgentPage(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            5,
                            Icons.group,
                            'View Agents',
                            'Manage all agents',
                            Colors.pink,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAllAgentsPage(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            6,
                            Icons.people_alt,
                            'View Voters',
                            'Access voter records',
                            Colors.green,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewAllVotersPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Mobile: Single column layout
                    _buildSectionHeader('Electoral Management'),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      0,
                      Icons.how_to_vote_outlined,
                      'Election Declaration',
                      'Declare election and publish schedule',
                      Colors.indigo,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ElectionDeclarationPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      7,
                      Icons.manage_accounts_outlined,
                      'Manage Elections',
                      'View, edit, and delete declared elections',
                      Colors.deepPurple,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewElectionsPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      1,
                      Icons.how_to_vote,
                      'View Candidates',
                      'Manage candidate information',
                      Colors.blue,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminCandidatesPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      2,
                      Icons.add_location_alt,
                      'Add Polling Booth',
                      'Create new polling location',
                      Colors.orange,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPollingBoothPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      3,
                      Icons.location_on,
                      'View Booths',
                      'View all polling locations',
                      Colors.teal,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllBoothsPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Personnel & Voters'),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      4,
                      Icons.person_add,
                      'Add Agent',
                      'Register new polling agent',
                      Colors.purple,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAgentPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      5,
                      Icons.group,
                      'View Agents',
                      'Manage all agents',
                      Colors.pink,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewAllAgentsPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      6,
                      Icons.people_alt,
                      'View Voters',
                      'Access voter records',
                      Colors.green,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllVotersPage(),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // <CHANGE> New widget for section headers with underline accent
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B2C5D), // dark blue
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.withOpacity(0)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // <CHANGE> Completely redesigned action card with modern glass effect and hover animation
  Widget _buildActionCard(
      BuildContext context,
      int index,
      IconData icon,
      String title,
      String subtitle,
      Color accentColor,
      VoidCallback onTap,
      ) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? accentColor.withOpacity(0.5)
                  : Colors.blueGrey.withOpacity(0.25),
              width: isHovered ? 1.5 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFF1F6FF), // light blue shade
              ],
            ),

            boxShadow: isHovered
                ? [
              BoxShadow(
                color: accentColor.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.blue.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),

            ],
          ),
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -4.0 : 0.0),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // <CHANGE> Icon container with gradient background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.2),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B2C5D), // dark blue
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // <CHANGE> Action indicator with arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Access',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.arrow_forward,
                        color: accentColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}