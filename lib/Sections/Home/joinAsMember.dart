import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:ngo_web/constraints/all_colors.dart';

class MembershipRequestDialog extends StatefulWidget {
  const MembershipRequestDialog({super.key});

  @override
  State<MembershipRequestDialog> createState() =>
      _MembershipRequestDialogState();
}

class _MembershipRequestDialogState extends State<MembershipRequestDialog> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController(); // ← ADDED

  String? selectedGender = 'Male';
  String? selectedState = 'Arunachal Pradesh';
  DateTime? arrivalDate;
  DateTime? exitDate;
  bool isLoading = false;
  bool _isImageHovered = false;

  // ✅ Photo state
  Uint8List? pickedImageBytes;
  String? pickedImageName;

  final List<String> genders = ['Male', 'Female', 'Children', 'Others'];

  final List<String> states = [
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Karnataka',
    'Kerala',
    'Tamil Nadu',
    'Telangana',
    'Manipur',
    'Mizoram',
    'Nagaland',
    'Tripura',
    'Meghalaya',
    'Sikkim',
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose(); // ← ADDED
    super.dispose();
  }

  // ✅ Pick image
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
        pickedImageBytes = bytes;
        pickedImageName = picked.name;
      });
    }
  }

  Future<void> _pickDate(bool isArrival) async {
    DateTime tempDate = DateTime.now();
    await showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
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
                        child: Text("Cancel", style: GoogleFonts.inter()),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (isArrival) {
                              arrivalDate = tempDate;
                            } else {
                              exitDate = tempDate;
                            }
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
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select date";
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> _submitRequest() async {
    // ← UPDATED: added email validation
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

      await FirebaseFirestore.instance
          .collection('membership_requests')
          .add({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(), // ← ADDED
        'gender': selectedGender,
        'state': selectedState,
        'arrivalDate': arrivalDate != null
            ? Timestamp.fromDate(arrivalDate!)
            : null,
        'exitDate':
            exitDate != null ? Timestamp.fromDate(exitDate!) : null,
        'photoUrl': photoUrl ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Title ──
              Text(
                "Membership Request",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Fill in the details to be a part of BCS. Once approved will be updated in the BCS member list.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              // ── Upload Photo — CIRCLE STYLE ──
              Text(
                "Upload photo",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

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

                            // ── Circle avatar ──
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 110,
                              height: 110,
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
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: ClipOval(
                                child: pickedImageBytes == null
                                    // ── Empty state ──
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 30,
                                            color: Colors.grey.shade500,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Upload\nPhoto",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      )
                                    // ── Hover overlay on selected image ──
                                    : _isImageHovered
                                        ? Container(
                                            color: Colors.black
                                                .withOpacity(0.45),
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.edit,
                                                    color: Colors.white,
                                                    size: 26),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Change",
                                                  style: GoogleFonts.inter(
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

                            // ── Camera badge (bottom-left) ──
                            Positioned(
                              bottom: 2,
                              left: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade700,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ),

                            // ── Red ✕ remove button (bottom-right) ──
                            if (pickedImageBytes != null)
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    pickedImageBytes = null;
                                    pickedImageName = null;
                                  }),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Caption ──
                    Text(
                      pickedImageBytes != null
                          ? (pickedImageName ?? "Photo selected ✓")
                          : "Tap to choose a profile photo",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: pickedImageBytes != null
                            ? Colors.green
                            : Colors.grey.shade500,
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
                        _label("Name"),
                        _textField("Enter Name",
                            controller: nameController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Gender"),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: _inputDecoration(),
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: genders
                              .map((g) => DropdownMenuItem(
                                  value: g, child: Text(g)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedGender = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Email ── ADDED
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Email"),
                  _textField(
                    "Enter Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── State + Phone ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("State/ Hometown"),
                        DropdownButtonFormField<String>(
                          value: selectedState,
                          decoration: _inputDecoration(),
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: states
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedState = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Contact Number"),
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
                        _label("Arrival Date"),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      side: BorderSide(color: AllColors.fifthColor),
                    ),
                    onPressed:
                        isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AllColors.fifthColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AllColors.fifthColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : _submitRequest,
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Send Request",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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

  // ── Helpers ──
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      );

  Widget _textField(
    String hint, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
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
          borderSide: BorderSide(color: AllColors.primaryColor, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      );

  Widget _dateBox(DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              _formatDate(date),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: date == null
                    ? Colors.grey.shade500
                    : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
// import 'package:ngo_web/constraints/all_colors.dart';

// class MembershipRequestDialog extends StatefulWidget {
//   const MembershipRequestDialog({super.key});

//   @override
//   State<MembershipRequestDialog> createState() =>
//       _MembershipRequestDialogState();
// }

// class _MembershipRequestDialogState extends State<MembershipRequestDialog> {
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();

//   String? selectedGender = 'Male';
//   String? selectedState = 'Arunachal Pradesh';
//   DateTime? arrivalDate;
//   DateTime? exitDate;
//   bool isLoading = false;
//   bool _isImageHovered = false;

//   // ✅ Photo state
//   Uint8List? pickedImageBytes;
//   String? pickedImageName;

//   final List<String> genders = ['Male', 'Female', 'Children', 'Others'];

//   final List<String> states = [
//     'Arunachal Pradesh',
//     'Assam',
//     'Bihar',
//     'Karnataka',
//     'Kerala',
//     'Tamil Nadu',
//     'Telangana',
//     'Manipur',
//     'Mizoram',
//     'Nagaland',
//     'Tripura',
//     'Meghalaya',
//     'Sikkim',
//   ];

//   @override
//   void dispose() {
//     nameController.dispose();
//     phoneController.dispose();
//     super.dispose();
//   }

//   // ✅ Pick image
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final XFile? picked = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 1024,
//       maxHeight: 1024,
//       imageQuality: 85,
//     );
//     if (picked != null) {
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         pickedImageBytes = bytes;
//         pickedImageName = picked.name;
//       });
//     }
//   }

//   Future<void> _pickDate(bool isArrival) async {
//     DateTime tempDate = DateTime.now();
//     await showDialog(
//       context: context,
//       builder: (_) {
//         return Dialog(
//           backgroundColor: Colors.white,
//           child: SizedBox(
//             width: 350,
//             height: 420,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: CalendarDatePicker(
//                     initialDate: tempDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2100),
//                     onDateChanged: (d) => tempDate = d,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text("Cancel", style: GoogleFonts.inter()),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             if (isArrival) {
//                               arrivalDate = tempDate;
//                             } else {
//                               exitDate = tempDate;
//                             }
//                           });
//                           Navigator.pop(context);
//                         },
//                         child: Text("OK", style: GoogleFonts.inter()),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return "Select date";
//     return "${date.day.toString().padLeft(2, '0')}-"
//         "${date.month.toString().padLeft(2, '0')}-"
//         "${date.year}";
//   }

//   Future<void> _submitRequest() async {
//     if (nameController.text.isEmpty || phoneController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all required fields")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       String? photoUrl;
//       if (pickedImageBytes != null) {
//         final fileName =
//             'membership/${DateTime.now().millisecondsSinceEpoch}_$pickedImageName';
//         final ref = FirebaseStorage.instance.ref().child(fileName);
//         final snapshot = await ref.putData(
//           pickedImageBytes!,
//           SettableMetadata(contentType: 'image/jpeg'),
//         );
//         photoUrl = await snapshot.ref.getDownloadURL();
//       }

//       await FirebaseFirestore.instance
//           .collection('membership_requests')
//           .add({
//         'name': nameController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'gender': selectedGender,
//         'state': selectedState,
//         'arrivalDate': arrivalDate != null
//             ? Timestamp.fromDate(arrivalDate!)
//             : null,
//         'exitDate':
//             exitDate != null ? Timestamp.fromDate(exitDate!) : null,
//         'photoUrl': photoUrl ?? '',
//         'status': 'pending',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Membership request sent successfully ✅"),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to send request ❌ $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//       child: SizedBox(
//         width: 560,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [

//               // ── Title ──
//               Text(
//                 "Membership Request",
//                 style: GoogleFonts.inter(
//                   fontSize: 32,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Fill in the details to be a part of BCS. Once approved will be updated in the BCS member list.",
//                 style: GoogleFonts.inter(
//                   fontSize: 16,
//                   color: Colors.black54,
//                   height: 1.5,
//                 ),
//               ),

//               const SizedBox(height: 22),

//               // ── Upload Photo — CIRCLE STYLE ──
//               Text(
//                 "Upload photo",
//                 style: GoogleFonts.inter(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               Center(
//                 child: Column(
//                   children: [
//                     MouseRegion(
//                       onEnter: (_) =>
//                           setState(() => _isImageHovered = true),
//                       onExit: (_) =>
//                           setState(() => _isImageHovered = false),
//                       child: GestureDetector(
//                         onTap: _pickImage,
//                         child: Stack(
//                           clipBehavior: Clip.none,
//                           children: [

//                             // ── Circle avatar ──
//                             AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               width: 110,
//                               height: 110,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey.shade200,
//                                 border: Border.all(
//                                   color: _isImageHovered
//                                       ? AllColors.primaryColor
//                                       : Colors.grey.shade300,
//                                   width: 2,
//                                 ),
//                                 image: pickedImageBytes != null
//                                     ? DecorationImage(
//                                         image: MemoryImage(pickedImageBytes!),
//                                         fit: BoxFit.cover,
//                                       )
//                                     : null,
//                               ),
//                               child: ClipOval(
//                                 child: pickedImageBytes == null
//                                     // ── Empty state ──
//                                     ? Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.cloud_upload_outlined,
//                                             size: 30,
//                                             color: Colors.grey.shade500,
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             "Upload\nPhoto",
//                                             textAlign: TextAlign.center,
//                                             style: GoogleFonts.inter(
//                                               fontSize: 11,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                         ],
//                                       )
//                                     // ── Hover overlay on selected image ──
//                                     : _isImageHovered
//                                         ? Container(
//                                             color: Colors.black
//                                                 .withOpacity(0.45),
//                                             alignment: Alignment.center,
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 const Icon(Icons.edit,
//                                                     color: Colors.white,
//                                                     size: 26),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   "Change",
//                                                   style: GoogleFonts.inter(
//                                                     color: Colors.white,
//                                                     fontSize: 12,
//                                                     fontWeight:
//                                                         FontWeight.w600,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           )
//                                         : const SizedBox.shrink(),
//                               ),
//                             ),

//                             // ── Camera badge (bottom-left) ──
//                             Positioned(
//                               bottom: 2,
//                               left: 2,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade700,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                       color: Colors.white, width: 2),
//                                 ),
//                                 padding: const EdgeInsets.all(5),
//                                 child: const Icon(
//                                   Icons.camera_alt,
//                                   color: Colors.white,
//                                   size: 13,
//                                 ),
//                               ),
//                             ),

//                             // ── Red ✕ remove button (bottom-right) ──
//                             if (pickedImageBytes != null)
//                               Positioned(
//                                 bottom: 2,
//                                 right: 2,
//                                 child: GestureDetector(
//                                   onTap: () => setState(() {
//                                     pickedImageBytes = null;
//                                     pickedImageName = null;
//                                   }),
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                       color: Colors.red,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(
//                                       Icons.close,
//                                       color: Colors.white,
//                                       size: 13,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     // ── Caption ──
//                     Text(
//                       pickedImageBytes != null
//                           ? (pickedImageName ?? "Photo selected ✓")
//                           : "Tap to choose a profile photo",
//                       style: GoogleFonts.inter(
//                         fontSize: 12,
//                         color: pickedImageBytes != null
//                             ? Colors.green
//                             : Colors.grey.shade500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // ── Name + Gender ──
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _label("Name"),
//                         _textField("Enter Name",
//                             controller: nameController),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _label("Gender"),
//                         DropdownButtonFormField<String>(
//                           value: selectedGender,
//                           decoration: _inputDecoration(),
//                           dropdownColor: Colors.white,
//                           icon: const Icon(Icons.keyboard_arrow_down),
//                           items: genders
//                               .map((g) => DropdownMenuItem(
//                                   value: g, child: Text(g)))
//                               .toList(),
//                           onChanged: (v) =>
//                               setState(() => selectedGender = v),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               // const SizedBox(height: 16),
//               //    Expanded(
//               //       child: Column(
//               //         crossAxisAlignment: CrossAxisAlignment.start,
//               //         children: [
//               //           _label("Email"),
//               //           _textField("Enter Email",
//               //               controller: nameController),
//               //         ],
//               //       ),
//               //     ),
//               const SizedBox(height: 16),

//               // ── State + Phone ──
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _label("State/ Hometown"),
//                         DropdownButtonFormField<String>(
//                           value: selectedState,
//                           decoration: _inputDecoration(),
//                           dropdownColor: Colors.white,
//                           icon: const Icon(Icons.keyboard_arrow_down),
//                           items: states
//                               .map((s) => DropdownMenuItem(
//                                   value: s, child: Text(s)))
//                               .toList(),
//                           onChanged: (v) =>
//                               setState(() => selectedState = v),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _label("Contact Number"),
//                         _textField("***********",
//                             controller: phoneController,
//                             keyboardType: TextInputType.phone),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // ── Arrival + Exit Date ──
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _label("Arrival Date"),
//                         _dateBox(arrivalDate, () => _pickDate(true)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _label("Exit Date"),
//                         _dateBox(exitDate, () => _pickDate(false)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // ── Buttons ──
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 28, vertical: 12),
//                       shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.zero),
//                       side: BorderSide(color: AllColors.fifthColor),
//                     ),
//                     onPressed:
//                         isLoading ? null : () => Navigator.pop(context),
//                     child: Text(
//                       "Cancel",
//                       style: GoogleFonts.inter(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: AllColors.fifthColor,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AllColors.fifthColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 28, vertical: 12),
//                       shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.zero),
//                       elevation: 0,
//                     ),
//                     onPressed: isLoading ? null : _submitRequest,
//                     child: isLoading
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : Text(
//                             "Send Request",
//                             style: GoogleFonts.inter(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Helpers ──
//   Widget _label(String text) => Padding(
//         padding: const EdgeInsets.only(bottom: 6),
//         child: Text(
//           text,
//           style: GoogleFonts.inter(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//       );

//   Widget _textField(
//     String hint, {
//     TextEditingController? controller,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: _inputDecoration(hint: hint),
//     );
//   }

//   InputDecoration _inputDecoration({String? hint}) => InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(4),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(4),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(4),
//           borderSide: BorderSide(color: AllColors.primaryColor, width: 1),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
//       );

//   Widget _dateBox(DateTime? date, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 46,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Row(
//           children: [
//             Text(
//               _formatDate(date),
//               style: GoogleFonts.inter(
//                 fontSize: 13,
//                 color: date == null
//                     ? Colors.grey.shade500
//                     : Colors.black87,
//               ),
//             ),
//             const Spacer(),
//             Icon(Icons.calendar_today_outlined,
//                 size: 16, color: Colors.grey.shade500),
//           ],
//         ),
//       ),
//     );
//   }
// }