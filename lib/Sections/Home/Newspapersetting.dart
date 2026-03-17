import 'package:flutter/material.dart';
import 'package:ngo_web/constraints/CustomButton.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:google_fonts/google_fonts.dart';

class Newspapersetting extends StatelessWidget {
  const Newspapersetting({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const NewspapersettingsDesktop();
          default:
            return const NewspapersettingsMobile();
        }
      },
    );
  }
}

//===================Desktop==============
class NewspapersettingsDesktop extends StatelessWidget {
  const NewspapersettingsDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 600 ? 550 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AllColors.secondaryColor,
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Title and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'Post News',
                  style: GoogleFonts.inter(
                    fontSize: 40, 
                    fontWeight: FontWeight.bold,
                    color: AllColors.thirdColor
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

            // Upload Photo Section
            Text(
              'Upload photo',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AllColors.thirdColor
                ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Add image picker logic here
              },
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag and drop or choose an image',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title Field
            Text('Title', 
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AllColors.thirdColor
              )),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Post title',
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description Field
             Text(
              'Description',
              style: GoogleFonts.inter( 
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AllColors.thirdColor),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter a brief description about the post',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  outlined: true,
                ),
                const SizedBox(width: 12),
                CustomButton(
                  label: 'Post News',
                  onPressed: () {
                    // Add post logic here
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//===================Mobile==============
class NewspapersettingsMobile extends StatelessWidget {
  const NewspapersettingsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Post News',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
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
            // Upload Photo Section
             Text(
              'Upload photo',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Add image picker logic here
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to choose an image',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title Field
             Text('Title',  
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Post title',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Field
             Text(
              'Description',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter a brief description about the post',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Buttons - Stacked for mobile UX
            // Buttons - Side by side
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    outlined: true,
                    height: 48,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Post News',
                    onPressed: () {
                      // Add post logic here
                      Navigator.pop(context);
                    },
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
