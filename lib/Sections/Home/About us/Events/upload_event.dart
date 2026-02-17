import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EventsUploadPage extends StatefulWidget {
  const EventsUploadPage({super.key});

  @override
  State<EventsUploadPage> createState() => _EventsUploadPageState();
}

class _EventsUploadPageState extends State<EventsUploadPage> {

  final TextEditingController title1Controller = TextEditingController();
  final TextEditingController title2Controller = TextEditingController();
  final TextEditingController title3Controller = TextEditingController();
  final TextEditingController title4Controller = TextEditingController();
  final TextEditingController keyInfoController = TextEditingController();

  Uint8List? image1;
  Uint8List? image2;
  Uint8List? image3;
  Uint8List? image4;

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // ================= IMAGE PICK FUNCTION =================
  Future<Uint8List?> pickImage() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }

  // ================= UPLOAD IMAGE TO STORAGE =================
  Future<String> uploadImage(Uint8List file, String name) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("events")
        .child("$name.jpg");

    await ref.putData(file);
    return await ref.getDownloadURL();
  }

  // ================= VALIDATION =================
  bool validateFields() {
    if (title1Controller.text.isEmpty ||
        title2Controller.text.isEmpty ||
        title3Controller.text.isEmpty ||
        title4Controller.text.isEmpty ||
        keyInfoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (image1 == null ||
        image2 == null ||
        image3 == null ||
        image4 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select all images"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  // ================= UPLOAD DATA =================
  Future<void> uploadEvent() async {

    if (!validateFields()) return;

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl1 =
          await uploadImage(image1!, "image1_${DateTime.now().millisecondsSinceEpoch}");

      String imageUrl2 =
          await uploadImage(image2!, "image2_${DateTime.now().millisecondsSinceEpoch}");

      String imageUrl3 =
          await uploadImage(image3!, "image3_${DateTime.now().millisecondsSinceEpoch}");

      String imageUrl4 =
          await uploadImage(image4!, "image4_${DateTime.now().millisecondsSinceEpoch}");

      await FirebaseFirestore.instance.collection("events").doc("uploaded_events").set({
        "title1": title1Controller.text.trim(),
        "title2": title2Controller.text.trim(),
        "title3": title3Controller.text.trim(),
        "title4": title4Controller.text.trim(),
        "key_information": keyInfoController.text.trim(),
        "image1": imageUrl1,
        "image2": imageUrl2,
        "image3": imageUrl3,
        "image4": imageUrl4,
        "created_at": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event Uploaded Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ================= UI HELPERS =================

  Widget buildTitleField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUploadField(Uint8List? image, Function(Uint8List) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Image",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  image == null ? "No file chosen" : "Image Selected",
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Uint8List? file = await pickImage();
                  if (file != null) {
                    onSelected(file);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AllColors.secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Choose file",
                    style: GoogleFonts.inter(
                        color: AllColors.primaryColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRow(
      String label,
      TextEditingController controller,
      Uint8List? image,
      Function(Uint8List) onSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          Expanded(child: buildTitleField(label, controller)),
          const SizedBox(width: 30),
          Expanded(child: buildUploadField(image, onSelected)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("EVENTS",
                  style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800)),

              const SizedBox(height: 35),

              buildRow("Image 1 Title", title1Controller, image1,
                  (file) => setState(() => image1 = file)),

              buildRow("Image 2 Title", title2Controller, image2,
                  (file) => setState(() => image2 = file)),

              buildRow("Image 3 Title", title3Controller, image3,
                  (file) => setState(() => image3 = file)),

              buildRow("Image 4 Title", title4Controller, image4,
                  (file) => setState(() => image4 = file)),

              const SizedBox(height: 20),

              buildTitleField("Key Information", keyInfoController),

              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _isLoading ? null : uploadEvent,
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AllColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              "Upload",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
