import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MembershipRequestDialog extends StatelessWidget {
  const MembershipRequestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const MembershipDesktop();
          default:
            return const MembershipMobile();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
//  DESKTOP
// ─────────────────────────────────────────────
class MembershipDesktop extends StatefulWidget {
  const MembershipDesktop({super.key});

  @override
  State<MembershipDesktop> createState() => _MembershipDesktopState();
}

class _MembershipDesktopState extends State<MembershipDesktop> {
  final nameController  = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String?    selectedGender  = 'Male';
  String?    selectedState   = 'Select States';
  DateTime?  arrivalDate;
  DateTime?  exitDate;
  bool       isLoading       = false;
  bool       _isImageHovered = false;
  Uint8List? pickedImageBytes;
  String?    pickedImageName;

  final List<String> genders = ['Male', 'Female', 'Children', 'Others'];
  final List<String> states = [
    'Select States',   // ← add this as first item
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() { pickedImageBytes = bytes; pickedImageName = picked.name; });
    }
  }

  Future<void> _pickDate(bool isArrival) async {
    DateTime tempDate = DateTime.now();
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
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
                        setState(() {
                          if (isArrival) arrivalDate = tempDate;
                          else           exitDate    = tempDate;
                        });
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
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select date";
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> _submitRequest() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      String? photoUrl;
      if (pickedImageBytes != null) {
        final fileName =
            'membership/${DateTime.now().millisecondsSinceEpoch}_$pickedImageName';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        final snapshot = await ref.putData(
          pickedImageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoUrl = await snapshot.ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('membership_requests').add({
        'name':        nameController.text.trim(),
        'phone':       phoneController.text.trim(),
        'email':       emailController.text.trim(),
        'gender':      selectedGender,
        'state':       selectedState,
        'arrivalDate': arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        'exitDate':    exitDate    != null ? Timestamp.fromDate(exitDate!)    : null,
        'photoUrl':    photoUrl ?? '',
        'status':      'pending',
        'createdAt':   FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Membership request sent successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send request ❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── Title + Close Button ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Membership Request",
                    style: GoogleFonts.inter(
                        fontSize: 32, fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fill in the details to be a part of BCS. Once approved will be updated in the BCS member list.",
                    style: GoogleFonts.inter(
                        fontSize: 16, color: Colors.black54, height: 1.5),
                  ),
                ],
              ),
            ),
            // ✅ Close Button
            IconButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              icon: const Icon(Icons.close, size: 22, color: Colors.black54),
              tooltip: "Close",
            ),
          ],
        ),

        const SizedBox(height: 22),

        // ── Upload Photo ──
        _label("Upload Photo"),
        const SizedBox(height: 12),
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
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: _isImageHovered
                                ? AllColors.primaryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          image: pickedImageBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(pickedImageBytes!),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: ClipOval(
                          child: pickedImageBytes == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload_outlined,
                                        size: 30, color: Colors.grey.shade500),
                                    const SizedBox(height: 4),
                                    Text("Upload\nPhoto",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.grey.shade600)),
                                  ],
                                )
                              : _isImageHovered
                                  ? Container(
                                      color: Colors.black.withOpacity(0.45),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.edit,
                                              color: Colors.white, size: 26),
                                          const SizedBox(height: 4),
                                          Text("Change",
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                        ),
                      ),
                      Positioned(
                        bottom: 2, left: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 13),
                        ),
                      ),
                      if (pickedImageBytes != null)
                        Positioned(
                          bottom: 2, right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              pickedImageBytes = null;
                              pickedImageName  = null;
                            }),
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 13),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pickedImageBytes != null
                    ? (pickedImageName ?? "Photo selected ✓")
                    : "Tap to choose a profile photo",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: pickedImageBytes != null
                      ? Colors.green : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Name + Gender ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Name", required: true),
                  _textField("Enter Name", controller: nameController),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Gender", required: true),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: _inputDecoration(),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: genders
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedGender = v),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Email ──
        _label("Email", required: true),
        _textField("Enter Email",
            controller: emailController,
            keyboardType: TextInputType.emailAddress),

        const SizedBox(height: 16),

        // ── State + Phone ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("State/ Hometown", required: true),
                  DropdownButtonFormField<String>(
                    value: selectedState,
                    decoration: _inputDecoration(),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: states
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedState = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Contact Number", required: true),
                  _textField("***********",
                      controller: phoneController,
                      keyboardType: TextInputType.phone),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Arrival + Exit Date ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Arrival Date",required: true),
                  _dateBox(arrivalDate, () => _pickDate(true)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Exit Date"),
                  _dateBox(exitDate, () => _pickDate(false)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Buttons ──
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                side: BorderSide(color: AllColors.fifthColor),
              ),
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text("Cancel",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AllColors.fifthColor)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColors.fifthColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              onPressed: isLoading ? null : _submitRequest,
              child: isLoading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text("Send Request",
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────

  Widget _label(String text, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: text,
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      );

  Widget _textField(String hint,
          {TextEditingController? controller,
          TextInputType keyboardType = TextInputType.text}) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(hint: hint),
      );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: AllColors.primaryColor, width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      );

  Widget _dateBox(DateTime? date, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4)),
          child: Row(
            children: [
              Text(_formatDate(date),
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: date == null
                          ? Colors.grey.shade500
                          : Colors.black87)),
              const Spacer(),
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey.shade500),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
//  MOBILE
// ─────────────────────────────────────────────
class MembershipMobile extends StatefulWidget {
  const MembershipMobile({super.key});

  @override
  State<MembershipMobile> createState() => _MembershipMobileState();
}

class _MembershipMobileState extends State<MembershipMobile> {
  final nameController  = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String?    selectedGender  = 'Male';
  String?    selectedState   = 'Select States';
  DateTime?  arrivalDate;
  DateTime?  exitDate;
  bool       isLoading       = false;
  Uint8List? pickedImageBytes;
  String?    pickedImageName;

  final List<String> genders = ['Male', 'Female', 'Children', 'Others'];
  final List<String> states = [
      'Select States',   // ← add this as first item
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _closeSheet() {
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        pickedImageBytes = bytes;
        pickedImageName  = picked.name;
      });
    }
  }

  Future<void> _pickDate(bool isArrival) async {
    DateTime tempDate = DateTime.now();
    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 320, height: 420,
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
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text("Cancel", style: GoogleFonts.inter()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (isArrival) arrivalDate = tempDate;
                          else           exitDate    = tempDate;
                        });
                        Navigator.pop(dialogContext);
                      },
                      child: Text("OK", style: GoogleFonts.inter()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select date";
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> _submitRequest() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      String? photoUrl;
      if (pickedImageBytes != null) {
        final fileName =
            'membership/${DateTime.now().millisecondsSinceEpoch}_$pickedImageName';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        final snapshot = await ref.putData(
          pickedImageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoUrl = await snapshot.ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('membership_requests').add({
        'name':        nameController.text.trim(),
        'phone':       phoneController.text.trim(),
        'email':       emailController.text.trim(),
        'gender':      selectedGender,
        'state':       selectedState,
        'arrivalDate': arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        'exitDate':    exitDate    != null ? Timestamp.fromDate(exitDate!)    : null,
        'photoUrl':    photoUrl ?? '',
        'status':      'pending',
        'createdAt':   FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _closeSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Membership request sent successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send request ❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth,
          height: screenHeight * 0.92,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [

              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── Title + Close Button ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Membership Request",
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fill in the details to be a part of BCS. Once approved will be updated in the BCS member list.",
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.black, height: 1.5),
                  ),
                ],
              ),
            ),
            // ✅ Close Button in title row
            IconButton(
              onPressed: _closeSheet,
              icon: const Icon(Icons.close, size: 20, color: Colors.black54),
              tooltip: "Close",
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ── Upload Photo ──
        _label("Upload Photo"),
        const SizedBox(height: 10),
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
                        color: Colors.grey.shade200,
                        border: Border.all(
                            color: Colors.grey.shade300, width: 2),
                        image: pickedImageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(pickedImageBytes!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: pickedImageBytes == null
                          ? ClipOval(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined,
                                      size: 24, color: Colors.grey.shade500),
                                  const SizedBox(height: 4),
                                  Text("Upload\nPhoto",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.grey.shade600)),
                                ],
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0, left: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 10),
                      ),
                    ),
                    if (pickedImageBytes != null)
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            pickedImageBytes = null;
                            pickedImageName  = null;
                          }),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pickedImageBytes != null
                    ? (pickedImageName ?? "Photo selected ✓")
                    : "Tap to choose a profile photo",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: pickedImageBytes != null
                      ? Colors.green : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Name + Gender ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Name", required: true),
                  _textField("Enter Name", controller: nameController),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Gender", required: true),
                  _dropdownField<String>(
                    value: selectedGender,
                    items: genders,
                    onChanged: (v) => setState(() => selectedGender = v),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Email ──
        _label("Email", required: true),
        _textField("Enter Email",
            controller: emailController,
            keyboardType: TextInputType.emailAddress),

        const SizedBox(height: 12),

        // ── State / Hometown ──
        _label("State / Hometown", required: true),
        _dropdownField<String>(
          value: selectedState,
          items: states,
          onChanged: (v) => setState(() => selectedState = v),
        ),

        const SizedBox(height: 12),

        // ── Contact Number ──
        _label("Contact Number", required: true),
        _textField("***********",
            controller: phoneController,
            keyboardType: TextInputType.phone),

        const SizedBox(height: 12),

        // ── Arrival + Exit Date ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Arrival Date"),
                  _dateBox(arrivalDate, () => _pickDate(true)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Exit Date"),
                  _dateBox(exitDate, () => _pickDate(false)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Buttons ──
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  side: BorderSide(color: AllColors.fifthColor),
                ),
                onPressed: isLoading ? null : _closeSheet,
                child: Text("Cancel",
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AllColors.fifthColor)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColors.fifthColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                onPressed: isLoading ? null : _submitRequest,
                child: isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text("Send Request",
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────

  Widget _label(String text, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: text,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      );

  Widget _textField(String hint,
          {TextEditingController? controller,
          TextInputType keyboardType = TextInputType.text}) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 13),
        decoration: _inputDecoration(hint: hint),
      );

  Widget _dropdownField<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: _inputDecoration(),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
        items: items
            .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString(),
                    overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
      );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: AllColors.primaryColor, width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  Widget _dateBox(DateTime? date, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(date),
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: date == null
                          ? Colors.grey.shade500 : Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey.shade500),
            ],
          ),
        ),
      );
}
