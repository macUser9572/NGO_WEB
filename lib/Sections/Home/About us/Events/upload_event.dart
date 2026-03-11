import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
              "Events",
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 30),

            // ── Content Card ──
            Expanded(
              child: Center(
                child: Container(
                  width: 800,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const _EventsUploadBody(),
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
          "Events",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const _EventsUploadBody(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED EVENTS UPLOAD BODY
// ─────────────────────────────────────────────
class _EventsUploadBody extends StatefulWidget {
  const _EventsUploadBody();

  @override
  State<_EventsUploadBody> createState() => _EventsUploadBodyState();
}

class _EventsUploadBodyState extends State<_EventsUploadBody> {
  final TextEditingController title1Controller = TextEditingController();
  final TextEditingController title2Controller = TextEditingController();
  final TextEditingController title3Controller = TextEditingController();
  final TextEditingController title4Controller = TextEditingController();
  final TextEditingController keyInfoController = TextEditingController();

  Uint8List? image1;
  Uint8List? image2;
  Uint8List? image3;
  Uint8List? image4;

  String? existingUrl1;
  String? existingUrl2;
  String? existingUrl3;
  String? existingUrl4;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, String>> _existingImages = [];
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingImages();
  }

  @override
  void dispose() {
    title1Controller.dispose();
    title2Controller.dispose();
    title3Controller.dispose();
    title4Controller.dispose();
    keyInfoController.dispose();
    super.dispose();
  }

  // ── Load Existing Images ──
  Future<void> _loadExistingImages() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("events")
          .doc("upload_events")
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List<Map<String, String>> images = [];

        title1Controller.text = data["title1"] ?? "";
        title2Controller.text = data["title2"] ?? "";
        title3Controller.text = data["title3"] ?? "";
        title4Controller.text = data["title4"] ?? "";
        keyInfoController.text = data["key_information"] ?? "";

        existingUrl1 = data["image1"]?.toString() ?? "";
        existingUrl2 = data["image2"]?.toString() ?? "";
        existingUrl3 = data["image3"]?.toString() ?? "";
        existingUrl4 = data["image4"]?.toString() ?? "";

        for (int i = 1; i <= 4; i++) {
          final url = data["image$i"]?.toString() ?? "";
          final title = data["title$i"]?.toString() ?? "Image $i";
          if (url.isNotEmpty) images.add({"url": url, "name": title});
        }

        setState(() => _existingImages = images);
      }
    } catch (e) {
      // silently fail
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  // ── Pick Image ──
  Future<Uint8List?> pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) return await file.readAsBytes();
    return null;
  }

  // ── Upload Image ──
  Future<String> uploadImage(Uint8List file, String name) async {
    final ref =
        FirebaseStorage.instance.ref().child("events").child("$name.jpg");
    await ref.putData(file);
    return await ref.getDownloadURL();
  }

  // ── Validate ──
  bool validateFields() {
    final bool img1Ok = image1 != null || (existingUrl1?.isNotEmpty ?? false);
    final bool img2Ok = image2 != null || (existingUrl2?.isNotEmpty ?? false);
    final bool img3Ok = image3 != null || (existingUrl3?.isNotEmpty ?? false);
    final bool img4Ok = image4 != null || (existingUrl4?.isNotEmpty ?? false);

    if (title1Controller.text.isEmpty ||
        title2Controller.text.isEmpty ||
        title3Controller.text.isEmpty ||
        title4Controller.text.isEmpty ||
        keyInfoController.text.isEmpty ||
        !img1Ok ||
        !img2Ok ||
        !img3Ok ||
        !img4Ok) {
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

  // ── Upload Event ──
  Future<void> uploadEvent() async {
    if (!validateFields()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final time = DateTime.now().millisecondsSinceEpoch;

      final String imageUrl1 = image1 != null
          ? await uploadImage(image1!, "image1_$time")
          : existingUrl1 ?? "";
      final String imageUrl2 = image2 != null
          ? await uploadImage(image2!, "image2_$time")
          : existingUrl2 ?? "";
      final String imageUrl3 = image3 != null
          ? await uploadImage(image3!, "image3_$time")
          : existingUrl3 ?? "";
      final String imageUrl4 = image4 != null
          ? await uploadImage(image4!, "image4_$time")
          : existingUrl4 ?? "";

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
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  // ── Title Field ──
  Widget buildTitleField(
      String label, TextEditingController controller) {
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

  // ── Image Upload Field ──
  Widget buildUploadField(
    Uint8List? image,
    String? existingUrl,
    Function(Uint8List) onSelected,
  ) {
    final bool hasExisting = existingUrl != null && existingUrl.isNotEmpty;
    final String statusText = image != null
        ? "New image selected ✓"
        : hasExisting
            ? "Uploaded"
            : "No file chosen";
    final Color statusColor = image != null
        ? Colors.green.shade700
        : hasExisting
            ? Colors.blue.shade700
            : Colors.grey.shade600;

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
                    statusText,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: statusColor),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomButton(
                  label: hasExisting ? "Change" : "Choose file",
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

  // ── Desktop Row (title + image side by side) ──
  Widget buildDesktopRow(
    String label,
    TextEditingController controller,
    Uint8List? image,
    String? existingUrl,
    Function(Uint8List) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          Expanded(child: buildTitleField(label, controller)),
          const SizedBox(width: 30),
          Expanded(child: buildUploadField(image, existingUrl, onSelected)),
        ],
      ),
    );
  }

  // ── Mobile Column (title + image stacked) ──
  Widget buildMobileRow(
    String label,
    TextEditingController controller,
    Uint8List? image,
    String? existingUrl,
    Function(Uint8List) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        children: [
          buildTitleField(label, controller),
          const SizedBox(height: 12),
          buildUploadField(image, existingUrl, onSelected),
        ],
      ),
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
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 16),

        // ── Image Rows ──
        isMobile
            ? buildMobileRow("Image 1 Title", title1Controller, image1,
                existingUrl1, (f) => setState(() => image1 = f))
            : buildDesktopRow("Image 1 Title", title1Controller, image1,
                existingUrl1, (f) => setState(() => image1 = f)),

        isMobile
            ? buildMobileRow("Image 2 Title", title2Controller, image2,
                existingUrl2, (f) => setState(() => image2 = f))
            : buildDesktopRow("Image 2 Title", title2Controller, image2,
                existingUrl2, (f) => setState(() => image2 = f)),

        isMobile
            ? buildMobileRow("Image 3 Title", title3Controller, image3,
                existingUrl3, (f) => setState(() => image3 = f))
            : buildDesktopRow("Image 3 Title", title3Controller, image3,
                existingUrl3, (f) => setState(() => image3 = f)),

        isMobile
            ? buildMobileRow("Image 4 Title", title4Controller, image4,
                existingUrl4, (f) => setState(() => image4 = f))
            : buildDesktopRow("Image 4 Title", title4Controller, image4,
                existingUrl4, (f) => setState(() => image4 = f)),

        const SizedBox(height: 20),

        buildTitleField("Key Information", keyInfoController),

        const SizedBox(height: 40),

        // ── Upload Button ──
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
    );
  }
}

// ─────────────────────────────────────────────
//  EVENTS UPLOAD PAGE (Dialog — kept for showDialog usage)
// ─────────────────────────────────────────────
class EventsUploadPage extends StatelessWidget {
  const EventsUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      child: Container(
        width: isMobile ? double.infinity : 800,
        height: isMobile ? double.infinity : 700,
        padding: EdgeInsets.all(isMobile ? 20 : 30),
        child: Column(
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Events",
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 26 : 40,
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

            // ── Scrollable Body ──
            const Expanded(
              child: SingleChildScrollView(
                child: _EventsUploadBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
