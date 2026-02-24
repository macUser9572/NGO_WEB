import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/Student_list_page.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const _DesktopLayout();
          default:
            return const _MobileLayout();
        }
      },
    );
  }
}

// ====================== DESKTOP LAYOUT ======================
class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout();

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  // ===================== FETCH IMAGES FROM FIRESTORE =====================
  Future<void> _fetchImages() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("student_body")
          .doc("images")
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final List<String> urls = [];

        // Collect all image URLs dynamically
        int i = 1;
        while (data.containsKey("image_${i}_url")) {
          final url = data["image_${i}_url"];
          if (url != null && url.toString().isNotEmpty) {
            urls.add(url.toString());
          }
          i++;
        }

        if (mounted) {
          setState(() {
            _imageUrls = urls;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching student body images: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        width: width,
        height: height,
        color: AllColors.fourthColor,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= LEFT CONTENT =================
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BSCA",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      color: AllColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Student Body",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AllColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 720,
                    child: Text(
                      "The student body serves as a unifying platform that brings students together, "
                      "creating an environment where everyone can learn, grow, and thrive. It leads "
                      "student-driven activities, supports new initiatives, and ensures that every student "
                      "feels included, represented, and heard. Through these efforts, the community becomes "
                      "stronger, more cohesive, and better connected.\n"
                      "The student body also aims to collaborate with other Northeastern student organizations, "
                      "fostering shared learning, cultural exchange, and collective initiatives. It actively "
                      "participates in addressing student concerns and resolving issues as a united voice.\n"
                      "The Bangalore Chakma Students' Body operates as an integral part of the Bangalore Chakma "
                      "Society and functions under the guidance and supervision of senior members.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: AllColors.thirdColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Positioned(
                    left: 0,
                    bottom: 170,
                    child: CustomButton(
                      label: "Student Members", 
                      onPressed: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_)=> const StudentListPage()
                            )
                            );
                      }
                      )
                      )
                              ],
              ),
            ),

            const SizedBox(width: 60),

            // ================= RIGHT IMAGE CAROUSEL =================
            Expanded(
              flex: 5,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _imageUrls.isEmpty
                      ? Center(
                          child: Text(
                            "No images available",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AllColors.thirdColor,
                            ),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // ── Carousel ──
                            Expanded(
                              child: CarouselSlider(
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  height: 580,
                                  viewportFraction: 1.0,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 600),
                                  autoPlayCurve: Curves.easeInOut,
                                  enlargeCenterPage: false,
                                  scrollDirection: Axis.vertical,
                                  onPageChanged: (index, reason) {
                                    setState(() => _currentIndex = index);
                                  },
                                ),
                                items: _imageUrls.map((url) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      url,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stack) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ── Controls OUTSIDE to the RIGHT ──
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                // Up / Prev arrow
                                GestureDetector(
                                  onTap: () =>
                                      _carouselController.previousPage(),
                                  child: Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    color: AllColors.primaryColor,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Vertical dots
                                ..._imageUrls.asMap().entries.map((entry) {
                                  final isActive = entry.key == _currentIndex;
                                  return GestureDetector(
                                    onTap: () => _carouselController
                                        .animateToPage(entry.key),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      width: 8,
                                      height: isActive ? 24 : 8,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AllColors.primaryColor
                                            : AllColors.primaryColor
                                                .withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 10),

                                // Down / Next arrow
                                GestureDetector(
                                  onTap: () => _carouselController.nextPage(),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AllColors.primaryColor,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== MOBILE LAYOUT =====================
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Mobile Layout", style: GoogleFonts.inter(fontSize: 18)),
    );
  }
}