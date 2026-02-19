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
  String? _videoFileName;
  bool _isLoading = false;
  String _uploadStatus = "";
  final TextEditingController _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  // ===================== PICK VIDEO =====================
  Future<void> _pickVideo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _videoBytes = result.files.first.bytes;
          _videoFileName = result.files.first.name;
          _linkController.clear();
        });
        debugPrint("✅ Video picked: $_videoFileName");
      }
    } catch (e) {
      _showSnackBar("Failed to pick video: $e", isError: true);
    }
  }

  // ===================== UPLOAD VIDEO =====================
  Future<void> _uploadVideo() async {
    final String link = _linkController.text.trim();

    if (_videoBytes == null && link.isEmpty) {
      _showSnackBar("Please paste a link or choose a video file",
          isError: true);
      return;
    }

    // ✅ Set loading FIRST before anything else
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _uploadStatus = "Uploading...";
    });

    try {
      String videoUrl = "";

      if (_videoBytes != null) {
        // ── Upload file to Firebase Storage ──
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child("videos")
            .child("upload_video.mp4");

        final UploadTask task = ref.putData(
          _videoBytes!,
          SettableMetadata(contentType: "video/mp4"),
        );

        // ✅ Track progress
        task.snapshotEvents.listen((TaskSnapshot snap) {
          if (!mounted) return;
          final pct =
              (snap.bytesTransferred / snap.totalBytes * 100).toInt();
          setState(() => _uploadStatus = "Uploading video... $pct%");
        });

        final TaskSnapshot snapshot = await task;

        if (snapshot.state == TaskState.success) {
          videoUrl = await snapshot.ref.getDownloadURL();
          debugPrint("✅ Video URL: $videoUrl");
        } else {
          throw Exception("Upload failed");
        }
      } else {
        // ── Use pasted link directly ──
        videoUrl = link;
      }

      if (!mounted) return;
      setState(() => _uploadStatus = "Saving to database...");

      // ── Save to Firestore ──
      await FirebaseFirestore.instance
          .collection("videos")
          .doc("upload_video")
          .set({
        "video_url": videoUrl,
        "file_name": _videoFileName ?? "link",
        "updated_at": DateTime.now().toIso8601String(),
      });

      debugPrint("✅ Saved to Firestore!");
      _showSnackBar("Video Uploaded Successfully!");

      if (mounted) Navigator.pop(context);

    } on FirebaseException catch (e) {
      debugPrint("❌ Firebase [${e.code}]: ${e.message}");
      _showSnackBar("Firebase Error [${e.code}]: ${e.message}",
          isError: true);
    } catch (e) {
      debugPrint("❌ Error: $e");
      _showSnackBar("Error: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadStatus = "";
        });
      }
    }
  }

  // ===================== SNACKBAR =====================
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: isError ? 4 : 2),
    ));
  }

  // ===================== MAIN UI =====================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Video",
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ===== LABEL =====
            Text(
              "Video",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // ===== FILE INPUT =====
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _videoBytes != null
                        ? Text(
                            "✅  $_videoFileName",
                            style: GoogleFonts.inter(
                              color: Colors.green.shade700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : TextField(
                            controller: _linkController,
                            enabled: !_isLoading,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: "Paste video link here...",
                              hintStyle: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== UPLOAD STATUS =====
            if (_isLoading && _uploadStatus.isNotEmpty)
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _uploadStatus,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // ===== UPLOAD BUTTON =====
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                // ✅ Properly call async function
                onTap: _isLoading
                    ? null
                    : () {
                        _uploadVideo();
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? Colors.grey.shade400
                        : const Color(0xFF3E6B3E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Uploading...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "Upload",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
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
    );
  }
}
