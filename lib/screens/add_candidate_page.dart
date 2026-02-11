import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddCandidatePage extends StatefulWidget {
  const AddCandidatePage({Key? key}) : super(key: key);

  @override
  State<AddCandidatePage> createState() => _AddCandidatePageState();
}

class _AddCandidatePageState extends State<AddCandidatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController partyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController voterIdController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController searchVoterController = TextEditingController();
  bool isSearchingVoter = false;
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  String? selectedGender;
  File? candidatePhoto;
  File? symbolPhoto;
  bool _isSubmitting = false;
  bool _isVoterLocked = false;

  final String baseUrl =
      "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com";



  // ✅ Election Selection Variables

  String? selectedType; // AC or Ward
  String? selectedArea;

  List<Map<String, dynamic>> electionList = [];
  int? selectedElectionId;

  List<String> typeList = ['AC', 'Ward'];
  List<String> areaList = [];

  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    partyController.dispose();
    descriptionController.dispose();
    ageController.dispose();
    voterIdController.dispose();
    aadhaarController.dispose();
    phoneController.dispose();
    emailController.dispose();
    searchVoterController.dispose(); // ✅ ADD THIS
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadElections();
  }

  Future<void> _loadElections() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/masteradmin/elections"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          electionList = data
              .where((e) => e['status'] != 'past')
              .map((e) => {
            "id": e['id'],
            "name": e['election_name'],
          })
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Election load error: $e");
    }
  }



  Future<void> _loadAreas() async {
    if (selectedElectionId == null || selectedType == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      if (selectedType == "Ward") {
        final response = await http.get(
          Uri.parse("$baseUrl/api/wards?election_id=$selectedElectionId"),
          headers: {
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);

          setState(() {
            areaList = data
                .map((e) => "${e['id']}|${e['ward_name']}")
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Area load error: $e");
    }
  }



  Future<void> _searchVoter() async {
    if (searchVoterController.text.trim().isEmpty) {
      _showError("Enter voter ID to search");
      return;
    }

    setState(() {
      isSearchingVoter = true;
      _isVoterLocked = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/common/search-user?voter_id=${searchVoterController.text.trim()}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null) {
          _showError("User not found");
        } else {
          nameController.text =
          "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}";
          ageController.text = data["age"]?.toString() ?? "";
          phoneController.text = data["phone"] ?? "";
          emailController.text = data["email"] ?? "";
          voterIdController.text = data["voter_id"] ?? "";

          String? genderFromApi = data["gender"];
          if (genderFromApi == "M") selectedGender = "Male";
          if (genderFromApi == "F") selectedGender = "Female";
          if (genderFromApi == "O") selectedGender = "Other";

          setState(() {
            _isVoterLocked = true; // 🔥 LOCK FIELDS
          });
        }
      }
    } catch (e) {
      _showError("Search failed");
    }

    setState(() => isSearchingVoter = false);
  }

  Future<void> _pickImage(bool isCandidatePhoto) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          if (isCandidatePhoto) {
            candidatePhoto = File(pickedFile.path);
          } else {
            symbolPhoto = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error selecting image'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  bool _validateForm() {
    if (selectedElectionId == null) {
      _showError('Please select election');
      return false;
    }

    if (selectedType == null) {
      _showError('Please select AC or Ward');
      return false;
    }

    if (selectedArea == null) {
      _showError('Please select area');
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      _showError('Please enter candidate name');
      return false;
    }
    if (partyController.text.trim().isEmpty) {
      _showError('Please enter party name');
      return false;
    }
    if (ageController.text.trim().isEmpty) {
      _showError('Please enter age');
      return false;
    }
    if (int.tryParse(ageController.text.trim()) == null) {
      _showError('Please enter valid age (numbers only)');
      return false;
    }
    if (voterIdController.text.trim().isEmpty) {
      _showError('Please enter voter ID');
      return false;
    }
    if (aadhaarController.text.trim().isEmpty) {
      _showError('Please enter Aadhaar number');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      _showError('Please enter phone number');
      return false;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text.trim())) {
      _showError('Please enter valid 10-digit phone number');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter email address');
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _showError('Please enter password');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }

    if (!RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    ).hasMatch(emailController.text.trim())) {
      _showError('Please enter valid email address');
      return false;
    }
    if (selectedGender == null) {
      _showError('Please select gender');
      return false;
    }
    if (candidatePhoto == null) {
      _showError('Please select candidate photo');
      return false;
    }
    if (symbolPhoto == null) {
      _showError('Please select party symbol');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveCandidate() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      _showError("Authentication required");
      return;
    }

    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/candidate/create"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["election_id"] = selectedElectionId.toString();
      request.fields["voter_id"] = voterIdController.text.trim();
      request.fields["first_name"] = nameController.text.trim();
      request.fields["last_name"] = "";
      request.fields["phone"] = phoneController.text.trim();
      request.fields["email"] = emailController.text.trim();
      request.fields["password"] = passwordController.text.trim();
      request.fields["gender"] = selectedGender ?? "";
      request.fields["age"] = ageController.text.trim();
      request.fields["party"] = partyController.text.trim();
      request.fields["candidate_type"] = "party";

      if (selectedType == "Ward" && selectedArea != null) {
        request.fields["ward_id"] =
        selectedArea!.split("|")[0];
      }

      // 🔥 Attach Images
      request.files.add(
        await http.MultipartFile.fromPath(
          "candidate_photo",
          candidatePhoto!.path,
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          "party_symbol",
          symbolPhoto!.path,
        ),
      );

      final response = await request.send();
      final responseBody =
      await response.stream.bytesToString();

      final resData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        _showError(resData["message"] ?? "Failed");
      }
    } catch (e) {
      _showError("Upload failed");
    }

    setState(() => _isSubmitting = false);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: const Text(
          "Candidate Created Successfully!",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Done"),
          )
        ],
      ),
    );
  }


  Widget _buildPhotoSelector({
    required String title,
    required IconData icon,
    required File? selectedFile,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade700, width: 2),
                shape: title == "Candidate Photo"
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: title != "Candidate Photo"
                    ? BorderRadius.circular(16)
                    : null,
              ),
              child: selectedFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 48, color: Colors.blue.shade700),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: title != "Candidate Photo"
                          ? BorderRadius.circular(16)
                          : BorderRadius.circular(140),
                      child: Image.file(
                        selectedFile,
                        fit: BoxFit.cover,
                        width: 140,
                        height: 140,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Candidate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==============================
            // ELECTION SELECTION SECTION
            // ==============================
            _buildSectionHeader("Election Selection"),
            const SizedBox(height: 16),

            // Election Dropdown
            DropdownButtonFormField<int>(
              value: selectedElectionId,
              items: electionList.map((e) {
                return DropdownMenuItem<int>(
                  value: e['id'],
                  child: Text(e['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedElectionId = value;
                  selectedType = null;
                  selectedArea = null;
                  areaList.clear();
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Election',
                prefixIcon: Icon(Icons.how_to_vote, color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
            ),

            const SizedBox(height: 16),

            // AC / Ward selector
            if (selectedElectionId != null)
              DropdownButtonFormField<String>(
                value: selectedType,
                items: typeList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    selectedArea = null;
                  });
                  _loadAreas();
                },
                decoration: InputDecoration(
                  labelText: 'Choose AC or Ward',
                  prefixIcon: Icon(Icons.map, color: themeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),

            const SizedBox(height: 16),

            // Area List Dropdown
            if (selectedType != null)
              DropdownButtonFormField<String>(
                value: selectedArea,
                items: areaList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedArea = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Area',
                  prefixIcon: Icon(Icons.location_on, color: themeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),

            const SizedBox(height: 32),

            // ==============================
            // SEARCH VOTER SECTION
            // ==============================
            _buildSectionHeader("Search Voter"),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchVoterController,
                    decoration: InputDecoration(
                      labelText: "Search by Voter ID",
                      prefixIcon: Icon(Icons.search, color: themeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isSearchingVoter ? null : _searchVoter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSearchingVoter
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Photo Selectors
            _buildPhotoSelector(
              title: "Candidate Photo",
              icon: Icons.camera_alt,
              selectedFile: candidatePhoto,
              onTap: () => _pickImage(true),
            ),
            const SizedBox(height: 32),
            _buildPhotoSelector(
              title: "Party Symbol",
              icon: Icons.flag,
              selectedFile: symbolPhoto,
              onTap: () => _pickImage(false),
            ),
            const SizedBox(height: 32),

            // Political Information Section
            _buildSectionHeader("Political Information"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: partyController,
              label: 'Party Name *',
              icon: Icons.flag,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: descriptionController,
              label: 'Description (Optional)',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 28),

            // Personal Information Section
            _buildSectionHeader("Personal Information"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: nameController,
              label: 'Candidate Name *',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: ageController,
              label: 'Age *',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: ['Male', 'Female', 'Other']
                  .map(
                    (gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedGender = value),
              decoration: InputDecoration(
                labelText: 'Gender *',
                prefixIcon: Icon(Icons.wc, color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Government IDs Section
            _buildSectionHeader("Government IDs"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: voterIdController,
              label: 'Voter ID Number *',
              icon: Icons.how_to_vote,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: aadhaarController,
              label: 'Aadhaar Card Number *',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Contact Information Section
            _buildSectionHeader("Contact Information"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              label: 'Phone Number *',
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              label: 'Email Address *',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: Icon(Icons.lock, color: themeColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: themeColor,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _saveCandidate,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSubmitting ? 'Saving...' : 'Add Candidate',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade700,
        letterSpacing: 0.5,
      ),
    );
  }
}
