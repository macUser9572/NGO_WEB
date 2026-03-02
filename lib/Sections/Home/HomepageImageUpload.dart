import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class HomepageUploadPopup extends StatefulWidget {
  const HomepageUploadPopup({super.key});

  @override
  State<HomepageUploadPopup> createState() => _HomepageUploadPopupState();
}

class _HomepageUploadPopupState extends State<HomepageUploadPopup> {
  String fileName = "No file chosen";
  Uint8List? fileBytes;
  bool _isLoading = false;

  // ================= EXISTING IMAGE FROM FIRESTORE =================
  String _existingImageUrl = "";
  String _existingFileName = "";
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingImage();
  }

  Future<void> _loadExistingImage() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('homepage')
          .doc('banner_image')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _existingImageUrl = data["imageUrl"]?.toString() ?? "";
          _existingFileName = data["fileName"]?.toString() ?? "";
        });
      }
    } catch (e) {
      // silently fail
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        fileBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> uploadFile() async {
    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose a file first")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('homepage_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = await storageRef.putData(
        fileBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadURL = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('homepage')
          .doc('banner_image')
          .set({
        'imageUrl': downloadURL,
        'fileName': fileName,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= EXISTING IMAGE PREVIEW =================
  Widget _buildExistingImageSection() {
    if (_loadingExisting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_existingImageUrl.isEmpty) {
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
            "No existing image uploaded yet.",
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Currently Uploaded Image",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _existingImageUrl,
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileBytes != null
                    ? "New image selected ✓"
                    : _existingFileName.isNotEmpty
                        ? _existingFileName
                        : "banner_image",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: fileBytes != null
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.grey),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Homepage",
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Existing Image Preview ──
            _buildExistingImageSection(),

            // ── Image Label ──
            Text(
              "Image",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            // ── File Picker ──
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: fileBytes != null
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomButton(
                      label: "Choose file",
                      fontWeight: FontWeight.w600,
                      onPressed: _isLoading ? null : pickFile,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Upload Button ──
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                label: "Upload",
                fontWeight: FontWeight.w600,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : uploadFile,
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
// import 'package:file_picker/file_picker.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ngo_web/constraints/CustomButton.dart';
// import 'package:ngo_web/constraints/all_colors.dart';

// class HomepageUploadPopup extends StatefulWidget {
//   const HomepageUploadPopup({super.key});

//   @override
//   State<HomepageUploadPopup> createState() => _HomepageUploadPopupState();
// }

// class _HomepageUploadPopupState extends State<HomepageUploadPopup> {
//   String fileName = "No file chosen";
//   Uint8List? fileBytes;
//   bool _isLoading = false;

//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       withData: true,
//     );

//     if (result != null) {
//       setState(() {
//         fileName = result.files.single.name;
//         fileBytes = result.files.single.bytes;
//       });
//     }
//   }

//   Future<void> uploadFile() async {
//     if (fileBytes == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please choose a file first")),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('homepage_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

//       final uploadTask = await storageRef.putData(
//         fileBytes!,
//         SettableMetadata(contentType: 'image/jpeg'),
//       );

//       final downloadURL = await uploadTask.ref.getDownloadURL();

//       await FirebaseFirestore.instance
//           .collection('homepage')
//           .doc('banner_image')
//           .set({
//         'imageUrl': downloadURL,
//         'fileName': fileName,
//         'uploadedAt': FieldValue.serverTimestamp(),
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Image uploaded successfully!"),backgroundColor: Colors.green,),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Upload failed: $e"),backgroundColor: Colors.red,),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         width: 700,
//         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Header Row (Title + Close Icon)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Homepage",
//                   style: GoogleFonts.inter(
//                     fontSize: 36,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _isLoading ? null : () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                   splashRadius: 20,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             /// Image Label
//             Text(
//               "Image",
//               style: GoogleFonts.inter(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),

//             const SizedBox(height: 10),

//             /// File Picker Field — original big container UI
//             Container(
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   /// File Name
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         fileName,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.inter(
//                           fontSize: 15,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                     ),
//                   ),

//                   /// Choose File Button — same size as Upload button
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: CustomButton(
//                       label: "Choose file",
//                       fontWeight: FontWeight.w600,
//                       onPressed: _isLoading ? null : pickFile,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 40),

//             /// Upload Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: CustomButton(
//                 label: "Upload",
//                 fontWeight: FontWeight.w600,
//                 isLoading: _isLoading,
//                 onPressed: _isLoading ? null : uploadFile,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
