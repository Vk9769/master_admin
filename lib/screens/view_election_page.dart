import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'election_declaration_page.dart';
import '../models/election.dart';

class ViewElectionsPage extends StatefulWidget {
  const ViewElectionsPage({super.key});

  @override
  State<ViewElectionsPage> createState() => _ViewElectionsPageState();
}

class _ViewElectionsPageState extends State<ViewElectionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  // Sample election data
  final List<Election> _elections = [

    // ================= PARLIAMENTARY =================
    Election(
      id: '1',
      category: 'Parliamentary Elections',
      subType: 'Lok Sabha General Elections',
      state: 'All India',
      district: 'All',
      name: 'Lok Sabha General Elections 2024',
      electionCode: 'LS-2024',
      notificationDate: DateTime(2024, 3, 16),
      pollDate: DateTime(2024, 4, 19),
      countingDate: DateTime(2024, 6, 4),
      resultDate: DateTime(2024, 6, 4),
      totalSeats: 543,
      totalVoters: 900000000,
      voterTurnout: 67,
      status: 'ongoing',
      remarks: 'Nationwide parliamentary election',
      icon: '🏛️',
    ),

    // ================= STATE ASSEMBLY =================
    Election(
      id: '2',
      category: 'State Assembly Elections',
      subType: 'Vidhan Sabha Elections',
      state: 'Maharashtra',
      district: 'All',
      name: 'Maharashtra Assembly Elections 2024',
      electionCode: 'MH-VS-2024',
      notificationDate: DateTime(2024, 10, 1),
      pollDate: DateTime(2024, 11, 20),
      countingDate: DateTime(2024, 11, 23),
      resultDate: DateTime(2024, 11, 23),
      totalSeats: 288,
      totalVoters: 92000000,
      status: 'upcoming',
      remarks: 'State legislative assembly election',
      icon: '🏢',
    ),

    Election(
      id: '3',
      category: 'State Assembly Elections',
      subType: 'Vidhan Sabha Elections',
      state: 'Karnataka',
      district: 'All',
      name: 'Karnataka Assembly Elections 2023',
      electionCode: 'KA-VS-2023',
      notificationDate: DateTime(2023, 3, 29),
      pollDate: DateTime(2023, 5, 10),
      countingDate: DateTime(2023, 5, 13),
      resultDate: DateTime(2023, 5, 13),
      totalSeats: 224,
      totalVoters: 53000000,
      voterTurnout: 73,
      status: 'past',
      remarks: 'Completed state election',
      icon: '🏢',
    ),

    // ================= MUNICIPAL =================
    Election(
      id: '4',
      category: 'Municipal Elections',
      subType: 'Municipal Corporation Elections',
      state: 'Delhi',
      district: 'All',
      name: 'Delhi Municipal Corporation Elections',
      electionCode: 'DEL-MC-2024',
      notificationDate: DateTime(2024, 7, 15),
      pollDate: DateTime(2024, 8, 25),
      countingDate: DateTime(2024, 8, 28),
      resultDate: DateTime(2024, 8, 28),
      totalSeats: 250,
      totalVoters: 16000000,
      status: 'upcoming',
      remarks: 'Municipal body elections',
      icon: '🏙️',
    ),

    // ================= PANCHAYAT =================
    Election(
      id: '5',
      category: 'Panchayat Elections',
      subType: 'Gram Panchayat Elections',
      state: 'Rajasthan',
      district: 'Multiple Districts',
      name: 'Rajasthan Panchayat Elections 2024',
      electionCode: 'RJ-GP-2024',
      notificationDate: DateTime(2024, 9, 1),
      pollDate: DateTime(2024, 9, 20),
      countingDate: DateTime(2024, 9, 22),
      resultDate: DateTime(2024, 9, 22),
      totalSeats: 9894,
      totalVoters: 52000000,
      status: 'upcoming',
      remarks: 'Rural local body elections',
      icon: '🏘️',
    ),

    // ================= BYE ELECTION =================
    Election(
      id: '6',
      category: 'By-Elections',
      subType: 'Assembly By-Election',
      state: 'Uttar Pradesh',
      district: 'Rampur',
      name: 'Rampur Assembly By-Election',
      electionCode: 'UP-BYE-2024',
      notificationDate: DateTime(2024, 6, 10),
      pollDate: DateTime(2024, 7, 10),
      countingDate: DateTime(2024, 7, 13),
      resultDate: DateTime(2024, 7, 13),
      totalSeats: 1,
      totalVoters: 350000,
      status: 'upcoming',
      remarks: 'By-poll due to vacancy',
      icon: '🗳️',
    ),

    // ================= PRESIDENTIAL =================
    Election(
      id: '7',
      category: 'Presidential Elections',
      subType: 'President of India Election',
      state: 'All India',
      district: 'All',
      name: 'Presidential Election of India 2022',
      electionCode: 'PRES-2022',
      notificationDate: DateTime(2022, 6, 15),
      pollDate: DateTime(2022, 7, 18),
      countingDate: DateTime(2022, 7, 21),
      resultDate: DateTime(2022, 7, 21),
      totalSeats: 1,
      totalVoters: 4800, // MPs + MLAs
      voterTurnout: 99,
      status: 'past',
      remarks: 'Indirect election by electoral college',
      icon: '🇮🇳',
    ),
  ];

  void _confirmDeleteElection(Election election) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Election',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${election.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _elections.removeWhere((e) => e.id == election.id);
              });

              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close bottom sheet

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Election deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Election> _getFilteredElections() {
    switch (_selectedFilter) {
      case 'Ongoing':
        return _elections.where((e) => e.status == 'ongoing').toList();
      case 'Upcoming':
        return _elections.where((e) => e.status == 'upcoming').toList();
      case 'Past':
        return _elections.where((e) => e.status == 'past').toList();
      default:
        return _elections;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ongoing':
        return const Color(0xFF10B981);
      case 'upcoming':
        return const Color(0xFF3B82F6);
      case 'past':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ongoing':
        return 'LIVE NOW';
      case 'upcoming':
        return 'UPCOMING';
      case 'past':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredElections = _getFilteredElections();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF9933), // Saffron
                      Color(0xFFFFFFFF), // White
                      Color(0xFF138808), // Green
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🗳️',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, -14), // move slightly LOWER
                                      child: const Text(
                                        'Democracy in Action',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black, // changed to BLACK
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Transform.translate(
                offset: const Offset(4, 4), // move up by 10px (adjust as needed)
                child: const Text(
                  'Indian Elections',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', _elections.length),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Ongoing',
                      _elections.where((e) => e.status == 'ongoing').length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Upcoming',
                      _elections.where((e) => e.status == 'upcoming').length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Past',
                      _elections.where((e) => e.status == 'past').length,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '${_elections.where((e) => e.status == 'ongoing').length}',
                      'Live',
                      const Color(0xFF10B981),
                      Icons.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '${_elections.where((e) => e.status == 'upcoming').length}',
                      'Upcoming',
                      const Color(0xFF3B82F6),
                      Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '${_elections.where((e) => e.status == 'past').length}',
                      'Completed',
                      const Color(0xFF6B7280),
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Elections List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: filteredElections.isEmpty
                ? SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Text(
                        '🔍',
                        style: TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No elections found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try changing your filter',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final election = filteredElections[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildElectionCard(election),
                  );
                },
                childCount: filteredElections.length,
              ),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E293B) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectionCard(Election election) {
    final statusColor = _getStatusColor(election.status);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showElectionDetails(election);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.2),
                            statusColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          election.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (election.status == 'ongoing')
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      _getStatusText(election.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    election.subType,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            election.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      election.state,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.event_seat, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${election.totalSeats} Seats',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (election.remarks.isNotEmpty)
                  Text(
                    election.remarks,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(election.pollDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(election.resultDate ?? election.pollDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (election.voterTurnout > 0) ...[
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Turnout',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${election.voterTurnout}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showElectionDetails(Election election) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(election.status).withOpacity(0.2),
                                _getStatusColor(election.status).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              election.icon,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(election.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(election.status),
                                  style: TextStyle(
                                    color: _getStatusColor(election.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                election.subType,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      election.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(
                      Icons.location_on,
                      'State',
                      election.state,
                    ),
                    _buildDetailRow(Icons.map, 'District', election.district),
                    _buildDetailRow(Icons.category, 'Category', election.category),
                    _buildDetailRow(Icons.list_alt, 'Sub-Type', election.subType),
                    _buildDetailRow(Icons.confirmation_number, 'Election Code', election.electionCode),

                    _buildDetailRow(
                      Icons.notifications,
                      'Notification Date',
                      DateFormat('dd MMM yyyy').format(election.notificationDate),
                    ),

                    _buildDetailRow(
                      Icons.how_to_vote,
                      'Poll Date',
                      DateFormat('dd MMM yyyy').format(election.pollDate),
                    ),

                    if (election.countingDate != null)
                      _buildDetailRow(
                        Icons.bar_chart,
                        'Counting Date',
                        DateFormat('dd MMM yyyy').format(election.countingDate!),
                      ),

                    if (election.resultDate != null)
                      _buildDetailRow(
                        Icons.emoji_events,
                        'Result Date',
                        DateFormat('dd MMM yyyy').format(election.resultDate!),
                      ),

                    if (election.totalSeats != null)
                      _buildDetailRow(Icons.event_seat, 'Total Seats', '${election.totalSeats}'),

                    if (election.totalVoters != null)
                      _buildDetailRow(
                        Icons.people,
                        'Total Voters',
                        NumberFormat.decimalPattern().format(election.totalVoters),
                      ),

                    if (election.remarks.isNotEmpty)
                      _buildDetailRow(Icons.note, 'Remarks', election.remarks),

                    if (election.voterTurnout > 0) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.people,
                        'Voter Turnout',
                        '${election.voterTurnout}%',
                      ),
                    ],
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        // ✏️ EDIT BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              'Edit Election',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // close bottom sheet

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ElectionDeclarationPage(
                                    election: election, // 👈 pass election for edit
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E40AF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🗑️ DELETE BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Delete Election',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            onPressed: () {
                              _confirmDeleteElection(election);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child:
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),

          /// LABEL
          SizedBox(
            width: 110, // keeps labels aligned
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          /// VALUE (THIS FIXES OVERFLOW)
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
