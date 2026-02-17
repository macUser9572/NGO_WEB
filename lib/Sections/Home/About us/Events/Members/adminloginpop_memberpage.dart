import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/afterloginmainpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';
class AdminLoginPopup extends StatefulWidget {
  const AdminLoginPopup({super.key});

  @override
  State<AdminLoginPopup> createState() => _AdminLoginPopupState();
}

class _AdminLoginPopupState extends State<AdminLoginPopup> {
  bool isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String error = "";
  bool isLoading = false;

  // 🔒 FIXED ADMIN CREDENTIALS
  static const String ADMIN_EMAIL = "admin@ngo.com";
  static const String ADMIN_PASSWORD = "123456";
  void loginAdmin() {
    setState(() {
      error = "";
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (emailController.text.trim() == ADMIN_EMAIL &&
          passwordController.text.trim() == ADMIN_PASSWORD) {
        // ✅ SUCCESS
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AfterLoginPage()),
        );
      } else {
        // ❌ ERROR
        setState(() {
          error = "Invalid admin email or password";
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: AllColors.secondaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //====================TITLE======================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Admin Login",
                    style: GoogleFonts.inter(
                      fontSize: 28,
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
                "To view member  kindly login as an Admin",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 32),

              //=======================USER NAME==================
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

              //=====================PASSWORD======================
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

              const SizedBox(height: 30),

              //========================LOGIN BUTTON=================
              SizedBox(
                height: 45,
                width: 365,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: isLoading ? null : loginAdmin,
                  child: Text(
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
