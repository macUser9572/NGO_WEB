import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/Tabs.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:responsive_builder/responsive_builder.dart';

// ==================== ENTRY POINT ====================
class AdminLoginPopup extends StatelessWidget {
  const AdminLoginPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        if (sizing.deviceScreenType == DeviceScreenType.desktop) {
          return const _DesktopLayout();
        } else {
          return const _MobileLayout();
        }
      },
    );
  }
}

// ==================== DESKTOP LAYOUT ====================
class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout({super.key});

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  bool isPasswordVisible = false;
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String emailError    = "";
  String passwordError = "";
  String loginError    = "";
  bool isLoading       = false;

  static const String ADMIN_EMAIL    = "admin@ngo.com";
  static const String ADMIN_PASSWORD = "changma@2026";

  Future<void> loginAdmin() async {
    // ── Clear all errors ──
    setState(() {
      emailError    = "";
      passwordError = "";
      loginError    = "";
    });

    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    // ── Field-level validation ──
    bool hasError = false;

    if (email.isEmpty) {
      setState(() => emailError = "Please fill the email id");
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => passwordError = "Please fill the password");
      hasError = true;
    }

    if (hasError) return; // stop if any field is empty

    // ── Proceed with login ──
    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (email == ADMIN_EMAIL && password == ADMIN_PASSWORD) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const AfterLoginPage()),
      );
    } else {
      setState(() {
        loginError = "Invalid admin email or password";
        isLoading  = false;
      });
    }
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

              // ── Title ──
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
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),

              Text(
                "To view members kindly login as an Admin",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // ── User Name ──
              Text(
                "User Id",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter User id",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                     ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: emailError.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: emailError.isNotEmpty ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
                onChanged: (_) {
                  if (emailError.isNotEmpty) {
                    setState(() => emailError = "");
                  }
                },
              ),

              // ── Email error ──
              if (emailError.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  emailError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],

              const SizedBox(height: 20),

              // ── Password ──
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
                  hintText: "Enter Password",
                  hintStyle: GoogleFonts.inter(
                    fontSize:14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400
                     ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: passwordError.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: passwordError.isNotEmpty ? Colors.red : Colors.blue,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                ),
                onChanged: (_) {
                  if (passwordError.isNotEmpty) {
                    setState(() => passwordError = "");
                  }
                },
              ),

              // ── Password error ──
              if (passwordError.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  passwordError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],

              // ── Wrong credentials error ──
              if (loginError.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  loginError,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 30),

              // ── Login Button ──
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

// ==================== MOBILE LAYOUT ====================
class _MobileLayout extends StatefulWidget {
  const _MobileLayout({super.key});

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  bool isPasswordVisible = false;
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String emailError    = "";
  String passwordError = "";
  String loginError    = "";
  bool isLoading       = false;

  static const String ADMIN_EMAIL    = "admin@ngo.com";
  static const String ADMIN_PASSWORD = "changma@2026";

  Future<void> loginAdmin() async {
    setState(() {
      emailError    = "";
      passwordError = "";
      loginError    = "";
    });

    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    bool hasError = false;

    if (email.isEmpty) {
      setState(() => emailError = "Please fill the email id");
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => passwordError = "Please fill the password");
      hasError = true;
    }

    if (hasError) return;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (email == ADMIN_EMAIL && password == ADMIN_PASSWORD) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const AfterLoginPage()),
      );
    } else {
      setState(() {
        loginError = "Invalid admin email or password";
        isLoading  = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AllColors.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Title ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Admin Login",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ],
              ),

              Text(
                "To view members kindly login as an Admin",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black),
              ),

              const SizedBox(height: 24),

              // ── User Name ──
              Text(
                "User Name",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter email id",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: emailError.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: emailError.isNotEmpty ? Colors.red : Colors.blue,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (_) {
                  if (emailError.isNotEmpty) {
                    setState(() => emailError = "");
                  }
                },
              ),

              // ── Email error ──
              if (emailError.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  emailError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],

              const SizedBox(height: 16),

              // ── Password ──
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
                  hintText: "Enter Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: passwordError.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: passwordError.isNotEmpty ? Colors.red : Colors.blue,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                ),
                onChanged: (_) {
                  if (passwordError.isNotEmpty) {
                    setState(() => passwordError = "");
                  }
                },
              ),

              // ── Password error ──
              if (passwordError.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  passwordError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],

              // ── Wrong credentials error ──
              if (loginError.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  loginError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],

              const SizedBox(height: 24),

              // ── Login Button ──
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
                            fontSize: 14,
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
