import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  // ================= CONTROLLERS =================
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();
  // LOding
  bool _isloading = false;

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

  // ================= SAVE TO FIRESTORE =================
  Future<void> addMember() async {
    try {
      setState(() {
        _isloading = true;
      });

      await FirebaseFirestore.instance.collection('Member_collection').add({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': selectedGender, // male / female / children / others
        'state': selectedState,
        'arrivalDate': arrivalDate != null
            ? Timestamp.fromDate(arrivalDate!)
            : null,
        'exitDate': exitDate != null ? Timestamp.fromDate(exitDate!) : null,
        'description': descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Keep the data into the firease
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
        } else  {
          await FirebaseFirestore.instance
              .collection("member_count")
              .doc("members")
              .update({"Others": FieldValue.increment(1)});
        }

      // Keep the total member'
      await FirebaseFirestore.instance
          .collection("member_count")
          .doc("members")
          .update({"total": FieldValue.increment(1)});

      setState(() {
        _isloading = false;
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
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
              // ================= HEADER =================
              Text(
                "Add new member",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // ================= NAME =================
              _label("Name"),
              _textField("Enter member name", controller: nameController),
              const SizedBox(height: 20),

              // ================= PHONE =================
              _label("Phone Number"),
              _textField(
                "Enter phone number",
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // ================= GENDER & STATE =================
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
                          hint: const Text(
                            "Select Gender",
                            style: TextStyle(color: Colors.black54),
                          ),
                          style: const TextStyle(color: Colors.black),
                          items: const [
                            DropdownMenuItem(
                              value: "Male",
                              child: Text("Male"),
                            ),
                            DropdownMenuItem(
                              value: "Female",
                              child: Text("Female"),
                            ),
                            DropdownMenuItem(
                              value: "Children",
                              child: Text("Childern"),
                            ),

                            DropdownMenuItem(
                              value: "Others",
                              child: Text("Others"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
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
                        _label("State/ Hometown"),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          dropdownColor: Colors.grey[100],
                          decoration: _inputDecoration().copyWith(
                            filled: true,
                            fillColor: Colors.grey[100],
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          hint: const Text(
                            "Select State",
                            style: TextStyle(color: Colors.black54),
                          ),
                          style: const TextStyle(color: Colors.black),
                          items: states
                              .map(
                                (state) => DropdownMenuItem<String>(
                                  value: state,
                                  child: Text(state),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedState = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ================= DATES =================
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
              Text(
                "Description",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 4,
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter a brief description",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ================= BUTTONS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // CANCEL
                  SizedBox(
                    height: 48,
                    width: 140,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AllColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          color: AllColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ADD MEMBER
                  _isloading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          height: 48,
                          width: 160,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AllColors.primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: addMember,
                            child: Text(
                              "Add Member",
                              style: GoogleFonts.inter(
                                color: AllColors.secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
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

  // ================= HELPERS =================
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
    required TextEditingController controller,
  }) => TextField(
    keyboardType: keyboardType,
    controller: controller,
    decoration: _inputDecoration(hint: hint),
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

// ================= MEMBER LIST PAGE =================
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

              DateTime? arrivalDate = data['arrivalDate'] != null
                  ? (data['arrivalDate'] as Timestamp).toDate()
                  : null;

              DateTime? exitDate = data['exitDate'] != null
                  ? (data['exitDate'] as Timestamp).toDate()
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text(data['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone: ${data['phone']}"),
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
