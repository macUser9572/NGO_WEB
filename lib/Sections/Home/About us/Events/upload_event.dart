import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
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

  // ================= EXISTING IMAGES FROM FIRESTORE =================
  List<Map<String, String>> _existingImages = [];
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingImages();
  }

  Future<void> _loadExistingImages() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("events")
          .doc("upload_events")
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List<Map<String, String>> images = [];

        // Pre-fill title & key info fields
        title1Controller.text = data["title1"] ?? "";
        title2Controller.text = data["title2"] ?? "";
        title3Controller.text = data["title3"] ?? "";
        title4Controller.text = data["title4"] ?? "";
        keyInfoController.text = data["key_information"] ?? "";

        for (int i = 1; i <= 4; i++) {
          final url = data["image$i"]?.toString() ?? "";
          final title = data["title$i"]?.toString() ?? "Image $i";
          if (url.isNotEmpty) {
            images.add({"url": url, "name": title});
          }
        }

        setState(() => _existingImages = images);
      }
    } catch (e) {
      // silently fail
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  // ================= PICK IMAGE =================
  Future<Uint8List?> pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }

  // ================= UPLOAD IMAGE =================
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
        keyInfoController.text.isEmpty ||
        image1 == null ||
        image2 == null ||
        image3 == null ||
        image4 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields & select images"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // ================= UPLOAD EVENT =================
  Future<void> uploadEvent() async {
    if (!validateFields()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final time = DateTime.now().millisecondsSinceEpoch;

      String imageUrl1 = await uploadImage(image1!, "image1_$time");
      String imageUrl2 = await uploadImage(image2!, "image2_$time");
      String imageUrl3 = await uploadImage(image3!, "image3_$time");
      String imageUrl4 = await uploadImage(image4!, "image4_$time");

      await FirebaseFirestore.instance
          .collection("events")
          .doc("upload_events")
          .set({
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
    }

    setState(() => _isLoading = false);
  }

  // ================= INPUT FIELD =================
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ================= IMAGE UPLOAD FIELD =================
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
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    image == null ? "No file chosen" : "Image Selected",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: image != null
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomButton(
                  label: "Choose file",
                  fontWeight: FontWeight.w600,
                  onPressed: _isLoading
                      ? null
                      : () async {
                          Uint8List? file = await pickImage();
                          if (file != null) onSelected(file);
                        },
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
    Function(Uint8List) onSelected,
  ) {
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

  // ================= EXISTING IMAGES PREVIEW =================
  Widget _buildExistingImagesSection() {
    if (_loadingExisting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_existingImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "No existing images uploaded yet.",
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Currently Uploaded Images",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _existingImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final img = _existingImages[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      img["url"]!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_outlined,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 70,
                    child: Text(
                      img["name"]!,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.grey),
        const SizedBox(height: 16),
      ],
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      child: Container(
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "EVENTS",
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== BODY (SCROLLABLE) =====
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Existing Images Preview ──
                    _buildExistingImagesSection(),

                    // ── Upload New Images label ──
                    Text(
                      "Upload New Images",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                  ],
                ),
              ),
            ),

            // ===== FOOTER =====
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                label: "Upload",
                fontWeight: FontWeight.w600,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : uploadEvent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ngo_web/constraints/CustomButton.dart';
// import 'package:ngo_web/constraints/all_colors.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';

// class EventsUploadPage extends StatefulWidget {
//   const EventsUploadPage({super.key});

//   @override
//   State<EventsUploadPage> createState() => _EventsUploadPageState();
// }

// class _EventsUploadPageState extends State<EventsUploadPage> {
//   final TextEditingController title1Controller = TextEditingController();
//   final TextEditingController title2Controller = TextEditingController();
//   final TextEditingController title3Controller = TextEditingController();
//   final TextEditingController title4Controller = TextEditingController();
//   final TextEditingController keyInfoController = TextEditingController();

//   Uint8List? image1;
//   Uint8List? image2;
//   Uint8List? image3;
//   Uint8List? image4;

//   bool _isLoading = false;
//   final ImagePicker _picker = ImagePicker();

//   // ================= PICK IMAGE =================
//   Future<Uint8List?> pickImage() async {
//     final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
//     if (file != null) {
//       return await file.readAsBytes();
//     }
//     return null;
//   }

//   // ================= UPLOAD IMAGE =================
//   Future<String> uploadImage(Uint8List file, String name) async {
//     final ref = FirebaseStorage.instance
//         .ref()
//         .child("events")
//         .child("$name.jpg");
//     await ref.putData(file);
//     return await ref.getDownloadURL();
//   }

//   // ================= VALIDATION =================
//   bool validateFields() {
//     if (title1Controller.text.isEmpty ||
//         title2Controller.text.isEmpty ||
//         title3Controller.text.isEmpty ||
//         title4Controller.text.isEmpty ||
//         keyInfoController.text.isEmpty ||
//         image1 == null ||
//         image2 == null ||
//         image3 == null ||
//         image4 == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please fill all fields & select images"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }
//     return true;
//   }

//   // ================= UPLOAD EVENT =================
//   Future<void> uploadEvent() async {
//     if (!validateFields()) return;
//     if (_isLoading) return;

//     setState(() => _isLoading = true);

//     try {
//       final time = DateTime.now().millisecondsSinceEpoch;

//       String imageUrl1 = await uploadImage(image1!, "image1_$time");
//       String imageUrl2 = await uploadImage(image2!, "image2_$time");
//       String imageUrl3 = await uploadImage(image3!, "image3_$time");
//       String imageUrl4 = await uploadImage(image4!, "image4_$time");

//       await FirebaseFirestore.instance
//           .collection("events")
//           .doc("upload_events")
//           .set({
//         "title1": title1Controller.text.trim(),
//         "title2": title2Controller.text.trim(),
//         "title3": title3Controller.text.trim(),
//         "title4": title4Controller.text.trim(),
//         "key_information": keyInfoController.text.trim(),
//         "image1": imageUrl1,
//         "image2": imageUrl2,
//         "image3": imageUrl3,
//         "image4": imageUrl4,
//         "created_at": Timestamp.now(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Event Uploaded Successfully"),
//           backgroundColor: Colors.green,
//         ),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   // ================= INPUT FIELD =================
//   Widget buildTitleField(String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: GoogleFonts.inter(
//                 fontWeight: FontWeight.w600, fontSize: 15)),
//         const SizedBox(height: 8),
//         Container(
//           height: 55,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: TextField(
//             controller: controller,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.symmetric(horizontal: 16),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ================= IMAGE UPLOAD FIELD =================
//   Widget buildUploadField(Uint8List? image, Function(Uint8List) onSelected) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Image",
//             style: GoogleFonts.inter(
//                 fontWeight: FontWeight.w600, fontSize: 15)),
//         const SizedBox(height: 8),
//         Container(
//           height: 55,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     image == null ? "No file chosen" : "Image Selected",
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.inter(
//                       color: image != null
//                           ? Colors.green.shade700
//                           : Colors.grey.shade600,
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: CustomButton(
//                   label: "Choose file",
//                   fontWeight: FontWeight.w600,
//                   onPressed: _isLoading
//                       ? null
//                       : () async {
//                           Uint8List? file = await pickImage();
//                           if (file != null) onSelected(file);
//                         },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildRow(
//     String label,
//     TextEditingController controller,
//     Uint8List? image,
//     Function(Uint8List) onSelected,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 25),
//       child: Row(
//         children: [
//           Expanded(child: buildTitleField(label, controller)),
//           const SizedBox(width: 30),
//           Expanded(child: buildUploadField(image, onSelected)),
//         ],
//       ),
//     );
//   }

//   // ================= MAIN UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AllColors.secondaryColor,
//       child: Container(
//         width: 800,
//         height: 650,
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           children: [
//             // ===== HEADER =====
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "EVENTS",
//                   style: GoogleFonts.inter(
//                     fontSize: 40,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ===== BODY (SCROLLABLE) =====
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     buildRow("Image 1 Title", title1Controller, image1,
//                         (file) => setState(() => image1 = file)),

//                     buildRow("Image 2 Title", title2Controller, image2,
//                         (file) => setState(() => image2 = file)),

//                     buildRow("Image 3 Title", title3Controller, image3,
//                         (file) => setState(() => image3 = file)),

//                     buildRow("Image 4 Title", title4Controller, image4,
//                         (file) => setState(() => image4 = file)),

//                     const SizedBox(height: 20),

//                     buildTitleField("Key Information", keyInfoController),

//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),

//             // ===== FOOTER =====
//             Align(
//               alignment: Alignment.centerRight,
//               child: CustomButton(
//                 label: "Upload",
//                 fontWeight: FontWeight.w600,
//                 isLoading: _isLoading,
//                 onPressed: _isLoading ? null : uploadEvent,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
