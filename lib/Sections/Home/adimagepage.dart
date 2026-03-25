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
//  MODEL: Single image slot (1 of 4)
// ─────────────────────────────────────────────
class _ImageSlot {
  final int index; // 1-based
  String pickedFileName;
  Uint8List? pickedBytes;
  String savedUrl;
  String savedFileName;

  _ImageSlot({
    required this.index,
    this.pickedFileName = '',
    this.pickedBytes,
    this.savedUrl = '',
    this.savedFileName = '',
  });

  bool get hasPicked => pickedBytes != null;
  bool get hasSaved => savedUrl.isNotEmpty;
  bool get hasContent => hasPicked || hasSaved;
}

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
class Adimagepage extends StatelessWidget {
  const Adimagepage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 20 : 40,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ResponsiveBuilder(
        builder: (context, sizing) =>
            sizing.deviceScreenType == DeviceScreenType.desktop
            ? const _DesktopLayout()
            : const _MobileLayout(),
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
      width: 760,
      constraints: const BoxConstraints(maxHeight: 720),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onClose: () => Navigator.pop(context), fontSize: 34),
          const SizedBox(height: 24),
          const Expanded(child: SingleChildScrollView(child: _UploadBody())),
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onClose: () => Navigator.pop(context), fontSize: 24),
          const SizedBox(height: 20),
          const Expanded(child: SingleChildScrollView(child: _UploadBody())),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final double fontSize;
  const _Header({required this.onClose, required this.fontSize});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Announcement',
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.close),
        splashRadius: 20,
      ),
    ],
  );
}

// ─────────────────────────────────────────────
//  UPLOAD BODY (stateful)
// ─────────────────────────────────────────────
class _UploadBody extends StatefulWidget {
  const _UploadBody();
  @override
  State<_UploadBody> createState() => _UploadBodyState();
}

class _UploadBodyState extends State<_UploadBody> {
  bool _isLoading = false;
  bool _loadingExisting = true;

  static const String _col = 'homepage';
  static const String _doc = 'ad_banner';

  final List<_ImageSlot> _slots = List.generate(
    4,
    (i) => _ImageSlot(index: i + 1),
  );

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  // ── Load saved images array ────────────────
  Future<void> _loadExisting() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_col)
          .doc(_doc)
          .get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final List raw = data['images'] as List? ?? [];
        for (int i = 0; i < raw.length && i < 4; i++) {
          final m = raw[i] as Map<String, dynamic>;
          _slots[i].savedUrl = m['imageUrl']?.toString() ?? '';
          _slots[i].savedFileName = m['fileName']?.toString() ?? '';
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  // ── Pick image ─────────────────────────────
  Future<void> _pick(_ImageSlot slot) async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (r != null && r.files.single.bytes != null) {
      setState(() {
        slot.pickedFileName = r.files.single.name;
        slot.pickedBytes = r.files.single.bytes;
      });
    }
  }

  void _clearPick(_ImageSlot slot) => setState(() {
    slot.pickedFileName = '';
    slot.pickedBytes = null;
  });

  void _removeSaved(_ImageSlot slot) => setState(() {
    slot.savedUrl = '';
    slot.savedFileName = '';
  });

  // ── Save ───────────────────────────────────
  Future<void> _save() async {
    final anyContent = _slots.any((s) => s.hasContent);

    if (!anyContent) {
      final ok = await _confirm(
        title: 'Remove all ads?',
        body:
            'No images selected. Saving will remove all ads and the popup will not show.',
        action: 'Yes, remove all',
      );
      if (ok != true) return;
    }

    setState(() => _isLoading = true);
    try {
      final List<Map<String, dynamic>> imageList = [];

      for (final slot in _slots) {
        if (slot.hasPicked) {
          final ref = FirebaseStorage.instance.ref().child(
            'ad_popup/slot${slot.index}_${DateTime.now().millisecondsSinceEpoch}_${slot.pickedFileName}',
          );
          final task = await ref.putData(
            slot.pickedBytes!,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final url = await task.ref.getDownloadURL();
          imageList.add({
            'slotIndex': slot.index,
            'imageUrl': url,
            'fileName': slot.pickedFileName,
          });
        } else if (slot.hasSaved) {
          imageList.add({
            'slotIndex': slot.index,
            'imageUrl': slot.savedUrl,
            'fileName': slot.savedFileName,
          });
        }
      }

      if (imageList.isEmpty) {
        await FirebaseFirestore.instance.collection(_col).doc(_doc).delete();
        _snack('✅ All ads removed.');
      } else {
        await FirebaseFirestore.instance.collection(_col).doc(_doc).set({
          'images': imageList,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _snack('✅ Ads saved successfully!');
      }

      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Save failed: $e', err: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String action,
  }) => showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: Colors.black45,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text(body, style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: Colors.grey.shade600),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(action, style: GoogleFonts.inter(color: Colors.red)),
        ),
      ],
    ),
  );

  void _snack(String msg, {bool err = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: err ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: err ? 5 : 2),
      ),
    );
  }

  // ── Chip ───────────────────────────────────
  Widget _chip(String label, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    ),
  );

  // ── Slot row ───────────────────────────────
  Widget _buildSlot(_ImageSlot slot) {
    final Widget thumb = _loadingExisting
        ? _thumbShell(child: const CircularProgressIndicator(strokeWidth: 2))
        : slot.hasPicked
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              slot.pickedBytes!,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          )
        : slot.hasSaved
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              slot.savedUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, p) => p == null
                  ? child
                  : _thumbShell(
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
              errorBuilder: (_, __, ___) => _thumbShell(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          )
        : _thumbShell(
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey.shade400,
              size: 22,
            ),
          );

    final Widget statusChip = slot.hasPicked
        ? _chip('New', Colors.green.shade700, Colors.green.shade50)
        : slot.hasSaved
        ? _chip('Running', Colors.blue.shade700, Colors.blue.shade50)
        : _chip('Empty', Colors.grey.shade500, Colors.grey.shade100);

    final Color borderColor = slot.hasPicked
        ? Colors.green.shade300
        : slot.hasSaved
        ? Colors.blue.shade200
        : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Index badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${slot.index}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Thumbnail
          thumb,
          const SizedBox(width: 12),

          // Name + chip
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.hasPicked
                      ? slot.pickedFileName
                      : slot.hasSaved
                      ? (slot.savedFileName.isNotEmpty
                            ? slot.savedFileName
                            : 'ad_image_${slot.index}')
                      : slot.index == 1
                      ? 'Primary slide'
                      : 'Optional slide ${slot.index}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: slot.hasContent
                        ? Colors.black87
                        : Colors.grey.shade400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                statusChip,
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (slot.hasSaved && !slot.hasPicked)
                IconButton(
                  onPressed: _isLoading ? null : () => _removeSaved(slot),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  tooltip: 'Remove this ad',
                  splashRadius: 18,
                ),
              if (slot.hasPicked)
                IconButton(
                  onPressed: _isLoading ? null : () => _clearPick(slot),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  tooltip: 'Clear selection',
                  splashRadius: 18,
                ),
              CustomButton(
                label: slot.hasContent ? 'Replace' : 'Browse',
                fontWeight: FontWeight.w600,
                onPressed: _isLoading ? null : () => _pick(slot),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _thumbShell({required Widget child}) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Center(child: child),
  );

  int get _activeCount => _slots.where((s) => s.hasContent).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Upload up to 4 images. They will be shown as a slideshow '
                  'in the ad popup (auto-play + manual arrows). Slide order '
                  'follows slot order 1 → 4. All slots are optional.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Count
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '$_activeCount / 4 slide${_activeCount == 1 ? '' : 's'} configured',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _activeCount > 0 ? Colors.black87 : Colors.grey.shade500,
            ),
          ),
        ),

        // Slots
        ..._slots.map(_buildSlot),

        const SizedBox(height: 16),

        // Save
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            label: 'Save Ads',
            fontWeight: FontWeight.w700,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _save,
          ),
        ),
      ],
    );
  }
}
// import 'dart:typed_data';
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
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Announcement",
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
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Announcement",
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

//   // ── Load Existing Image ──
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

//   // ── Pick File ──
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

//   Future<void> _saveAd() async {
//     // ── Case 1: No new image picked ──
//     if (fileBytes == null) {
//       // Nothing running either — just close
//       if (_existingImageUrl.isEmpty) {
//         Navigator.pop(context);
//         return;
//       }

//       // An ad is currently running — ask before removing it
//       final bool? confirm = await showDialog<bool>(
//         context: context,
//         useRootNavigator: true, // ← renders above the parent dialog
//         barrierColor: Colors.black.withOpacity(0.4),
//         builder: (ctx) => AlertDialog(
//           backgroundColor: Colors.white,
//           surfaceTintColor: Colors.transparent,
//           title: Text(
//             "Remove Ad?",
//             style: GoogleFonts.inter(fontWeight: FontWeight.w600),
//           ),
//           content: Text(
//             "No image is selected. Saving now will remove the existing ad and the popup will not be shown to users. Continue?",
//             style: GoogleFonts.inter(fontSize: 14),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: Text(
//                 "Cancel",
//                 style: GoogleFonts.inter(color: Colors.grey.shade600),
//               ),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, true),
//               child: Text(
//                 "Yes, remove ad",
//                 style: GoogleFonts.inter(color: Colors.red),
//               ),
//             ),
//           ],
//         ),
//       );

//       if (confirm != true) return;

//       try {
//         await FirebaseFirestore.instance
//             .collection('homepage')
//             .doc('ad_banner')
//             .delete();

//         if (mounted) {
//           _showSnackBar("✅ Ad removed. No popup will be shown.");
//           await Future.delayed(const Duration(milliseconds: 800));
//           if (mounted) Navigator.pop(context);
//         }
//       } catch (e) {
//         _showSnackBar("Failed to remove ad: $e", isError: true);
//       }
//       return;
//     }

//     // ── Case 2: New image selected — upload it ──
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
//         _showSnackBar("✅ Ad image uploaded successfully!");
//         await Future.delayed(const Duration(milliseconds: 800));
//         if (mounted) Navigator.pop(context);
//       }
//     } catch (e) {
//       _showSnackBar("Upload failed: $e", isError: true);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   // ── Snackbar ──
//   void _showSnackBar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: isError ? 5 : 2),
//       ),
//     );
//   }

//   // ── Existing Image Section ──
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
//             "No ads currently running. Upload an image below to show an ad.",
//             style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
//           ),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Currently Running Ad",
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
//     // Button label reflects what will actually happen when tapped
//     final String buttonLabel;
//     if (fileBytes != null) {
//       buttonLabel = "Upload";
//     } else if (_existingImageUrl.isNotEmpty) {
//       buttonLabel = "Remove Ad";
//     } else {
//       buttonLabel = "Close";
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Existing image preview ──
//         _buildExistingImageSection(),

//         // ── Hint banner ──
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           margin: const EdgeInsets.only(bottom: 16),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             border: Border.all(color: Colors.blue.shade100),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             " Choose an image to run an ad. Leave empty and save to disable the ad popup entirely.",
//             style: GoogleFonts.inter(fontSize: 12, color: Colors.blue.shade700),
//           ),
//         ),

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

//         // ── Action button ──
//         Align(
//           alignment: Alignment.centerRight,
//           child: CustomButton(
//             label: buttonLabel,
//             fontWeight: FontWeight.w600,
//             isLoading: _isLoading,
//             onPressed: _isLoading ? null : _saveAd,
//           ),
//         ),
//       ],
//     );
//   }
// }
