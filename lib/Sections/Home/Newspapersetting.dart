import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Newspapersetting extends StatelessWidget {
  final String? docId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialImageUrl;

  const Newspapersetting({
    super.key,
    this.docId,
    this.initialTitle,
    this.initialDescription,
    this.initialImageUrl,
  });

  bool get isEditing => docId != null;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return NewspapersettingsDesktop(
              docId: docId,
              initialTitle: initialTitle,
              initialDescription: initialDescription,
              initialImageUrl: initialImageUrl,
            );
          default:
            return NewspapersettingsMobile(
              docId: docId,
              initialTitle: initialTitle,
              initialDescription: initialDescription,
              initialImageUrl: initialImageUrl,
            );
        }
      },
    );
  }
}

// ─── Shared State Mixin ──────────────────────────────────────────────────────

mixin NewsPostMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  XFile? pickedFile;
  Uint8List? imageBytes;
  bool isUploading = false;

  // For edit mode
  String? docId;
  String? existingImageUrl;

  bool get isEditing => docId != null;

  void initFields({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
  }) {
    docId = id;
    existingImageUrl = imageUrl;
    titleController.text = title ?? '';
    descriptionController.text = description ?? '';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      pickedFile = file;
      imageBytes = bytes;
    });
  }

  Future<void> saveNews(BuildContext context) async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    // For new post, image is required. For edit, image is optional (keep existing).
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    if (!isEditing && pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image.')),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      String imageUrl = existingImageUrl ?? '';

      // Upload new image if picked
      if (pickedFile != null) {
        final fileName =
            'news/${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);

        UploadTask uploadTask;
        if (kIsWeb) {
          uploadTask = storageRef.putData(
            imageBytes!,
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else {
          uploadTask = storageRef.putFile(File(pickedFile!.path));
        }

        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      if (isEditing) {
        // Update existing post
        await FirebaseFirestore.instance
            .collection('news_posts')
            .doc(docId)
            .update({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News updated successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new post
        await FirebaseFirestore.instance.collection('news_posts').add({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News posted successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving news: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Widget buildImagePicker({required double height, required String tapText}) {
    // Show picked image bytes first, then fall back to existing URL
    final hasPickedImage = imageBytes != null;
    final hasExistingImage =
        existingImageUrl != null && existingImageUrl!.isNotEmpty;

    return InkWell(
      onTap: pickImage,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasPickedImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Change image',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              )
            : hasExistingImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        existingImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _emptyImagePlaceholder(tapText),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Change image',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  )
                : _emptyImagePlaceholder(tapText),
      ),
    );
  }

  Widget _emptyImagePlaceholder(String tapText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, color: Colors.grey[400], size: 36),
        const SizedBox(height: 8),
        Text(
          tapText,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  InputDecoration fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AllColors.thirdColor.withOpacity(0.6)),
        ),
      );

  TextStyle labelStyle(double size) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AllColors.thirdColor,
      );
}

// ============================== Desktop LAYOUT ==============================

class NewspapersettingsDesktop extends StatefulWidget {
  final String? docId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialImageUrl;

  const NewspapersettingsDesktop({
    super.key,
    this.docId,
    this.initialTitle,
    this.initialDescription,
    this.initialImageUrl,
  });

  @override
  State<NewspapersettingsDesktop> createState() =>
      _NewspapersettingsDesktopState();
}

class _NewspapersettingsDesktopState extends State<NewspapersettingsDesktop>
    with NewsPostMixin {
  @override
  void initState() {
    super.initState();
    initFields(
      id: widget.docId,
      title: widget.initialTitle,
      description: widget.initialDescription,
      imageUrl: widget.initialImageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 600 ? 550 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AllColors.secondaryColor,
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit News' : 'Post News',
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AllColors.thirdColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upload Photo
            Text('Upload photo', style: labelStyle(16)),
            const SizedBox(height: 8),
            buildImagePicker(
                height: 140,
                tapText: 'Drag and drop or choose an image'),
            const SizedBox(height: 20),

            // Title
            Text('Title', style: labelStyle(16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              decoration: fieldDecoration('Post title'),
            ),
            const SizedBox(height: 20),

            // Description
            Text('Description', style: labelStyle(16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: fieldDecoration(
                  'Enter a brief description about the post'),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: 'Cancel',
                  onPressed:
                      isUploading ? null : () => Navigator.pop(context),
                  outlined: true,
                ),
                const SizedBox(width: 12),
                isUploading
                    ? const SizedBox(
                        width: 100,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : CustomButton(
                        label: isEditing ? 'Save Changes' : 'Post News',
                        onPressed: () => saveNews(context),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================== MOBILE LAYOUT ==============================

class NewspapersettingsMobile extends StatefulWidget {
  final String? docId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialImageUrl;

  const NewspapersettingsMobile({
    super.key,
    this.docId,
    this.initialTitle,
    this.initialDescription,
    this.initialImageUrl,
  });

  @override
  State<NewspapersettingsMobile> createState() =>
      _NewspapersettingsMobileState();
}

class _NewspapersettingsMobileState extends State<NewspapersettingsMobile>
    with NewsPostMixin {
  @override
  void initState() {
    super.initState();
    initFields(
      id: widget.docId,
      title: widget.initialTitle,
      description: widget.initialDescription,
      imageUrl: widget.initialImageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit News' : 'Post News',
          style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(foregroundColor: Colors.grey[600]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload photo', style: labelStyle(14)),
            const SizedBox(height: 8),
            buildImagePicker(
                height: 180, tapText: 'Tap to choose an image'),
            const SizedBox(height: 24),

            Text('Title', style: labelStyle(14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              decoration: fieldDecoration('Post title'),
            ),
            const SizedBox(height: 24),

            Text('Description', style: labelStyle(14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: descriptionController,
              maxLines: 5,
              decoration: fieldDecoration(
                  'Enter a brief description about the post'),
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Cancel',
                    onPressed:
                        isUploading ? null : () => Navigator.pop(context),
                    outlined: true,
                    height: 48,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isUploading
                      ? const SizedBox(
                          height: 48,
                          child: Center(child: CircularProgressIndicator()))
                      : CustomButton(
                          label: isEditing ? 'Save Changes' : 'Post News',
                          onPressed: () => saveNews(context),
                          height: 48,
                          fontSize: 16,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}