import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageBoothsPage extends StatefulWidget {
  const ManageBoothsPage({super.key});

  @override
  State<ManageBoothsPage> createState() => _ManageBoothsPageState();
}

class _ManageBoothsPageState extends State<ManageBoothsPage> {
  // -------------------------------
  // STATE
  // -------------------------------
  bool isLoading = false;

  String selectedElection = '';
  String selectedState = '';
  String selectedDistrict = '';
  String selectedAC = '';
  String selectedWard = '';
  String filterMode = ''; // 'AC' or 'WARD'

  List<Map<String, dynamic>> booths = [];
  Set<int> selectedBoothIds = {};

  // Dummy dropdown data (replace with API later)
  final elections = ['Election 2025', 'Assembly 2024'];
  final states = ['Maharashtra'];
  final districts = ['Pune', 'Mumbai'];
  final acs = ['AC 101', 'AC 102'];
  final wards = ['Ward 1', 'Ward 2'];

  // -------------------------------
  // FETCH BOOTHS
  // -------------------------------
  Future<void> fetchBooths() async {
    setState(() => isLoading = true);

    // 🔗 API PLACEHOLDER
    // final response = await http.get(Uri.parse('YOUR_API/booths'));

    await Future.delayed(const Duration(seconds: 1));

    // Dummy data
    booths = [
      {'id': 12, 'name': 'Booth 12 - ZP School'},
      {'id': 18, 'name': 'Booth 18 - Community Hall'},
      {'id': 23, 'name': 'Booth 23 - Municipal Office'},
      {'id': 41, 'name': 'Booth 41 - College Campus'},
    ];

    setState(() => isLoading = false);
  }

  // -------------------------------
  // ALLOCATE BOOTHS
  // -------------------------------
  Future<void> allocateBooths() async {
    if (selectedBoothIds.isEmpty || selectedElection.isEmpty) return;

    final payload = {
      "election_id": 5, // 🔁 replace from selectedElection mapping
      "booth_ids": selectedBoothIds.toList(),
    };

    // 🔗 API CALL
    // await http.post(
    //   Uri.parse('YOUR_API/election-booths/allocate'),
    //   headers: {"Content-Type": "application/json"},
    //   body: jsonEncode(payload),
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booths allocated successfully')),
    );

    setState(() => selectedBoothIds.clear());
  }

  @override
  void initState() {
    super.initState();
    fetchBooths();
  }

  // -------------------------------
  // UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Booths',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== SECTION 1: FILTER CONTROLS ==========
                _buildSectionTitle('📋 Election & Location Filters'),
                const SizedBox(height: 16),

                _dropdown('Select Election', elections, (v) {
                  selectedElection = v;
                }),

                Row(
                  children: [
                    Expanded(
                      child: _dropdown(
                        'State',
                        states,
                        (v) => selectedState = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdown(
                        'District',
                        districts,
                        (v) => selectedDistrict = v,
                      ),
                    ),
                  ],
                ),

                if (selectedDistrict.isNotEmpty) ...[
                  _dropdown('Filter By', const ['AC', 'Ward'], (v) {
                    filterMode = v;
                    selectedAC = '';
                    selectedWard = '';
                    booths.clear();
                    selectedBoothIds.clear();
                  }),
                ],

                // Show AC dropdown ONLY if filterMode == 'AC'
                if (filterMode == 'AC')
                  _dropdown('Assembly Constituency', acs, (v) {
                    selectedAC = v;
                    fetchBooths();
                  }),

                // Show Ward dropdown ONLY if filterMode == 'Ward'
                if (filterMode == 'Ward')
                  _dropdown('Ward', wards, (v) {
                    selectedWard = v;
                    fetchBooths();
                  }),

                const SizedBox(height: 24),

                // ========== SECTION 2: BULK SELECTION CONTROLS ==========
                _buildSectionTitle('✅ Bulk Selection Options'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildActionButton(
                        'Select All',
                        Icons.check_circle_outline,
                        booths.isEmpty ? null : _selectAllVisible,
                        const Color(0xFF4CAF50),
                      ),
                      _buildActionButton(
                        'District Wise',
                        Icons.map_outlined,
                        selectedDistrict.isEmpty ? null : _selectDistrictWise,
                        const Color(0xFF2196F3),
                      ),
                      _buildActionButton(
                        'AC Wise',
                        Icons.domain_outlined,
                        filterMode == 'AC' && selectedAC.isNotEmpty
                            ? _selectACWise
                            : null,
                        const Color(0xFFF57C00),
                      ),
                      _buildActionButton(
                        'Ward Wise',
                        Icons.location_on_outlined,
                        filterMode == 'Ward' && selectedWard.isNotEmpty
                            ? _selectWardWise
                            : null,
                        const Color(0xFF7B1FA2),
                      ),
                      _buildActionButton(
                        'Clear All',
                        Icons.clear,
                        selectedBoothIds.isEmpty ? null : _clearSelection,
                        const Color(0xFFD32F2F),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ========== SECTION 3: BOOTHS LIST ==========
                _buildSectionTitle('🏛️ Available Booths'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      color: Colors.white,
                      child:
                          (filterMode.isEmpty ||
                              (filterMode == 'AC' && selectedAC.isEmpty) ||
                              (filterMode == 'Ward' && selectedWard.isEmpty))
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Please select AC or Ward to view booths',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1E88E5),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: booths.length,
                              itemBuilder: (context, index) {
                                final booth = booths[index];
                                final id = booth['id'];
                                final isSelected = selectedBoothIds.contains(
                                  id,
                                );

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 0,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isSelected
                                              ? selectedBoothIds.remove(id)
                                              : selectedBoothIds.add(id);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue.shade50
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF1E88E5)
                                                : Colors.grey.shade200,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          activeColor: const Color(0xFF1E88E5),
                                          checkColor: Colors.white,
                                          title: Text(
                                            booth['name'],
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? const Color(0xFF1E88E5)
                                                  : Colors.black87,
                                            ),
                                          ),
                                          value: isSelected,
                                          onChanged: (checked) {
                                            setState(() {
                                              checked!
                                                  ? selectedBoothIds.add(id)
                                                  : selectedBoothIds.remove(id);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ========== SECTION 4: ALLOCATION BUTTON ==========
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedBoothIds.isEmpty ? null : allocateBooths,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Allocate ${selectedBoothIds.length > 0 ? '(${selectedBoothIds.length})' : ''} Booths',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== HELPER: SECTION TITLE ==========
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
        letterSpacing: 0.3,
      ),
    );
  }

  // ========== HELPER: ACTION BUTTON ==========
  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback? onPressed,
    Color color,
  ) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: onPressed != null ? 2 : 0,
        ),
      ),
    );
  }

  void _selectAllVisible() {
    setState(() {
      selectedBoothIds = booths.map<int>((b) => b['id'] as int).toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      selectedBoothIds.clear();
    });
  }

  void _selectDistrictWise() {
    if (selectedDistrict.isEmpty) return;
    _selectAllVisible();
  }

  void _selectACWise() {
    if (selectedAC.isEmpty) return;
    _selectAllVisible();
  }

  void _selectWardWise() {
    if (selectedWard.isEmpty) return;
    _selectAllVisible();
  }

  // ========== HELPER: REUSABLE DROPDOWN ==========
  Widget _dropdown(
    String label,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF1E88E5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          prefixIcon: const Icon(
            Icons.filter_list_rounded,
            color: Color(0xFF1E88E5),
            size: 20,
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() {
              onChanged(v);
            });
          }
        },
        icon: const Icon(
          Icons.arrow_drop_down_rounded,
          color: Color(0xFF1E88E5),
          size: 24,
        ),
      ),
    );
  }
}
