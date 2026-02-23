import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // 1. Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('homepage_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = await storageRef.putData(
        fileBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // 2. Get the download URL
      final downloadURL = await uploadTask.ref.getDownloadURL();

      // 3. Save URL to Firestore
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
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 700,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 Header Row (Title + Close Icon)
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

            const SizedBox(height: 30),

            /// 🔹 Image Label
            Text(
              "Image",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            /// 🔹 File Picker Field
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [

                  /// File Name
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),

                  /// Choose File Button
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: _isLoading ? null : pickFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AllColors.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Choose file",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AllColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// 🔹 Upload Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F6B3F),
                  fixedSize: const Size(160, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : uploadFile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Upload",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}