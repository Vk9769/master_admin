import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EditDistrictAdminPage extends StatefulWidget {
  final String districtAdminId;

  const EditDistrictAdminPage({super.key, required this.districtAdminId});

  @override
  State<EditDistrictAdminPage> createState() => _EditDistrictAdminPageState();
}

class _EditDistrictAdminPageState extends State<EditDistrictAdminPage> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _elections = [];
  String? _selectedElectionId;

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _voterIdCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  File? _pickedImage; // Mobile
  Uint8List? _webImageBytes; // Web

  // State
  bool _obscurePassword = true;
  bool _loading = false;
  String? _existingProfilePhotoUrl;

  // Voter Search State
  bool _searchingVoter = false;
  bool _voterFetched = false;
  Map<String, dynamic>? _voterData;

  static const String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";

  List<String> _states = [];

  String? _selectedState;

  @override
  void initState() {
    super.initState();
    _fetchElections();
    _loadDistrictAdminDetails();
  }

  Future<void> _fetchElections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final res = await http.get(
        Uri.parse('$baseUrl/masteradmin/elections/active'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          _elections = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        });
      } else {
        print("Election fetch error: ${res.body}");
      }
    } catch (e) {
      print("Election fetch exception: $e");
    }
  }

  Future<void> _fetchStatesByElection(String electionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/common/election-states?election_id=$electionId",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          _states = List<String>.from(data);
          _selectedState = null;
        });
      } else {
        debugPrint("State API error: ${response.body}");
      }
    } catch (e) {
      debugPrint("State fetch error: $e");
    }
  }

  Future<void> _loadDistrictAdminDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) return;

      final response = await http.get(
        Uri.parse("$baseUrl/admin/${widget.districtAdminId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _firstNameCtrl.text = data['first_name'] ?? '';
          _lastNameCtrl.text = data['last_name'] ?? '';
          _voterIdCtrl.text = data['voter_id'] ?? '';
          _idNumberCtrl.text = data['gov_id_no'] ?? '';
          _emailCtrl.text = data['email'] ?? '';
          _phoneCtrl.text = data['phone'] ?? '';
          _addressCtrl.text = data['address'] ?? '';
          if (data['date_of_birth'] != null) {
            DateTime dob = DateTime.parse(data['date_of_birth']);
            _dobCtrl.text = DateFormat('dd-MM-yyyy').format(dob);
          }
          _selectedGender = normalizeGender(data['gender']);
          _selectedElectionId = data['election_id']?.toString();
          _selectedState = data['state'];
          _existingProfilePhotoUrl = data['profile_photo'];
        });

        if (_selectedElectionId != null) {
          await _fetchStatesByElection(_selectedElectionId!);
        }
      }
    } catch (e) {
      debugPrint("Load error: $e");
    }
  }

  String? safeDropdownValue(List<String> items, String? value) {
    if (value == null) return null;
    final matches = items.where((e) => e == value).toList();
    return matches.length == 1 ? value : null;
  }

  String safeKeyFromList(List list, String prefix) {
    if (list.isEmpty) return '${prefix}_empty';
    return '${prefix}${list.join("")}';
  }

  String? normalizeGender(String? apiGender) {
    if (apiGender == null) return null;

    switch (apiGender.toUpperCase()) {
      case 'M':
      case 'MALE':
        return 'Male';
      case 'F':
      case 'FEMALE':
        return 'Female';
      case 'O':
      case 'OTHER':
        return 'Other';
      default:
        return null;
    }
  }

  ImageProvider _agentProfileImageProvider() {
    if (kIsWeb && _webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    }

    if (!kIsWeb && _pickedImage != null) {
      return FileImage(_pickedImage!);
    }

    if (_existingProfilePhotoUrl != null &&
        _existingProfilePhotoUrl!.isNotEmpty &&
        _existingProfilePhotoUrl!.startsWith("http")) {
      return NetworkImage(_existingProfilePhotoUrl!);
    }

    return const AssetImage("assets/admin_avatar.png");
  }

  double get _formCompletion {
    int total = 14;
    int filled = 0;
    if (_firstNameCtrl.text.trim().isNotEmpty) filled++;
    if (_lastNameCtrl.text.trim().isNotEmpty) filled++;
    if (_idNumberCtrl.text.trim().isNotEmpty) filled++;
    if (_emailCtrl.text.trim().isNotEmpty) filled++;
    if (_passwordCtrl.text.trim().isNotEmpty) filled++;
    if (_phoneCtrl.text.trim().isNotEmpty) filled++;
    if (_selectedState != null) filled++;
    if (_selectedGender != null) filled++;
    if (_dobCtrl.text.trim().isNotEmpty) filled++;
    if (_addressCtrl.text.trim().isNotEmpty) filled++;
    if (_selectedElectionId != null) filled++;
    return filled / total;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
        _pickedImage = null;
      });
    } else {
      setState(() {
        _pickedImage = File(picked.path);
        _webImageBytes = null;
      });
    }
  }

  Future<void> _searchByVoterId() async {
    if (_voterIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter Voter ID to search')));
      return;
    }

    setState(() {
      _searchingVoter = true;
      _voterFetched = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/voter/by-voter-id/${_voterIdCtrl.text.trim()}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Voter not found');
      }

      final data = jsonDecode(response.body);
      _voterData = data;

      // 🔽 AUTO-FILL FORM FIELDS
      // 1️⃣ Basic fields
      _firstNameCtrl.text = data['first_name'] ?? '';
      _lastNameCtrl.text = data['last_name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      _idNumberCtrl.text = data['gov_id_no'] ?? '';
      _addressCtrl.text = data['address'] ?? '';
      if (data['dob'] != null) {
        DateTime dob = DateTime.parse(data['dob']);
        _dobCtrl.text = DateFormat('dd-MM-yyyy').format(dob);
      }
      _selectedGender = normalizeGender(data['gender']);
      _existingProfilePhotoUrl = data['profile_photo'];

      // 2️⃣ LOCATION — STEP BY STEP
      final state = data['state'];

      // STATE
      if (state != null && _states.contains(state)) {
        _selectedState = state;
      }

      setState(() {
        _voterFetched = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voter details loaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      setState(() => _searchingVoter = false);
    }
  }

  void _togglePassword() =>
      setState(() => _obscurePassword = !_obscurePassword);

  void _resetForm() {
    _formKey.currentState?.reset();
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _voterIdCtrl.clear();
    _idNumberCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    _phoneCtrl.clear();
    _addressCtrl.clear();
    _dobCtrl.clear();
    _pickedImage = null;

    _selectedGender = null;

    _selectedState = null;

    _voterFetched = false;
    _voterData = null;

    // ✅ DO NOT CLEAR STATE DATA
    setState(() {});
  }

  bool _validateEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  bool _validatePhone(String v) {
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  bool _validateAndLog() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      debugPrint('❌ FORM VALIDATION FAILED – check highlighted fields');
    }
    return valid;
  }

  Future<void> _submit() async {
    print("🟢 DISTRICT ADMIN SUBMIT CLICKED");

    if (_selectedElectionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select election')));
      return;
    }

    if (_selectedState == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select state')));
      return;
    }

    if (!_validateAndLog()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ✅ CORRECT ENDPOINT
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(
          '$baseUrl/district-admin/update-full/${widget.districtAdminId}',
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // =========================
      // BASIC FIELDS
      // =========================
      request.fields['firstName'] = _firstNameCtrl.text.trim();
      request.fields['lastName'] = _lastNameCtrl.text.trim();
      request.fields['voterId'] = _voterFetched && _voterData != null
          ? _voterData!['voter_id']
          : _voterIdCtrl.text.trim();

      request.fields['phone'] = _phoneCtrl.text.trim();
      request.fields['email'] = _emailCtrl.text.trim();
      request.fields['gender'] = _selectedGender ?? '';
      request.fields['dob'] = _dobCtrl.text.trim();
      request.fields['address'] = _addressCtrl.text.trim();

      request.fields['idType'] = 'Aadhaar';
      request.fields['idNumber'] = _idNumberCtrl.text.trim();

      // ✅ IMPORTANT
      request.fields['electionId'] = _selectedElectionId!;
      request.fields['state'] = _selectedState!;

      // =========================
      // PROFILE PHOTO
      // =========================
      if (!_voterFetched) {
        if (kIsWeb && _webImageBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'profilePhoto',
              _webImageBytes!,
              filename: 'district_admin.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else if (!kIsWeb && _pickedImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profilePhoto',
              _pickedImage!.path,
            ),
          );
        }
      }

      print("🟢 CALLING DISTRICT ADMIN API");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("STATUS => ${response.statusCode}");
      print("BODY => $responseBody");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('District Admin Updated Successfully')),
        );
        _resetForm();
      } else {
        final data = jsonDecode(responseBody);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Error")));
      }
    } catch (e) {
      print("ERROR => $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Server Error')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Colors.blue;
    final textPrimary = Theme.of(context).colorScheme.onSurface.withOpacity(.9);
    final textSecondary = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(.65);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Edit District Admin'),
        backgroundColor: primary,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🗳️ Election Selection Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Election Selection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // STEP 1 — Select Election
                          DropdownButtonFormField<String>(
                            value: _selectedElectionId,
                            items: _elections.map((e) {
                              return DropdownMenuItem(
                                value: e['id'].toString(),
                                child: Text(e['election_name']),
                              );
                            }).toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedElectionId = v;
                                _selectedState = null;
                                _states = [];
                              });

                              if (v != null) {
                                _fetchStatesByElection(v);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: "Select Election",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v == null ? 'Select election' : null,
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔍 VOTER SEARCH CARD
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Search Voter by Voter ID',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _voterIdCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Voter ID',
                              prefixIcon: Icon(
                                Icons.how_to_vote,
                                color: Colors.blue,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _searchingVoter
                                  ? null
                                  : _searchByVoterId,
                              icon: const Icon(Icons.search),
                              label: Text(
                                _searchingVoter ? 'Searching...' : 'Search',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                          if (_voterFetched)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                '✔ Voter exists. Photo will not be changed.',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile Photo Card
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _agentProfileImageProvider(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Profile Photo',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.photo_library,
                              color: primary,
                            ),
                            label: const Text(
                              'Choose',
                              style: TextStyle(color: primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: primary,
                                width: 1.25,
                              ),
                            ),
                            onPressed: _voterFetched ? null : _pickImage,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Form Fields Card
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Name fields
                          TextFormField(
                            controller: _firstNameCtrl,
                            enabled: !_voterFetched,

                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: Icon(Icons.badge, color: primary),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (_voterFetched) return null;
                              if (v == null || v.trim().isEmpty)
                                return 'First name is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastNameCtrl,
                            enabled: !_voterFetched,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: Icon(
                                Icons.badge_outlined,
                                color: primary,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (_voterFetched) return null;
                              if (v == null || v.trim().isEmpty)
                                return 'Last name is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // ✅ Voter ID Field
                          TextFormField(
                            controller: _voterIdCtrl,
                            enabled: !_voterFetched,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Voter ID Number',
                              prefixIcon: Icon(
                                Icons.how_to_vote,
                                color: primary,
                              ),
                              border: OutlineInputBorder(),
                              hintText: 'e.g., XYZ1234567',
                            ),
                            validator: (v) {
                              if (_voterFetched) return null;
                              if (v == null || v.trim().isEmpty)
                                return 'Voter ID is required';
                              if (v.trim().length < 7)
                                return 'Invalid Voter ID';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Aadhaar Number
                          TextFormField(
                            controller: _idNumberCtrl,
                            enabled: !_voterFetched,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Aadhaar Number',
                              prefixIcon: Icon(
                                Icons.credit_card,
                                color: primary,
                              ),
                              border: OutlineInputBorder(),
                              hintText: '12-digit Aadhaar number',
                            ),
                            validator: (v) {
                              if (_voterFetched) return null;
                              if (v == null || v.trim().isEmpty)
                                return 'Aadhaar number is required';
                              if (!RegExp(r'^\d{12}$').hasMatch(v.trim()))
                                return 'Enter valid 12-digit Aadhaar';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email, color: primary),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (_voterFetched) return null;
                              if (v == null || v.trim().isEmpty)
                                return 'Email is required';
                              if (!_validateEmail(v))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            enabled: !_voterFetched,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: primary,
                              ),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: _togglePassword,
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: primary,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return null; // allow blank on edit
                              }

                              if (v.trim().length < 6) {
                                return 'Minimum 6 characters';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Phone
                          TextFormField(
                            controller: _phoneCtrl,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone, color: primary),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (_voterFetched) return null;
                              if (v == null || v.trim().isEmpty)
                                return 'Phone is required';
                              if (!_validatePhone(v))
                                return 'Enter a valid phone';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          const SizedBox(height: 12),

                          // Gender Dropdown
                          DropdownButtonFormField<String>(
                            value: _genders.contains(_selectedGender)
                                ? _selectedGender
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            items: _genders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                            validator: (v) =>
                                v == null ? 'Please select gender' : null,
                          ),
                          const SizedBox(height: 12),

                          // DOB Picker
                          TextFormField(
                            controller: _dobCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              border: OutlineInputBorder(),
                              hintText: 'Select Date',
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime(1990, 1, 1),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                _dobCtrl.text =
                                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                setState(() {});
                              }
                            },
                            validator: (v) => v == null || v.isEmpty
                                ? 'Please select date of birth'
                                : null,
                          ),

                          const SizedBox(height: 12),

                          // Address
                          TextFormField(
                            controller: _addressCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: Colors.blue,
                              ),
                              border: OutlineInputBorder(),
                              hintText: 'Enter full address',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Address is required'
                                : null,
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Card
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // CARD TITLE
                          Row(
                            children: const [
                              Icon(Icons.assignment_ind, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Role & State Assignment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Please select role and exact election and state to assign this district admin carefully',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ROLE (FIXED)
                          // ROLE (FIXED)
                          ListTile(
                            leading: const Icon(
                              Icons.security,
                              color: Colors.blue,
                            ),
                            title: const Text("Role"),
                            subtitle: const Text("District Admin"),
                          ),

                          const SizedBox(height: 16),

                          // STATE ONLY
                          DropdownButtonFormField<String>(
                            key: ValueKey(safeKeyFromList(_states, 'state')),
                            value: safeDropdownValue(_states, _selectedState),
                            items: _states
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedState = v;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Select State",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null ? 'Select state' : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress + Buttons Card
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.task_alt, color: primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: _formCompletion.clamp(0, 1),
                                  backgroundColor: primary.withOpacity(.12),
                                  color: primary,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(_formCompletion * 100).round()}%',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: 220,
                                child: OutlinedButton.icon(
                                  onPressed: _resetForm,
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: primary,
                                  ),
                                  label: const Text(
                                    'Reset',
                                    style: TextStyle(color: primary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: primary,
                                      width: 1.25,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _loading ? null : _submit,
                                  icon: const Icon(Icons.person_add_alt_1),
                                  label: Text(
                                    _loading
                                        ? 'Updating...'
                                        : 'Update District Admin',
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}
