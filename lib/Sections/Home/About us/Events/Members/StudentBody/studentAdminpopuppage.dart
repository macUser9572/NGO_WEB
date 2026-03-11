import 'package:flutter/material.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/StudentBody/Afterstudentloginpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';

// ─────────────────────────────────────────────
//  STUDENT LIST PAGE
// ─────────────────────────────────────────────
class Studentadminpopuppage extends StatelessWidget {
  const Studentadminpopuppage ({super.key});

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

// ─────────────────────────────────────────────
//  ADMIN LOGIN POPUP (unchanged)
// ─────────────────────────────────────────────
class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout({super.key});

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  bool isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String error = "";
  bool isLoading = false;

  static const String ADMIN_EMAIL = "admin@ngo.com";
  static const String ADMIN_PASSWORD = "changma@2026";

  void loginAdmin() {
    setState(() {
      error = "";
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (emailController.text.trim() == ADMIN_EMAIL &&
          passwordController.text.trim() == ADMIN_PASSWORD) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AfterLoginStudentPage(),
          ),
        );
      } else {
        setState(() {
          error = "Invalid admin email or password";
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: AllColors.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= TITLE =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Student Admin Login",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              Text(
                "To view members kindly login as an Admin",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 32),

              // ================= USER NAME =================
              Text(
                "User Name",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Test",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= PASSWORD =================
              Text(
                "Password",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              if (error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              const SizedBox(height: 30),

              // ================= LOGIN BUTTON =================
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllColors.fifthColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: isLoading ? null : loginAdmin,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          "LOGIN",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AllColors.secondaryColor,
                            letterSpacing: 1,
                          ),
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
// ====================== MOBILE LAYOUT ======================

class _MobileLayout extends StatefulWidget {
  const _MobileLayout({super.key});

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  bool isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String error = "";
  bool isLoading = false;

  static const String ADMIN_EMAIL = "admin@ngo.com";
  static const String ADMIN_PASSWORD = "changma@2026";

  void loginAdmin() {
    setState(() {
      error = "";
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (emailController.text.trim() == ADMIN_EMAIL &&
          passwordController.text.trim() == ADMIN_PASSWORD) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AfterLoginStudentPage(),
          ),
        );
      } else {
        setState(() {
          error = "Invalid admin email or password";
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,                                      // full width on mobile
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // tighter padding
        decoration: BoxDecoration(
          color: AllColors.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= TITLE =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Student Admin Login",
                    style: GoogleFonts.inter(
                      fontSize: 22,                                 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              Text(
                "To view members kindly login as an Admin",
                style: GoogleFonts.inter(
                  fontSize: 12,                                      // slightly smaller
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),                           // reduced spacing

              // ================= USER NAME =================
              Text(
                "User Name",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Test",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= PASSWORD =================
              Text(
                "Password",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              if (error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              const SizedBox(height: 24),                           // reduced spacing

              // ================= LOGIN BUTTON =================
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllColors.fifthColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: isLoading ? null : loginAdmin,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          "LOGIN",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AllColors.secondaryColor,
                            letterSpacing: 1,
                          ),
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
