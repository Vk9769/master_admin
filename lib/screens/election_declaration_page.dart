import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/election.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ElectionDeclarationPage extends StatefulWidget {
  final Election? election; // 👈 ADD THIS LINE

  const ElectionDeclarationPage({
    Key? key,
    this.election, // 👈 ADD THIS
  }) : super(key: key);

  @override
  State<ElectionDeclarationPage> createState() => _ElectionDeclarationPageState();
}

class _ElectionDeclarationPageState extends State<ElectionDeclarationPage> {
  // Election Type Categories
  final Map<String, List<String>> electionTypes = {
    'Parliamentary Elections': [
      'Lok Sabha General Elections',
      'Lok Sabha By-Elections',
      'Lok Sabha Mid-Term Polls'
    ],
    'Upper House Elections': [
      'Rajya Sabha Regular Elections',
      'Rajya Sabha Bye-Elections',
      'Rajya Sabha Special Elections'
    ],
    'State Assembly Elections': [
      'State Vidhan Sabha - General Elections',
      'State Vidhan Sabha - By-Elections',
      'State Vidhan Sabha - Special Elections'
    ],
    'Local Body Elections': [
      'Municipal Corporation Elections',
      'Municipal Council Elections',
      'Nagar Panchayat Elections',
      'Village Panchayat Elections',
      'Ward Committee Elections'
    ],
    'Union Territory Elections': [
      'UT Assembly Elections',
      'UT Assembly By-Elections',
      'UT Local Body Elections'
    ],
    'Constitutional Posts': [
      'Presidential Election',
      'Vice-Presidential Election',
      'Governor Elections',
      'Lieutenant Governor Appointment'
    ],
  };

  // State → District mapping
  final Map<String, List<String>> statesAndDistricts = {
    'All India': ['All'],
    'Maharashtra': [
      'Mumbai City',
      'Mumbai Suburban',
      'Thane',
      'Pune',
      'Nagpur',
    ],
    'Gujarat': [
      'Ahmedabad',
      'Surat',
      'Vadodara',
      'Rajkot',
    ],
    'Karnataka': [
      'Bengaluru Urban',
      'Mysuru',
      'Mangaluru',
    ],
  };

  final String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";


  // Form Controllers
  late TextEditingController electionNameController;
  late TextEditingController electionCodeController;
  late TextEditingController notificationDateController;
  late TextEditingController pollDateController;
  late TextEditingController countingDateController;
  late TextEditingController resultDateController;
  late TextEditingController totalSeatsController;
  late TextEditingController totalVotersController;
  late TextEditingController remarksController;

  // State Variables
  String? selectedMainCategory;
  String? selectedSubType;
  String? selectedState;
  String? selectedDistrict;
  DateTime? notificationDate;
  DateTime? pollDate;
  DateTime? countingDate;
  DateTime? resultDate;
  bool isFormExpanded = false;

  @override
  void initState() {
    super.initState();

    electionNameController = TextEditingController();
    electionCodeController = TextEditingController();
    notificationDateController = TextEditingController();
    pollDateController = TextEditingController();
    countingDateController = TextEditingController();
    resultDateController = TextEditingController();
    totalSeatsController = TextEditingController();
    totalVotersController = TextEditingController();
    remarksController = TextEditingController();

    // ================= EDIT MODE PREFILL =================
    if (widget.election != null) {
      final e = widget.election!;

      selectedMainCategory = e.category;
      selectedSubType = e.subType;
      if (statesAndDistricts.containsKey(e.state)) {
        selectedState = e.state;
        selectedDistrict = e.district;
      } else {
        selectedState = null;
        selectedDistrict = null;
      }

      electionNameController.text = e.name;
      electionCodeController.text = e.electionCode;
      remarksController.text = e.remarks;

      notificationDate = e.notificationDate;
      pollDate = e.pollDate;
      countingDate = e.countingDate;
      resultDate = e.resultDate;

      notificationDateController.text =
          DateFormat('dd/MM/yyyy').format(e.notificationDate);
      pollDateController.text =
          DateFormat('dd/MM/yyyy').format(e.pollDate);

      if (e.countingDate != null) {
        countingDateController.text =
            DateFormat('dd/MM/yyyy').format(e.countingDate!);
      }

      if (e.resultDate != null) {
        resultDateController.text =
            DateFormat('dd/MM/yyyy').format(e.resultDate!);
      }

      if (e.totalSeats != null) {
        totalSeatsController.text = e.totalSeats.toString();
      }

      if (e.totalVoters != null) {
        totalVotersController.text = e.totalVoters.toString();
      }
    }
  }

  @override
  void dispose() {
    electionNameController.dispose();
    electionCodeController.dispose();
    notificationDateController.dispose();
    pollDateController.dispose();
    countingDateController.dispose();
    resultDateController.dispose();
    totalSeatsController.dispose();
    totalVotersController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E40AF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
        '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
        onDateSelected(picked);
      });
    }
  }

  Future<void> _submitElection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication required")),
        );
        return;
      }

      final body = {
        "election_category": selectedMainCategory,
        "election_type": selectedSubType,
        "election_name": electionNameController.text.trim(),
        "election_code": electionCodeController.text.trim(),
        "notification_date": _formatDate(notificationDate),
        "poll_date": _formatDate(pollDate),
        "counting_date": _formatDate(countingDate),
        "result_date": _formatDate(resultDate),
        "total_seats": _parseInt(totalSeatsController.text),
        "total_voters": _parseInt(totalVotersController.text),
        "state": selectedState,
        "district": selectedDistrict,
        "description": remarksController.text.trim(),
      };

      final isEdit = widget.election != null;
      final uri = isEdit
          ? Uri.parse("$baseUrl/masteradmin/elections/${widget.election!.id}")
          : Uri.parse("$baseUrl/masteradmin/elections");

      final response = await (isEdit
          ? http.put(uri,
          headers: _headers(token), body: jsonEncode(body))
          : http.post(uri,
          headers: _headers(token), body: jsonEncode(body)));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isEdit ? "Election updated successfully" : "Election declared successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        debugPrint("Election error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save election")),
        );
      }
    } catch (e) {
      debugPrint("Submit election error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  Map<String, String> _headers(String token) => {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  int? _parseInt(String value) {
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }


  void _declareElection() {
    if (selectedMainCategory == null ||
        selectedSubType == null ||
        selectedState == null ||
        selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select election type, sub-type, state and district'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (electionNameController.text.isEmpty ||
        electionCodeController.text.isEmpty ||
        notificationDateController.text.isEmpty ||
        pollDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all mandatory fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Election Declaration Logic
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Election Declared Successfully',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E40AF),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Election Type:', selectedMainCategory!),
                _buildDetailRow('Sub-Type:', selectedSubType!),
                _buildDetailRow('State:', selectedState!),
                _buildDetailRow('District:', selectedDistrict!),
                _buildDetailRow('Election Name:', electionNameController.text),
                _buildDetailRow('Election Code:', electionCodeController.text),
                _buildDetailRow('Notification Date:', notificationDateController.text),
                _buildDetailRow('Poll Date:', pollDateController.text),
                if (countingDateController.text.isNotEmpty)
                  _buildDetailRow('Counting Date:', countingDateController.text),
                if (resultDateController.text.isNotEmpty)
                  _buildDetailRow('Result Date:', resultDateController.text),
                if (totalSeatsController.text.isNotEmpty)
                  _buildDetailRow('Total Seats:', totalSeatsController.text),
                if (totalVotersController.text.isNotEmpty)
                  _buildDetailRow('Total Voters:', totalVotersController.text),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E40AF),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        // ✅ BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E40AF)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        title: Text(
          widget.election == null
              ? 'Election Declaration'
              : 'Edit Election',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.how_to_vote,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Declare New Election',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select election type and provide details for official declaration',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Election Type Selection
                  _buildSectionHeader('Step 1: Select Election Type', '01'),
                  const SizedBox(height: 16),

                  // Main Category Dropdown
                  _buildDropdownCard(
                    label: 'Election Category *',
                    value: selectedMainCategory,
                    items: electionTypes.keys.toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMainCategory = value;
                        selectedSubType = null;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sub Type Dropdown
                  if (selectedMainCategory != null)
                    _buildDropdownCard(
                      label: 'Election Sub-Type *',
                      value: selectedSubType,
                      items: electionTypes[selectedMainCategory!]!,
                      onChanged: (value) {
                        setState(() {
                          selectedSubType = value;
                          selectedState = null;
                          selectedDistrict = null;
                        });
                      },
                    ),

                  const SizedBox(height: 16),

// State Dropdown
                  if (selectedSubType != null) ...[
                    const SizedBox(height: 16),
                    _buildDropdownCard(
                      label: 'State *',
                      value: selectedState,
                      items: statesAndDistricts.keys.toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedState = value;
                          selectedDistrict = null;
                        });
                      },
                    ),
                  ],

// District Dropdown
                  if (selectedState != null) ...[
                    const SizedBox(height: 16),
                    _buildDropdownCard(
                      label: 'District *',
                      value: selectedDistrict,
                      items: statesAndDistricts[selectedState!] ?? [],
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Step 2: Election Details
                  _buildSectionHeader('Step 2: Election Details', '02'),
                  const SizedBox(height: 16),

                  // Election Name
                  _buildTextField(
                    controller: electionNameController,
                    label: 'Election Name *',
                    hint: 'e.g., General Elections 2025',
                    icon: Icons.edit,
                  ),

                  const SizedBox(height: 12),

                  // Election Code
                  _buildTextField(
                    controller: electionCodeController,
                    label: 'Election Code *',
                    hint: 'e.g., LS-2025-001',
                    icon: Icons.code,
                  ),

                  const SizedBox(height: 32),

                  // Step 3: Important Dates
                  _buildSectionHeader('Step 3: Important Dates', '03'),
                  const SizedBox(height: 16),

                  // Notification Date
                  _buildDateField(
                    controller: notificationDateController,
                    label: 'Notification Date *',
                    onTap: () => _selectDate(context, notificationDateController, (date) {
                      setState(() => notificationDate = date);
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Poll Date
                  _buildDateField(
                    controller: pollDateController,
                    label: 'Poll Date *',
                    onTap: () => _selectDate(context, pollDateController, (date) {
                      setState(() => pollDate = date);
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Counting Date
                  _buildDateField(
                    controller: countingDateController,
                    label: 'Counting Date',
                    onTap: () => _selectDate(context, countingDateController, (date) {
                      setState(() => countingDate = date);
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Result Date
                  _buildDateField(
                    controller: resultDateController,
                    label: 'Result Date',
                    onTap: () => _selectDate(context, resultDateController, (date) {
                      setState(() => resultDate = date);
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Step 4: Election Statistics
                  _buildSectionHeader('Step 4: Election Statistics', '04'),
                  const SizedBox(height: 16),

                  // Total Seats
                  _buildTextField(
                    controller: totalSeatsController,
                    label: 'Total Seats',
                    hint: 'e.g., 543',
                    icon: Icons.domain,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 12),

                  // Total Voters
                  _buildTextField(
                    controller: totalVotersController,
                    label: 'Total Voters',
                    hint: 'e.g., 900000000',
                    icon: Icons.people,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 32),

                  // Step 5: Additional Information
                  _buildSectionHeader('Step 5: Additional Information', '05'),
                  const SizedBox(height: 16),

                  // Remarks
                  _buildTextAreaField(
                    controller: remarksController,
                    label: 'Remarks & Notes',
                    hint: 'Enter any additional information or special conditions',
                  ),

                  const SizedBox(height: 32),

                  // Declare Election Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E40AF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _submitElection,
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                widget.election == null
                                    ? 'Declare Election'
                                    : 'Update Election',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedMainCategory = null;
                          selectedSubType = null;
                          selectedState = null;
                          selectedDistrict = null;
                          electionNameController.clear();
                          electionCodeController.clear();
                          notificationDateController.clear();
                          pollDateController.clear();
                          countingDateController.clear();
                          resultDateController.clear();
                          totalSeatsController.clear();
                          totalVotersController.clear();
                          remarksController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1E40AF), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reset Form',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String step) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            ),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
          DropdownButtonFormField<String>(
            value: value,
            isDense: true, // ✅ FIX 1: removes extra height
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true, // ✅ FIX 2
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12, // ✅ FIX 3: force same height
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ))
                .toList(),
            onChanged: onChanged,
            hint: Text(
              'Select $label',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E40AF)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(icon, color: const Color(0xFF1E40AF)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'DD/MM/YYYY',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  prefixIcon:
                  Icon(Icons.calendar_today, color: Color(0xFF1E40AF)),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}