 import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bangalore_chakma_society/constraints/CustomButton.dart';

// ─────────────────────────────────────────────
//  AD POPUP WIDGET
//  Reads 'homepage/ad_banner' → images[]
//  Shows a slideshow if count > 1,
//  a single image if count == 1.
//  Auto-advances every 4 s + manual prev/next.
// ─────────────────────────────────────────────
class AdPopup extends StatefulWidget {
  const AdPopup({super.key});

  static Future<void> showIfActive(BuildContext context) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('homepage')
          .doc('ad_banner')
          .get();

      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final List images = data['images'] as List? ?? [];
      if (images.isEmpty) return;

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.55),
          builder: (_) => const AdPopup(),
        );
      }
    } catch (_) {
      // silently skip if Firestore fails
    }
  }

  @override
  State<AdPopup> createState() => _AdPopupState();
}

class _AdPopupState extends State<AdPopup> {
  List<String> _imageUrls = [];
  bool _loading = true;
  int _currentIndex = 0;
  Timer? _autoTimer;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchImages();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('homepage')
          .doc('ad_banner')
          .get();

      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final List raw = data['images'] as List? ?? [];
        final urls = raw
            .map(
              (e) => (e as Map<String, dynamic>)['imageUrl']?.toString() ?? '',
            )
            .where((u) => u.isNotEmpty)
            .toList();

        setState(() {
          _imageUrls = urls;
          _loading = false;
        });

        // Start auto-play only when there are multiple slides
        if (_imageUrls.length > 1) _startAutoPlay();
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _goToNext();
    });
  }

  void _goToNext() {
    final next = (_currentIndex + 1) % _imageUrls.length;
    _animateTo(next);
  }

  void _goToPrev() {
    final prev = (_currentIndex - 1 + _imageUrls.length) % _imageUrls.length;
    _animateTo(prev);
  }

  void _animateTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
    );
  }

  // Reset auto-play timer when user manually navigates
  void _onManualNav(int index) {
    _autoTimer?.cancel();
    _animateTo(index);
    if (_imageUrls.length > 1) _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double maxW = isMobile ? double.infinity : 480;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 32 : 60,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image / Slideshow area ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: _buildImageArea(isMobile),
            ),

            // ── Dot indicators (only when >1 slide) ──
            if (!_loading && _imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _buildDots(),
              ),

            // ── Close button ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CustomButton(
                label: 'Close',
                fontWeight: FontWeight.w600,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image area ─────────────────────────────
  Widget _buildImageArea(bool isMobile) {
    final double height = isMobile ? 300 : 380;

    if (_loading) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_imageUrls.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No ad available.',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ),
      );
    }

    // Single image — no arrows, no page view overhead
    if (_imageUrls.length == 1) {
      return _networkImage(_imageUrls.first, height);
    }

    // Slideshow
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _imageUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (ctx, i) => _networkImage(_imageUrls[i], height),
          ),

          // Left arrow
          Positioned(
            left: 8,
            child: _ArrowButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _onManualNav(
                (_currentIndex - 1 + _imageUrls.length) % _imageUrls.length,
              ),
            ),
          ),

          // Right arrow
          Positioned(
            right: 8,
            child: _ArrowButton(
              icon: Icons.chevron_right_rounded,
              onTap: () =>
                  _onManualNav((_currentIndex + 1) % _imageUrls.length),
            ),
          ),
        ],
      ),
    );
  }

  // ── Network image helper ───────────────────
  Widget _networkImage(String url, double height) {
    return Image.network(
      url,
      width: double.infinity,
      height: height,
      fit: BoxFit.contain,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => SizedBox(
        height: height,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade400,
            size: 40,
          ),
        ),
      ),
    );
  }

  // ── Dot indicators ─────────────────────────
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _imageUrls.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentIndex ? Colors.black87 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ARROW BUTTON
// ─────────────────────────────────────────────
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
