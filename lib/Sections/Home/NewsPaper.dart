import 'package:flutter/material.dart';
import 'package:ngo_web/Sections/Home/Newspapersetting.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Newspaper extends StatelessWidget {
  const Newspaper({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        switch (sizing.deviceScreenType) {
          case DeviceScreenType.desktop:
            return const NewspaperDesktop();
          default:
            return const NewspaperMobile();
        }
      },
    );
  }
}
//=======================Desktop=======================

class NewspaperDesktop extends StatelessWidget {
  const NewspaperDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AllColors.thirdColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (_)=>const Newspapersetting());
              },
              icon: SvgPicture.asset(
                'assets/icons/settings.svg',
                color: AllColors.thirdColor,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//=================================Mobile===========================
class NewspaperMobile extends StatelessWidget {
  const NewspaperMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AllColors.thirdColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const NewspapersettingsMobile(),
                );
              },
              icon: SvgPicture.asset(
                'assets/icons/settings.svg',
                color: AllColors.thirdColor,
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}