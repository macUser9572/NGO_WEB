import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/addmemberpage.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/custom_text.dart';

class AddMemberPageTab extends StatelessWidget {
  const AddMemberPageTab({super.key});

  // ===================== FIREBASE STREAM =====================
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
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Row(mainAxisSize: MainAxisSize.min),
            ),
            const SizedBox(height: 24),
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
                      label: "Add members",
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

  // ===================== MEMBER ROW =====================
  Widget _memberRow(BuildContext context, Member member) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              // ── Avatar ──
            member.image.isEmpty
            ? CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(member.image),
            )
            // :SvgPicture.asset("assets/icons/user.svg",
            //       width: 32,
            //       height: 32,),
            : Icon(Icons.abc_outlined),
              const SizedBox(width: 12),

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
                SvgPicture.asset("assets/icons/PhoneCall.svg", height: 32,width: 32,),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        member.phone,
                        overflow: TextOverflow.ellipsis,
                        style: CustomText.memberBodyColor
                        ,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Place ──
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                     SvgPicture.asset("assets/icons/place.svg", height: 32,width: 32,),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        member.place,
                        overflow: TextOverflow.ellipsis,
                        style: CustomText.memberBodyColor
                      ),
                    ),
                  ],
                ),
              ),

              // ── Check In ──
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/SignIn.svg", height: 32,width: 32,),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        member.checkIn,
                        overflow: TextOverflow.ellipsis,
                        style: CustomText.memberBodyColor
                      ),
                    ),
                  ],
                ),
              ),

              // ── Check Out ──
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                     SvgPicture.asset("assets/icons/SignOut.svg", height: 32,width: 32,),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        member.checkOut,
                        overflow: TextOverflow.ellipsis,
                        style: CustomText.memberBodyColor
                      ),
                    ),
                  ],
                ),
              ),

              // ── Actions ──
              IconButton(
                icon: SvgPicture.asset("assets/icons/edit.svg"),
                onPressed: () => _showEditMemberDialog(context, member),
              ),
              IconButton(
                icon: SvgPicture.asset("assets/icons/Trash.svg"),
                onPressed: () => _showDeleteDialog(context, member.id),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}

// ==================== DELETE DIALOG ====================
void _showDeleteDialog(BuildContext context, String memberId) {
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/image/dustbin.png", height: 120),
                const SizedBox(height: 20),
                Text(
                  "Delete Member",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete this member?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AllColors.thirdColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    CustomButton(
                      label: "Delete",
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('Member_collection')
                            .doc(memberId)
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
  String? selectedState = member.place;

  DateTime? arrivalDate =
      member.checkIn.isNotEmpty ? DateTime.parse(member.checkIn) : null;
  DateTime? exitDate =
      member.checkOut.isNotEmpty ? DateTime.parse(member.checkOut) : null;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 520,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit Member",
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Fill in the details to edit a member.",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AllColors.thirdColor,
                        ),
                      ),
                      const SizedBox(height: 28),

                      _label("Member Name"),
                      _textField("Edit Member name", controller: nameController),
                      const SizedBox(height: 20),

                      _label("Member Phone Number"),
                      _textField(
                        "Edit Member phone number",
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                      ),
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
                                    fillColor: Colors.grey[100],
                                  ),
                                  hint: const Text("Select Gender"),
                                  items: const [
                                    DropdownMenuItem(value: "Male", child: Text("Male")),
                                    DropdownMenuItem(value: "Female", child: Text("Female")),
                                    DropdownMenuItem(value: "Children", child: Text("Children")),
                                    DropdownMenuItem(value: "Others", child: Text("Others")),
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
                                    fillColor: Colors.grey[100],
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                  ),
                                  hint: const Text("Select State"),
                                  value: selectedState,
                                  items: states
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ))
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

                      _label("Description"),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration:
                            _inputDecoration(hint: "Enter a brief description"),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                  color: AllColors.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            label: "Update Member",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 48,
                            backgroundColor: AllColors.primaryColor,
                            textColor: AllColors.secondaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('Member_collection')
                                  .doc(member.id)
                                  .update({
                                "name": nameController.text.trim(),
                                "phone": phoneController.text.trim(),
                                "state": selectedState,
                                "gender": selectedGender,
                                "arrivalDate": arrivalDate,
                                "exitDate": exitDate,
                                "updatedAt": FieldValue.serverTimestamp(),
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Member updated successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
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
            : "${date.day.toString().padLeft(2, '0')}-"
                "${date.month.toString().padLeft(2, '0')}-"
                "${date.year}",
      ),
    ),
  );
}

// ==================== CALENDAR ====================
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

// ==================== PAGINATION ====================
Widget _pagination() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFEFFAF2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.arrow_back),
        const SizedBox(width: 12),
        ...List.generate(18, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: index == 0 ? AllColors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: index == 0 ? AllColors.secondaryColor : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward),
      ],
    ),
  );
}

// ==================== MEMBER MODEL ====================
class Member {
  final String id;
  final String name;
  final String phone;
  final String place;
  final String checkIn;
  final String checkOut;
  final String image;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.place,
    required this.checkIn,
    required this.checkOut,
    required this.image,
  });

  factory Member.fromFirestore(String id, Map<String, dynamic> data) {
    return Member(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      place: data['state'] ?? data['place'] ?? '',
      checkIn: data['arrivalDate'] != null
          ? (data['arrivalDate'] as Timestamp)
              .toDate()
              .toString()
              .split(' ')[0]
          : '',
      checkOut: data['exitDate'] != null
          ? (data['exitDate'] as Timestamp)
              .toDate()
              .toString()
              .split(' ')[0]
          : '',
      image: data['image'] ?? '',
    );
  }
}
