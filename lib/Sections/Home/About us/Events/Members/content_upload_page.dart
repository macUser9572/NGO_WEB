import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/upload_event.dart';
import 'package:ngo_web/Sections/Home/About%20us/vediolink.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class ContentUploadPageTab extends StatelessWidget {
  const ContentUploadPageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title
          Text(
            "Content Upload",
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 40),

          // Upload Events Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AllColors.primaryColor,
    fixedSize: const Size(200, 45), 
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, 
    ),
  ),
  onPressed: () {
    showDialog(context: context, 
    builder: (_)=>EventsUploadPage());
  },
  child: Text(
    "Upload Events",
    style: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AllColors.secondaryColor,
    ),
  ),
),

const SizedBox(height: 15),

// Video About Page Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AllColors.primaryColor,
    fixedSize: const Size(200, 45),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
  ),
  onPressed: () {
    showDialog(context: context, 
    builder:(_)=>Videolink());
  },
  child: Text(
    "Video About Page",
    style: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AllColors.secondaryColor,
    ),
  ),
),

const SizedBox(height: 15),

// Homepage Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AllColors.primaryColor,
    fixedSize: const Size(200, 45),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
  ),
  onPressed: () {},
  child: Text(
    "Homepage",
    style: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AllColors.secondaryColor,
    ),
  ),
),
],
),
);
}
}