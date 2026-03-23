import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bangalore_chakma_society/Sections/Home/About%20us/Events/Members/addmemberpage.dart';
import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:bangalore_chakma_society/constraints/custom_text.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:typed_data';

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class AddMemberPageTab extends StatelessWidget {
  const AddMemberPageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const AddMemberDesktopLayout();
          default:
            return const AddMemberMobileLayout();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
//  MEMBER MODEL
// ─────────────────────────────────────────────
class Member {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String place;
  final String checkIn;
  final String checkOut;
  final String photoUrl;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
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
      email: data['email']?.toString() ?? '',
      place: data['state']?.toString() ?? data['place']?.toString() ?? '',
      checkIn: data['arrivalDate'] is Timestamp
          ? _formatDate(data['arrivalDate'])
          : '',
      checkOut:
          data['exitDate'] is Timestamp ? _formatDate(data['exitDate']) : '',
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

// ─────────────────────────────────────────────
//  DESKTOP LAYOUT
// ─────────────────────────────────────────────
class AddMemberDesktopLayout extends StatelessWidget {
  const AddMemberDesktopLayout({super.key});

  Widget _memberStream() {
    return StreamBuilder<QuerySnapshot>(
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
        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Colors.grey),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final member = Member.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>);
            return _memberRow(context, member);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      label: "Add Member",
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: false,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const _FullPageBottomSheetDesktop(
                              child: AddMemberPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(child: _memberStream()),
          ],
        ),
      ),
    );
  }

  Widget _memberRow(BuildContext context, Member member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
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
                        color: AllColors.primaryColor),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(member.name,
                style: CustomText.memberBodyColor,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Row(children: [
              SvgPicture.asset("assets/icons/PhoneCall.svg",
                  height: 20, width: 20),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(member.phone,
                      overflow: TextOverflow.ellipsis,
                      style: CustomText.memberBodyColor)),
            ]),
          ),
          Expanded(
            flex: 4,
            child: Row(children: [
              SvgPicture.asset("assets/icons/mail.svg",
                  height: 20, width: 20),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(
                      member.email.isNotEmpty ? member.email : 'N/A',
                      overflow: TextOverflow.ellipsis,
                      style: CustomText.memberBodyColor)),
            ]),
          ),
          Expanded(
            flex: 3,
            child: Row(children: [
              SvgPicture.asset("assets/icons/place.svg",
                  height: 20, width: 20),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(member.place,
                      overflow: TextOverflow.ellipsis,
                      style: CustomText.memberBodyColor)),
            ]),
          ),
          Expanded(
            flex: 3,
            child: Row(children: [
              SvgPicture.asset("assets/icons/SignIn.svg",
                  height: 20, width: 20),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(member.checkIn,
                      overflow: TextOverflow.ellipsis,
                      style: CustomText.memberBodyColor)),
            ]),
          ),
          Expanded(
            flex: 3,
            child: Row(children: [
              SvgPicture.asset("assets/icons/SignOut.svg",
                  height: 20, width: 20),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(member.checkOut,
                      overflow: TextOverflow.ellipsis,
                      style: CustomText.memberBodyColor)),
            ]),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: SvgPicture.asset("assets/icons/edit.svg",
                    height: 20, width: 20),
                onPressed: () => _showDesktopEditDialog(context, member),
              ),
              IconButton(
                icon: SvgPicture.asset("assets/icons/Trash.svg",
                    height: 20, width: 20),
                onPressed: () => _showDesktopDeleteDialog(context, member),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DESKTOP BOTTOM SHEET WRAPPER
// ─────────────────────────────────────────────
class _FullPageBottomSheetDesktop extends StatelessWidget {
  final Widget child;
  const _FullPageBottomSheetDesktop({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: AllColors.secondaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  DESKTOP DELETE DIALOG
// ─────────────────────────────────────────────
void _showDesktopDeleteDialog(BuildContext context, Member member) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AllColors.secondaryColor,
        child: SizedBox(
          width: 420,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                member.photoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(member.photoUrl),
                      )
                    : Image.asset("assets/image/dustbin.png", height: 120),
                const SizedBox(height: 20),
                Text("Delete Member",
                    style: GoogleFonts.inter(
                        fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete this member?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 240, 26, 11)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel",
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Color.fromARGB(255, 240, 26, 11))),
                    ),
                    const SizedBox(width: 24),
                    CustomButton(
                      label: "Delete",
                      backgroundColor:
                          const Color.fromARGB(255, 240, 26, 11),
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

// ─────────────────────────────────────────────
//  DESKTOP EDIT BOTTOM SHEET
// ─────────────────────────────────────────────
void _showDesktopEditDialog(BuildContext context, Member member) {
  final nameController = TextEditingController(text: member.name);
  final phoneController = TextEditingController(text: member.phone);
  final emailController = TextEditingController(text: member.email);
  final descriptionController = TextEditingController();

  String? selectedGender;
  String? selectedState = member.place.isNotEmpty ? member.place : null;
  DateTime? arrivalDate = member.checkIn.isNotEmpty
      ? DateTime.tryParse(member.checkIn.split('-').reversed.join('-'))
      : null;
  DateTime? exitDate = member.checkOut.isNotEmpty
      ? DateTime.tryParse(member.checkOut.split('-').reversed.join('-'))
      : null;

  Uint8List? editImageBytes;
  String? editImageName;
  bool isEditHovered = false;
  String currentPhotoUrl = member.photoUrl;
  bool isUpdating = false;

  final List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh',
    'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra',
    'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AllColors.secondaryColor,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
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
                      editImageBytes = bytes;
                      editImageName = picked.name;
                    });
                  }
                }

                ImageProvider? avatarImage() {
                  if (editImageBytes != null)
                    return MemoryImage(editImageBytes!);
                  if (currentPhotoUrl.isNotEmpty)
                    return NetworkImage(currentPhotoUrl);
                  return null;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Edit Member",
                                  style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text("Fill in the details to edit a member.",
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AllColors.thirdColor)),
                            ],
                          ),
                          IconButton(
                            onPressed: isUpdating
                                ? null
                                : () => Navigator.pop(context),
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
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 520),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _desktopLabel("Profile Photo"),
                                Center(
                                  child: MouseRegion(
                                    onEnter: (_) => setState(
                                        () => isEditHovered = true),
                                    onExit: (_) => setState(
                                        () => isEditHovered = false),
                                    child: GestureDetector(
                                      onTap:
                                          isUpdating ? null : pickImage,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
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
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
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
                                                            color: AllColors.fourthColor,
                                                          ),
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
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 12),
                                            ),
                                          ),
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: const EdgeInsets.all(4),
                                                  child: const Icon(
                                                      Icons.close,
                                                      color: Colors.grey,
                                                      size: 13),
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
                                _desktopLabel("Member Name"),
                                _desktopTextField("Edit member name",
                                    controller: nameController),
                                const SizedBox(height: 20),
                                _desktopLabel("Phone Number"),
                                _desktopTextField("Edit phone number",
                                    keyboardType: TextInputType.phone,
                                    controller: phoneController),
                                const SizedBox(height: 20),
                                _desktopLabel("Email Address"),
                                _desktopTextField("Edit email address",
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    controller: emailController),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _desktopLabel("Gender"),
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            dropdownColor: Colors.grey[100],
                                            decoration:
                                                _desktopInputDecoration()
                                                    .copyWith(
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey[100]),
                                            hint: const Text("Select Gender"),
                                            items: const [
                                              DropdownMenuItem(
                                                  value: "Male",
                                                  child: Text("Male")),
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
                                            onChanged: isUpdating
                                                ? null
                                                : (v) => setState(
                                                    () => selectedGender = v),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _desktopLabel("State / Hometown"),
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            dropdownColor: Colors.grey[100],
                                            decoration:
                                                _desktopInputDecoration()
                                                    .copyWith(
                                                        filled: true,
                                                        fillColor:
                                                            Colors.grey[100]),
                                            hint: const Text("Select State"),
                                            value: selectedState,
                                            items: states
                                                .map((s) => DropdownMenuItem(
                                                    value: s, child: Text(s)))
                                                .toList(),
                                            onChanged: isUpdating
                                                ? null
                                                : (v) => setState(
                                                    () => selectedState = v),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _desktopLabel("Arrival Date"),
                                          _desktopDateBox(arrivalDate, () {
                                            if (isUpdating) return;
                                            _desktopOpenCalendar(
                                                context,
                                                arrivalDate,
                                                (d) => setState(
                                                    () => arrivalDate = d));
                                          }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _desktopLabel("Exit Date"),
                                          _desktopDateBox(exitDate, () {
                                            if (isUpdating) return;
                                            _desktopOpenCalendar(
                                                context,
                                                exitDate,
                                                (d) => setState(
                                                    () => exitDate = d));
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _desktopLabel("Description"),
                                TextField(
                                  controller: descriptionController,
                                  maxLines: 4,
                                  decoration: _desktopInputDecoration(
                                      hint: "Enter a brief description"),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 160,
                                      height: 30,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero),
                                          side: const BorderSide(
                                              color: Colors.black87, width: 1),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                        ),
                                        onPressed: isUpdating
                                            ? null
                                            : () => Navigator.pop(context),
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    SizedBox(
                                      height: 30,
                                      width: 160,
                                      child: CustomButton(
                                        label: isUpdating
                                            ? "Saving..."
                                            : "Update Member",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 48,
                                        isLoading: isUpdating,
                                        onPressed: isUpdating
                                            ? null
                                            : () async {
                                                setState(() =>
                                                    isUpdating = true);
                                                try {
                                                  String? newPhotoUrl;
                                                  if (editImageBytes != null) {
                                                    final fileName =
                                                        'members/${DateTime.now().millisecondsSinceEpoch}_$editImageName';
                                                    final ref =
                                                        FirebaseStorage
                                                            .instance
                                                            .ref()
                                                            .child(fileName);
                                                    final snap =
                                                        await ref.putData(
                                                      editImageBytes!,
                                                      SettableMetadata(
                                                          contentType:
                                                              'image/jpeg'),
                                                    );
                                                    newPhotoUrl = await snap
                                                        .ref
                                                        .getDownloadURL();
                                                    setState(() {
                                                      currentPhotoUrl =
                                                          newPhotoUrl!;
                                                      editImageBytes = null;
                                                    });
                                                  }
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'Member_collection')
                                                      .doc(member.id)
                                                      .update({
                                                    "name": nameController
                                                        .text.trim(),
                                                    "phone": phoneController
                                                        .text.trim(),
                                                    "email": emailController
                                                        .text.trim(),
                                                    "state": selectedState,
                                                    "gender": selectedGender,
                                                    "arrivalDate":
                                                        arrivalDate != null
                                                            ? Timestamp.fromDate(
                                                                arrivalDate!)
                                                            : null,
                                                    "exitDate":
                                                        exitDate != null
                                                            ? Timestamp.fromDate(
                                                                exitDate!)
                                                            : null,
                                                    "photoUrl": newPhotoUrl ??
                                                        currentPhotoUrl,
                                                    "updatedAt": FieldValue
                                                        .serverTimestamp(),
                                                  });
                                                  if (!context.mounted) return;
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Member updated successfully ✅"),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } catch (e) {
                                                  if (!context.mounted) return;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Failed to update ❌ $e"),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } finally {
                                                  if (context.mounted) {
                                                    setState(() =>
                                                        isUpdating = false);
                                                  }
                                                }
                                              },
                                      ),
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
                );
              },
            ),
          );
        },
      );
    },
  );
}

// ─────────────────────────────────────────────
//  DESKTOP HELPERS
// ─────────────────────────────────────────────
Widget _desktopLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600)),
    );

Widget _desktopTextField(String hint,
        {TextInputType keyboardType = TextInputType.text,
        TextEditingController? controller}) =>
    TextField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: _desktopInputDecoration(hint: hint));

InputDecoration _desktopInputDecoration({String? hint}) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none),
    );

Widget _desktopDateBox(DateTime? date, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.centerLeft,
        child: Text(date == null
            ? "Select date"
            : "${date.day.toString().padLeft(2, '0')}-"
                "${date.month.toString().padLeft(2, '0')}-"
                "${date.year}"),
      ),
    );

void _desktopOpenCalendar(BuildContext context, DateTime? initialDate,
    Function(DateTime) onSelected) {
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
                        child: Text("Cancel", style: GoogleFonts.inter())),
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

// ─────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────
class AddMemberMobileLayout extends StatelessWidget {
  const AddMemberMobileLayout({super.key});

  Widget _memberStream() {
    return StreamBuilder<QuerySnapshot>(
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
        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Colors.grey),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final member = Member.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>);
            return _memberCard(context, member);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "BCS Members",
          style:
              GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CustomButton(
              label: "Add Member",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const _FullPageBottomSheetMobile(
                      child: AddMemberPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _memberStream(),
      ),
    );
  }

  Widget _memberCard(BuildContext context, Member member) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
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
                          color: AllColors.primaryColor),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _infoRow("assets/icons/PhoneCall.svg", member.phone),
                  _infoRow(
                    "assets/icons/mail.svg",
                    member.email.isNotEmpty ? member.email : 'N/A',
                    wrap: true,
                  ),
                  _infoRow("assets/icons/place.svg", member.place),
                  _infoRow("assets/icons/SignIn.svg", member.checkIn),
                  _infoRow("assets/icons/SignOut.svg", member.checkOut),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: SvgPicture.asset("assets/icons/edit.svg",
                      height: 16, width: 16),
                  onPressed: () => _showMobileEditDialog(context, member),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: SvgPicture.asset("assets/icons/Trash.svg",
                      height: 16, width: 16),
                  onPressed: () =>
                      _showMobileDeleteDialog(context, member),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String iconPath, String text, {bool wrap = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SvgPicture.asset(iconPath, height: 16, width: 16),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: wrap
                ? Text(text,
                    softWrap: true, style: CustomText.memberBodyColor)
                : Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE BOTTOM SHEET WRAPPER
// ─────────────────────────────────────────────
class _FullPageBottomSheetMobile extends StatelessWidget {
  final Widget child;
  const _FullPageBottomSheetMobile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: AllColors.secondaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE DELETE DIALOG
// ─────────────────────────────────────────────
void _showMobileDeleteDialog(BuildContext context, Member member) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AllColors.secondaryColor,
        child: SizedBox(
          width: 360,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                member.photoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(member.photoUrl),
                      )
                    : Image.asset("assets/image/dustbin.png", height: 100),
                const SizedBox(height: 20),
                Text("Delete Member",
                    style: GoogleFonts.inter(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete this member?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 240, 26, 11)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel",
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Color.fromARGB(255, 240, 26, 11))),
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      label: "Delete",
                      backgroundColor:
                          const Color.fromARGB(255, 240, 26, 11),
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

// ─────────────────────────────────────────────
//  MOBILE EDIT BOTTOM SHEET
// ─────────────────────────────────────────────
void _showMobileEditDialog(BuildContext context, Member member) {
  final nameController = TextEditingController(text: member.name);
  final phoneController = TextEditingController(text: member.phone);
  final emailController = TextEditingController(text: member.email);
  final descriptionController = TextEditingController();

  String? selectedGender;
  String? selectedState = member.place.isNotEmpty ? member.place : null;
  DateTime? arrivalDate = member.checkIn.isNotEmpty
      ? DateTime.tryParse(member.checkIn.split('-').reversed.join('-'))
      : null;
  DateTime? exitDate = member.checkOut.isNotEmpty
      ? DateTime.tryParse(member.checkOut.split('-').reversed.join('-'))
      : null;

  Uint8List? editImageBytes;
  String? editImageName;
  String currentPhotoUrl = member.photoUrl;
  bool isUpdating = false;

  final List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh',
    'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra',
    'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AllColors.secondaryColor,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
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
                      editImageBytes = bytes;
                      editImageName = picked.name;
                    });
                  }
                }

                ImageProvider? avatarImage() {
                  if (editImageBytes != null)
                    return MemoryImage(editImageBytes!);
                  if (currentPhotoUrl.isNotEmpty)
                    return NetworkImage(currentPhotoUrl);
                  return null;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Edit Member",
                                  style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text("Fill in the details to edit a member.",
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AllColors.thirdColor)),
                            ],
                          ),
                          IconButton(
                            onPressed: isUpdating
                                ? null
                                : () => Navigator.pop(context),
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _mobileLabel("Profile Photo"),
                            Center(
                              child: GestureDetector(
                                onTap: isUpdating ? null : pickImage,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AllColors.fourthColor,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
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
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.cloud_upload_outlined,
                                                    size: 24,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Upload\nPhoto",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 9,
                                                      color:
                                                          AllColors.fourthColor,
                                                    ),
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
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white, size: 11),
                                      ),
                                    ),
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
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(3),
                                            child: const Icon(Icons.close,
                                                color: Colors.grey, size: 11),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                editImageBytes != null
                                    ? "${editImageName ?? 'New photo selected'} ✓"
                                    : currentPhotoUrl.isNotEmpty
                                        ? "Current photo loaded ✓"
                                        : "Tap to upload a photo",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: editImageBytes != null ||
                                          currentPhotoUrl.isNotEmpty
                                      ? Colors.green
                                      : Colors.grey[500],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _mobileLabel("Member Name"),
                            _mobileTextField("Edit member name",
                                controller: nameController),
                            const SizedBox(height: 16),
                            _mobileLabel("Phone Number"),
                            _mobileTextField("Edit phone number",
                                keyboardType: TextInputType.phone,
                                controller: phoneController),
                            const SizedBox(height: 16),
                            _mobileLabel("Email Address"),
                            _mobileTextField("Edit email address",
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController),
                            const SizedBox(height: 16),
                            _mobileLabel("Gender"),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              dropdownColor: Colors.grey[100],
                              decoration: _mobileInputDecoration().copyWith(
                                  filled: true, fillColor: Colors.grey[100]),
                              hint: const Text("Select Gender"),
                              items: const [
                                DropdownMenuItem(
                                    value: "Male", child: Text("Male")),
                                DropdownMenuItem(
                                    value: "Female", child: Text("Female")),
                                DropdownMenuItem(
                                    value: "Children",
                                    child: Text("Children")),
                                DropdownMenuItem(
                                    value: "Others", child: Text("Others")),
                              ],
                              onChanged: isUpdating
                                  ? null
                                  : (v) => setState(() => selectedGender = v),
                            ),
                            const SizedBox(height: 16),
                            _mobileLabel("State / Hometown"),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              dropdownColor: Colors.grey[100],
                              decoration: _mobileInputDecoration().copyWith(
                                  filled: true, fillColor: Colors.grey[100]),
                              hint: const Text("Select State"),
                              value: selectedState,
                              items: states
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: isUpdating
                                  ? null
                                  : (v) => setState(() => selectedState = v),
                            ),
                            const SizedBox(height: 16),
                            _mobileLabel("Arrival Date"),
                            _mobileDateBox(arrivalDate, () {
                              if (isUpdating) return;
                              _mobileOpenCalendar(context, arrivalDate,
                                  (d) => setState(() => arrivalDate = d));
                            }),
                            const SizedBox(height: 16),
                            _mobileLabel("Exit Date"),
                            _mobileDateBox(exitDate, () {
                              if (isUpdating) return;
                              _mobileOpenCalendar(context, exitDate,
                                  (d) => setState(() => exitDate = d));
                            }),
                            const SizedBox(height: 16),
                            _mobileLabel("Description"),
                            TextField(
                              controller: descriptionController,
                              maxLines: 4,
                              decoration: _mobileInputDecoration(
                                  hint: "Enter a brief description"),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 180,
                                  height: 30,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero),
                                      side: const BorderSide(
                                          color: Colors.black87, width: 1),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    onPressed: isUpdating
                                        ? null
                                        : () => Navigator.pop(context),
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                SizedBox(
                                  width: 180,
                                  child: CustomButton(
                                    label: isUpdating
                                        ? "Saving..."
                                        : "Update Member",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 48,
                                    isLoading: isUpdating,
                                    onPressed: isUpdating
                                        ? null
                                        : () async {
                                            setState(() => isUpdating = true);
                                            try {
                                              String? newPhotoUrl;
                                              if (editImageBytes != null) {
                                                final fileName =
                                                    'members/${DateTime.now().millisecondsSinceEpoch}_$editImageName';
                                                final ref = FirebaseStorage
                                                    .instance
                                                    .ref()
                                                    .child(fileName);
                                                final snap = await ref.putData(
                                                  editImageBytes!,
                                                  SettableMetadata(
                                                      contentType:
                                                          'image/jpeg'),
                                                );
                                                newPhotoUrl = await snap.ref
                                                    .getDownloadURL();
                                                setState(() {
                                                  currentPhotoUrl = newPhotoUrl!;
                                                  editImageBytes = null;
                                                });
                                              }
                                              await FirebaseFirestore.instance
                                                  .collection(
                                                      'Member_collection')
                                                  .doc(member.id)
                                                  .update({
                                                "name":
                                                    nameController.text.trim(),
                                                "phone": phoneController.text
                                                    .trim(),
                                                "email": emailController.text
                                                    .trim(),
                                                "state": selectedState,
                                                "gender": selectedGender,
                                                "arrivalDate": arrivalDate !=
                                                        null
                                                    ? Timestamp.fromDate(
                                                        arrivalDate!)
                                                    : null,
                                                "exitDate": exitDate != null
                                                    ? Timestamp.fromDate(
                                                        exitDate!)
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
                                                      "Member updated successfully ✅"),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Failed to update ❌ $e"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } finally {
                                              if (context.mounted) {
                                                setState(
                                                    () => isUpdating = false);
                                              }
                                            }
                                          },
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
                );
              },
            ),
          );
        },
      );
    },
  );
}

// ─────────────────────────────────────────────
//  MOBILE HELPERS
// ─────────────────────────────────────────────
Widget _mobileLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600)),
    );

Widget _mobileTextField(String hint,
        {TextInputType keyboardType = TextInputType.text,
        TextEditingController? controller}) =>
    TextField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: _mobileInputDecoration(hint: hint));

InputDecoration _mobileInputDecoration({String? hint}) => InputDecoration(
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
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.centerLeft,
        child: Text(date == null
            ? "Select date"
            : "${date.day.toString().padLeft(2, '0')}-"
                "${date.month.toString().padLeft(2, '0')}-"
                "${date.year}"),
      ),
    );

void _mobileOpenCalendar(BuildContext context, DateTime? initialDate,
    Function(DateTime) onSelected) {
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
                        child: Text("Cancel", style: GoogleFonts.inter())),
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
