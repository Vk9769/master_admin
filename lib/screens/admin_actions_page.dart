import 'package:flutter/material.dart';
import 'add_polling_booth_page.dart';
import 'view_all_booth.dart';
import 'view_all_agents.dart';
import 'view_all_voters.dart';
import 'view_candidate.dart';
import 'view_election_page.dart';
import 'election_declaration_page.dart';
import 'view_superadmin_page.dart';
import 'view_all_admins_page.dart';
import 'view_super_agent_page.dart';
import 'add_ward_page.dart';
import 'manage_booths_page.dart';
import 'allocate_booths.dart';
import 'view_all_observer_page.dart';
import 'view_all_campaigner_page.dart';

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
        decoration: BoxDecoration(
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

                        _buildSubSectionTitle('Booths & Ward Management'),

                        const SizedBox(height: 16),

                        // Existing row shifted DOWN
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                context,
                                11,
                                Icons.account_tree_outlined,
                                'Add Ward',
                                'Create and manage wards',
                                Colors.cyan,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddWardPage(),
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
                                12,
                                Icons.how_to_vote_outlined,
                                'Allocate Booths',
                                'Allocate booths to elections',
                                Colors.blue,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllocateBoothsPage(),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: _buildActionCard(
                                context,
                                13, // ✅ NEW UNIQUE INDEX
                                Icons.settings_outlined,
                                'Manage Booths',
                                'Create, edit and update booths',
                                Colors.indigo,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ManageBoothsPage(),
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
                            1, // same index is OK
                            Icons.how_to_vote,
                            'Manage Candidates',
                            'View, edit and manage candidates',
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
                            8,
                            Icons.admin_panel_settings,
                            'Manage Super Admins',
                            'View, edit and manage super admins',
                            Colors.redAccent,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewSuperAdminPage(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            9,
                            Icons.manage_accounts,
                            'Manage Admins',
                            'View, edit and manage election administrators',
                            Colors.blueGrey,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAdminPage(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            10,
                            Icons.supervisor_account,
                            'Manage Super Agents',
                            'View, edit and manage senior polling agents',
                            Colors.deepOrange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewSuperAgentPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            5,
                            Icons.group,
                            'Manage Agents',
                            'Manage all agents',
                            Colors.pink,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminAgentsPage(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildActionCard(
                            context,
                            14,
                            Icons.visibility,
                            'Manage Observers',
                            'View, edit and manage observers',
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewObserverPage(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildActionCard(
                            context,
                            15,
                            Icons.campaign,
                            'Manage Campaigners',
                            'View, edit and manage campaigners',
                            Colors.amber,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewCampaignerPage(),
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
                    const SizedBox(height: 16),

                    _buildSubSectionTitle('Booths & Ward Management'),
                    const SizedBox(height: 16),

                    // ✅ ADD WARD (MOBILE)
                    _buildActionCard(
                      context,
                      11,
                      Icons.account_tree_outlined,
                      'Add Ward',
                      'Create and manage wards',
                      Colors.cyan,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddWardPage()),
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
                      12,
                      Icons.how_to_vote_outlined,
                      'Allocate Booths',
                      'Allocate booths to elections',
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllocateBoothsPage()),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      13, // ✅ NEW UNIQUE INDEX
                      Icons.settings_outlined,
                      'Manage Booths',
                      'Create, edit and update booths',
                      Colors.indigo,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ManageBoothsPage()),
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
                        MaterialPageRoute(builder: (_) => ViewAllBoothsPage()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Personnel & Voters'),
                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      1,
                      Icons.how_to_vote,
                      'Manage Candidates',
                      'View, edit and manage candidates',
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
                      8,
                      Icons.admin_panel_settings,
                      'Manage Super Admins',
                      'View, edit and manage super admins',
                      Colors.redAccent,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewSuperAdminPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      9,
                      Icons.manage_accounts,
                      'Manage Admins',
                      'View, edit and manage election administrators',
                      Colors.blueGrey,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewAdminPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      10,
                      Icons.supervisor_account,
                      'Manage Super Agents',
                      'View, edit and manage senior polling agents',
                      Colors.deepOrange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewSuperAgentPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      5,
                      Icons.group,
                      'Manage Agents',
                      'Manage all agents',
                      Colors.pink,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAgentsPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      14,
                      Icons.visibility,
                      'Manage Observers',
                      'View, edit and manage observers',
                      Colors.purple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewObserverPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      15,
                      Icons.campaign,
                      'Manage Campaigners',
                      'View, edit and manage campaigners',
                      Colors.amber,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ViewCampaignerPage(),
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
                        MaterialPageRoute(builder: (_) => ViewAllVotersPage()),
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

  // ✅ SUB-SECTION TITLE (for Booths & Ward Management)
  Widget _buildSubSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16, // slightly smaller than main section
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B2C5D), // same dark blue
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),

        Container(
          width: 28, // smaller underline to indicate sub-section
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
              colors: [Colors.white, const Color(0xFFF1F6FF)],
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
          transform: Matrix4.identity()..translate(0.0, isHovered ? -4.0 : 0.0),
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
                  child: Icon(icon, color: accentColor, size: 32),
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
