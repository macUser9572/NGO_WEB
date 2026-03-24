import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class Adimagepage extends StatelessWidget {
  const Adimagepage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ResponsiveBuilder(
        builder: (context, sizing) {
          if (sizing.deviceScreenType == DeviceScreenType.desktop) {
            return const _DesktopLayout();
          } else {
            return const _MobileLayout();
          }
        },
      ),
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
    return Container(
      width: 700,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ad Pop Up",
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
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
          const _UploadBody(),
        ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ad Pop Up",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
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
          SingleChildScrollView(child: const _UploadBody()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED UPLOAD BODY
// ─────────────────────────────────────────────
class _UploadBody extends StatefulWidget {
  const _UploadBody();

  @override
  State<_UploadBody> createState() => _UploadBodyState();
}

class _UploadBodyState extends State<_UploadBody> {
  String fileName = "No file chosen";
  Uint8List? fileBytes;
  bool _isLoading = false;

  String _existingImageUrl = "";
  String _existingFileName = "";
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingImage();
  }

  // ── Load Existing Image ──
  Future<void> _loadExistingImage() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('homepage')
          .doc('ad_banner')
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

  // ── Pick File ──
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

  // ── Save Ad ──
  // • No image picked + no existing ad  → just close (nothing to do).
  // • No image picked + existing ad     → confirm, then delete doc (no ads shown).
  // • Image picked                      → upload and save as the active ad.
  Future<void> _saveAd() async {
    // ── Case 1: No new image picked ──
    if (fileBytes == null) {
      // Nothing running either — just close
      if (_existingImageUrl.isEmpty) {
        Navigator.pop(context);
        return;
      }

      // An ad is currently running — ask before removing it
      final bool? confirm = await showDialog<bool>(
        context: context,
        useRootNavigator: true, // ← renders above the parent dialog
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            "Remove Ad?",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "No image is selected. Saving now will remove the existing ad and the popup will not be shown to users. Continue?",
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                "Yes, remove ad",
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      // final bool? confirm = await showDialog<bool>(
      //   context: context,
      //   builder: (ctx) => AlertDialog(
      //     title: Text(
      //       "Remove Ad?",
      //       style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      //     ),
      //     content: Text(
      //       "No image is selected. Saving now will remove the existing ad and the popup will not be shown to users. Continue?",
      //       style: GoogleFonts.inter(fontSize: 14),
      //     ),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.pop(ctx, false),
      //         child: Text(
      //           "Cancel",
      //           style: GoogleFonts.inter(color: Colors.grey.shade600),
      //         ),
      //       ),
      //       TextButton(
      //         onPressed: () => Navigator.pop(ctx, true),
      //         child: Text(
      //           "Yes, remove ad",
      //           style: GoogleFonts.inter(color: Colors.red),
      //         ),
      //       ),
      //     ],
      //   ),
      // );

      if (confirm != true) return;

      try {
        await FirebaseFirestore.instance
            .collection('homepage')
            .doc('ad_banner')
            .delete();

        if (mounted) {
          _showSnackBar("✅ Ad removed. No popup will be shown.");
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        _showSnackBar("Failed to remove ad: $e", isError: true);
      }
      return;
    }

    // ── Case 2: New image selected — upload it ──
    setState(() => _isLoading = true);

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'ad_popup/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      final uploadTask = await storageRef.putData(
        fileBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadURL = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('homepage')
          .doc('ad_banner')
          .set({
            'imageUrl': downloadURL,
            'fileName': fileName,
            'uploadedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        _showSnackBar("✅ Ad image uploaded successfully!");
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("Upload failed: $e", isError: true);
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
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 2),
      ),
    );
  }

  // ── Existing Image Section ──
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
            "No ads currently running. Upload an image below to show an ad.",
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Currently Running Ad",
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
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
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
                    : "ad_banner",
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
    // Button label reflects what will actually happen when tapped
    final String buttonLabel;
    if (fileBytes != null) {
      buttonLabel = "Upload";
    } else if (_existingImageUrl.isNotEmpty) {
      buttonLabel = "Remove Ad";
    } else {
      buttonLabel = "Close";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Existing image preview ──
        _buildExistingImageSection(),

        // ── Hint banner ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            " Choose an image to run an ad. Leave empty and save to disable the ad popup entirely.",
            style: GoogleFonts.inter(fontSize: 12, color: Colors.blue.shade700),
          ),
        ),

        // ── Label ──
        Text(
          "Image",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),

        // ── File picker row ──
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

        // ── Action button ──
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            label: buttonLabel,
            fontWeight: FontWeight.w600,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _saveAd,
          ),
        ),
      ],
    );
  }
} // import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
// import 'package:bangalore_chakma_society/constraints/all_colors.dart';
// import 'package:responsive_builder/responsive_builder.dart';

// // ─────────────────────────────────────────────
// //  RESPONSIVE ENTRY POINT
// // ─────────────────────────────────────────────
// class Adimagepage extends StatelessWidget {
//   const Adimagepage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final bool isMobile = MediaQuery.of(context).size.width < 600;

//     return Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 40,
//         vertical: isMobile ? 24 : 40,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ResponsiveBuilder(
//         builder: (context, sizing) {
//           if (sizing.deviceScreenType == DeviceScreenType.desktop) {
//             return const _DesktopLayout();
//           } else {
//             return const _MobileLayout();
//           }
//         },
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  DESKTOP LAYOUT
// // ─────────────────────────────────────────────
// class _DesktopLayout extends StatelessWidget {
//   const _DesktopLayout();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 700,
//       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header ──
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Ad Pop Up",
//                 style: GoogleFonts.inter(
//                   fontSize: 36,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close),
//                 splashRadius: 20,
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // ── Upload Body ──
//           const _UploadBody(),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  MOBILE LAYOUT
// // ─────────────────────────────────────────────
// class _MobileLayout extends StatelessWidget {
//   const _MobileLayout();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header ──
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Ad Pop Up",
//                 style: GoogleFonts.inter(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close),
//                 splashRadius: 20,
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // ── Upload Body (scrollable on mobile) ──
//           SingleChildScrollView(child: const _UploadBody()),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SHARED UPLOAD BODY
// // ─────────────────────────────────────────────
// class _UploadBody extends StatefulWidget {
//   const _UploadBody();

//   @override
//   State<_UploadBody> createState() => _UploadBodyState();
// }

// class _UploadBodyState extends State<_UploadBody> {
//   String fileName = "No file chosen";
//   Uint8List? fileBytes;
//   bool _isLoading = false;

//   String _existingImageUrl = "";
//   String _existingFileName = "";
//   bool _loadingExisting = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadExistingImage();
//   }

//   Future<void> _loadExistingImage() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('homepage')
//           .doc('ad_banner')
//           .get();

//       if (doc.exists) {
//         final data = doc.data() as Map<String, dynamic>;
//         setState(() {
//           _existingImageUrl = data["imageUrl"]?.toString() ?? "";
//           _existingFileName = data["fileName"]?.toString() ?? "";
//         });
//       }
//     } catch (e) {
//       // silently fail
//     } finally {
//       if (mounted) setState(() => _loadingExisting = false);
//     }
//   }

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
//       final storageRef = FirebaseStorage.instance.ref().child(
//         'ad_popup/${DateTime.now().millisecondsSinceEpoch}_$fileName',
//       );

//       final uploadTask = await storageRef.putData(
//         fileBytes!,
//         SettableMetadata(contentType: 'image/jpeg'),
//       );

//       final downloadURL = await uploadTask.ref.getDownloadURL();

//       await FirebaseFirestore.instance
//           .collection('homepage')
//           .doc('ad_banner')
//           .set({
//             'imageUrl': downloadURL,
//             'fileName': fileName,
//             'uploadedAt': FieldValue.serverTimestamp(),
//           });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Ad image uploaded successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Upload failed: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildExistingImageSection() {
//     if (_loadingExisting) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 12),
//         child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//       );
//     }

//     if (_existingImageUrl.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 16),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             border: Border.all(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             "No existing ad image uploaded yet.",
//             style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Currently Uploaded Image",
//           style: GoogleFonts.inter(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 _existingImageUrl,
//                 width: 70,
//                 height: 70,
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, progress) {
//                   if (progress == null) return child;
//                   return Container(
//                     width: 70,
//                     height: 70,
//                     color: Colors.grey.shade200,
//                     child: const Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   );
//                 },
//                 errorBuilder: (_, __, ___) => Container(
//                   width: 70,
//                   height: 70,
//                   color: Colors.grey.shade200,
//                   child: const Icon(
//                     Icons.broken_image_outlined,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 fileBytes != null
//                     ? "New image selected ✓"
//                     : _existingFileName.isNotEmpty
//                     ? _existingFileName
//                     : "ad_banner",
//                 style: GoogleFonts.inter(
//                   fontSize: 13,
//                   color: fileBytes != null
//                       ? Colors.green.shade700
//                       : Colors.grey.shade600,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         const Divider(color: Colors.grey),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Existing image ──
//         _buildExistingImageSection(),

//         // ── Label ──
//         Text(
//           "Image",
//           style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 10),

//         // ── File picker row ──
//         Container(
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     fileName,
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.inter(
//                       fontSize: 15,
//                       color: fileBytes != null
//                           ? Colors.green.shade700
//                           : Colors.grey.shade700,
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: CustomButton(
//                   label: "Choose file",
//                   fontWeight: FontWeight.w600,
//                   onPressed: _isLoading ? null : pickFile,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 40),

//         // ── Upload button ──
//         Align(
//           alignment: Alignment.centerRight,
//           child: CustomButton(
//             label: "Upload",
//             fontWeight: FontWeight.w600,
//             isLoading: _isLoading,
//             onPressed: _isLoading ? null : uploadFile,
//           ),
//         ),
//       ],
//     );
//   }
// }
