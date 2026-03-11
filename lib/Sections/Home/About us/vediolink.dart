import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class ContentUploadPageTab extends StatelessWidget {
  const ContentUploadPageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _DesktopLayout();
        } else {
          return const _MobileLayout();
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
//  DESKTOP LAYOUT
// ─────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Back Button ──
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

            // ── Title ──
            Text(
              "Upload Video",
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),

            // ── Content Card ──
            Expanded(
              child: Center(
                child: Container(
                  width: 700,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const _VideoBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE LAYOUT
// ─────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Upload Video",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const _VideoBody(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED VIDEO BODY
// ─────────────────────────────────────────────
class _VideoBody extends StatefulWidget {
  const _VideoBody();

  @override
  State<_VideoBody> createState() => _VideoBodyState();
}

class _VideoBodyState extends State<_VideoBody> {
  Uint8List? _videoBytes;
  String _videoFileName = "No file chosen";
  bool _isLoading = false;
  final TextEditingController _linkController = TextEditingController();

  // ── Existing data from Firestore ──
  String _existingVideoUrl = "";
  String _existingFileName = "";
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingVideo();
  }

  Future<void> _loadExistingVideo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("videos")
          .doc("upload_video")
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _existingVideoUrl = data["video_url"]?.toString() ?? "";
          _existingFileName = data["file_name"]?.toString() ?? "";
        });
      }
    } catch (e) {
      // silently fail
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  // ── Pick Video ──
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

  // ── Upload Video ──
  Future<void> _uploadVideo() async {
    final String pastedLink = _linkController.text.trim();
    final bool hasFile = _videoBytes != null;
    final bool hasLink = pastedLink.isNotEmpty;

    if (!hasFile && !hasLink) {
      _showSnackBar("Please choose a video file or paste a link",
          isError: true);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (hasFile) {
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

        await FirebaseFirestore.instance
            .collection("videos")
            .doc("upload_video")
            .set({
          "video_url": videoUrl,
          "file_name": _videoFileName,
          "updated_at": DateTime.now().toIso8601String(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection("videos")
            .doc("upload_video")
            .set({
          "video_url": pastedLink,
          "file_name": "External Link",
          "updated_at": DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;
      _showSnackBar("✅ Video uploaded successfully!");
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Snackbar ──
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 2),
      ),
    );
  }

  // ── Existing Video Preview ──
  Widget _buildExistingVideoSection() {
    if (_loadingExisting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_existingVideoUrl.isEmpty) {
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
            "No existing video uploaded yet.",
            style:
                GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    final bool isExternalLink = _existingFileName == "External Link";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Currently Uploaded Video",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isExternalLink
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExternalLink
                      ? Icons.link
                      : Icons.videocam_outlined,
                  color: isExternalLink
                      ? Colors.blue.shade400
                      : Colors.orange.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _existingFileName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _existingVideoUrl,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.grey),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Existing Video Preview ──
        _buildExistingVideoSection(),

        // ── File Picker ──
        Text(
          "Video File",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
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
                    _videoFileName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _videoBytes != null
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
                  onPressed: _isLoading ? null : _pickVideo,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── OR Divider ──
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "OR",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),

        const SizedBox(height: 20),

        // ── Paste Link ──
        Text(
          "Paste Video Link",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.link, color: Colors.grey.shade500, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _linkController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "https://www.youtube.com/watch?v=...",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
            onPressed: _isLoading ? null : _uploadVideo,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  VIDEOLINK (Dialog — kept for showDialog usage)
// ─────────────────────────────────────────────
class Videolink extends StatelessWidget {
  const Videolink({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isMobile ? double.infinity : 700,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: isMobile ? 20 : 30,
        ),
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
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _VideoBody(),
          ],
        ),
      ),
    );
  }
}
