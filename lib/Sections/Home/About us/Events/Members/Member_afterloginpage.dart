import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/addmemberpage.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/custom_text.dart';
import 'dart:typed_data';

class AddMemberPageTab extends StatelessWidget {
  const AddMemberPageTab({super.key});

  Widget membersStream() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Member_collection')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No members found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final member = Member.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
              return _memberRow(context, member);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "BCS Members",
                  style: GoogleFonts.inter(
                      fontSize: 40, fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 16),
                    CustomButton(
                      label: "Add Members",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AddMemberPage(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            membersStream(),
          ],
        ),
      ),
    );
  }

  Widget _memberRow(BuildContext context, Member member) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // ── Avatar ──
              CircleAvatar(
                radius: 22,
                backgroundColor: AllColors.fourthColor,
                backgroundImage: member.photoUrl.isNotEmpty
                    ? NetworkImage(member.photoUrl)
                    : null,
                child: member.photoUrl.isEmpty
                    ? Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AllColors.primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // ── Name ──
              Expanded(
                flex: 3,
                child: Text(member.name,
                    style: CustomText.memberBodyColor,
                    overflow: TextOverflow.ellipsis),
              ),

              // ── Phone ──
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/PhoneCall.svg",
                        height: 20, width: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(member.phone,
                          overflow: TextOverflow.ellipsis,
                          style: CustomText.memberBodyColor),
                    ),
                  ],
                ),
              ),

              // ── Place ──
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/place.svg",
                        height: 20, width: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(member.place,
                          overflow: TextOverflow.ellipsis,
                          style: CustomText.memberBodyColor),
                    ),
                  ],
                ),
              ),

              // ── Check In ──
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/SignIn.svg",
                        height: 20, width: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(member.checkIn,
                          overflow: TextOverflow.ellipsis,
                          style: CustomText.memberBodyColor),
                    ),
                  ],
                ),
              ),

              // ── Check Out ──
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/SignOut.svg",
                        height: 20, width: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(member.checkOut,
                          overflow: TextOverflow.ellipsis,
                          style: CustomText.memberBodyColor),
                    ),
                  ],
                ),
              ),

              // ── Actions ──
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/edit.svg",
                        height: 20, width: 20),
                    onPressed: () => _showEditMemberDialog(context, member),
                  ),
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/Trash.svg",
                        height: 20, width: 20),
                    onPressed: () => _showDeleteDialog(context, member),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}

// ==================== MEMBER MODEL ====================
class Member {
  final String id;
  final String name;
  final String phone;
  final String place;
  final String checkIn;
  final String checkOut;
  final String photoUrl;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.place,
    required this.checkIn,
    required this.checkOut,
    required this.photoUrl,
  });

  factory Member.fromFirestore(String id, Map<String, dynamic> data) {
    return Member(
      id: id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      place: data['state']?.toString() ?? data['place']?.toString() ?? '',
      checkIn: data['arrivalDate'] is Timestamp
          ? _formatDate(data['arrivalDate'])
          : '',
      checkOut: data['exitDate'] is Timestamp
          ? _formatDate(data['exitDate'])
          : '',
      photoUrl: data['photoUrl']?.toString() ?? '',
    );
  }

  static String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}

// ==================== DELETE DIALOG ====================
void _showDeleteDialog(BuildContext context, Member member) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AllColors.secondaryColor,
        child: SizedBox(
          width: 420,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Show member photo or dustbin ──
                member.photoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(member.photoUrl),
                      )
                    : Image.asset("assets/image/dustbin.png", height: 120),

                const SizedBox(height: 20),
                Text("Delete Member",
                    style: GoogleFonts.inter(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete this member?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Cancel ──
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel",
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.red)),
                    ),
                    const SizedBox(width: 24),
                    // ── Delete ──
                    CustomButton(
                      label: "Delete",
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('Member_collection')
                            .doc(member.id)
                            .delete();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ==================== EDIT DIALOG ====================
void _showEditMemberDialog(BuildContext context, Member member) {
  final nameController = TextEditingController(text: member.name);
  final phoneController = TextEditingController(text: member.phone);
  final descriptionController = TextEditingController();

  String? selectedGender;
  String? selectedState = member.place.isNotEmpty ? member.place : null;

  DateTime? arrivalDate = member.checkIn.isNotEmpty
      ? DateTime.tryParse(member.checkIn.split('-').reversed.join('-'))
      : null;
  DateTime? exitDate = member.checkOut.isNotEmpty
      ? DateTime.tryParse(member.checkOut.split('-').reversed.join('-'))
      : null;

  // ✅ ALL declared OUTSIDE StatefulBuilder — never reset on setState
  Uint8List? editImageBytes;
  String? editImageName;
  bool isEditHovered = false;
  String currentPhotoUrl = member.photoUrl;
  bool isUpdating = false; // ✅ loading state for Update button

  final List<String> states = [
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Karnataka',
    'Kerala',
    'Tamil Nadu',
    'Telangana',
  ];

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: AllColors.secondaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(
          builder: (context, setState) {

            Future<void> pickEditImage() async {
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
                  editImageBytes = bytes;
                  editImageName = picked.name;
                });
              }
            }

            ImageProvider? avatarImage() {
              if (editImageBytes != null) return MemoryImage(editImageBytes!);
              if (currentPhotoUrl.isNotEmpty)
                return NetworkImage(currentPhotoUrl);
              return null;
            }

            return SizedBox(
              width: 520,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Header ──
                      Text("Edit Member",
                          style: GoogleFonts.inter(
                              fontSize: 26, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text("Fill in the details to edit a member.",
                          style: GoogleFonts.inter(
                              fontSize: 16, color: AllColors.thirdColor)),
                      const SizedBox(height: 24),

                      // ── Profile Photo ──
                      _label("Profile Photo"),
                      Center(
                        child: MouseRegion(
                          onEnter: (_) =>
                              setState(() => isEditHovered = true),
                          onExit: (_) =>
                              setState(() => isEditHovered = false),
                          child: GestureDetector(
                            onTap: pickEditImage,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // ── Circle ──
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AllColors.fourthColor,
                                    border: Border.all(
                                      color: isEditHovered
                                          ? AllColors.primaryColor
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    image: avatarImage() != null
                                        ? DecorationImage(
                                            image: avatarImage()!,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: ClipOval(
                                    child: avatarImage() == null
                                        // No photo — placeholder
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 28,
                                                color: Colors.grey[500],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Upload\nPhoto",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    color:
                                                        AllColors.fourthColor),
                                              ),
                                            ],
                                          )
                                        // Has photo — hover overlay
                                        : isEditHovered
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
                                                        size: 24),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Change",
                                                      style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                  ),
                                ),

                                // ── Camera badge ──
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
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 12),
                                  ),
                                ),

                                // ── Remove button ──
                                if (editImageBytes != null)
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        editImageBytes = null;
                                        editImageName = null;
                                      }),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
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
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          editImageBytes != null
                              ? "${editImageName ?? 'New photo selected'} ✓"
                              : currentPhotoUrl.isNotEmpty
                                  ? "Current photo loaded ✓"
                                  : "Tap to upload a photo",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: editImageBytes != null ||
                                    currentPhotoUrl.isNotEmpty
                                ? Colors.green
                                : Colors.grey[500],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Name ──
                      _label("Member Name"),
                      _textField("Edit Member name",
                          controller: nameController),
                      const SizedBox(height: 20),

                      // ── Phone ──
                      _label("Member Phone Number"),
                      _textField("Edit Member phone number",
                          keyboardType: TextInputType.phone,
                          controller: phoneController),
                      const SizedBox(height: 20),

                      // ── Gender & State ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Gender"),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.grey[100],
                                  decoration: _inputDecoration().copyWith(
                                      filled: true,
                                      fillColor: Colors.grey[100]),
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
                                  onChanged: (value) =>
                                      setState(() => selectedGender = value),
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
                                  dropdownColor: Colors.grey[100],
                                  decoration: _inputDecoration().copyWith(
                                      filled: true,
                                      fillColor: Colors.grey[100]),
                                  hint: const Text("Select State"),
                                  value: selectedState,
                                  items: states
                                      .map((s) => DropdownMenuItem(
                                          value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => selectedState = value),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Dates ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Arrival Date"),
                                _dateBox(arrivalDate, () {
                                  _openCalendar(context, arrivalDate,
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
                                _label("Exit Date"),
                                _dateBox(exitDate, () {
                                  _openCalendar(context, exitDate,
                                      (d) => setState(() => exitDate = d));
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Description ──
                      _label("Description"),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                            hint: "Enter a brief description"),
                      ),

                      const SizedBox(height: 32),

                      // ── Buttons ──
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
                            onPressed: isUpdating
                                ? null // disabled while saving
                                : () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: GoogleFonts.inter(
                                    color: AllColors.primaryColor)),
                          ),
                          const SizedBox(width: 16),

                          // ✅ Update button with loading spinner
                          CustomButton(
                            label: "Update Member",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 48,
                            backgroundColor: AllColors.primaryColor,
                            textColor: AllColors.secondaryColor,
                            isLoading: isUpdating, // ✅ spinner
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            onPressed: isUpdating
                                ? null // ✅ disabled while saving
                                : () async {
                                    setState(() => isUpdating = true);

                                    try {
                                      // ── Upload photo if new one picked ──
                                      String? newPhotoUrl;
                                      if (editImageBytes != null) {
                                        try {
                                          final fileName =
                                              'members/${DateTime.now().millisecondsSinceEpoch}_$editImageName';
                                          final ref = FirebaseStorage.instance
                                              .ref()
                                              .child(fileName);
                                          final snapshot = await ref.putData(
                                            editImageBytes!,
                                            SettableMetadata(
                                                contentType: 'image/jpeg'),
                                          );
                                          newPhotoUrl = await snapshot.ref
                                              .getDownloadURL();
                                          setState(() {
                                            currentPhotoUrl = newPhotoUrl!;
                                            editImageBytes = null;
                                          });
                                        } catch (e) {
                                          debugPrint("Upload error: $e");
                                        }
                                      }

                                      // ── Save to Firestore ──
                                      await FirebaseFirestore.instance
                                          .collection('Member_collection')
                                          .doc(member.id)
                                          .update({
                                        "name": nameController.text.trim(),
                                        "phone": phoneController.text.trim(),
                                        "state": selectedState,
                                        "gender": selectedGender,
                                        "arrivalDate": arrivalDate != null
                                            ? Timestamp.fromDate(arrivalDate!)
                                            : null,
                                        "exitDate": exitDate != null
                                            ? Timestamp.fromDate(exitDate!)
                                            : null,
                                        "photoUrl":
                                            newPhotoUrl ?? currentPhotoUrl,
                                        "updatedAt":
                                            FieldValue.serverTimestamp(),
                                      });

                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Member updated successfully"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() => isUpdating = false);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("Error: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

// ==================== SHARED HELPERS ====================

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600)),
    );

Widget _textField(
  String hint, {
  TextInputType keyboardType = TextInputType.text,
  TextEditingController? controller,
}) {
  return TextField(
    keyboardType: keyboardType,
    controller: controller,
    decoration: _inputDecoration(hint: hint),
  );
}

InputDecoration _inputDecoration({String? hint}) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
    );

Widget _dateBox(DateTime? date, VoidCallback onTap) {
  return InkWell(
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
            : "${date.day.toString().padLeft(2, '0')}-"
                "${date.month.toString().padLeft(2, '0')}-"
                "${date.year}",
      ),
    ),
  );
}

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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ngo_web/Sections/Home/About%20us/Events/Members/addmemberpage.dart';
// import 'package:ngo_web/constraints/CustomButton.dart';
// import 'package:ngo_web/constraints/all_colors.dart';
// import 'package:ngo_web/constraints/custom_text.dart';
// import 'dart:typed_data';

// class AddMemberPageTab extends StatelessWidget {
//   const AddMemberPageTab({super.key});

//   Widget membersStream() {
//     return Expanded(
//       child: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('Member_collection')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No members found"));
//           }
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final doc = snapshot.data!.docs[index];
//               final member = Member.fromFirestore(
//                 doc.id,
//                 doc.data() as Map<String, dynamic>,
//               );
//               return _memberRow(context, member);
//             },
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AllColors.secondaryColor,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 40),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "BCS Members",
//                   style: GoogleFonts.inter(
//                       fontSize: 40, fontWeight: FontWeight.w700),
//                 ),
//                 Row(
//                   children: [
//                     const Icon(Icons.search),
//                     const SizedBox(width: 16),
//                     CustomButton(
//                       label: "Add Members",
//                       onPressed: () {
//                         showDialog(
//                           context: context,
//                           builder: (_) => const AddMemberPage(),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             membersStream(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _memberRow(BuildContext context, Member member) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 22,
//                 backgroundColor: AllColors.fourthColor,
//                 backgroundImage: member.photoUrl.isNotEmpty
//                     ? NetworkImage(member.photoUrl)
//                     : null,
//                 child: member.photoUrl.isEmpty
//                     ? Text(
//                         member.name.isNotEmpty
//                             ? member.name[0].toUpperCase()
//                             : '?',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: AllColors.primaryColor,
//                         ),
//                       )
//                     : null,
//               ),
//               const SizedBox(width: 16),

//               Expanded(
//                 flex: 3,
//                 child: Text(member.name,
//                     style: CustomText.memberBodyColor,
//                     overflow: TextOverflow.ellipsis),
//               ),

//               Expanded(
//                 flex: 3,
//                 child: Row(
//                   children: [
//                     SvgPicture.asset("assets/icons/PhoneCall.svg",
//                         height: 20, width: 20),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(member.phone,
//                           overflow: TextOverflow.ellipsis,
//                           style: CustomText.memberBodyColor),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 flex: 3,
//                 child: Row(
//                   children: [
//                     SvgPicture.asset("assets/icons/place.svg",
//                         height: 20, width: 20),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(member.place,
//                           overflow: TextOverflow.ellipsis,
//                           style: CustomText.memberBodyColor),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 flex: 3,
//                 child: Row(
//                   children: [
//                     SvgPicture.asset("assets/icons/SignIn.svg",
//                         height: 20, width: 20),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(member.checkIn,
//                           overflow: TextOverflow.ellipsis,
//                           style: CustomText.memberBodyColor),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 flex: 3,
//                 child: Row(
//                   children: [
//                     SvgPicture.asset("assets/icons/SignOut.svg",
//                         height: 20, width: 20),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(member.checkOut,
//                           overflow: TextOverflow.ellipsis,
//                           style: CustomText.memberBodyColor),
//                     ),
//                   ],
//                 ),
//               ),

//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: SvgPicture.asset("assets/icons/edit.svg",
//                         height: 20, width: 20),
//                     onPressed: () => _showEditMemberDialog(context, member),
//                   ),
//                   IconButton(
//                     icon: SvgPicture.asset("assets/icons/Trash.svg",
//                         height: 20, width: 20),
//                     onPressed: () => _showDeleteDialog(context, member),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const Divider(height: 1, color: Colors.grey),
//       ],
//     );
//   }
// }

// // ==================== MEMBER MODEL ====================
// class Member {
//   final String id;
//   final String name;
//   final String phone;
//   final String place;
//   final String checkIn;
//   final String checkOut;
//   final String photoUrl;

//   Member({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.place,
//     required this.checkIn,
//     required this.checkOut,
//     required this.photoUrl,
//   });

//   factory Member.fromFirestore(String id, Map<String, dynamic> data) {
//     return Member(
//       id: id,
//       name: data['name']?.toString() ?? '',
//       phone: data['phone']?.toString() ?? '',
//       place: data['state']?.toString() ?? data['place']?.toString() ?? '',
//       checkIn: data['arrivalDate'] is Timestamp
//           ? _formatDate(data['arrivalDate'])
//           : '',
//       checkOut: data['exitDate'] is Timestamp
//           ? _formatDate(data['exitDate'])
//           : '',
//       photoUrl: data['photoUrl']?.toString() ?? '',
//     );
//   }

//   static String _formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return "${date.day.toString().padLeft(2, '0')}-"
//         "${date.month.toString().padLeft(2, '0')}-"
//         "${date.year}";
//   }
// }

// // ==================== DELETE DIALOG ====================
// void _showDeleteDialog(BuildContext context, Member member) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (_) {
//       return Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         backgroundColor: AllColors.secondaryColor,
//         child: SizedBox(
//           width: 420,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 member.photoUrl.isNotEmpty
//                     ? CircleAvatar(
//                         radius: 60,
//                         backgroundImage: NetworkImage(member.photoUrl),
//                       )
//                     : Image.asset("assets/image/dustbin.png", height: 120),
//                 const SizedBox(height: 20),
//                 Text("Delete Member",
//                     style: GoogleFonts.inter(
//                         fontSize: 22, fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 12),
//                 Text(
//                   "Are you sure you want to delete this member?",
//                   textAlign: TextAlign.center,
//                   style:
//                       GoogleFonts.inter(fontSize: 15, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 28),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.zero),
//                         side:
//                             const BorderSide(color: Color.fromARGB(255, 238, 29, 14)),
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                       child: Text("Cancel",
//                           style: GoogleFonts.inter(
//                               fontSize: 14, color: Color.fromARGB(255, 238, 29, 14))),
//                     ),
//                     const SizedBox(width: 24),
//                     CustomButton(
//                       label: "Delete",
//                       backgroundColor: const Color.fromARGB(255, 238, 29, 14),
//                       textColor: Colors.white,
//                       onPressed: () async {
//                         await FirebaseFirestore.instance
//                             .collection('Member_collection')
//                             .doc(member.id)
//                             .delete();
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// // ==================== EDIT DIALOG ====================
// void _showEditMemberDialog(BuildContext context, Member member) {
//   final nameController = TextEditingController(text: member.name);
//   final phoneController = TextEditingController(text: member.phone);
//   final descriptionController = TextEditingController();

//   String? selectedGender;
//   String? selectedState = member.place.isNotEmpty ? member.place : null;

//   DateTime? arrivalDate = member.checkIn.isNotEmpty
//       ? DateTime.tryParse(member.checkIn.split('-').reversed.join('-'))
//       : null;
//   DateTime? exitDate = member.checkOut.isNotEmpty
//       ? DateTime.tryParse(member.checkOut.split('-').reversed.join('-'))
//       : null;

//   // ✅ Declared OUTSIDE StatefulBuilder so setState doesn't reset them
//   Uint8List? editImageBytes;
//   String? editImageName;
//   bool isEditHovered = false;
//   String currentPhotoUrl = member.photoUrl;

//   final List<String> states = [
//     'Arunachal Pradesh',
//     'Assam',
//     'Bihar',
//     'Karnataka',
//     'Kerala',
//     'Tamil Nadu',
//     'Telangana',
//   ];

//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (context) {
//       return Dialog(
//         backgroundColor: AllColors.secondaryColor,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: StatefulBuilder(
//           builder: (context, setState) {

//             Future<void> pickEditImage() async {
//               final picker = ImagePicker();
//               final XFile? picked = await picker.pickImage(
//                 source: ImageSource.gallery,
//                 maxWidth: 1024,
//                 maxHeight: 1024,
//                 imageQuality: 85,
//               );
//               if (picked != null) {
//                 final bytes = await picked.readAsBytes();
//                 // ✅ setState correctly updates the outer variables
//                 setState(() {
//                   editImageBytes = bytes;
//                   editImageName = picked.name;
//                 });
//               }
//             }

//             // ✅ Reads from outer variables — not reset on rebuild
//             ImageProvider? avatarImage() {
//               if (editImageBytes != null) return MemoryImage(editImageBytes!);
//               if (currentPhotoUrl.isNotEmpty) return NetworkImage(currentPhotoUrl);
//               return null;
//             }

//             return SizedBox(
//               width: 520,
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Edit Member",
//                           style: GoogleFonts.inter(
//                               fontSize: 26, fontWeight: FontWeight.w700)),
//                       const SizedBox(height: 6),
//                       Text("Fill in the details to edit a member.",
//                           style: GoogleFonts.inter(
//                               fontSize: 16, color: AllColors.thirdColor)),
//                       const SizedBox(height: 24),

//                       _label("Profile Photo"),
//                       Center(
//                         child: MouseRegion(
//                           onEnter: (_) =>
//                               setState(() => isEditHovered = true),
//                           onExit: (_) =>
//                               setState(() => isEditHovered = false),
//                           child: GestureDetector(
//                             onTap: pickEditImage,
//                             child: Stack(
//                               clipBehavior: Clip.none,
//                               children: [
//                                 // ── Circle ──
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 200),
//                                   width: 100,
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: AllColors.fourthColor,
//                                     border: Border.all(
//                                       color: isEditHovered
//                                           ? AllColors.primaryColor
//                                           : Colors.grey.shade300,
//                                       width: 2,
//                                     ),
//                                     // ✅ Shows picked image OR existing Firebase photo
//                                     image: avatarImage() != null
//                                         ? DecorationImage(
//                                             image: avatarImage()!,
//                                             fit: BoxFit.cover,
//                                           )
//                                         : null,
//                                   ),
//                                   child: ClipOval(
//                                     child: avatarImage() == null
//                                         // No photo — placeholder
//                                         ? Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(
//                                                   Icons.cloud_upload_outlined,
//                                                   size: 28,
//                                                   color: Colors.grey[500]),
//                                               const SizedBox(height: 4),
//                                               Text("Upload\nPhoto",
//                                                   textAlign: TextAlign.center,
//                                                   style: GoogleFonts.inter(
//                                                       fontSize: 10,
//                                                       color: AllColors
//                                                           .fourthColor)),
//                                             ],
//                                           )
//                                         // Has photo — hover overlay
//                                         : isEditHovered
//                                             ? Container(
//                                                 color: Colors.black
//                                                     .withOpacity(0.45),
//                                                 alignment: Alignment.center,
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     const Icon(Icons.edit,
//                                                         color: Colors.white,
//                                                         size: 24),
//                                                     const SizedBox(height: 4),
//                                                     Text("Change",
//                                                         style: GoogleFonts.inter(
//                                                             color: Colors.white,
//                                                             fontSize: 11,
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .w600)),
//                                                   ],
//                                                 ),
//                                               )
//                                             : const SizedBox.shrink(),
//                                   ),
//                                 ),

//                                 // Camera badge
//                                 Positioned(
//                                   bottom: 2,
//                                   left: 2,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: AllColors.primaryColor,
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                           color: Colors.white, width: 2),
//                                     ),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(Icons.camera_alt,
//                                         color: Colors.white, size: 12),
//                                   ),
//                                 ),

//                                 // Remove button
//                                 if (editImageBytes != null)
//                                   Positioned(
//                                     bottom: 2,
//                                     right: 2,
//                                     child: GestureDetector(
//                                       onTap: () => setState(() {
//                                         editImageBytes = null;
//                                         editImageName = null;
//                                       }),
//                                       child: Container(
//                                         decoration: const BoxDecoration(
//                                             color: Colors.red,
//                                             shape: BoxShape.circle),
//                                         padding: const EdgeInsets.all(4),
//                                         child: const Icon(Icons.close,
//                                             color: Colors.white, size: 13),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 8),
//                       Center(
//                         child: Text(
//                           editImageBytes != null
//                               ? "${editImageName ?? 'New photo selected'} ✓"
//                               : currentPhotoUrl.isNotEmpty
//                                   ? "Current photo loaded ✓"
//                                   : "Tap to upload a photo",
//                           style: GoogleFonts.inter(
//                             fontSize: 11,
//                             color: editImageBytes != null ||
//                                     currentPhotoUrl.isNotEmpty
//                                 ? Colors.green
//                                 : Colors.grey[500],
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       _label("Member Name"),
//                       _textField("Edit Member name",
//                           controller: nameController),
//                       const SizedBox(height: 20),

//                       _label("Member Phone Number"),
//                       _textField("Edit Member phone number",
//                           keyboardType: TextInputType.phone,
//                           controller: phoneController),
//                       const SizedBox(height: 20),

//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _label("Gender"),
//                                 DropdownButtonFormField<String>(
//                                   isExpanded: true,
//                                   dropdownColor: Colors.grey[100],
//                                   decoration: _inputDecoration().copyWith(
//                                       filled: true,
//                                       fillColor: Colors.grey[100]),
//                                   hint: const Text("Select Gender"),
//                                   items: const [
//                                     DropdownMenuItem(
//                                         value: "Male", child: Text("Male")),
//                                     DropdownMenuItem(
//                                         value: "Female",
//                                         child: Text("Female")),
//                                     DropdownMenuItem(
//                                         value: "Children",
//                                         child: Text("Children")),
//                                     DropdownMenuItem(
//                                         value: "Others",
//                                         child: Text("Others")),
//                                   ],
//                                   onChanged: (value) =>
//                                       setState(() => selectedGender = value),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _label("State / Hometown"),
//                                 DropdownButtonFormField<String>(
//                                   isExpanded: true,
//                                   dropdownColor: Colors.grey[100],
//                                   decoration: _inputDecoration().copyWith(
//                                       filled: true,
//                                       fillColor: Colors.grey[100]),
//                                   hint: const Text("Select State"),
//                                   value: selectedState,
//                                   items: states
//                                       .map((s) => DropdownMenuItem(
//                                           value: s, child: Text(s)))
//                                       .toList(),
//                                   onChanged: (value) =>
//                                       setState(() => selectedState = value),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _label("Arrival Date"),
//                                 _dateBox(arrivalDate, () {
//                                   _openCalendar(context, arrivalDate,
//                                       (d) => setState(() => arrivalDate = d));
//                                 }),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _label("Exit Date"),
//                                 _dateBox(exitDate, () {
//                                   _openCalendar(context, exitDate,
//                                       (d) => setState(() => exitDate = d));
//                                 }),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       _label("Description"),
//                       TextField(
//                         controller: descriptionController,
//                         maxLines: 4,
//                         decoration: _inputDecoration(
//                             hint: "Enter a brief description"),
//                       ),

//                       const SizedBox(height: 32),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           OutlinedButton(
//                             style: OutlinedButton.styleFrom(
//                               shape: const RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.zero),
//                               side: const BorderSide(
//                                   color: AllColors.primaryColor),
//                             ),
//                             onPressed: () => Navigator.pop(context),
//                             child: Text("Cancel",
//                                 style: GoogleFonts.inter(
//                                     color: AllColors.primaryColor)),
//                           ),
//                           const SizedBox(width: 16),
//                           CustomButton(
//                             label: "Update Member",
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             height: 48,
//                             backgroundColor: AllColors.primaryColor,
//                             textColor: AllColors.secondaryColor,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 24, vertical: 10),
//                             onPressed: () async {
//                               String? newPhotoUrl;
//                               if (editImageBytes != null) {
//                                 try {
//                                   final fileName =
//                                       'members/${DateTime.now().millisecondsSinceEpoch}_$editImageName';
//                                   final ref = FirebaseStorage.instance
//                                       .ref()
//                                       .child(fileName);
//                                   final snapshot = await ref.putData(
//                                     editImageBytes!,
//                                     SettableMetadata(
//                                         contentType: 'image/jpeg'),
//                                   );
//                                   newPhotoUrl =
//                                       await snapshot.ref.getDownloadURL();
//                                   // ✅ Update display immediately after upload
//                                   setState(() {
//                                     currentPhotoUrl = newPhotoUrl!;
//                                     editImageBytes = null;
//                                   });
//                                 } catch (e) {
//                                   debugPrint("Upload error: $e");
//                                 }
//                               }

//                               await FirebaseFirestore.instance
//                                   .collection('Member_collection')
//                                   .doc(member.id)
//                                   .update({
//                                 "name": nameController.text.trim(),
//                                 "phone": phoneController.text.trim(),
//                                 "state": selectedState,
//                                 "gender": selectedGender,
//                                 "arrivalDate": arrivalDate != null
//                                     ? Timestamp.fromDate(arrivalDate!)
//                                     : null,
//                                 "exitDate": exitDate != null
//                                     ? Timestamp.fromDate(exitDate!)
//                                     : null,
//                                 // ✅ Always writes photoUrl — new or existing
//                                 "photoUrl": newPhotoUrl ?? currentPhotoUrl,
//                                 "updatedAt": FieldValue.serverTimestamp(),
//                               });

//                               if (!context.mounted) return;
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text("Member updated successfully"),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     },
//   );
// }

// // ==================== SHARED HELPERS ====================

// Widget _label(String text) => Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(text,
//           style: GoogleFonts.inter(
//               fontSize: 16, fontWeight: FontWeight.w600)),
//     );

// Widget _textField(
//   String hint, {
//   TextInputType keyboardType = TextInputType.text,
//   TextEditingController? controller,
// }) {
//   return TextField(
//     keyboardType: keyboardType,
//     controller: controller,
//     decoration: _inputDecoration(hint: hint),
//   );
// }

// InputDecoration _inputDecoration({String? hint}) => InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.grey[100],
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(4),
//         borderSide: BorderSide.none,
//       ),
//     );

// Widget _dateBox(DateTime? date, VoidCallback onTap) {
//   return InkWell(
//     onTap: onTap,
//     child: Container(
//       height: 48,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(4),
//       ),
//       alignment: Alignment.centerLeft,
//       child: Text(
//         date == null
//             ? "Select date"
//             : "${date.day.toString().padLeft(2, '0')}-"
//                 "${date.month.toString().padLeft(2, '0')}-"
//                 "${date.year}",
//       ),
//     ),
//   );
// }

// void _openCalendar(
//   BuildContext context,
//   DateTime? initialDate,
//   Function(DateTime) onSelected,
// ) {
//   showDialog(
//     context: context,
//     builder: (_) {
//       DateTime tempDate = initialDate ?? DateTime.now();
//       return Dialog(
//         backgroundColor: AllColors.secondaryColor,
//         child: SizedBox(
//           width: 350,
//           height: 420,
//           child: Column(
//             children: [
//               Expanded(
//                 child: CalendarDatePicker(
//                   initialDate: tempDate,
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                   onDateChanged: (d) => tempDate = d,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: Text("Cancel", style: GoogleFonts.inter()),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         onSelected(tempDate);
//                         Navigator.pop(context);
//                       },
//                       child: Text("OK", style: GoogleFonts.inter()),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }