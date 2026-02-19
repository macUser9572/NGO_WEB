import 'package:flutter/material.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Videolink extends StatefulWidget {
  const Videolink({super.key});

  @override
  State<Videolink> createState() => _VideolinkState();
}

class _VideolinkState extends State<Videolink> {

  final TextEditingController videoController = TextEditingController();
  bool _isLoading = false;

  void uploadVideo() {
    if (videoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter video link"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Add your Firestore upload logic here

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Video Link Uploaded"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AllColors.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [

          // ================= Main Content =================
          Container(
            width: 800,
            padding: const EdgeInsets.all(40),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // // Title
                  // Text(
                  //   "Video",
                  //   style: GoogleFonts.inter(
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  // ),

                  // const SizedBox(height: 30),

                  // // Label
                  // Text(
                  //   "Video Link",
                  //   style: GoogleFonts.inter(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),

                  // const SizedBox(height: 10),

                  // Text Field
                  Container(
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),

                    ),

                  ),
                  // Container(
                  //   height: 55,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade100,
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: Border.all(color: Colors.grey.shade300),
                  //   ),
                  //   child: TextField(
                  //     controller: videoController,
                  //     decoration: InputDecoration(
                  //       hintText: "Paste video link here",
                  //       hintStyle:
                  //           GoogleFonts.inter(color: Colors.grey),
                  //       border: InputBorder.none,
                  //       contentPadding:
                  //           const EdgeInsets.symmetric(
                  //               horizontal: 16, vertical: 14),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 40),

                  // Upload Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _isLoading ? null : uploadVideo,
                      child: Container(
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AllColors.primaryColor,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  "Upload",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= Close Button =================
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
