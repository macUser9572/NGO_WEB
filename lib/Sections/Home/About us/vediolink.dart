import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class Videolink extends StatefulWidget {
  const Videolink({super.key});

  @override
  State<Videolink> createState() => _VideolinkState();
}

class _VideolinkState extends State<Videolink> {
  Uint8List? _videoBytes;
  String _videoFileName = "No file chosen";
  bool _isLoading = false;

  // ===================== PICK VIDEO =====================
  Future<void> _pickVideo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _videoBytes = file.bytes;
          _videoFileName = file.name;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to pick video: $e", isError: true);
    }
  }

  // ===================== UPLOAD VIDEO =====================
  Future<void> _uploadVideo() async {
    if (_videoBytes == null) {
      _showSnackBar("Please choose a video file first", isError: true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // ── Upload to Firebase Storage ──
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child("videos")
          .child("upload_video.mp4");

      final UploadTask task = ref.putData(
        _videoBytes!,
        SettableMetadata(contentType: "video/mp4"),
      );

      final TaskSnapshot snapshot = await task;

      if (snapshot.state != TaskState.success) {
        throw Exception("Upload did not complete successfully.");
      }

      final String videoUrl = await snapshot.ref.getDownloadURL();


      // ── Save URL + metadata to Firestore ──
      await FirebaseFirestore.instance
          .collection("videos")
          .doc("upload_video")
          .set({
        "video_url": videoUrl,
        "file_name": _videoFileName,
        "updated_at": DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      _showSnackBar("✅ Video uploaded successfully!");

      // Small delay so user sees the success message before dialog closes
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (e) {
      _showSnackBar(
        "Firebase Error [${e.code}]: ${e.message ?? 'Unknown error'}",
        isError: true,
      );
    } catch (e) {
      _showSnackBar("Unexpected error: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===================== SNACKBAR =====================
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 2),
      ),
    );
  }

  // ===================== BUILD =====================
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Upload Video",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
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

            // ── Label ──
            Text(
              "Video File",
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // ── File Picker Row ──
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // File name display
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _videoFileName,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _videoBytes != null
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                  // Choose file button
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: _isLoading ? null : _pickVideo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AllColors.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Choose file",
                          style: GoogleFonts.inter(
                            fontSize: 14,
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

            const SizedBox(height: 16),

            // // ── Progress Spinner ──
            //   const Row(
            //     children: [
            //       SizedBox(
            //         width: 14,
            //         height: 14,
            //         child: CircularProgressIndicator(
            //           strokeWidth: 2,
            //           color: Colors.grey,
            //         ),
            //       ),
            //     ],
            //   ),

            const SizedBox(height: 40),

            // ── Upload Button ──
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F6B3F),
                  fixedSize: const Size(160, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _uploadVideo,
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