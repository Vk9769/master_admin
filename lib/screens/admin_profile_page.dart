import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';


class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String adminName = '';
  String adminEmail = '';
  String adminId = '';
  String phoneNumber = '';

  // New fields
  String firstName = '';
  String lastName = '';
  String gender = 'Male';
  String selectedDocument = 'Aadhar Card';
  String documentNumber = '';

  File? _profileImageFile;        // Android / iOS
  Uint8List? _webImageBytes;     // Web
  String? _profileImageUrl;      // backend image


  final ImagePicker _picker = ImagePicker();
  final List<String> _documentTypes = [
    'Aadhaar',
    'Passport',
    'Voter ID',
    'Driving License'
  ];

  String normalizeDocumentType(String? dbValue) {
    if (dbValue == null) return 'Aadhaar';

    final value = dbValue.toUpperCase();

    if (value.contains('AADHAR') || value.contains('AADHAAR')) {
      return 'Aadhaar';
    }
    if (value.contains('PASSPORT')) {
      return 'Passport';
    }
    if (value.contains('VOTER')) {
      return 'Voter ID';
    }
    if (value.contains('DRIVING')) {
      return 'Driving License';
    }

    return 'Aadhaar'; // safe fallback
  }


  final List<String> _genderList = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final res = await http.get(
      Uri.parse(
        "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/masteradmin/profile",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    setState(() {
      firstName = data["first_name"] ?? "";
      lastName = data["last_name"] ?? "";
      adminName = "$firstName $lastName";
      adminId = data["voter_id"] ?? "";
      adminEmail = data["email"] ?? "";
      phoneNumber = data["phone"] ?? "";
      gender = data["gender"] ?? "Male";
      selectedDocument = normalizeDocumentType(data["gov_id_type"]);
      documentNumber = data["gov_id_no"] ?? "";
      _profileImageUrl = data["profile_photo"];
    });

  }


  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
        _profileImageFile = null;
      });
    } else {
      setState(() {
        _profileImageFile = File(picked.path);
        _webImageBytes = null;
      });
    }
  }



  ImageProvider profileImageProvider() {
    // 1️⃣ Picked image preview (WEB)
    if (kIsWeb && _webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    }

    // 2️⃣ Picked image preview (MOBILE)
    if (!kIsWeb && _profileImageFile != null) {
      return FileImage(_profileImageFile!);
    }

    // 3️⃣ Existing backend image
    if (_profileImageUrl != null &&
        _profileImageUrl!.isNotEmpty &&
        _profileImageUrl!.startsWith("http")) {
      return NetworkImage(_profileImageUrl!);
    }

    // 4️⃣ Default avatar
    return const AssetImage("assets/admin_avatar.png");
  }




  Future<void> _uploadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) return;

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/masteradmin/profile/photo",
      ),
    );

    request.headers["Authorization"] = "Bearer $token";

    if (kIsWeb && _webImageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "photo",
          _webImageBytes!,
          filename: "profile.png",
        ),
      );
    } else if (!kIsWeb && _profileImageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "photo",
          _profileImageFile!.path,
        ),
      );
    } else {
      return;
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Profile photo updated");

      setState(() {
        _profileImageFile = null;
        _webImageBytes = null;
      });

      await _loadAdminData(); // reload signed URL
    } else {
      Fluttertoast.showToast(msg: "Photo upload failed");
    }
  }




  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    // 1️⃣ Upload photo IF user selected one
    if (_profileImageFile != null || _webImageBytes != null) {
      await _uploadPhoto();
    }

    await http.put(
      Uri.parse(
        "http://voting-alb-1933918113.eu-north-1.elb.amazonaws.com/masteradmin/profile",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "phone": phoneNumber,
        "email": adminEmail,
        "gender": gender,
        "gov_id_type": selectedDocument,
        "gov_id_no": documentNumber,
      }),
    );

    Fluttertoast.showToast(msg: "Profile updated successfully");
  }


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    Fluttertoast.showToast(msg: "Logged out successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAdminData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profileImageProvider(),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                adminName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text("Admin ID: $adminId",
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 25),

              // Editable Info Fields
              _buildEditableField(
                icon: Icons.person,
                label: "First Name",
                value: firstName,
                onChanged: (v) => firstName = v,
              ),
              const SizedBox(height: 10),
              _buildEditableField(
                icon: Icons.person_outline,
                label: "Last Name",
                value: lastName,
                onChanged: (v) => lastName = v,
              ),
              const SizedBox(height: 10),
              _buildEditableField(
                icon: Icons.phone_android,
                label: "Mobile Number",
                value: phoneNumber,
                onChanged: (v) => phoneNumber = v,
              ),
              const SizedBox(height: 10),
              _buildEditableField(
                icon: Icons.email,
                label: "Email",
                value: adminEmail,
                onChanged: (v) => adminEmail = v,
              ),
              const SizedBox(height: 10),

              // Gender Selector
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wc, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: gender,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _genderList
                              .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                gender = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Document Type Selector
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedDocument,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _documentTypes
                              .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedDocument = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Document Number Field
              _buildEditableField(
                icon: Icons.confirmation_number,
                label: "$selectedDocument Number",
                value: documentNumber,
                onChanged: (v) => documentNumber = v,
              ),
              const SizedBox(height: 20),


              // Save + Logout Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(140, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Logout"),
                          content: const Text(
                              "Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Logout",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) _logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(140, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    final controller = TextEditingController(text: value);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.blue),
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 20, color: Colors.grey);

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}
