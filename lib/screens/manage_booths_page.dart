import 'package:flutter/material.dart';
import 'add_polling_booth_page.dart';

class ManageBoothsPage extends StatefulWidget {
  const ManageBoothsPage({super.key});

  @override
  State<ManageBoothsPage> createState() => _ManageBoothsPageState();
}

class _ManageBoothsPageState extends State<ManageBoothsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int selectedElectionId = 0;
  String search = '';

  // 🎨 Color Palette
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // 🔹 Dummy elections
  final List<Map<String, dynamic>> elections = [
    {"id": 1, "name": "Lok Sabha 2024"},
    {"id": 2, "name": "Municipal Election 2025"},
  ];

  // 🔹 Dummy booths (ALL)
  final List<Map<String, dynamic>> allBooths = [
    {"id": 1, "name": "ZP School Booth", "ward": "Ward 3", "ac": "AC 216"},
    {"id": 2, "name": "Municipal Hall Booth", "ward": "Ward 5", "ac": "AC 216"},
    {"id": 3, "name": "Primary School Booth", "ward": "Ward 1", "ac": "AC 215"},
  ];

  // 🔹 Dummy election-wise booth mapping
  final Map<int, List<int>> electionBooths = {
    1: [1, 2], // Election 1 has booth 1 & 2
    2: [3], // Election 2 has booth 3
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          search = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Manage Booths',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          tabs: const [
            Tab(text: 'By Election'),
            Tab(text: 'All Booths'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_location_outlined, size: 24),
        label: const Text(
          'Add Booth',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPollingBoothPage()),
          );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildElectionBoothsTab(), _buildAllBoothsTab()],
      ),
    );
  }

  // ================= TAB 1: MANAGE ELECTION BOOTHS =================
  Widget _buildElectionBoothsTab() {
    final List<Map<String, dynamic>> booths = selectedElectionId == 0
        ? <Map<String, dynamic>>[]
        : allBooths
              .where(
                (b) =>
                    (electionBooths[selectedElectionId]?.contains(b['id']) ??
                        false) &&
                    b['name'].toString().toLowerCase().contains(search),
              )
              .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // 🔽 Election dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Election',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.ballot_outlined,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    value: selectedElectionId == 0 ? null : selectedElectionId,
                    hint: const Text(
                      'Choose an election',
                      style: TextStyle(color: textSecondary),
                    ),
                    items: elections
                        .map(
                          (e) => DropdownMenuItem<int>(
                            value: e['id'],
                            child: Text(
                              e['name'],
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedElectionId = value ?? 0;
                        search = '';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search booth name',
                hintStyle: const TextStyle(color: textSecondary),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primaryColor,
                  size: 22,
                ),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) {
                setState(() {
                  search = v.toLowerCase();
                });
              },
            ),
          ),

          // 📋 List or empty state
          SizedBox(
            height: MediaQuery.of(context).size.height - 380,
            child: selectedElectionId == 0
                ? _buildEmptyState(
                    icon: Icons.ballot_outlined,
                    title: 'Select an Election',
                    subtitle: 'Choose an election to view its polling booths',
                  )
                : booths.isEmpty
                ? _buildEmptyState(
                    icon: Icons.location_off_outlined,
                    title: 'No Booths Found',
                    subtitle: 'No polling booths match your search',
                  )
                : _buildBoothList(booths),
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: MANAGE ALL BOOTHS =================
  Widget _buildAllBoothsTab() {
    final filteredBooths = allBooths
        .where((b) => b['name'].toString().toLowerCase().contains(search))
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by booth name',
                hintStyle: const TextStyle(color: textSecondary),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primaryColor,
                  size: 22,
                ),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) {
                setState(() {
                  search = v.toLowerCase();
                });
              },
            ),
          ),

          // 📋 List or empty state
          SizedBox(
            height: MediaQuery.of(context).size.height - 280,
            child: filteredBooths.isEmpty && search.isNotEmpty
                ? _buildEmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No Results Found',
                    subtitle: 'Try adjusting your search terms',
                  )
                : filteredBooths.isEmpty
                ? _buildEmptyState(
                    icon: Icons.location_disabled_outlined,
                    title: 'No Booths Available',
                    subtitle: 'Add a booth to get started',
                  )
                : _buildBoothList(filteredBooths),
          ),
        ],
      ),
    );
  }

  // ================= COMMON BOOTH LIST =================
  Widget _buildBoothList(List<Map<String, dynamic>> booths) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: booths.length,
      itemBuilder: (context, index) {
        final booth = booths[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  // Handle tap
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booth['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Booth ID: ${booth['id']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: textSecondary,
                            ),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _confirmDelete(booth['id']);
                              } else if (value == 'edit') {
                                // Handle edit
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: errorColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Delete',
                                      style: TextStyle(color: errorColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBoothInfo(
                              icon: Icons.map_outlined,
                              label: booth['ward'],
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBoothInfo(
                              icon: Icons.domain_outlined,
                              label: booth['ac'],
                              color: successColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= BOOTH INFO CHIP =================
  Widget _buildBoothInfo({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, size: 56, color: primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ================= DELETE CONFIRM =================
  void _confirmDelete(int boothId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Booth',
              style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Are you sure you want to delete this polling booth? All associated data will be removed permanently.',
              style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                allBooths.removeWhere((b) => b['id'] == boothId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Booth deleted successfully'),
                  backgroundColor: successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
