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
//  HELPER — call this instead of showDialog
// ─────────────────────────────────────────────
void showAddStudentPage(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1024) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddStudentMemberPage(),
    );
  } else {
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const _MobileLayout(),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE DATA
// ─────────────────────────────────────────────
const List<String> _kStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
  'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
  'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
  'West Bengal',
];

// ─────────────────────────────────────────────
//  DESKTOP LAYOUT
// ─────────────────────────────────────────────
class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout();

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  final _nameCtrl        = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _collageCtrl     = TextEditingController();
  final _courseCtrl      = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  bool       _isLoading       = false;
  bool       _isImageHovered  = false;
  String?    _selectedGender;
  String?    _selectedState;
  DateTime?  _arrivalDate;
  DateTime?  _exitDate;
  Uint8List? _imageBytes;
  String?    _imageName;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _collageCtrl.dispose();
    _courseCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName  = picked.name;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;
    try {
      final fileName =
          'students/${DateTime.now().millisecondsSinceEpoch}_$_imageName';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final snapshot = await ref.putData(
        _imageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  Future<void> _addStudent() async {
    setState(() => _isLoading = true);
    try {
      final photoUrl = await _uploadImage();
      await FirebaseFirestore.instance
          .collection('Student_collection')
          .add({
        'name':        _nameCtrl.text.trim(),
        'phone':       _phoneCtrl.text.trim(),
        'email':       _emailCtrl.text.trim(),
        'collage':     _collageCtrl.text.trim(),
        'course':      _courseCtrl.text.trim(),
        'gender':      _selectedGender,
        'state':       _selectedState,
        'arrivalDate': _arrivalDate != null
            ? Timestamp.fromDate(_arrivalDate!)
            : null,
        'exitDate':    _exitDate != null
            ? Timestamp.fromDate(_exitDate!)
            : null,
        'description': _descriptionCtrl.text.trim(),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: SizedBox(
        width: 700,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
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
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 20, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Fill in the details to add a new student member.",
                style: GoogleFonts.inter(
                    fontSize: 16, color: AllColors.thirdColor),
              ),
              const SizedBox(height: 20),

              // ── Scrollable form ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Photo ──
                      _desktopLabel("Upload Photo"),
                      Center(
                        child: Column(
                          children: [
                            MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _isImageHovered = true),
                              onExit: (_) =>
                                  setState(() => _isImageHovered = false),
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[200],
                                        border: Border.all(
                                          color: _isImageHovered
                                              ? AllColors.primaryColor
                                              : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        image: _imageBytes != null
                                            ? DecorationImage(
                                                image:
                                                    MemoryImage(_imageBytes!),
                                                fit: BoxFit.cover)
                                            : null,
                                      ),
                                      child: ClipOval(
                                        child: _imageBytes == null
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .cloud_upload_outlined,
                                                      size: 30,
                                                      color: Colors.grey[500]),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Upload\nPhoto",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                        fontSize: 11,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              )
                                            : _isImageHovered
                                                ? Container(
                                                    color: Colors.black
                                                        .withOpacity(0.45),
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(Icons.edit,
                                                            color: Colors.white,
                                                            size: 26),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          "Change",
                                                          style: GoogleFonts
                                                              .inter(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                      ),
                                    ),
                                    // Camera badge
                                    Positioned(
                                      bottom: 2,
                                      left: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AllColors.primaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white, size: 13),
                                      ),
                                    ),
                                    // Remove badge
                                    if (_imageBytes != null)
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            _imageBytes = null;
                                            _imageName  = null;
                                          }),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.close,
                                                color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _imageBytes != null
                                  ? (_imageName ?? "Photo selected ✓")
                                  : "Tap to choose a profile photo",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _imageBytes != null
                                    ? Colors.green
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Text fields ──
                      _desktopLabel("Name"),
                      _desktopField(_nameCtrl, "Enter Name"),
                      const SizedBox(height: 20),

                      _desktopLabel("Phone Number"),
                      _desktopField(_phoneCtrl, "Enter Phone number",
                          type: TextInputType.phone),
                      const SizedBox(height: 20),

                      _desktopLabel("Email"),
                      _desktopField(_emailCtrl, "Enter Email",
                          type: TextInputType.emailAddress),
                      const SizedBox(height: 20),

                      _desktopLabel("College Name"),
                      _desktopField(_collageCtrl, "Enter College Name"),
                      const SizedBox(height: 20),

                      _desktopLabel("Degree Name"),
                      _desktopField(_courseCtrl, "Enter Degree Name"),
                      const SizedBox(height: 20),

                      // ── Gender + State ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _desktopLabel("Gender"),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  decoration: _decoration()
                                      .copyWith(filled: true),
                                  hint: const Text("Select Gender"),
                                  items: const [
                                    DropdownMenuItem(
                                        value: "Male", child: Text("Male")),
                                    DropdownMenuItem(
                                        value: "Female",
                                        child: Text("Female")),
                                    DropdownMenuItem(
                                        value: "Children",
                                        child: Text("Children")),
                                    DropdownMenuItem(
                                        value: "Others",
                                        child: Text("Others")),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _selectedGender = v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _desktopLabel("State / Hometown"),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  decoration: _decoration()
                                      .copyWith(filled: true),
                                  hint: const Text("Select State"),
                                  items: _kStates
                                      .map((s) => DropdownMenuItem(
                                          value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedState = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Arrival + Exit Date ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _desktopLabel("Arrival Date"),
                                _dateBox(
                                  _arrivalDate,
                                  () => _openCalendar(
                                    context,
                                    _arrivalDate,
                                    (d) => setState(() => _arrivalDate = d),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _desktopLabel("Exit Date"),
                                _dateBox(
                                  _exitDate,
                                  () => _openCalendar(
                                    context,
                                    _exitDate,
                                    (d) => setState(() => _exitDate = d),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Description ──
                      _desktopLabel("Description"),
                      TextField(
                        controller: _descriptionCtrl,
                        maxLines: 4,
                        decoration:
                            _decoration(hint: "Enter a brief description"),
                      ),

                      const SizedBox(height: 32),

                      // ── Action buttons ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              side: const BorderSide(
                                  color: AllColors.primaryColor),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: GoogleFonts.inter(
                                    color: AllColors.primaryColor)),
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            label: "Add Student",
                            height: 48,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _addStudent,
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

  // ── Desktop helpers ──
  Widget _desktopLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w600)),
      );

  Widget _desktopField(
    TextEditingController controller,
    String hint, {
    TextInputType type = TextInputType.text,
  }) =>
      TextField(
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        controller: controller,
        keyboardType: type,
        decoration: _decoration(hint: hint),
      );

  InputDecoration _decoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 16),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
      );

  Widget _dateBox(DateTime? date, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4)),
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
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        DateTime tempDate = initialDate ?? DateTime.now();
        return Dialog(
          backgroundColor: AllColors.secondaryColor,
          child: SizedBox(
            width: 350,
            height: 420,
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
                        child:
                            Text("Cancel", style: GoogleFonts.inter()),
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
  final _nameCtrl        = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _collageCtrl     = TextEditingController();
  final _courseCtrl      = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  bool       _isLoading  = false;
  String?    _selectedGender;
  String?    _selectedState;
  DateTime?  _arrivalDate;
  DateTime?  _exitDate;
  Uint8List? _imageBytes;
  String?    _imageName;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _collageCtrl.dispose();
    _courseCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName  = picked.name;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;
    try {
      final fileName =
          'students/${DateTime.now().millisecondsSinceEpoch}_$_imageName';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final snapshot = await ref.putData(
        _imageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Image upload error: $e");
      return null;
    }
  }

  Future<void> _addStudent() async {
    setState(() => _isLoading = true);
    try {
      final photoUrl = await _uploadImage();
      await FirebaseFirestore.instance
          .collection('Student_collection')
          .add({
        'name':        _nameCtrl.text.trim(),
        'phone':       _phoneCtrl.text.trim(),
        'email':       _emailCtrl.text.trim(),
        'collage':     _collageCtrl.text.trim(),
        'course':      _courseCtrl.text.trim(),
        'gender':      _selectedGender,
        'state':       _selectedState,
        'arrivalDate': _arrivalDate != null
            ? Timestamp.fromDate(_arrivalDate!)
            : null,
        'exitDate':    _exitDate != null
            ? Timestamp.fromDate(_exitDate!)
            : null,
        'description': _descriptionCtrl.text.trim(),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add New Student",
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Fill in the details to add a new student member.",
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AllColors.thirdColor),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _isLoading ? null : () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Scrollable form ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Photo ──
                    _mobileLabel("Upload Photo"),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 2),
                                    image: _imageBytes != null
                                        ? DecorationImage(
                                            image:
                                                MemoryImage(_imageBytes!),
                                            fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: _imageBytes == null
                                      ? ClipOval(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .cloud_upload_outlined,
                                                  size: 24,
                                                  color: Colors.grey[500]),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Upload\nPhoto",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    color:
                                                        Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                                // Camera badge
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AllColors.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 11),
                                  ),
                                ),
                                // Remove badge
                                if (_imageBytes != null)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _imageBytes = null;
                                        _imageName  = null;
                                      }),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        padding:
                                            const EdgeInsets.all(3),
                                        child: const Icon(Icons.close,
                                            color: Colors.white,
                                            size: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _imageBytes != null
                                ? (_imageName ?? "Photo selected ✓")
                                : "Tap to choose a profile photo",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _imageBytes != null
                                  ? Colors.green
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Text fields ──
                    _mobileLabel("Name"),
                    _mobileField(_nameCtrl, "Enter Name"),
                    const SizedBox(height: 14),

                    _mobileLabel("Phone Number"),
                    _mobileField(_phoneCtrl, "Enter Phone number",
                        type: TextInputType.phone),
                    const SizedBox(height: 14),

                    _mobileLabel("Email"),
                    _mobileField(_emailCtrl, "Enter Email",
                        type: TextInputType.emailAddress),
                    const SizedBox(height: 14),

                    _mobileLabel("College Name"),
                    _mobileField(_collageCtrl, "Enter College Name"),
                    const SizedBox(height: 14),

                    _mobileLabel("Degree Name"),
                    _mobileField(_courseCtrl, "Enter Degree Name"),
                    const SizedBox(height: 14),

                    // ── Gender ──
                    _mobileLabel("Gender"),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      decoration: _mobileDecoration().copyWith(filled: true),
                      hint: const Text("Select Gender"),
                      items: const [
                        DropdownMenuItem(
                            value: "Male", child: Text("Male")),
                        DropdownMenuItem(
                            value: "Female", child: Text("Female")),
                        DropdownMenuItem(
                            value: "Children", child: Text("Children")),
                        DropdownMenuItem(
                            value: "Others", child: Text("Others")),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedGender = v),
                    ),
                    const SizedBox(height: 14),

                    // ── State ──
                    _mobileLabel("State / Hometown"),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      decoration: _mobileDecoration().copyWith(filled: true),
                      hint: const Text("Select State"),
                      items: _kStates
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedState = v),
                    ),
                    const SizedBox(height: 14),

                    // ── Arrival + Exit Date ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _mobileLabel("Arrival Date"),
                              _mobileDateBox(
                                _arrivalDate,
                                () => _openCalendar(
                                  context,
                                  _arrivalDate,
                                  (d) =>
                                      setState(() => _arrivalDate = d),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _mobileLabel("Exit Date"),
                              _mobileDateBox(
                                _exitDate,
                                () => _openCalendar(
                                  context,
                                  _exitDate,
                                  (d) => setState(() => _exitDate = d),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Description ──
                    _mobileLabel("Description"),
                    TextField(
                      controller: _descriptionCtrl,
                      maxLines: 3,
                      decoration: _mobileDecoration(
                          hint: "Enter a brief description"),
                    ),

                    const SizedBox(height: 24),

                    // ── Action buttons ──
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              side: const BorderSide(
                                  color: AllColors.primaryColor),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  // height: 3.5,
                                    color: AllColors.primaryColor)),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: CustomButton(
                            label: "Add Student",
                            height: 48,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _addStudent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile helpers ──
  Widget _mobileLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _mobileField(
    TextEditingController controller,
    String hint, {
    TextInputType type = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: type,
        decoration: _mobileDecoration(hint: hint),
      );

  InputDecoration _mobileDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
      );

  Widget _mobileDateBox(DateTime? date, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4)),
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
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        DateTime tempDate = initialDate ?? DateTime.now();
        return Dialog(
          backgroundColor: AllColors.secondaryColor,
          child: SizedBox(
            width: 320,
            height: 400,
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
                        child:
                            Text("Cancel", style: GoogleFonts.inter()),
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
