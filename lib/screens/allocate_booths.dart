import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AllocateBoothsPage extends StatefulWidget {
  const AllocateBoothsPage({super.key});

  @override
  State<AllocateBoothsPage> createState() => _AllocateBoothsPageState();
}

class _AllocateBoothsPageState extends State<AllocateBoothsPage> {
  final String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";

  // -------------------------------
  // STATE
  // -------------------------------
  bool isLoading = false;

  int selectedElectionId = 0;
  String filterMode = ''; // AC | WARD
  String selectedAC = '';
  int selectedWardId = 0;

  List<Map<String, dynamic>> elections = [];
  List<Map<String, dynamic>> wards = [];
  List<Map<String, dynamic>> booths = [];
  List<String> acs = [];

  Set<int> selectedBoothIds = {};

  Future<void> fetchElections() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) return;

    final res = await http.get(
      Uri.parse("$baseUrl/masteradmin/elections"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      setState(() {
        elections = list
            .where((e) => e['status'] != 'past')
            .map(
              (e) => {
                "id": e['id'],
                "name": e['election_name'],
                "type": e['election_type'],
              },
            )
            .toList();
      });
    }
  }

  Future<void> fetchACs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null || selectedElectionId == 0) return;

    final res = await http.get(
      Uri.parse(
        "$baseUrl/api/booths/acs-for-election?election_id=$selectedElectionId",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      setState(() {
        acs = List<String>.from(jsonDecode(res.body));
      });
    }
  }

  Future<void> fetchWards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null || selectedElectionId == 0) return;

    final res = await http.get(
      Uri.parse("$baseUrl/api/wards?election_id=$selectedElectionId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      setState(() {
        wards = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      });
    }
  }

  // -------------------------------
  // FETCH BOOTHS
  // -------------------------------
  Future<void> fetchBooths() async {
    if (selectedElectionId == 0) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) return;

    String url =
        "$baseUrl/api/booths/for-election?election_id=$selectedElectionId";

    if (filterMode == 'AC' && selectedAC.isNotEmpty) {
      url += "&ac_name_no=$selectedAC";
    }

    if (filterMode == 'WARD' && selectedWardId != 0) {
      url += "&ward_id=$selectedWardId";
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      setState(() {
        booths = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      });
    }

    setState(() => isLoading = false);
  }

  // -------------------------------
  // ALLOCATE BOOTHS
  // -------------------------------
  Future<void> allocateBooths() async {
    if (selectedBoothIds.isEmpty || selectedElectionId == 0) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null) return;

    final res = await http.post(
      Uri.parse("$baseUrl/api/election-booths/allocate"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "election_id": selectedElectionId,
        "booth_ids": selectedBoothIds.toList(),
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booths allocated successfully")),
      );
      setState(() => selectedBoothIds.clear());
      fetchBooths(); // refresh
    }
  }

  @override
  void initState() {
    super.initState();
    fetchElections();
  }

  List<String> get uniqueACs {
    final set = <String>{};
    for (final b in booths) {
      if (b['ac_name_no'] != null && b['ac_name_no'].toString().isNotEmpty) {
        set.add(b['ac_name_no']);
      }
    }
    return set.toList();
  }

  // -------------------------------
  // UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Allocate Booths',
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

                buildDropdown<int>(
                  label: 'Select Election',
                  value: selectedElectionId == 0 ? null : selectedElectionId,
                  items: elections
                      .map(
                        (e) => DropdownMenuItem<int>(
                          value: e['id'],
                          child: Text(e['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedElectionId = value ?? 0;
                      filterMode = '';
                      selectedAC = '';
                      selectedWardId = 0;
                      booths.clear();
                      selectedBoothIds.clear();
                      acs.clear();
                      wards.clear();
                    });

                    fetchWards(); // municipal
                    fetchACs(); // assembly
                  },
                ),

                if (selectedElectionId != 0)
                  buildDropdown<String>(
                    label: 'Filter By',
                    value: filterMode.isEmpty ? null : filterMode,
                    items: const [
                      DropdownMenuItem(value: 'AC', child: Text('AC Wise')),
                      DropdownMenuItem(value: 'WARD', child: Text('Ward Wise')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        filterMode = v ?? '';
                        selectedAC = '';
                        selectedWardId = 0;
                        booths.clear();
                        selectedBoothIds.clear();
                      });
                    },
                  ),

                if (filterMode == 'AC')
                  buildDropdown<String>(
                    label: 'Assembly Constituency',
                    value: selectedAC.isEmpty ? null : selectedAC,
                    items: acs
                        .map(
                          (ac) => DropdownMenuItem<String>(
                            value: ac,
                            child: Text(ac),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedAC = v ?? '';
                      });
                      fetchBooths();
                    },
                  ),

                if (filterMode == 'WARD')
                  buildDropdown<int>(
                    label: 'Ward',
                    value: selectedWardId == 0 ? null : selectedWardId,
                    items: wards.map((w) {
                      return DropdownMenuItem<int>(
                        value: w['id'],
                        child: Text("${w['ward_no']} - ${w['ward_name']}"),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedWardId = v ?? 0;
                      });
                      fetchBooths();
                    },
                  ),

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
                        filterMode == 'WARD' && selectedWardId != 0
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
                              (filterMode == 'WARD' && selectedWardId == 0))
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

  void _selectACWise() {
    if (selectedAC.isEmpty) return;
    _selectAllVisible();
  }

  void _selectWardWise() {
    if (selectedWardId == 0) return;
    _selectAllVisible();
  }

  // ========== HELPER: UNIVERSAL DROPDOWN ==========
  Widget buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool isExpanded = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: isExpanded,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF1E88E5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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
        items: items,
        onChanged: onChanged,
        icon: const Icon(
          Icons.arrow_drop_down_rounded,
          color: Color(0xFF1E88E5),
          size: 24,
        ),
        dropdownColor: Colors.white,
      ),
    );
  }
}
