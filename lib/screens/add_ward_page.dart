import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddWardPage extends StatefulWidget {
  AddWardPage({super.key});

  @override
  State<AddWardPage> createState() => _AddWardPageState();
}

class _AddWardPageState extends State<AddWardPage> {
  late FocusNode _wardNumberFocus;
  late FocusNode _wardNameFocus;
  late FocusNode _descriptionFocus;

  final RxMap<String, bool> fieldErrors = {
    'election': false,
    'wardNumber': false,
    'wardName': false,
    'description': false,
  }.obs;

  late RxBool isSubmitting = RxBool(false);

  final TextEditingController wardNumberController = TextEditingController();
  final TextEditingController wardNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final RxString selectedElection = 'Select Election'.obs;

  final List<String> elections = [
    'Select Election',
    'Municipal Election 2025',
    'Assembly Election 2024',
    'Lok Sabha Election 2024',
  ];

  @override
  void initState() {
    super.initState();
    _wardNumberFocus = FocusNode();
    _wardNameFocus = FocusNode();
    _descriptionFocus = FocusNode();
  }

  @override
  void dispose() {
    _wardNumberFocus.dispose();
    _wardNameFocus.dispose();
    _descriptionFocus.dispose();
    wardNumberController.dispose();
    wardNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  int _calculateProgress() {
    int completed = 0;

    if (selectedElection.value != 'Select Election') completed++;
    if (wardNumberController.text.isNotEmpty) completed++;
    if (wardNameController.text.isNotEmpty) completed++;
    if (descriptionController.text.isNotEmpty) completed++;

    return ((completed / 4) * 100).toInt();
  }

  bool _validateWardNumber() {
    final isEmpty = wardNumberController.text.isEmpty;
    fieldErrors['wardNumber'] = isEmpty;
    return !isEmpty;
  }

  bool _validateWardName() {
    final isEmpty = wardNameController.text.isEmpty;
    fieldErrors['wardName'] = isEmpty;
    return !isEmpty;
  }

  bool _validateForm() {
    fieldErrors['election'] = selectedElection.value == 'Select Election';
    fieldErrors['wardNumber'] = wardNumberController.text.isEmpty;
    fieldErrors['wardName'] = wardNameController.text.isEmpty;
    fieldErrors['description'] = descriptionController.text.isEmpty;

    return !fieldErrors.values.contains(true);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 70,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Ward Added Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Your electoral ward has been successfully\nregistered for the election process.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
    int progress = _calculateProgress();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Form Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progress < 50
                      ? Colors.orange.withOpacity(0.15)
                      : progress < 100
                      ? Colors.blue.withOpacity(0.15)
                      : Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: progress < 50
                        ? Colors.orange.withOpacity(0.3)
                        : progress < 100
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$progress%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: progress < 50
                        ? Colors.orange[700]
                        : progress < 100
                        ? Colors.blue[700]
                        : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _calculateProgress() / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _calculateProgress() < 50
                      ? Colors.orange
                      : _calculateProgress() < 100
                      ? Colors.blue
                      : Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String fieldKey,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              boxShadow: focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              maxLines: maxLines,
              onChanged: (value) {
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFB4BFCD),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: controller.text.isNotEmpty
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: fieldErrors[fieldKey] == true
                            ? Colors.red
                            : Colors.green,
                        size: 22,
                      )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey[200] ?? Colors.grey,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: fieldErrors[fieldKey] == true
                        ? Colors.red.withOpacity(0.4)
                        : Colors.grey[200] ?? Colors.grey,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.red.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(
                  14, // left
                  14, // top
                  44, // right ← space for tick
                  14, // bottom
                ),
              ),
            ),
          ),
          if (fieldErrors[fieldKey] == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.error_rounded, size: 16, color: Colors.red[400]),
                  const SizedBox(width: 6),
                  Text(
                    'This field is required',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required RxString selectedValue,
    required List<String> options,
    required String fieldKey,
  }) {
    return Obx(() {
      // ✅ SAFETY: Ensure selected value always exists in options
      final String dropdownValue = options.contains(selectedValue.value)
          ? selectedValue.value
          : options.first;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: fieldErrors[fieldKey] == true
                    ? Colors.red.withOpacity(0.4)
                    : Colors.grey[200] ?? Colors.grey,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: dropdownValue,
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null && newValue != options.first) {
                  selectedValue.value = newValue;
                  setState(() {});
                }
              },
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              icon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          if (fieldErrors[fieldKey] == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.error_rounded, size: 16, color: Colors.red[400]),
                  const SizedBox(width: 6),
                  Text(
                    'Please select an option',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          'Add Electoral Ward',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.blue.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _buildProgressTracker(),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.blue.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildDropdownField(
                    label: 'Select Election',
                    selectedValue: selectedElection,
                    options: elections,
                    fieldKey: 'election',
                  ),
                  const SizedBox(height: 16),

                  _buildTextInputField(
                    label: 'Ward Number',
                    hint: 'Enter ward number (e.g., W-001)',
                    controller: wardNumberController,
                    focusNode: _wardNumberFocus,
                    fieldKey: 'wardNumber',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 18),
                  _buildTextInputField(
                    label: 'Ward Name',
                    hint: 'Enter ward name',
                    controller: wardNameController,
                    focusNode: _wardNameFocus,
                    fieldKey: 'wardName',
                  ),
                  const SizedBox(height: 16),

                  _buildTextInputField(
                    label: 'Description',
                    hint: 'Enter ward description',
                    controller: descriptionController,
                    focusNode: _descriptionFocus,
                    fieldKey: 'description',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting.value
                      ? null
                      : () async {
                          if (_validateForm()) {
                            isSubmitting.value = true;
                            await Future.delayed(const Duration(seconds: 2));
                            isSubmitting.value = false;
                            _showSuccessDialog();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.error_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Please fill all required fields',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.red[500],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue.shade200,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: isSubmitting.value
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.9),
                            ),
                          ),
                        )
                      : const Text(
                          'Add Ward',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
