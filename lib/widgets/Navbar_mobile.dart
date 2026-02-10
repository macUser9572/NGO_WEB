import 'package:flutter/material.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/widgets/scroll_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class NavbarMobile extends StatelessWidget {
  const NavbarMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final double height =  MediaQuery.of(context).padding.top + 50;

    return SafeArea(
      bottom: false,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: AllColors.fourthColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           InkWell(
            onTap: (){
              scrollToSection(context, 0);
              if(Scaffold.of(context).isEndDrawerOpen){
                Navigator.of(context).pop();
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Image.asset("assets/image/green_logo.png",
                height: 36,
                fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  "NGO",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AllColors.secondaryColor,
                  )
                )
              ],
            ),
           ),
           Builder(
            builder: (context) => IconButton(
              icon:const Icon(Icons.menu,
              color: AllColors.secondaryColor),
              onPressed: ()=>Scaffold.of(context).openDrawer(),)
            )
          ],
        ),
      )
      );

  }
}