import 'package:flutter/material.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:typed_data';

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class AddStudentMemberPage extends StatelessWidget {
  const AddStudentMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const _DesktopLayout();
          default:
            return const _MobileLayout();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
//  DESKTOP LAYOUT (original — unchanged)
// ─────────────────────────────────────────────
class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout();

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  final nameController        = TextEditingController();
  final phoneController       = TextEditingController();
  final emailController       = TextEditingController();
  final collageController     = TextEditingController();
  final courseController      = TextEditingController();
  final descriptionController = TextEditingController();

  bool      _isLoading       = false;
  String?   selectedGender;
  String?   selectedState;
  DateTime? arrivalDate;
  DateTime? exitDate;

  Uint8List? _selectedImageBytes;
  String?    _selectedImageName;
  bool       _isImageHovered = false;

  final List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName  = picked.name;
      });
    }
  }

  Future<String?> _uploadImageToStorage() async {
    if (_selectedImageBytes == null) return null;
    try {
      final fileName =
          'students/${DateTime.now().millisecondsSinceEpoch}_$_selectedImageName';
      final ref      = FirebaseStorage.instance.ref().child(fileName);
      final snapshot = await ref.putData(
        _selectedImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  Future<void> addStudent() async {
    setState(() => _isLoading = true);
    try {
      final String? photoUrl = await _uploadImageToStorage();
      await FirebaseFirestore.instance.collection('Student_collection').add({
        'name':        nameController.text.trim(),
        'phone':       phoneController.text.trim(),
        'email':       emailController.text.trim(),
        'collage':     collageController.text.trim(),
        'course':      courseController.text.trim(),
        'gender':      selectedGender,
        'state':       selectedState,
        'arrivalDate': arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        'exitDate':    exitDate    != null ? Timestamp.fromDate(exitDate!)    : null,
        'description': descriptionController.text.trim(),
        'photoUrl':    photoUrl ?? '',
        'createdAt':   FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Add New Student",
                    style: GoogleFonts.inter(
                        fontSize: 40, fontWeight: FontWeight.w800),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 36, width: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              "Fill in the details to add a new student member.",
              style: GoogleFonts.inter(fontSize: 16, color: AllColors.thirdColor),
            ),
            const SizedBox(height: 20),

            // ── Scrollable body ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Upload Photo"),
                    Center(
                      child: Column(
                        children: [
                          MouseRegion(
                            onEnter: (_) => setState(() => _isImageHovered = true),
                            onExit:  (_) => setState(() => _isImageHovered = false),
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 110, height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                      border: Border.all(
                                        color: _isImageHovered
                                            ? AllColors.primaryColor
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      image: _selectedImageBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(_selectedImageBytes!),
                                              fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: ClipOval(
                                      child: _selectedImageBytes == null
                                          ? Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.cloud_upload_outlined,
                                                    size: 30, color: Colors.grey[500]),
                                                const SizedBox(height: 4),
                                                Text("Upload\nPhoto",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        fontSize: 11,
                                                        color: Colors.grey[600])),
                                              ],
                                            )
                                          : _isImageHovered
                                              ? Container(
                                                  color: Colors.black.withOpacity(0.45),
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.edit,
                                                          color: Colors.white, size: 26),
                                                      const SizedBox(height: 4),
                                                      Text("Change",
                                                          style: GoogleFonts.inter(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600)),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                    ),
                                  ),
                                  if (_selectedImageBytes != null)
                                    Positioned(
                                      bottom: 2, right: 2,
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _selectedImageBytes = null;
                                          _selectedImageName  = null;
                                        }),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.red, shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 2, left: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AllColors.primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.white, size: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedImageBytes != null
                                ? (_selectedImageName ?? "Photo selected ✓")
                                : "Tap to choose a profile photo",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _selectedImageBytes != null
                                  ? Colors.green : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _label("Name"),
                    TextField(controller: nameController, decoration: _inputDecoration(hint: "Enter Name")),
                    const SizedBox(height: 20),

                    _label("Phone Number"),
                    TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration(hint: "Enter Phone number")),
                    const SizedBox(height: 20),

                    _label("Email"),
                    TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration(hint: "Enter Email")),
                    const SizedBox(height: 20),

                    _label("College Name"),
                    TextField(controller: collageController, decoration: _inputDecoration(hint: "Enter College Name")),
                    const SizedBox(height: 20),

                    _label("Degree Name"),
                    TextField(controller: courseController, decoration: _inputDecoration(hint: "Enter Degree Name")),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Gender"),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                decoration: _inputDecoration().copyWith(filled: true),
                                hint: const Text("Select Gender"),
                                items: const [
                                  DropdownMenuItem(value: "Male",     child: Text("Male")),
                                  DropdownMenuItem(value: "Female",   child: Text("Female")),
                                  DropdownMenuItem(value: "Children", child: Text("Children")),
                                  DropdownMenuItem(value: "Others",   child: Text("Others")),
                                ],
                                onChanged: (value) => setState(() => selectedGender = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("State / Hometown"),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                decoration: _inputDecoration().copyWith(filled: true),
                                hint: const Text("Select State"),
                                items: states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (value) => setState(() => selectedState = value),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Arrival Date"),
                              _dateBox(arrivalDate, () => _openCalendar(
                                  context, arrivalDate, (d) => setState(() => arrivalDate = d))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Exit Date"),
                              _dateBox(exitDate, () => _openCalendar(
                                  context, exitDate, (d) => setState(() => exitDate = d))),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _label("Description"),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration(hint: "Enter a brief description"),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            side: const BorderSide(color: AllColors.primaryColor),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: GoogleFonts.inter(color: AllColors.primaryColor)),
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          label: "Add Student",
                          height: 48,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : addStudent,
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
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
      );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      );

  Widget _dateBox(DateTime? date, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          alignment: Alignment.centerLeft,
          child: Text(
            date == null
                ? "Select date"
                : "${date.day.toString().padLeft(2, '0')}-"
                    "${date.month.toString().padLeft(2, '0')}-"
                    "${date.year}",
          ),
        ),
      );

  void _openCalendar(
      BuildContext context, DateTime? initialDate, Function(DateTime) onSelected) {
    showDialog(
      context: context,
      builder: (_) {
        DateTime tempDate = initialDate ?? DateTime.now();
        return Dialog(
          backgroundColor: AllColors.secondaryColor,
          child: SizedBox(
            width: 350, height: 420,
            child: Column(
              children: [
                Expanded(
                  child: CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (d) => tempDate = d,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: GoogleFonts.inter()),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          onSelected(tempDate);
                          Navigator.pop(context);
                        },
                        child: Text("OK", style: GoogleFonts.inter()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────
class _MobileLayout extends StatefulWidget {
  const _MobileLayout();

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  final nameController        = TextEditingController();
  final phoneController       = TextEditingController();
  final emailController       = TextEditingController();
  final collageController     = TextEditingController();
  final courseController      = TextEditingController();
  final descriptionController = TextEditingController();

  bool      _isLoading   = false;
  String?   selectedGender;
  String?   selectedState;
  DateTime? arrivalDate;
  DateTime? exitDate;

  Uint8List? _selectedImageBytes;
  String?    _selectedImageName;

  final List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName  = picked.name;
      });
    }
  }

  Future<String?> _uploadImageToStorage() async {
    if (_selectedImageBytes == null) return null;
    try {
      final fileName =
          'students/${DateTime.now().millisecondsSinceEpoch}_$_selectedImageName';
      final ref      = FirebaseStorage.instance.ref().child(fileName);
      final snapshot = await ref.putData(
        _selectedImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  Future<void> addStudent() async {
    setState(() => _isLoading = true);
    try {
      final String? photoUrl = await _uploadImageToStorage();
      await FirebaseFirestore.instance.collection('Student_collection').add({
        'name':        nameController.text.trim(),
        'phone':       phoneController.text.trim(),
        'email':       emailController.text.trim(),
        'collage':     collageController.text.trim(),
        'course':      courseController.text.trim(),
        'gender':      selectedGender,
        'state':       selectedState,
        'arrivalDate': arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        'exitDate':    exitDate    != null ? Timestamp.fromDate(exitDate!)    : null,
        'description': descriptionController.text.trim(),
        'photoUrl':    photoUrl ?? '',
        'createdAt':   FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),  // tighter on mobile
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Add New Student",
                      style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.w800),      // smaller on mobile
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 32, width: 32,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: Colors.black87),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                "Fill in the details to add a new student member.",
                style: GoogleFonts.inter(fontSize: 13, color: AllColors.thirdColor),
              ),
              const SizedBox(height: 16),

              // ── Scrollable body ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Upload Photo"),
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 90, height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                      border: Border.all(color: Colors.grey.shade300, width: 2),
                                      image: _selectedImageBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(_selectedImageBytes!),
                                              fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: _selectedImageBytes == null
                                        ? ClipOval(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.cloud_upload_outlined,
                                                    size: 24, color: Colors.grey[500]),
                                                const SizedBox(height: 4),
                                                Text("Upload\nPhoto",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        fontSize: 10, color: Colors.grey[600])),
                                              ],
                                            ),
                                          )
                                        : null,
                                  ),
                                  if (_selectedImageBytes != null)
                                    Positioned(
                                      bottom: 0, right: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _selectedImageBytes = null;
                                          _selectedImageName  = null;
                                        }),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.red, shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(3),
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0, left: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AllColors.primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.white, size: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedImageBytes != null
                                  ? (_selectedImageName ?? "Photo selected ✓")
                                  : "Tap to choose a profile photo",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: _selectedImageBytes != null
                                    ? Colors.green : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _label("Name"),
                      TextField(controller: nameController, decoration: _inputDecoration(hint: "Enter Name")),
                      const SizedBox(height: 14),

                      _label("Phone Number"),
                      TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration(hint: "Enter Phone number")),
                      const SizedBox(height: 14),

                      _label("Email"),
                      TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration(hint: "Enter Email")),
                      const SizedBox(height: 14),

                      _label("College Name"),
                      TextField(controller: collageController, decoration: _inputDecoration(hint: "Enter College Name")),
                      const SizedBox(height: 14),

                      _label("Degree Name"),
                      TextField(controller: courseController, decoration: _inputDecoration(hint: "Enter Degree Name")),
                      const SizedBox(height: 14),

                      _label("Gender"),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        decoration: _inputDecoration().copyWith(filled: true),
                        hint: const Text("Select Gender"),
                        items: const [
                          DropdownMenuItem(value: "Male",     child: Text("Male")),
                          DropdownMenuItem(value: "Female",   child: Text("Female")),
                          DropdownMenuItem(value: "Children", child: Text("Children")),
                          DropdownMenuItem(value: "Others",   child: Text("Others")),
                        ],
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                      const SizedBox(height: 14),

                      _label("State / Hometown"),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        decoration: _inputDecoration().copyWith(filled: true),
                        hint: const Text("Select State"),
                        items: states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (value) => setState(() => selectedState = value),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Arrival Date"),
                                _dateBox(arrivalDate, () => _openCalendar(
                                    context, arrivalDate, (d) => setState(() => arrivalDate = d))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Exit Date"),
                                _dateBox(exitDate, () => _openCalendar(
                                    context, exitDate, (d) => setState(() => exitDate = d))),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _label("Description"),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: _inputDecoration(hint: "Enter a brief description"),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                side: const BorderSide(color: AllColors.primaryColor),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel",
                                  style: GoogleFonts.inter(color: AllColors.primaryColor)),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: CustomButton(
                              label: "Add Student",
                              height: 44,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : addStudent,
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
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      );

  Widget _dateBox(DateTime? date, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          alignment: Alignment.centerLeft,
          child: Text(
            date == null
                ? "Select date"
                : "${date.day.toString().padLeft(2, '0')}-"
                    "${date.month.toString().padLeft(2, '0')}-"
                    "${date.year}",
            style: GoogleFonts.inter(fontSize: 13),
          ),
        ),
      );

  void _openCalendar(
      BuildContext context, DateTime? initialDate, Function(DateTime) onSelected) {
    showDialog(
      context: context,
      builder: (_) {
        DateTime tempDate = initialDate ?? DateTime.now();
        return Dialog(
          backgroundColor: AllColors.secondaryColor,
          child: SizedBox(
            width: 320, height: 400,
            child: Column(
              children: [
                Expanded(
                  child: CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (d) => tempDate = d,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: GoogleFonts.inter()),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          onSelected(tempDate);
                          Navigator.pop(context);
                        },
                        child: Text("OK", style: GoogleFonts.inter()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
