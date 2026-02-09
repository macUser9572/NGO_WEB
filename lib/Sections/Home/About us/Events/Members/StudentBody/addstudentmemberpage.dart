import 'package:flutter/material.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

////////////////////////////////////////Add Student Member page////////////////////////////////
class AddStudentMemberPage extends StatefulWidget {
  const AddStudentMemberPage({super.key});

  @override
  State<AddStudentMemberPage> createState() => _AddStudentMemberPageState();
}

class _AddStudentMemberPageState extends State<AddStudentMemberPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final collageController = TextEditingController();
  final courseController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _isLoading = false;

  String? selectedGender;
  String? selectedState;

  DateTime? arrivalDate;
  DateTime? exitDate;

  final List<String> states = [
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Karnataka',
    'Kerala',
    'Tamil Nadu',
    'Telangana',
  ];

  Future<void> addStudent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Student_collection')
          .add({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'collage': collageController.text.trim(),
        'course': courseController.text.trim(),
        'gender': selectedGender,
        'state': selectedState,
        'arrivalDate':
            arrivalDate != null ? Timestamp.fromDate(arrivalDate!) : null,
        'exitDate':
            exitDate != null ? Timestamp.fromDate(exitDate!) : null,
        'description': descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase error: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Student",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Fill in the details to add a new student member.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AllColors.thirdColor,
                ),
              ),
              const SizedBox(height: 20),

//               //const SizedBox(height: 28),

//               //================ UPLOAD PHOTO =================
//               // Text(
//               //   "Upload photo",
//               //   style: GoogleFonts.inter(
//               //     fontSize: 14,
//               //     fontWeight: FontWeight.w600,
//               //     color: Colors.black,
//               //   ),
//               // ),
//               // const SizedBox(height: 10),

//               // Container(
//               //   height: 140,
//               //   width: double.infinity,
//               //   decoration: BoxDecoration(
//               //     color: Colors.grey[100],
//               //     borderRadius: BorderRadius.circular(12),
//               //     border: Border.all(color: Colors.white10),
//               //   ),
//               //   child: Column(
//               //     mainAxisAlignment: MainAxisAlignment.center,
//               //     children: [
//               //       Icon(
//               //         Icons.cloud_upload_outlined,
//               //         size: 34,
//               //         color: Colors.grey,
//               //       ),
//               //       const SizedBox(height: 10),
//               //       Text(
//               //         "Drag and drop or choose an image",
//               //         style: GoogleFonts.inter(
//               //           fontSize: 14,
//               //           fontWeight: FontWeight.w400,
//               //           color: Colors.grey,
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),

              //================ NAME =================
              _label("Student Name"),
              TextField(
                controller: nameController,
                decoration: _inputDecoration(hint: "Enter Student name"),
              ),
              const SizedBox(height: 20),

              //================ PHONE =================
              _label("Student Phone Number"),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(hint: "Enter Student Phone number"),
              ),
              const SizedBox(height: 20),

              //================ COLLEGE =================
              _label("Collage Name"),
              TextField(
                controller: collageController,
                decoration: _inputDecoration(hint: "Enter Collage Name"),
              ),
              const SizedBox(height: 20),

              //================ COURSE =================
              _label("Course Name"),
              TextField(
                controller: courseController,
                decoration: _inputDecoration(hint: "Enter Course Name"),
              ),
              const SizedBox(height: 20),

              //================ GENDER & STATE =================
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Gender"),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration(),
                          hint: const Text("Select Gender"),
                          items: const [
                            DropdownMenuItem(value: "Male", child: Text("Male")),
                            DropdownMenuItem(value: "Female", child: Text("Female")),
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
                          decoration: _inputDecoration(),
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

              const SizedBox(height: 20),

              //================ DATES =================
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

              const SizedBox(height: 20),

              //================ DESCRIPTION =================
              _label("Description"),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(hint: "Enter a brief description"),
              ),

              const SizedBox(height: 32),

              //================ BUTTONS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 48,
                    width: 140,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AllColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(6)
                      )
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 48,
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(6),
                        ),
                      ),
                      onPressed: _isLoading ? null : addStudent,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Add Student"),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );

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
}

