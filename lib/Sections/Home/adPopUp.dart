import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdPopup {
  AdPopup._();

  static const String _prefKey = 'bcs_ad_shown';

  static Future<void> showIfFirstVisit(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeen = prefs.getBool(_prefKey) ?? false;

    if (!alreadySeen && context.mounted) {
      await prefs.setBool(_prefKey, true);
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.55),
          builder: (_) => const _AdPopupDialog(),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────
//  DIALOG SHELL — routes desktop vs mobile
// ─────────────────────────────────────────────
class _AdPopupDialog extends StatelessWidget {
  const _AdPopupDialog();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 160,
        vertical: isMobile ? 24 : 40,
      ),
      child: isMobile ? const _MobilePopupCard() : const _DesktopPopupCard(),
    );
  }
}

// ─────────────────────────────────────────────
//  DESKTOP CARD
// ─────────────────────────────────────────────
class _DesktopPopupCard extends StatelessWidget {
  const _DesktopPopupCard();

  // Desktop fixed dimensions
  static const double _imageWidth = 520;
  static const double _imageHeight = 420;
  static const double _outerWidth = _imageWidth + 140; // 460
  static const double _outerPadding = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _outerWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Image box ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _outerPadding,
              _outerPadding,
              _outerPadding,
              20,
            ),
            child: Container(
              width: _imageWidth,
              height: _imageHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: const _AdImageFromFirestore(),
            ),
          ),

          // ── Close button ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: CustomButton(
              label: "Close",
              width: 140,
              height: 44,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              backgroundColor: AllColors.fifthColor,
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE CARD
// ─────────────────────────────────────────────
class _MobilePopupCard extends StatelessWidget {
  const _MobilePopupCard();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Mobile scales with screen
    final double imageWidth = screenWidth * 0.62;
    final double imageHeight = screenHeight * 0.44;
    final double outerWidth = imageWidth + 60;

    return Container(
      width: outerWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Image box ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Container(
              width: imageWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade100,
              ),
              clipBehavior: Clip.hardEdge,
              child: const _AdImageFromFirestore(),
            ),
          ),

          // ── Close button ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: CustomButton(
              label: "Close",
              width: 120,
              height: 40,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              backgroundColor: const Color(0xFF9B3A3A),
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  IMAGE — streams from Firestore
// ─────────────────────────────────────────────
class _AdImageFromFirestore extends StatelessWidget {
  const _AdImageFromFirestore();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('homepage')
          .doc('ad_banner')
          .snapshots(),
      builder: (context, snapshot) {
        // ── Loading ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        // ── Error or no data ──
        if (!snapshot.hasData ||
            !snapshot.data!.exists ||
            !(snapshot.data!.data() as Map<String, dynamic>).containsKey(
              'imageUrl',
            )) {
          return _buildPlaceholder();
        }

        final imageUrl =
            (snapshot.data!.data() as Map<String, dynamic>)['imageUrl']
                as String;

        if (imageUrl.isEmpty) return _buildPlaceholder();

        // ── Image ──
        return Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "No ad image uploaded yet",
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
