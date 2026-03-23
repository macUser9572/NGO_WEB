import 'dart:js_interop';
import 'dart:ui_web' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'package:bangalore_chakma_society/Sections/Home/Be%20a%20contributor.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bangalore_chakma_society/constraints/CustomButton.dart';
import 'package:bangalore_chakma_society/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

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

String? extractYoutubeId(String url) {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
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
                // ── LEFT ──
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
                              fontWeight: FontWeight.bold,
                              color: AllColors.thirdColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 60),

                // ── RIGHT: Video ──
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _placeholderBox(
                            height: height * 0.6,
                            child: const CircularProgressIndicator(),
                          );
                        }
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
                                Text("No video uploaded yet",
                                    style: GoogleFonts.inter(
                                        color: Colors.grey, fontSize: 14)),
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

                        if (isYoutubeUrl(videoUrl)) {
                          return _YoutubeThumbnailPlayer(
                            videoUrl: videoUrl,
                            youtubeId: extractYoutubeId(videoUrl),
                            height: height * 0.6,
                          );
                        }

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

            // ── Read More ──
            Positioned(
              left: 0,
              bottom: 200,
              child: CustomButton(
                label: "Read More",
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const ComingSoonDialog(),
                  );
                },
              ),
            ),
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

// ===================== YOUTUBE THUMBNAIL PLAYER =====================
class _YoutubeThumbnailPlayer extends StatefulWidget {
  final String videoUrl;
  final String? youtubeId;
  final double height;

  const _YoutubeThumbnailPlayer({
    required this.videoUrl,
    required this.youtubeId,
    required this.height,
  });

  @override
  State<_YoutubeThumbnailPlayer> createState() =>
      _YoutubeThumbnailPlayerState();
}

class _YoutubeThumbnailPlayerState extends State<_YoutubeThumbnailPlayer>
    with WidgetsBindingObserver {
  bool _playing = false;

  // A single stable ID for the entire lifetime of this widget.
  // Using a counter avoids re-registration crashes on hot-reload.
  static int _counter = 0;
  final String _viewId = 'yt-player-${++_counter}';

  web.HTMLIFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Called the first time the user taps "play" to build the iframe lazily.
  void _registerIframe() {
    if (_iframe != null) return; // already registered

    final web.HTMLIFrameElement iframe = web.HTMLIFrameElement()
      ..id = _viewId
      ..src = 'https://www.youtube.com/embed/${widget.youtubeId}'
          '?autoplay=1&rel=0&controls=1&modestbranding=1&enablejsapi=1'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..setAttribute(
        'allow',
        'accelerometer; autoplay; clipboard-write; '
            'encrypted-media; gyroscope; picture-in-picture',
      );

    _iframe = iframe;

    // Register the view factory (can only be called once per viewId).
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int id) => iframe,
    );

    // Wait for Flutter to actually insert the element into the DOM,
    // then attach the IntersectionObserver with a retry loop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _retryAttachObserverForYoutube(retries: 20);
    });
  }

  /// Retries up to [retries] times (every 200 ms) until the iframe
  /// element exists in the DOM, then attaches the IntersectionObserver.
  void _retryAttachObserverForYoutube({int retries = 20}) {
    final el = web.document.getElementById(_viewId);
    if (el != null) {
      _injectYoutubeObserverScript();
      return;
    }
    if (retries <= 0) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _retryAttachObserverForYoutube(retries: retries - 1);
    });
  }

  void _injectYoutubeObserverScript() {
    // Remove any previously injected script for this id to stay clean.
    final oldScript =
        web.document.getElementById('observer-script-$_viewId');
    oldScript?.remove();

    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..id = 'observer-script-$_viewId'
      ..text = '''
(function() {
  var el = document.getElementById("$_viewId");
  if (!el) return;
  // Disconnect any previous observer stored on the element.
  if (el._flutterObserver) { el._flutterObserver.disconnect(); }
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (!entry.isIntersecting) {
        el.contentWindow.postMessage(
          JSON.stringify({event:"command", func:"pauseVideo", args:[]}),
          "*"
        );
      }
    });
  }, { threshold: 0.1 });
  observer.observe(el);
  el._flutterObserver = observer;
})();
''';
    web.document.body?.append(script);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseYoutube();
    // Clean up the injected script tag.
    web.document.getElementById('observer-script-$_viewId')?.remove();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      _pauseYoutube();
    }
  }

  void _pauseYoutube() {
    try {
      _iframe?.contentWindow?.postMessage(
        '{"event":"command","func":"pauseVideo","args":[]}'.toJS,
        '*'.toJS,
      );
    } catch (_) {}
  }

  Future<void> _openInYouTube() async {
    final uri = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
        child: !_playing
        // ── Thumbnail + play button ──
            ? GestureDetector(
                onTap: () {
                  _registerIframe(); // build the iframe on first tap
                  setState(() => _playing = true);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.black),
                      errorWidget: (_, __, ___) => CachedNetworkImage(
                        imageUrl:
                            'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Container(color: const Color(0xFFE0E0E0)),
                      ),
                    ),
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
              )
        // ── Iframe + fallback overlay ──
            : Stack(
                fit: StackFit.expand,
                children: [
                  HtmlElementView(viewType: _viewId),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.75),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Embedding restricted by video owner",
                            style: GoogleFonts.inter(
                                color: Colors.white70, fontSize: 11),
                          ),
                          GestureDetector(
                            onTap: _openInYouTube,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Watch on YouTube",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ===================== FIREBASE STORAGE VIDEO PLAYER =====================
class _FirebaseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;

  const _FirebaseVideoPlayer({required this.videoUrl, required this.height});

  @override
  State<_FirebaseVideoPlayer> createState() => _FirebaseVideoPlayerState();
}

class _FirebaseVideoPlayerState extends State<_FirebaseVideoPlayer>
    with WidgetsBindingObserver {
  static int _counter = 0;
  final String _viewId = 'firebase-video-${++_counter}';

  web.HTMLVideoElement? _videoEl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final web.HTMLVideoElement video = web.HTMLVideoElement()
      ..id = _viewId
      ..src = widget.videoUrl
      ..controls = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '8px';

    _videoEl = video;

    ui.platformViewRegistry.registerViewFactory(
        _viewId, (int id) => video);

    // Wait for Flutter to render, then retry until element is in the DOM.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _retryAttachObserverForVideo(retries: 20);
    });
  }

  void _retryAttachObserverForVideo({int retries = 20}) {
    final el = web.document.getElementById(_viewId);
    if (el != null) {
      _injectVideoObserverScript();
      return;
    }
    if (retries <= 0) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _retryAttachObserverForVideo(retries: retries - 1);
    });
  }

  void _injectVideoObserverScript() {
    web.document.getElementById('observer-script-$_viewId')?.remove();

    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..id = 'observer-script-$_viewId'
      ..text = '''
(function() {
  var el = document.getElementById("$_viewId");
  if (!el) return;
  if (el._flutterObserver) { el._flutterObserver.disconnect(); }
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (!entry.isIntersecting) {
        el.pause();
      }
    });
  }, { threshold: 0.1 });
  observer.observe(el);
  el._flutterObserver = observer;
})();
''';
    web.document.body?.append(script);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      _videoEl?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoEl?.pause();
    web.document.getElementById('observer-script-$_viewId')?.remove();
    super.dispose();
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
    return Container(
      width: double.infinity,
      color: AllColors.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 63),

          Text(
            "About us",
            style: GoogleFonts.inter(
              color: AllColors.primaryColor,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),

          const SizedBox(height: 20),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("videos")
                .doc("upload_video")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _videoPlaceholder(
                    child: const CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  !snapshot.data!.exists) {
                return _videoPlaceholder(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_rounded,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text("No video uploaded yet",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final String videoUrl =
                  data["video_url"]?.toString().trim() ?? "";

              if (videoUrl.isEmpty) {
                return _videoPlaceholder(
                    child: const Icon(Icons.play_circle_outline,
                        size: 48, color: Colors.grey));
              }
              if (isYoutubeUrl(videoUrl)) {
                return _YoutubeThumbnailPlayer(
                  videoUrl: videoUrl,
                  youtubeId: extractYoutubeId(videoUrl),
                  height: 220,
                );
              }
              return _FirebaseVideoPlayer(videoUrl: videoUrl, height: 220);
            },
          ),

          const SizedBox(height: 15),

          Text(
            "The Bangalore Chakma Society (BCS) represents the collective journey, "
            "resilience, and unity of the Chakma and Buddhist communities who have "
            "made Bengaluru their home. The roots of this journey trace back to the "
            "early arrivals of Chakma individuals in the city, beginning with pioneers "
            "who came as students and professionals and went on to build successful "
            "careers laying a proud foundation for the community.",
            style: GoogleFonts.inter(
                fontSize: 12, height: 1.6, color: AllColors.thirdColor),
          ),

          const SizedBox(height: 16),

          Text(
            "While small groups of Chakma individuals visited or stayed briefly in "
            "the 1990s, the true groundwork of BCS began to take shape around 2007, "
            "when a growing number of students and working professionals settled in "
            "Bangalore. Even during these early years, community members came together "
            "informally to celebrate culture, religion, and shared identity.",
            style: GoogleFonts.inter(
                fontSize: 12, height: 1.6, color: AllColors.thirdColor),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColors.fifthColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const ComingSoonDialog(),
                );
              },
              child: Text("Read More",
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _videoPlaceholder({required Widget child}) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }
}
