import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/custom_text.dart';
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
            return const _DesktopLayout();
          default:
            return const _MobileLayout();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
//  FULL-PAGE BOTTOM SHEET WRAPPER
//  Slides up from bottom, covers full screen,
//  rounded top corners
// ─────────────────────────────────────────────
class _FullPageSheet extends StatelessWidget {
  final Widget child;
  const _FullPageSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HELPER — show Add Member as bottom sheet
// ─────────────────────────────────────────────
void _showAddMemberSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FullPageSheet(child: AddMemberPage()),
  );
}

// ─────────────────────────────────────────────
//  DESKTOP LAYOUT
// ─────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  Widget memberStream() {
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
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
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
            // ── Back Button ──
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 6),
                  Text("Back"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "BCS Members",
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 16),
                    CustomButton(
                      label: "Add Member",
                      onPressed: () => _showAddMemberSheet(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(child: memberStream()),
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
          // ── Avatar ──
          CircleAvatar(
            radius: 22,
            backgroundColor: AllColors.fourthColor,
            backgroundImage: member.photoUrl.isNotEmpty
                ? NetworkImage(member.photoUrl)
                : null,
            child: member.photoUrl.isEmpty
                ? Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
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
            child: Text(
              member.name,
              style: CustomText.memberBodyColor,
              overflow: TextOverflow.ellipsis,
            ),
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

          // ── Email ──
          Expanded(
            flex: 4,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/mail.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                      member.email.isNotEmpty ? member.email : 'N/A',
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
                onPressed: () => _showEditMemberSheet(context, member),
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
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  Widget memberStream() {
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
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "BCS Members",
          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CustomButton(
              label: "Add Member",
              onPressed: () => _showAddMemberSheet(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: memberStream(),
      ),
    );
  }

  Widget _memberCard(BuildContext context, Member member) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──
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
                        color: AllColors.primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // ── Info ──
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
                  _infoRow("assets/icons/mail.svg",
                      member.email.isNotEmpty ? member.email : 'N/A'),
                  _infoRow("assets/icons/place.svg", member.place),
                  _infoRow("assets/icons/SignIn.svg", member.checkIn),
                  _infoRow("assets/icons/SignOut.svg", member.checkOut),
                ],
              ),
            ),

            // ── Actions ──
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: SvgPicture.asset("assets/icons/edit.svg",
                      height: 16, width: 16),
                  onPressed: () => _showEditMemberSheet(context, member),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: SvgPicture.asset("assets/icons/Trash.svg",
                      height: 16, width: 16),
                  onPressed: () => _showDeleteDialog(context, member),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String iconPath, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, height: 16, width: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: CustomText.memberBodyColor),
          ),
        ],
      ),
    );
  }
}

// ==================== MEMBER MODEL ====================
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
                member.photoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(member.photoUrl),
                      )
                    : Image.asset("assets/image/dustbin.png", height: 120),
                const SizedBox(height: 20),
                Text(
                  "Delete Member",
                  style: GoogleFonts.inter(
                      fontSize: 28, fontWeight: FontWeight.w700),
                ),
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
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Color.fromARGB(255, 240, 26, 11)),
                      ),
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

// ==================== EDIT — BOTTOM SHEET ====================
void _showEditMemberSheet(BuildContext context, Member member) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _FullPageSheet(child: _EditMemberPage(member: member)),
  );
}

// ─────────────────────────────────────────────
//  EDIT MEMBER — FULL PAGE STATEFUL WIDGET
// ─────────────────────────────────────────────
class _EditMemberPage extends StatefulWidget {
  final Member member;
  const _EditMemberPage({required this.member});

  @override
  State<_EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<_EditMemberPage> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  final TextEditingController descriptionController = TextEditingController();

  String? selectedGender;
  String? selectedState;

  DateTime? arrivalDate;
  DateTime? exitDate;

  Uint8List? editImageBytes;
  String? editImageName;
  bool isEditHovered = false;
  late String currentPhotoUrl;
  bool isUpdating = false;

  final List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.member.name);
    phoneController = TextEditingController(text: widget.member.phone);
    emailController = TextEditingController(text: widget.member.email);
    selectedState =
        widget.member.place.isNotEmpty ? widget.member.place : null;
    currentPhotoUrl = widget.member.photoUrl;
    arrivalDate = widget.member.checkIn.isNotEmpty
        ? DateTime.tryParse(
            widget.member.checkIn.split('-').reversed.join('-'))
        : null;
    exitDate = widget.member.checkOut.isNotEmpty
        ? DateTime.tryParse(
            widget.member.checkOut.split('-').reversed.join('-'))
        : null;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickEditImage() async {
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

  ImageProvider? get _avatarImage {
    if (editImageBytes != null) return MemoryImage(editImageBytes!);
    if (currentPhotoUrl.isNotEmpty) return NetworkImage(currentPhotoUrl);
    return null;
  }

  Future<void> _updateMember() async {
    setState(() => isUpdating = true);
    try {
      String? newPhotoUrl;
      if (editImageBytes != null) {
        final fileName =
            'members/${DateTime.now().millisecondsSinceEpoch}_$editImageName';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        final snapshot = await ref.putData(
          editImageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        newPhotoUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          currentPhotoUrl = newPhotoUrl!;
          editImageBytes = null;
        });
      }

      await FirebaseFirestore.instance
          .collection('Member_collection')
          .doc(widget.member.id)
          .update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "state": selectedState,
        "gender": selectedGender,
        "arrivalDate":
            arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        "exitDate": exitDate != null ? Timestamp.fromDate(exitDate!) : null,
        "photoUrl": newPhotoUrl ?? currentPhotoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member updated successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update ❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with close button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Member",
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Fill in the details to edit a member.",
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AllColors.thirdColor),
                        ),
                      ],
                    ),
                  ),
                  // ── Close Button ──
                  InkWell(
                    onTap: isUpdating ? null : () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 38,
                      width: 38,
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
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // ── Scrollable form ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Photo ──
                    _label("Profile Photo"),
                    Center(
                      child: MouseRegion(
                        onEnter: (_) =>
                            setState(() => isEditHovered = true),
                        onExit: (_) =>
                            setState(() => isEditHovered = false),
                        child: GestureDetector(
                          onTap: isUpdating ? null : _pickEditImage,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
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
                                  image: _avatarImage != null
                                      ? DecorationImage(
                                          image: _avatarImage!,
                                          fit: BoxFit.cover)
                                      : null,
                                ),
                                child: ClipOval(
                                  child: _avatarImage == null
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
                                        color: Colors.white, width: 2),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 12),
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

                    _label("Member Name"),
                    _textField("Edit member name",
                        controller: nameController),
                    const SizedBox(height: 20),

                    _label("Phone Number"),
                    _textField("Edit phone number",
                        keyboardType: TextInputType.phone,
                        controller: phoneController),
                    const SizedBox(height: 20),

                    _label("Email Address"),
                    _textField("Edit email address",
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController),
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
                                onChanged: isUpdating
                                    ? null
                                    : (value) => setState(
                                        () => selectedGender = value),
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
                                onChanged: isUpdating
                                    ? null
                                    : (value) => setState(
                                        () => selectedState = value),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Arrival Date"),
                              _dateBox(arrivalDate, () {
                                if (isUpdating) return;
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
                                if (isUpdating) return;
                                _openCalendar(context, exitDate,
                                    (d) => setState(() => exitDate = d));
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _label("Description"),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration(
                          hint: "Enter a brief description"),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            side: BorderSide(
                              color: isUpdating
                                  ? Colors.grey
                                  : AllColors.primaryColor,
                            ),
                          ),
                          onPressed: isUpdating
                              ? null
                              : () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: GoogleFonts.inter(
                                  color: AllColors.primaryColor)),
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          label:
                              isUpdating ? "Saving..." : "Update Member",
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          height: 48,
                          isLoading: isUpdating,
                          onPressed: isUpdating ? null : _updateMember,
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
}

// ==================== SHARED HELPERS ====================

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
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
            : "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}",
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

// ─────────────────────────────────────────────
//  ADD MEMBER PAGE — FULL PAGE FORM
// ─────────────────────────────────────────────
class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _isloading = false;

  String? selectedGender;
  String? selectedState;

  DateTime? arrivalDate;
  DateTime? exitDate;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isImageHovered = false;

  final List<String> states = [
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
    descriptionController.dispose();
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
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
      });
    }
  }

  Future<String?> _uploadImageToStorage() async {
    if (_selectedImageBytes == null) return null;
    try {
      final fileName =
          'members/${DateTime.now().millisecondsSinceEpoch}_$_selectedImageName';
      final ref = FirebaseStorage.instance.ref().child(fileName);
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

  Future<void> addMember() async {
    setState(() => _isloading = true);

    try {
      final String? photoUrl = await _uploadImageToStorage();

      await FirebaseFirestore.instance.collection('Member_collection').add({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'gender': selectedGender,
        'state': selectedState,
        'arrivalDate':
            arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        'exitDate': exitDate != null ? Timestamp.fromDate(exitDate!) : null,
        'description': descriptionController.text.trim(),
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update gender count
      if (selectedGender == 'Male') {
        await FirebaseFirestore.instance
            .collection("member_count")
            .doc("members")
            .update({"Male": FieldValue.increment(1)});
      } else if (selectedGender == 'Female') {
        await FirebaseFirestore.instance
            .collection("member_count")
            .doc("members")
            .update({"Female": FieldValue.increment(1)});
      } else if (selectedGender == 'Children') {
        await FirebaseFirestore.instance
            .collection("member_count")
            .doc("members")
            .update({"Children": FieldValue.increment(1)});
      } else {
        await FirebaseFirestore.instance
            .collection("member_count")
            .doc("members")
            .update({"Others": FieldValue.increment(1)});
      }

      // Update total count
      await FirebaseFirestore.instance
          .collection("member_count")
          .doc("members")
          .update({"total": FieldValue.increment(1)});

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
      if (mounted) setState(() => _isloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with close button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add New Member",
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Fill in the details to add a new member.",
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AllColors.thirdColor),
                        ),
                      ],
                    ),
                  ),
                  // ── Close Button ──
                  InkWell(
                    onTap:
                        _isloading ? null : () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 38,
                      width: 38,
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
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // ── Scrollable form ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Photo ──
                    _addFormLabel("Upload Photo"),
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
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                        color: _isImageHovered
                                            ? AllColors.primaryColor
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                      image: _selectedImageBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(
                                                  _selectedImageBytes!),
                                              fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: ClipOval(
                                      child: _selectedImageBytes == null
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cloud_upload_outlined,
                                                  size: 30,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Upload\nPhoto",
                                                  textAlign:
                                                      TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : _isImageHovered
                                              ? Container(
                                                  color: Colors.black
                                                      .withOpacity(0.45),
                                                  alignment:
                                                      Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                          Icons.edit,
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
                                  if (_selectedImageBytes != null)
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _selectedImageBytes = null;
                                          _selectedImageName = null;
                                        }),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle),
                                          padding:
                                              const EdgeInsets.all(4),
                                          child: const Icon(Icons.close,
                                              color: Colors.white,
                                              size: 14),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedImageBytes != null
                                ? _selectedImageName ?? "Photo selected ✓"
                                : "Tap to choose a profile photo",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _selectedImageBytes != null
                                  ? Colors.green
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _addFormLabel("Name"),
                    _addFormTextField("Enter member name",
                        controller: nameController),
                    const SizedBox(height: 20),

                    _addFormLabel("Phone Number"),
                    _addFormTextField("Enter phone number",
                        controller: phoneController,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),

                    _addFormLabel("Email Address"),
                    _addFormTextField("Enter email address",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _addFormLabel("Gender"),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                dropdownColor: Colors.grey[100],
                                decoration:
                                    _addFormInputDecoration().copyWith(
                                        filled: true,
                                        fillColor: Colors.grey[100]),
                                hint: const Text("Select Gender",
                                    style: TextStyle(
                                        color: Colors.black54)),
                                style:
                                    const TextStyle(color: Colors.black),
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
                              _addFormLabel("State / Hometown"),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                dropdownColor: Colors.grey[100],
                                decoration:
                                    _addFormInputDecoration().copyWith(
                                        filled: true,
                                        fillColor: Colors.grey[100]),
                                hint: const Text("Select State",
                                    style: TextStyle(
                                        color: Colors.black54)),
                                style:
                                    const TextStyle(color: Colors.black),
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
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _addFormLabel("Arrival Date"),
                              _addFormDateBox(arrivalDate, () {
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
                              _addFormLabel("Exit Date"),
                              _addFormDateBox(exitDate, () {
                                _openCalendar(context, exitDate,
                                    (d) => setState(() => exitDate = d));
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _addFormLabel("Description"),
                    TextField(
                      maxLines: 4,
                      controller: descriptionController,
                      decoration: _addFormInputDecoration(
                          hint: "Enter a brief description"),
                    ),
                    const SizedBox(height: 32),

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
                          onPressed: _isloading
                              ? null
                              : () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: GoogleFonts.inter(
                                  color: AllColors.primaryColor)),
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          label: "Add Member",
                          height: 48,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          isLoading: _isloading,
                          onPressed: _isloading ? null : addMember,
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

  Widget _addFormLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w600)),
      );

  Widget _addFormTextField(
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController controller,
  }) =>
      TextField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: _addFormInputDecoration(hint: hint),
      );

  InputDecoration _addFormInputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
      );

  Widget _addFormDateBox(DateTime? date, VoidCallback onTap) {
    return InkWell(
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
              : "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}",
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MEMBER LIST PAGE
// ─────────────────────────────────────────────
class MemberListPage extends StatelessWidget {
  const MemberListPage({super.key});

  Stream<QuerySnapshot> fetchMembers() {
    return FirebaseFirestore.instance
        .collection('Member_collection')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Member List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No members found"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String photoUrl = data['photoUrl']?.toString() ?? '';

              DateTime? arrivalDate = data['arrivalDate'] != null
                  ? (data['arrivalDate'] as Timestamp).toDate()
                  : null;
              DateTime? exitDate = data['exitDate'] != null
                  ? (data['exitDate'] as Timestamp).toDate()
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AllColors.fourthColor,
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl.isEmpty
                        ? Text(
                            (data['name'] ?? '').isNotEmpty
                                ? (data['name'] as String)[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(data['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone: ${data['phone'] ?? ''}"),
                      if ((data['email'] ?? '').isNotEmpty)
                        Text("Email: ${data['email']}"),
                      Text("Arrival: ${formatDate(arrivalDate)}"),
                      Text("Exit: ${formatDate(exitDate)}"),
                      if (data['description'] != null)
                        Text("Description: ${data['description']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
