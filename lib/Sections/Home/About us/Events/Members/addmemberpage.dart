import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:typed_data';

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class AddMemberPage extends StatelessWidget {
  const AddMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const _AddMemberDesktop();
          default:
            return const _AddMemberMobile();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED FORM STATE MIXIN
// ─────────────────────────────────────────────
mixin _AddMemberFormMixin<T extends StatefulWidget> on State<T> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedGender;
  String? selectedState;
  DateTime? arrivalDate;
  DateTime? exitDate;

  Uint8List? imageBytes;
  String? imageName;
  bool isHovered = false;
  bool isSaving = false;

  final List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  Future<void> pickImage() async {
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
        imageBytes = bytes;
        imageName = picked.name;
      });
    }
  }

  Future<void> submitForm(BuildContext context) async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a member name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      String? photoUrl;
      if (imageBytes != null) {
        final fileName =
            'members/${DateTime.now().millisecondsSinceEpoch}_$imageName';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        final snapshot = await ref.putData(
          imageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoUrl = await snapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('Member_collection').add({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "state": selectedState ?? '',
        "gender": selectedGender ?? '',
        "arrivalDate":
            arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        "exitDate": exitDate != null ? Timestamp.fromDate(exitDate!) : null,
        "description": descriptionController.text.trim(),
        "photoUrl": photoUrl ?? '',
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member added successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add member ❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void openCalendar(
    BuildContext context,
    DateTime? initial,
    void Function(DateTime) onPicked,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        DateTime temp = initial ?? DateTime.now();
        return Dialog(
          backgroundColor: AllColors.secondaryColor,
          child: SizedBox(
            width: 350,
            height: 420,
            child: Column(
              children: [
                Expanded(
                  child: CalendarDatePicker(
                    initialDate: temp,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (d) => temp = d,
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
                          onPicked(temp);
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

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  DESKTOP LAYOUT
// ─────────────────────────────────────────────
class _AddMemberDesktop extends StatefulWidget {
  const _AddMemberDesktop();

  @override
  State<_AddMemberDesktop> createState() => _AddMemberDesktopState();
}

class _AddMemberDesktopState extends State<_AddMemberDesktop>
    with _AddMemberFormMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: Column(
        children: [
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 28, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Member",
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Fill in the details to add a new member.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AllColors.thirdColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // ── Scrollable form ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Upload Photo ──
                      _sectionLabel("Upload Photo"),
                      Center(
                        child: MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          child: GestureDetector(
                            onTap: isSaving ? null : pickImage,
                            child: _photoWidget(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          imageBytes != null
                              ? "${imageName ?? 'Photo selected'} ✓"
                              : "Tap to choose a profile photo",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: imageBytes != null
                                ? Colors.green
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Name ──
                      _fieldLabel("Name"),
                      _textField("Enter member name",
                          controller: nameController),
                      const SizedBox(height: 20),

                      // ── Phone ──
                      _fieldLabel("Phone Number"),
                      _textField("Enter phone number",
                          controller: phoneController,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),

                      // ── Email ──
                      _fieldLabel("Email Address"),
                      _textField("Enter email address",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 20),

                      // ── Gender + State ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("Gender"),
                                _dropdown(
                                  hint: "Select Gender",
                                  value: selectedGender,
                                  items: const [
                                    "Male", "Female", "Children", "Others"
                                  ],
                                  onChanged: isSaving
                                      ? null
                                      : (v) =>
                                          setState(() => selectedGender = v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("State / Hometown"),
                                _dropdown(
                                  hint: "Select State",
                                  value: selectedState,
                                  items: states,
                                  onChanged: isSaving
                                      ? null
                                      : (v) =>
                                          setState(() => selectedState = v),
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
                                _fieldLabel("Arrival Date"),
                                _dateBox(arrivalDate, () {
                                  if (isSaving) return;
                                  openCalendar(context, arrivalDate,
                                      (d) => setState(() => arrivalDate = d));
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("Exit Date"),
                                _dateBox(exitDate, () {
                                  if (isSaving) return;
                                  openCalendar(context, exitDate,
                                      (d) => setState(() => exitDate = d));
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Description ──
                      _fieldLabel("Description"),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                            hint: "Enter a brief description"),
                      ),
                      const SizedBox(height: 32),

                      // ── Buttons (desktop: right-aligned) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              side: BorderSide(
                                color: isSaving
                                    ? Colors.grey
                                    : AllColors.primaryColor,
                              ),
                            ),
                            onPressed:
                                isSaving ? null : () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSaving
                                    ? Colors.grey
                                    : AllColors.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            label: isSaving ? "Saving..." : "Add Member",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 48,
                            isLoading: isSaving,
                            onPressed:
                                isSaving ? null : () => submitForm(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoWidget() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(
              color:
                  isHovered ? AllColors.primaryColor : Colors.grey.shade300,
              width: 2,
            ),
            image: imageBytes != null
                ? DecorationImage(
                    image: MemoryImage(imageBytes!), fit: BoxFit.cover)
                : null,
          ),
          child: ClipOval(
            child: imageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 30, color: Colors.grey[500]),
                      const SizedBox(height: 4),
                      Text(
                        "Upload\nPhoto",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Positioned(
          bottom: 2,
          left: 2,
          child: Container(
            decoration: BoxDecoration(
              color: AllColors.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(5),
            child:
                const Icon(Icons.camera_alt, color: Colors.white, size: 13),
          ),
        ),
        if (imageBytes != null)
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => setState(() {
                imageBytes = null;
                imageName = null;
              }),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                padding: const EdgeInsets.all(4),
                child:
                    const Icon(Icons.close, color: Colors.white, size: 13),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────
class _AddMemberMobile extends StatefulWidget {
  const _AddMemberMobile();

  @override
  State<_AddMemberMobile> createState() => _AddMemberMobileState();
}

class _AddMemberMobileState extends State<_AddMemberMobile>
    with _AddMemberFormMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: Column(
        children: [
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Member",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Fill in the details to add a new member.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AllColors.thirdColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),

          // ── Scrollable form ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Upload Photo ──
                  _sectionLabel("Upload Photo"),
                  Center(
                    child: GestureDetector(
                      onTap: isSaving ? null : pickImage,
                      child: _photoWidget(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      imageBytes != null
                          ? "${imageName ?? 'Photo selected'} ✓"
                          : "Tap to choose a profile photo",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: imageBytes != null
                            ? Colors.green
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Name ──
                  _fieldLabel("Name"),
                  _textField("Enter member name", controller: nameController),
                  const SizedBox(height: 16),

                  // ── Phone ──
                  _fieldLabel("Phone Number"),
                  _textField("Enter phone number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  // ── Email ──
                  _fieldLabel("Email Address"),
                  _textField("Enter email address",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  // ── Gender + State ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Gender"),
                            _dropdown(
                              hint: "Select Gender",
                              value: selectedGender,
                              items: const [
                                "Male", "Female", "Children", "Others"
                              ],
                              onChanged: isSaving
                                  ? null
                                  : (v) =>
                                      setState(() => selectedGender = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("State / Hometown"),
                            _dropdown(
                              hint: "Select State",
                              value: selectedState,
                              items: states,
                              onChanged: isSaving
                                  ? null
                                  : (v) =>
                                      setState(() => selectedState = v),
                            ),
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
                            _fieldLabel("Arrival Date"),
                            _dateBox(arrivalDate, () {
                              if (isSaving) return;
                              openCalendar(context, arrivalDate,
                                  (d) => setState(() => arrivalDate = d));
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Exit Date"),
                            _dateBox(exitDate, () {
                              if (isSaving) return;
                              openCalendar(context, exitDate,
                                  (d) => setState(() => exitDate = d));
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Description ──
                  _fieldLabel("Description"),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration:
                        _inputDecoration(hint: "Enter a brief description"),
                  ),
                  const SizedBox(height: 28),

                  // ── Buttons (mobile: full-width) ──
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            side: BorderSide(
                              color: isSaving
                                  ? Colors.grey
                                  : AllColors.primaryColor,
                            ),
                          ),
                          onPressed: isSaving
                              ? null
                              : () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSaving
                                  ? Colors.grey
                                  : AllColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: isSaving ? "Saving..." : "Add Member",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 48,
                          isLoading: isSaving,
                          onPressed:
                              isSaving ? null : () => submitForm(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoWidget() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            image: imageBytes != null
                ? DecorationImage(
                    image: MemoryImage(imageBytes!), fit: BoxFit.cover)
                : null,
          ),
          child: ClipOval(
            child: imageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 28, color: Colors.grey[500]),
                      const SizedBox(height: 4),
                      Text(
                        "Upload\nPhoto",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Positioned(
          bottom: 2,
          left: 2,
          child: Container(
            decoration: BoxDecoration(
              color: AllColors.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
          ),
        ),
        if (imageBytes != null)
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => setState(() {
                imageBytes = null;
                imageName = null;
              }),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                padding: const EdgeInsets.all(4),
                child:
                    const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
      ],
    );
  }
}

// ==================== SHARED HELPERS ====================

Widget _sectionLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );

Widget _fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );

Widget _textField(
  String hint, {
  TextEditingController? controller,
  TextInputType keyboardType = TextInputType.text,
}) =>
    TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint: hint),
    );

Widget _dropdown({
  required String hint,
  required String? value,
  required List<String> items,
  required void Function(String?)? onChanged,
}) =>
    DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.grey[100],
      value: value,
      decoration: _inputDecoration().copyWith(
        filled: true,
        fillColor: Colors.grey[100],
      ),
      hint: Text(hint,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])),
      items: items
          .map((s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: GoogleFonts.inter(fontSize: 13))))
          .toList(),
      onChanged: onChanged,
    );

Widget _dateBox(DateTime? date, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          date == null
              ? "Select date"
              : "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}",
          style: GoogleFonts.inter(
            fontSize: 13,
            color: date == null ? Colors.grey[500] : Colors.black87,
          ),
        ),
      ),
    );

InputDecoration _inputDecoration({String? hint}) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide:
            BorderSide(color: AllColors.primaryColor, width: 1.5),
      ),
    );
