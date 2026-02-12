import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class EditCandidatePage extends StatefulWidget {
  final int candidateId;

  const EditCandidatePage({Key? key, required this.candidateId})
      : super(key: key);

  @override
  State<EditCandidatePage> createState() => _EditCandidatePageState();
}

class _EditCandidatePageState extends State<EditCandidatePage> {
  Map<String, dynamic>? candidate;
  bool isLoading = true;

  late TextEditingController nameController;
  late TextEditingController partyController;
  late TextEditingController descriptionController;
  late TextEditingController ageController;
  late TextEditingController constituencyController;
  late TextEditingController voterIdController;
  late TextEditingController aadhaarController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  String? gender;
  File? candidatePhoto;
  File? symbolPhoto;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCandidateDetails();   // ✅ ONLY THIS
  }

  Future<void> _fetchCandidateDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await http.get(
      Uri.parse(
          "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/candidate/details/${widget.candidateId}"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      candidate = jsonDecode(response.body);
      _initializeControllers();  // ✅ initialize AFTER data
    }

    setState(() {
      isLoading = false;
    });
  }


  void _initializeControllers() {
    nameController = TextEditingController(
      text:
      "${candidate!['first_name'] ?? ''} ${candidate!['last_name'] ?? ''}"
          .trim(),
    );

    partyController =
        TextEditingController(text: candidate!['party'] ?? '');

    descriptionController =
        TextEditingController(text: candidate!['description'] ?? '');

    ageController =
        TextEditingController(text: candidate!['age']?.toString() ?? '');

    // 🔥 Municipal vs Assembly
    if (candidate!['election_type']
        ?.toString()
        .toLowerCase()
        .contains("municipal") ==
        true) {
      constituencyController =
          TextEditingController(text: candidate!['ward_name'] ?? '');
    } else {
      constituencyController =
          TextEditingController(text: candidate!['constituency'] ?? '');
    }

    voterIdController =
        TextEditingController(text: candidate!['voter_id'] ?? '');

    aadhaarController =
        TextEditingController(text: candidate!['gov_id_no'] ?? '');

    phoneController =
        TextEditingController(text: candidate!['phone'] ?? '');

    emailController =
        TextEditingController(text: candidate!['email'] ?? '');

    String? rawGender = candidate!['gender'];

    if (rawGender == 'M') {
      gender = 'Male';
    } else if (rawGender == 'F') {
      gender = 'Female';
    } else if (rawGender == 'O') {
      gender = 'Other';
    } else {
      gender = null;
    }

  }



  @override
  void dispose() {
    nameController.dispose();
    partyController.dispose();
    descriptionController.dispose();
    ageController.dispose();
    constituencyController.dispose();
    voterIdController.dispose();
    aadhaarController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCandidatePhoto) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
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
          _hasChanges = true;
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
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter candidate name');
      return false;
    }
    if (partyController.text.trim().isEmpty) {
      _showError('Please enter party name');
      return false;
    }
    if (ageController.text.trim().isNotEmpty &&
        int.tryParse(ageController.text.trim()) == null) {
      _showError('Please enter valid age (numbers only)');
      return false;
    }
    if (phoneController.text.trim().isNotEmpty &&
        !RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text.trim())) {
      _showError('Please enter valid 10-digit phone number');
      return false;
    }
    if (emailController.text.trim().isNotEmpty &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
            .hasMatch(emailController.text.trim())) {
      _showError('Please enter valid email address');
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

  Future<void> _updateCandidate() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      var request = http.MultipartRequest(
        "PUT",
        Uri.parse(
            "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/candidate/update/${candidate!['id']}"),
      );

      request.headers['Authorization'] = "Bearer $token";

      // 🔹 Split first & last name (backend expects separately)
      final fullName = nameController.text.trim().split(" ");
      request.fields['first_name'] = fullName.first;
      request.fields['last_name'] =
      fullName.length > 1 ? fullName.sublist(1).join(" ") : "";

      request.fields['party'] = partyController.text.trim();
      request.fields['age'] = ageController.text.trim();
      String dbGender = '';

      if (gender == 'Male') {
        dbGender = 'M';
      } else if (gender == 'Female') {
        dbGender = 'F';
      } else if (gender == 'Other') {
        dbGender = 'O';
      }

      request.fields['gender'] = dbGender;

      request.fields['phone'] = phoneController.text.trim();
      request.fields['email'] = emailController.text.trim();

      // 🔹 Image upload (only if changed)
      if (candidatePhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "candidate_photo",
            candidatePhoto!.path,
          ),
        );
      }

      if (symbolPhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "party_symbol",
            symbolPhoto!.path,
          ),
        );
      }

      final response = await request.send();

      final responseData =
      await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Candidate updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context, true); // trigger refresh
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Update failed: $responseData"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }


  Widget _buildPhotoSelector({
    required String title,
    required IconData icon,
    required File? selectedFile,
    required String? imageUrl,
    required VoidCallback onTap,
    required bool isCircle,
  }) {
    ImageProvider? displayImage;

    if (selectedFile != null) {
      displayImage = FileImage(selectedFile);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      displayImage = NetworkImage(imageUrl);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircle ? null : BorderRadius.circular(16),
                color: Colors.blue.shade50,
                border: Border.all(
                  color: Colors.blue.shade700,
                  width: 2,
                ),
                image: displayImage != null
                    ? DecorationImage(
                  image: displayImage,
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: displayImage == null
                  ? Icon(icon, size: 48, color: Colors.blue.shade700)
                  : null,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => setState(() => _hasChanges = true),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (candidate == null) {
      return const Scaffold(
        body: Center(child: Text("Candidate not found")),
      );
    }

    final themeColor = Colors.blue.shade700;
    final isLocked = candidate!['nomination_status'] == "approved";
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Unsaved Changes'),
              content: const Text('Do you want to discard your changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep Editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Discard',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Candidate',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: themeColor,
          elevation: 3,
        ),
        backgroundColor: Colors.grey.shade50,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPhotoSelector(
                    title: "Candidate Photo",
                    icon: Icons.person,
                    selectedFile: candidatePhoto,
                    imageUrl: candidate!['candidate_photo_url'],
                    onTap: () => _pickImage(true),
                    isCircle: true,
                  ),
                  const SizedBox(height: 25),
                  _buildPhotoSelector(
                    title: "Party Symbol",
                    icon: Icons.flag,
                    selectedFile: symbolPhoto,
                    imageUrl: candidate!['party_symbol_url'],
                    onTap: () => _pickImage(false),
                    isCircle: false,
                  ),
                  const SizedBox(height: 30),

                  // Personal Information
                  _buildSectionHeader("Personal Information"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: nameController,
                    label: 'Candidate Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: ageController,
                    label: 'Age',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      gender = value;
                      _hasChanges = true;
                    }),
                    decoration: _inputDecoration('Gender', Icons.wc),
                  ),
                  const SizedBox(height: 24),

                  // Government IDs
                  _buildSectionHeader("Government IDs"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: voterIdController,
                    label: 'Voter ID',
                    icon: Icons.how_to_vote,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: aadhaarController,
                    label: 'Aadhaar Card',
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(height: 24),

                  // Contact Information
                  _buildSectionHeader("Contact Information"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  // Political Information
                  _buildSectionHeader("Political Information"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: partyController,
                    label: 'Party Name',
                    icon: Icons.flag,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: constituencyController,
                    readOnly: true,
                    enableInteractiveSelection: false,
                    decoration: _inputDecoration(
                      candidate!['election_type']
                          ?.toString()
                          .toLowerCase()
                          .contains("municipal") == true
                          ? 'Ward'
                          : 'Constituency',
                      Icons.location_city,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: descriptionController,
                    label: 'Description',
                    icon: Icons.description,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 30),

                  // Update Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: _isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        _isSubmitting ? 'Updating...' : 'Update Candidate',
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
                        elevation: 5,
                      ),
                      onPressed: (_isSubmitting || isLocked) ? null : _updateCandidate,
                    ),

                  ),
                  if (isLocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        "This candidate is approved and cannot be edited.",
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
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
