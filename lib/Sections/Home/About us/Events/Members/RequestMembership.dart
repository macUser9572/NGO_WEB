import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ngo_web/constraints/all_colors.dart';
import 'package:ngo_web/constraints/custom_text.dart';

class MembershipRequestPage extends StatelessWidget {
  const MembershipRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Text(
              "Membership Request",
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('membership_requests')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No pending requests",
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.grey),
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _RequestRow(docId: doc.id, data: data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== REQUEST ROW ====================
class _RequestRow extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _RequestRow({required this.docId, required this.data});

  @override
  State<_RequestRow> createState() => _RequestRowState();
}

class _RequestRowState extends State<_RequestRow> {
  bool isApproving = false;
  bool isRejecting = false;

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year}";
    }
    return "N/A";
  }

  // ✅ Approve — copy to Member_collection + delete from requests
  Future<void> _approve(BuildContext context) async {
    setState(() => isApproving = true);
    try {
      await FirebaseFirestore.instance.collection('Member_collection').add({
        'name': widget.data['name'] ?? '',
        'phone': widget.data['phone'] ?? '',
        'email': widget.data['email'] ?? '',
        'gender': widget.data['gender'] ?? '',
        'state': widget.data['state'] ?? '',
        'place': widget.data['state'] ?? '',
        'arrivalDate': widget.data['arrivalDate'],
        'exitDate': widget.data['exitDate'],
        'photoUrl': widget.data['photoUrl'] ?? '',
        'approvedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('membership_requests')
          .doc(widget.docId)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member approved and added to Member list ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to approve ❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isApproving = false);
    }
  }

  // ❌ Reject — directly delete without confirm dialog
  Future<void> _reject(BuildContext context) async {
    setState(() => isRejecting = true);
    try {
      await FirebaseFirestore.instance
          .collection('membership_requests')
          .doc(widget.docId)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request deleted ❌"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
    } finally {
      if (mounted) setState(() => isRejecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.data['photoUrl']?.toString() ?? '';
    final name = widget.data['name']?.toString() ?? '';
    final phone = widget.data['phone']?.toString() ?? '';
    final email = widget.data['email']?.toString() ?? '';  // ← NEW
    final state = widget.data['state']?.toString() ?? '';
    final arrivalDate = _formatDate(widget.data['arrivalDate']);
    final exitDate = _formatDate(widget.data['exitDate']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [

          // ── Avatar ──
          CircleAvatar(
            radius: 22,
            backgroundColor: AllColors.fourthColor,
            backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AllColors.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // ── Name ──
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: CustomText.memberBodyColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Phone ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/PhoneCall.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    phone,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Email ── (NEW)
          Expanded(
            flex: 4,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/mail.svg",height: 20,width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    email.isNotEmpty ? email : 'N/A',
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          // ── State ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/place.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    state,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Arrival Date ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignIn.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    arrivalDate,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Exit Date ──
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignOut.svg",
                    height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    exitDate,
                    overflow: TextOverflow.ellipsis,
                    style: CustomText.memberBodyColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Approve ✅ / Reject ❌ ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Tick
              isApproving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.green),
                    )
                  : IconButton(
                      icon: const Icon(Icons.check,
                          color: Colors.green, size: 22),
                      onPressed:
                          isRejecting ? null : () => _approve(context),
                      tooltip: "Approve",
                    ),

              // ❌ Cross
              isRejecting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.red),
                    )
                  : IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.red, size: 22),
                      onPressed:
                          isApproving ? null : () => _reject(context),
                      tooltip: "Reject",
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
