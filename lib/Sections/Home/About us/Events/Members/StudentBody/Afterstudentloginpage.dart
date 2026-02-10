import 'package:flutter/material.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/Student_list_page.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/addstudentmemberpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/addstudentmemberpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class AfterLoginStudentPage extends StatelessWidget {
  const AfterLoginStudentPage({super.key});

  // ================== FIREBASE STREAM ==================
  Widget memberStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Student_collection')
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
          return const Center(child: Text("No Student found"));
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
            // BACK
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

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Student Member",
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AddStudentMemberPage(),
                        );
                      },
                      child: Text(
                        "Add Student",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AllColors.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // LIST
            Expanded(child: memberStream()),
          ],
        ),
      ),
    );
  }

  // ===================== MEMBER ROW =====================
  Widget _memberRow(BuildContext context, Member member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage:
                member.image.isNotEmpty ? NetworkImage(member.image) : null,
            child: member.image.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 20),

          SizedBox(width: 120, child: Text(member.name)),
          const SizedBox(width: 10),

          const Icon(Icons.phone, size: 18),
          const SizedBox(width: 6),
          SizedBox(width: 110, child: Text(member.phone)),

          const SizedBox(width: 20),
          const Icon(Icons.place, size: 18),
          const SizedBox(width: 6),
          SizedBox(width: 120, child: Text(member.collage)),

          const SizedBox(width: 20),
          const Icon(Icons.place, size: 18),
          const SizedBox(width: 6),
          SizedBox(width: 120, child: Text(member.course)),


          const SizedBox(width: 20),
          const Icon(Icons.place, size: 18),
          const SizedBox(width: 6),
          SizedBox(width: 120, child: Text(member.place)),

          const SizedBox(width: 20),
          const Icon(Icons.login, size: 18),
          const SizedBox(width: 6),
          Text(member.checkIn),

          const SizedBox(width: 30),
          const Icon(Icons.logout, size: 18),
          const SizedBox(width: 6),
          Text(member.checkOut),

          const Spacer(),

          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              _showEditMemberDialog(context, member);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showDeleteDialog(context, member.id);
            },
          ),
        ],
      ),
    );
  }
}
// ================= MEMBER MODEL =================
class Member {
  final String id;
  final String name;
  final String phone;
  final String collage;
  final String course;
  final String place;
  final String checkIn;
  final String checkOut;
  final String image;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.collage,
    required this.course,
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
      collage: data['collage'] ?? '',
      course: data['course'] ?? '',
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


  //Delete
void _showDeleteDialog(BuildContext context, String memberId) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AllColors.secondaryColor,
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon / Image
                Image.asset("assets/image/dustbin.png", height: 120),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Delete Student",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                Text(
                  "Are you sure you want to delete this member?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel
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

                    // Delete
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('Student_collection') // ✅ SAME as old
                            .doc(memberId)
                            .delete();

                        Navigator.pop(context);
                      },
                      child: Text(
                        "DELETE",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: AllColors.secondaryColor,
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
    },
  );
}
//===================EDIT DIALOG=================
void _showEditMemberDialog(BuildContext context, Member member) {
  // controllers (pre-filled)
  final nameController = TextEditingController(text: member.name);
  final phoneController = TextEditingController(text: member.phone);
  final CollageController = TextEditingController(text: member.collage);
  final CouresController = TextEditingController(text: member.course);

  final descriptionController = TextEditingController();

  String? selectedGender;
  String? selectedState = member.place;
  //loading
 // bool _isloading =false;

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                        "Edit Studend",
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Fill in the details to edit a student.",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AllColors.thirdColor,
                        ),
                      ),
                      const SizedBox(height: 28),

                      _label("Student Name"),
                      _textField(
                        "Edit Student name",
                        controller: nameController,
                      ),

                      const SizedBox(height: 20),

                      _label("Student Phone Number"),
                      _textField(
                        "Edit Studemt phone number",
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                      ),
                      const SizedBox(height: 20),

                      _label("Student Collage"),
                      _textField(
                        "Edit Studemt collage",
                        keyboardType: TextInputType.phone,
                        controller: CollageController,
                      ),
                      const SizedBox(height: 20),

                      _label("Student Course"),
                      _textField(
                        "Edit Studemt Course",
                        keyboardType: TextInputType.phone,
                        controller: CouresController,
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
                            DropdownMenuItem(value: "Children",child: Text("Childern")),
                            DropdownMenuItem(value: "Others", child: Text("Others")),
                          ],
                          onChanged: (value) {
                            setState(() => selectedGender = value);
                          },
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
                            floatingLabelBehavior: FloatingLabelBehavior.never
                          ),
                          hint: const Text("Select State"),
                          items: states
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedState = value);
                          },
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
                                  _openCalendar(
                                    context,
                                    arrivalDate,
                                    (d) => setState(() => arrivalDate = d),
                                  );
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
                                  _openCalendar(
                                    context,
                                    exitDate,
                                    (d) => setState(() => exitDate = d),
                                  );
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
                          hint: "Enter a brief description",
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AllColors.primaryColor, // ✅ PRIMARY COLOR
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              // setState((){
                              // _isloading = true;
                              //});
                                  await FirebaseFirestore.instance
                                  .collection('Student_collection')
                                  .doc(member.id)
                                  .update({
                                "name": nameController.text.trim(),
                                "phone": phoneController.text.trim(),
                                "Collage":CollageController.text.trim(),
                                "Coures":CouresController.text.trim(),
                                "state": selectedState,
                                "gender": selectedGender,
                                "arrivalDate": arrivalDate,
                                "exitDate": exitDate,
                                "updatedAt": FieldValue.serverTimestamp(),
                              });
                              // setState((){
                              //   _isloading = false;
                              // });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Student updated successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // setState((){
                              //   _isloading= false;
                              // });

                            },
                            child: Text(
                              "Update Member",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: AllColors.secondaryColor, // text color
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
          },
        ),
      );
    },
  );
}


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
//==========================CALENDER ONLY=========================

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

// PAGINATION (UNCHANGED)
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

// ===================== MEMBER MODEL =====================
class Student {
  final String id;
  final String name;
  final String phone;
  final String collage;
  final String course;
  final String place;
  final String checkIn;
  final String checkOut;
  final String image;

  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.collage,
    required this.course,
    required this.place,
    required this.checkIn,
    required this.checkOut,
    required this.image,
  });

  factory Student.fromFirestore(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      collage: data['collage']?.toString() ?? '',
      course: data['course']?.toString() ?? '',
      place: data['state']?.toString() ??
          data['place']?.toString() ??
          '',
      checkIn: data['arrivalDate'] is Timestamp
          ? _formatDate(data['arrivalDate'])
          : '',
      checkOut: data['exitDate'] is Timestamp
          ? _formatDate(data['exitDate'])
          : '',
      image: data['image']?.toString() ?? '',
    );
  }

  // ================= HELPER =================
  static String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}-"
           "${date.month.toString().padLeft(2, '0')}-"
           "${date.year}";
  }
}
