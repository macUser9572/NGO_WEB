
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/Sections/Home/About%20us/Events/Members/adminloginpop_memberpage.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembersListPage extends StatelessWidget {
  const MembersListPage({super.key});

  // ================= FIREBASE STREAM =================
  Widget membersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Member_collection')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No members found"));
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final member = Member.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
            return _memberRow(member);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AllColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AllColors.thirdColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AllColors.thirdColor),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColors.fifthColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AdminLoginPopup(),
                );
              },
              child: Text(
                "Admin Login",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AllColors.secondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BCS Members",
              style: GoogleFonts.inter(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Phone numbers are hidden. Admin login required to view them.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AllColors.thirdColor,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(child: membersStream()),
          ],
        ),
      ),
    );
  }

  // ================= MEMBER ROW =================
  Widget _memberRow(Member member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ✅ Avatar — shows Firebase photo, falls back to initial letter only
          // No person icon at all
          CircleAvatar(
            radius: 22,
            backgroundColor: AllColors.fourthColor,
            child: member.photoUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      member.photoUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      // ✅ Shows spinner while photo loads from Firebase
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AllColors.primaryColor,
                          ),
                        );
                      },
                      // ✅ Falls back to initial letter if URL is broken
                      errorBuilder: (context, error, stackTrace) => Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AllColors.primaryColor,
                        ),
                      ),
                    ),
                  )
                // ✅ No photo uploaded — show initial letter, no icon
                : Text(
                    member.name.isNotEmpty
                        ? member.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AllColors.primaryColor,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // ── Name ──
          Expanded(
            flex: 3,
            child: Text(
              member.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          // ── Phone (masked) ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/PhoneCall.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Text(
                  "***********",
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AllColors.thirdColor),
                ),
              ],
            ),
          ),

          // ── Place ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/place.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.place,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AllColors.thirdColor),
                  ),
                ),
              ],
            ),
          ),

          // ── Check In ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignIn.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.checkIn,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AllColors.thirdColor),
                  ),
                ),
              ],
            ),
          ),

          // ── Check Out ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignOut.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.checkOut,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AllColors.thirdColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= MEMBER MODEL =================
class Member {
  final String id;
  final String name;
  final String phone;
  final String place;
  final String checkIn;
  final String checkOut;
  final String photoUrl;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.place,
    required this.checkIn,
    required this.checkOut,
    required this.photoUrl,
  });

  factory Member.fromFirestore(String id, Map<String, dynamic> data) {
    return Member(
      id: id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      place: data['state']?.toString() ?? data['place']?.toString() ?? '',
      checkIn: data['arrivalDate'] is Timestamp
          ? _formatDate(data['arrivalDate'])
          : '',
      checkOut: data['exitDate'] is Timestamp
          ? _formatDate(data['exitDate'])
          : '',
      photoUrl: data['photoUrl']?.toString() ?? '',
    );
  }

  static String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}