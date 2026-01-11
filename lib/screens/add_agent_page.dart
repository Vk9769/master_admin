import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Booth model from backend
class Booth {
  final String id;
  final String name;
  String address;
  final int radiusMeters;
  final double latitude;
  final double longitude;

  Booth({
    required this.id,
    required this.name,
    required this.address,
    required this.radiusMeters,
    required this.latitude,
    required this.longitude,
  });

  factory Booth.fromJson(Map<String, dynamic> json) {
    return Booth(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      radiusMeters: (json['radius_meters'] ?? 100).toInt(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  @override
  String toString() => '$name ($id)';
}

class AddAgentPage extends StatefulWidget {
  const AddAgentPage({super.key});

  @override
  State<AddAgentPage> createState() => _AddAgentPageState();
}

class _AddAgentPageState extends State<AddAgentPage> {
  final _formKey = GlobalKey<FormState>();

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
  File? _pickedImage;        // Mobile
  Uint8List? _webImageBytes; // Web


  // State
  bool _obscurePassword = true;
  Booth? _selectedBooth;
  bool _loading = false;
  String? _existingProfilePhotoUrl;

  // Voter Search State
  bool _searchingVoter = false;
  bool _voterFetched = false;
  Map<String, dynamic>? _voterData;
  static const String _fixedRole = 'AGENT';

  static const String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";

  String? _selectedIdType;
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>
  locationHierarchy = {};

  List<String> _states = [];
  List<String> _districts = [];
  List<String> _assemblies = [];
  List<Map<String, dynamic>> _parts = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedAssembly;
  String? _selectedPart;

  List<Map<String, dynamic>> _elections = [];
  String? _selectedElectionId;

  @override
  void initState() {
    super.initState();
    _fetchLocationHierarchy();
    _fetchElections();
  }

  Future<void> _fetchLocationHierarchy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/masteradmin/booths'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print("Error: ${response.body}");
        return;
      }

      final List data = json.decode(response.body);

      print("API DATA LENGTH: ${data.length}");
      print("First Item: ${data.isNotEmpty ? data[0] : 'No Data'}");

      Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> temp =
          {};

      for (var booth in data) {
        final state = booth['state']?.toString().trim() ?? '';
        final district = booth['district']?.toString().trim() ?? '';
        final assembly =
            booth['assembly_constituency']?.toString().trim() ?? '';
        final part = booth['part_name']?.toString().trim() ?? '';
        final boothId = booth['id']?.toString();
        final boothName = booth['name']?.toString() ?? 'Unknown Booth';

        if (state.isEmpty ||
            district.isEmpty ||
            assembly.isEmpty ||
            part.isEmpty)
          continue;

        temp[state] ??= {};
        temp[state]![district] ??= {};
        temp[state]![district]![assembly] ??= [];

        // Store full booth info
        temp[state]![district]![assembly]!.add({
          "id": boothId,
          "name": boothName,
          "part_name": part,
        });
      }

      setState(() {
        locationHierarchy = temp;
        _states = temp.keys.toList()..sort();

        // 🔒 reset dependent selections
        _selectedState = null;
        _selectedDistrict = null;
        _selectedAssembly = null;
        _selectedPart = null;
      });
    } catch (e) {
      print("Fetch error => $e");
    }
  }

  String? safeDropdownValue(List<String> items, String? value) {
    if (value == null) return null;
    final matches = items.where((e) => e == value).toList();
    return matches.length == 1 ? value : null;
  }
  String safeKeyFromList(List list, String prefix) {
    if (list.isEmpty) return '${prefix}_empty';
    return '${prefix}_${list.join("_")}';
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

    return const AssetImage("admin_avatar.png");
  }




  Future<void> _fetchElections() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    final res = await http.get(
      Uri.parse('$baseUrl/masteradmin/elections/active'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        _elections = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      });
    }
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
    if (_selectedDistrict != null) filled++;
    if (_selectedAssembly != null) filled++;
    if (_selectedPart != null) filled++; // ✅ Correct booth selection
    if (_selectedGender != null) filled++;
    if (_dobCtrl.text.trim().isNotEmpty) filled++;
    if (_addressCtrl.text.trim().isNotEmpty) filled++;
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
      final token = prefs.getString('auth_token');
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
      _lastNameCtrl.text  = data['last_name'] ?? '';
      _phoneCtrl.text     = data['phone'] ?? '';
      _emailCtrl.text     = data['email'] ?? '';
      _idNumberCtrl.text  = data['gov_id_no'] ?? '';
      _addressCtrl.text   = data['address'] ?? '';
      _dobCtrl.text       = data['dob'] ?? '';
      _selectedGender     = normalizeGender(data['gender']);
      _existingProfilePhotoUrl = data['profile_photo'];


// 2️⃣ LOCATION — STEP BY STEP
      final state = data['state'];
      final district = data['district'];
      final assembly = data['assembly_constituency'];
      final boothId = data['boothid']?.toString();

// STATE
      if (state != null && locationHierarchy.containsKey(state)) {
        _selectedState = state;
        _districts = locationHierarchy[state]!.keys.toList();

        // DISTRICT
        if (_districts.contains(district)) {
          _selectedDistrict = district;
          _assemblies = locationHierarchy[state]![district]!.keys.toList();

          // ASSEMBLY
          if (_assemblies.contains(assembly)) {
            _selectedAssembly = assembly;
            _parts = List<Map<String, dynamic>>.from(
              locationHierarchy[state]![district]![assembly]!,
            );

            // BOOTH
            if (_parts.any((p) => p['id'].toString() == boothId)) {
              _selectedPart = boothId;
            }
          }
        }
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
    _selectedDistrict = null;
    _selectedAssembly = null;
    _selectedPart = null;
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

  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found, please login again')),
      );
      setState(() => _loading = false);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validate required dropdowns
    if (_selectedPart == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select booth')));
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('$baseUrl/agent');

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['firstName'] = _firstNameCtrl.text.trim();
      request.fields['lastName'] = _lastNameCtrl.text.trim();
      request.fields['voterId'] = _voterIdCtrl.text.trim();
      request.fields['gov_id_type'] = 'Aadhaar';
      request.fields['gov_id_no'] = _idNumberCtrl.text.trim();
      request.fields['email'] = _emailCtrl.text.trim();
      request.fields['password'] = _passwordCtrl.text.trim();
      request.fields['phone'] = _phoneCtrl.text.trim();
      request.fields['role'] = 'AGENT';
      request.fields['electionId'] = _selectedElectionId!;
      request.fields['state'] = _selectedState ?? '';
      request.fields['district'] = _selectedDistrict ?? '';
      request.fields['assembly_constituency'] = _selectedAssembly ?? '';
      request.fields['boothId'] = _selectedPart!; // ✅ Correct
      request.fields['gender'] = _selectedGender ?? '';
      request.fields['dob'] = _dobCtrl.text.trim();
      request.fields['address'] = _addressCtrl.text.trim();

      if (!_voterFetched && _pickedImage != null) {
        var pic = await http.MultipartFile.fromPath(
          'profilePhoto',
          _pickedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(pic);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agent added successfully')),
        );
        _resetForm();
      } else {
        try {
          final resBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${resBody['error'] ?? 'Unknown error'}'),
            ),
          );
        } catch (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
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
        title: const Text('Add Agent'),
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
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'First name is required'
                                : null,
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
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Last name is required'
                                : null,
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
                              if (v == null || v.trim().isEmpty)
                                return 'Voter ID is required';
                              if (v.trim().length < 7)
                                return 'Invalid Voter ID (min 7 characters)';
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
                              if (v == null || v.trim().isEmpty) {
                                return 'Aadhaar number is required';
                              }
                              if (!RegExp(r'^\d{12}$').hasMatch(v.trim())) {
                                return 'Enter valid 12-digit Aadhaar number';
                              }
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
                              if (v == null || v.trim().isEmpty)
                                return 'Password is required';
                              if (v.trim().length < 6)
                                return 'Minimum 6 characters';
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
                            value: _genders.contains(_selectedGender) ? _selectedGender : null,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            items: _genders.map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedGender = v),
                            validator: (v) => v == null ? 'Please select gender' : null,
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
                                'Role & Booth Assignment',
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
                            'Please select role and exact polling location carefully',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 16),
                          // SELECT ROLE
                          ListTile(
                            leading: const Icon(
                              Icons.security,
                              color: Colors.blue,
                            ),
                            title: const Text("Role"),
                            subtitle: const Text("Agent (Part Level)"),
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _selectedElectionId,
                            items: _elections.map((e) {
                              return DropdownMenuItem(
                                value: e['id'].toString(),
                                child: Text(e['election_name']),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedElectionId = v),
                            decoration: const InputDecoration(
                              labelText: "Select Election",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null ? 'Select election' : null,
                          ),


                          // STATE
                          DropdownButtonFormField<String>(
                            key: ValueKey(safeKeyFromList(_states, 'state')),
                            // ✅ ADD HERE
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
                                _districts = locationHierarchy[v]!.keys
                                    .toList();
                                _selectedDistrict = null;
                                _assemblies = [];
                                _selectedAssembly = null;
                                _parts = [];
                                _selectedPart = null;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Select State",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // DISTRICT
                          if (_selectedState != null)
                            DropdownButtonFormField<String>(
                              key: ValueKey(safeKeyFromList(_districts, 'district')),
                              value: safeDropdownValue(
                                _districts,
                                _selectedDistrict,
                              ),
                              items: _districts
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedDistrict = v;
                                  _assemblies =
                                      locationHierarchy[_selectedState]![v]!
                                          .keys
                                          .toList();
                                  _selectedAssembly = null;
                                  _parts = [];
                                  _selectedPart = null;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: "Select District",
                                border: OutlineInputBorder(),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // ASSEMBLY
                          if (_selectedDistrict != null)
                            DropdownButtonFormField<String>(
                              key: ValueKey(safeKeyFromList(_assemblies, 'assembly')),
                              // ✅ ADD HERE
                              value: safeDropdownValue(
                                _assemblies,
                                _selectedAssembly,
                              ),
                              items: _assemblies
                                  .map(
                                    (a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(a),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedAssembly = v;
                                  _parts = List<Map<String, dynamic>>.from(
                                    locationHierarchy[_selectedState]![_selectedDistrict]![v]!,
                                  );
                                  _selectedPart = null;
                                });
                              },

                              decoration: const InputDecoration(
                                labelText: "Select Assembly Constituency",
                                border: OutlineInputBorder(),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // BOOTH
                          if (_selectedAssembly != null)
                            DropdownButtonFormField<String>(
                              key: ValueKey(
                                _parts.isEmpty
                                    ? 'booth_empty'
                                    : 'booth_${_parts.map((e) => e['id']).join("_")}',
                              ),
                              isExpanded: true,
                              menuMaxHeight: 300,

                              value: _parts.any((p) => p['id'].toString() == _selectedPart)
                                  ? _selectedPart
                                  : null,

                              items: _parts.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p["id"].toString(),
                                  child: Text("${p["part_name"]} - ${p["name"]}"),
                                );
                              }).toList(),

                              onChanged: (v) => setState(() => _selectedPart = v),

                              decoration: const InputDecoration(
                                labelText: "Select Booth",
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v == null ? "Select booth" : null,
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
                                    _loading ? 'Adding...' : 'Add Agent',
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
