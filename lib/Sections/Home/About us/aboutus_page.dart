import 'dart:ui_web' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';


class AboutusPage extends StatelessWidget {
  const AboutusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _AboutDesktop();
        } else {
          return const _MobileLayout();
        }
      },
    );
  }
}

// ===================== HELPERS =====================

/// Extracts the YouTube video ID from various YouTube URL formats.
String? extractYoutubeId(String url) {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) return null;

  // youtu.be/<id>
  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  // youtube.com/watch?v=<id>  or  youtube.com/embed/<id>
  if (uri.host.contains('youtube.com')) {
    return uri.queryParameters['v'] ??
        (uri.pathSegments.length > 1 ? uri.pathSegments.last : null);
  }
  return null;
}

bool isYoutubeUrl(String url) =>
    url.contains('youtu.be') || url.contains('youtube.com');

// ===================== DESKTOP =====================
class _AboutDesktop extends StatelessWidget {
  const _AboutDesktop();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        height: height,
        color: AllColors.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT: Text content ──
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About us",
                          style: GoogleFonts.inter(
                            color: AllColors.primaryColor,
                            fontSize: 80,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 820,
                          child: Text(
                            "The Bangalore Chakma Society (BCS) represents the collective journey, "
                            "resilience, and unity of the Chakma and Buddhist communities who have "
                            "made Bengaluru their home. The roots of this journey trace back to the "
                            "early arrivals of Chakma individuals in the city, beginning with pioneers "
                            "who came as students and professionals and went on to build successful "
                            "careers laying a proud foundation for the community.",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              height: 1.6,
                              color: AllColors.thirdColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 820,
                          child: Text(
                            "While small groups of Chakma individuals visited or stayed briefly in "
                            "the 1990s, the true groundwork of BCS began to take shape around 2007, "
                            "when a growing number of students and working professionals settled in "
                            "Bangalore. Even during these early years, community members came together "
                            "informally to celebrate culture, religion, and shared identity.",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              height: 1.6,
                              color: AllColors.thirdColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 60),

                // ── RIGHT: Video fetched from Firebase ──
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 160),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("videos")
                          .doc("upload_video")
                          .snapshots(),
                      builder: (context, snapshot) {
                        // Loading
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _placeholderBox(
                            height: height * 0.6,
                            child: const CircularProgressIndicator(),
                          );
                        }

                        // Error or no document
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            !snapshot.data!.exists) {
                          return _placeholderBox(
                            height: height * 0.6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.videocam_off_rounded,
                                    size: 56, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  "No video uploaded yet",
                                  style: GoogleFonts.inter(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final String videoUrl =
                            data["video_url"]?.toString().trim() ?? "";

                        if (videoUrl.isEmpty) {
                          return _placeholderBox(
                            height: height * 0.6,
                            child: const Icon(Icons.play_circle_outline,
                                size: 64, color: Colors.grey),
                          );
                        }

                        // ── YouTube URL ──
                        if (isYoutubeUrl(videoUrl)) {
                          return _YoutubeInBoxPlayer(
                            videoUrl: videoUrl,
                            youtubeId: extractYoutubeId(videoUrl),
                            height: height * 0.6,
                          );
                        }

                        // ── Firebase Storage .mp4 ──
                        return _FirebaseVideoPlayer(
                          videoUrl: videoUrl,
                          height: height * 0.6,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // ── Read More Button ──
            Positioned(
              left: 0,
              bottom: 170,
              child: CustomButton(
                label:"Read More" ,
                 onPressed: (){}),
            )
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox({required double height, required Widget child}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }
}

// ===================== YOUTUBE PLAYER =====================
// Shows thumbnail first → tap play → YouTube iframe loads inside the box
class _YoutubeInBoxPlayer extends StatefulWidget {
  final String videoUrl;
  final String? youtubeId;
  final double height;

  const _YoutubeInBoxPlayer({
    required this.videoUrl,
    required this.youtubeId,
    required this.height,
  });

  @override
  State<_YoutubeInBoxPlayer> createState() => _YoutubeInBoxPlayerState();
}

class _YoutubeInBoxPlayerState extends State<_YoutubeInBoxPlayer> {
  bool _playing = false;
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId =
        'yt-inbox-${widget.youtubeId ?? widget.videoUrl.hashCode}';

    // Pre-register the iframe so it's ready when the user taps play
    final web.HTMLIFrameElement iframe = web.HTMLIFrameElement()
      ..src =
          'https://www.youtube.com/embed/${widget.youtubeId}?autoplay=1&rel=0&controls=1&modestbranding=1'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..setAttribute(
        'allow',
        'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture',
      );

    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String thumbnailUrl = widget.youtubeId != null
        ? 'https://img.youtube.com/vi/${widget.youtubeId}/maxresdefault.jpg'
        : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: widget.height,
        child: _playing
            // ── Iframe plays inline ──
            ? HtmlElementView(viewType: _viewId)
            // ── Thumbnail + play overlay ──
            : GestureDetector(
                onTap: () => setState(() => _playing = true),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail (fallback to hqdefault)
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.black),
                      errorWidget: (_, __, ___) => CachedNetworkImage(
                        imageUrl:
                            'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Container(color: const Color(0xFFE0E0E0)),
                      ),
                    ),

                    // Dark gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),

                    // Red play button
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ===================== FIREBASE STORAGE VIDEO PLAYER =====================
// Renders an HTML <video> element pointing to the Firebase Storage .mp4 URL
class _FirebaseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;

  const _FirebaseVideoPlayer({
    required this.videoUrl,
    required this.height,
  });

  @override
  State<_FirebaseVideoPlayer> createState() => _FirebaseVideoPlayerState();
}

class _FirebaseVideoPlayerState extends State<_FirebaseVideoPlayer> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'firebase-video-${widget.videoUrl.hashCode}';

    final web.HTMLVideoElement video = web.HTMLVideoElement()
      ..src = widget.videoUrl
      ..controls = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '8px';

    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => video,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: widget.height,
        child: HtmlElementView(viewType: _viewId),
      ),
    );
  }
}

// ===================== MOBILE LAYOUT =====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: AllColors.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About us",
              style: GoogleFonts.inter(
                color: AllColors.primaryColor,
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "The Bangalore Chakma Society (BCS) represents the collective journey, "
              "resilience, and unity of the Chakma and Buddhist communities who have "
              "made Bengaluru their home.",
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: AllColors.thirdColor,
              ),
            ),
            const SizedBox(height: 24),

            // ── Mobile Video ──
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("videos")
                  .doc("upload_video")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: Icon(Icons.videocam_off_rounded,
                          size: 48, color: Colors.grey),
                    ),
                  );
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>;
                final String videoUrl =
                    data["video_url"]?.toString().trim() ?? "";

                if (videoUrl.isEmpty) {
                  return const SizedBox(height: 220);
                }

                if (isYoutubeUrl(videoUrl)) {
                  return _YoutubeInBoxPlayer(
                    videoUrl: videoUrl,
                    youtubeId: extractYoutubeId(videoUrl),
                    height: 220,
                  );
                }

                return _FirebaseVideoPlayer(videoUrl: videoUrl, height: 220);
              },
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              child: const Text(
                'Read More about BCS',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}