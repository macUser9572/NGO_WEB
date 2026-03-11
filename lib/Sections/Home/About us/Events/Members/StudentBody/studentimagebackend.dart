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
              "Student Body",
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
                  width: 500,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const _StudentImageBody(),
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
          "Student Body",
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
          child: const _StudentImageBody(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED STUDENT IMAGE BODY
// ─────────────────────────────────────────────
class _StudentImageBody extends StatefulWidget {
  const _StudentImageBody();

  @override
  State<_StudentImageBody> createState() => _StudentImageBodyState();
}

class _StudentImageBodyState extends State<_StudentImageBody> {
  final int _requiredCount = 4;

  final List<Uint8List?> _imageBytes = [null, null, null, null];
  final List<String> _imageFileNames = [
    "No file chosen",
    "No file chosen",
    "No file chosen",
    "No file chosen",
  ];

  bool _isLoading = false;

  List<Map<String, String>> _existingImages = [];
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingImages();
  }

  // ── Load Existing Images ──
  Future<void> _loadExistingImages() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("student_body")
          .doc("images")
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List<Map<String, String>> images = [];
        int i = 1;
        while (data.containsKey("image_${i}_url")) {
          images.add({
            "url": data["image_${i}_url"] ?? "",
            "name": data["image_${i}_name"] ?? "Image $i",
          });
          i++;
        }
        setState(() => _existingImages = images);
      }
    } catch (e) {
      // silently fail
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  // ── Add More ──
  void _addMoreRow() {
    setState(() {
      _imageBytes.add(null);
      _imageFileNames.add("No file chosen");
    });
  }

  // ── Pick Image ──
  Future<void> _pickImage(int index) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _imageBytes[index] = file.bytes;
          _imageFileNames[index] = file.name;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to pick image: $e", isError: true);
    }
  }

  // ── Upload Images ──
  Future<void> _uploadImages() async {
    for (int i = 0; i < _requiredCount; i++) {
      if (_imageBytes[i] == null) {
        _showSnackBar(
          "Please choose all required images (Image ${i + 1})",
          isError: true,
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {};
      final int totalCount = _imageBytes.length;

      for (int i = 0; i < totalCount; i++) {
        if (_imageBytes[i] == null) continue;

        final String fileName = "student_image_${i + 1}.jpg";
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child("student_body")
            .child(fileName);

        final UploadTask task = ref.putData(
          _imageBytes[i]!,
          SettableMetadata(contentType: "image/jpeg"),
        );

        final TaskSnapshot snapshot = await task;

        if (snapshot.state != TaskState.success) {
          throw Exception("Upload failed for image ${i + 1}");
        }

        final String url = await snapshot.ref.getDownloadURL();
        data["image_${i + 1}_url"] = url;
        data["image_${i + 1}_name"] = _imageFileNames[i];
      }

      data["updated_at"] = DateTime.now().toIso8601String();

      await FirebaseFirestore.instance
          .collection("student_body")
          .doc("images")
          .set(data);

      if (!mounted) return;
      _showSnackBar("✅ Images uploaded successfully!");
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

  // ── Image Picker Row ──
  Widget _buildImagePicker(int index) {
    final bool isRequired = index < _requiredCount;
    final bool isPicked = _imageBytes[index] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Image",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                "*",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    _imageFileNames[index],
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isPicked
                          ? Colors.green.shade700
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomButton(
                  label: "Choose file",
                  fontWeight: FontWeight.w600,
                  onPressed: _isLoading ? null : () => _pickImage(index),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Existing Images Preview ──
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
            style:
                GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
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
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
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
                          fontSize: 10, color: Colors.grey.shade600),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Existing Images Preview ──
        _buildExistingImagesSection(),

        // ── Upload New Images Label ──
        Text(
          "Upload New Images",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // ── Image Pickers ──
        ...List.generate(
          _imageBytes.length,
          (index) => _buildImagePicker(index),
        ),

        // ── Add More Button ──
        GestureDetector(
          onTap: _isLoading ? null : _addMoreRow,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  "Add More",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Upload Button ──
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            label: "Upload",
            fontWeight: FontWeight.w600,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _uploadImages,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  STUDENTIMAGEBACKEND (Dialog — kept for showDialog usage)
// ─────────────────────────────────────────────
class Studentimagebackend extends StatelessWidget {
  const Studentimagebackend({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isMobile ? double.infinity : 500,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 36,
          vertical: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Student body",
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 22 : 26,
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
            const SizedBox(height: 20),

            // ── Scrollable Body ──
            const Expanded(
              child: SingleChildScrollView(
                child: _StudentImageBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
