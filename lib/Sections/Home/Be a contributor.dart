import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ComingSoonDialog extends StatelessWidget {
  const ComingSoonDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Coming Soon Image Icon
                SvgPicture.asset(
                  "assets/icons/coming_soon.svg",
                  height: 50,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                /// Title
                const Text(
                  "New Feature In Progress !",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                /// Description
                const Text(
                  "Thank you for your continued support as we finalize this update.",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          /// Close Button
          Positioned(
            right: 12,
            top: 12,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 22, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const ComingSoonDialog());
  }
}
