import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
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
    if (timestamp == null || timestamp is! Timestamp) return "N/A";
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

 Future<void> _sendEmail(String status) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      region: 'us-central1',
    ).httpsCallable('sendMembershipEmail');

    final result = await callable.call({
      'email': widget.data['email']?.toString() ?? '',
      'name': widget.data['name']?.toString() ?? 'Member',
      'status': status,
    });

    debugPrint("Email sent → ${result.data}");
  } catch (e) {
    debugPrint("Email failed: $e");

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Could not send email: $e"),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

  Future<void> _approve() async {
  setState(() => isApproving = true);

  try {
    await FirebaseFirestore.instance.collection('Member_collection').add({
      'name': widget.data['name'] ?? '',
      'phone': widget.data['phone'] ?? '',
      'email': widget.data['email'] ?? '',
      'gender': widget.data['gender'] ?? '',
      'state': widget.data['state'] ?? '',
      'place': widget.data['place'] ?? widget.data['state'] ?? '',
      'arrivalDate': widget.data['arrivalDate'],
      'exitDate': widget.data['exitDate'],
      'photoUrl': widget.data['photoUrl'] ?? '',
      'approvedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _sendEmail('approved');

    await FirebaseFirestore.instance
        .collection('membership_requests')
        .doc(widget.docId)
        .delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Member approved ✅ — Email sent"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Approval failed: $e"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => isApproving = false);
  }
}
  Future<void> _reject() async {
  setState(() => isRejecting = true);

  try {
    await _sendEmail('rejected');

    await FirebaseFirestore.instance
        .collection('membership_requests')
        .doc(widget.docId)
        .delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request rejected ❌ — Email sent"),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Rejection failed: $e"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => isRejecting = false);
  }
}
  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.data['photoUrl']?.toString() ?? '';
    final name = widget.data['name']?.toString() ?? 'Unknown';
    final phone = widget.data['phone']?.toString() ?? 'N/A';
    final email = widget.data['email']?.toString() ?? 'N/A';
    final state = widget.data['state']?.toString() ?? 'N/A';
    final arrival = _formatDate(widget.data['arrivalDate']);
    final exit = _formatDate(widget.data['exitDate']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AllColors.fourthColor,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AllColors.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Name
          Expanded(
            flex: 3,
            child: Text(name, style: CustomText.memberBodyColor, overflow: TextOverflow.ellipsis),
          ),

          // Phone
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/PhoneCall.svg", height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(child: Text(phone, overflow: TextOverflow.ellipsis, style: CustomText.memberBodyColor)),
              ],
            ),
          ),

          // Email
          Expanded(
            flex: 4,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/mail.svg", height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(child: Text(email, overflow: TextOverflow.ellipsis, style: CustomText.memberBodyColor)),
              ],
            ),
          ),

          // State
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/place.svg", height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(child: Text(state, overflow: TextOverflow.ellipsis, style: CustomText.memberBodyColor)),
              ],
            ),
          ),

          // Arrival
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignIn.svg", height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(child: Text(arrival, overflow: TextOverflow.ellipsis, style: CustomText.memberBodyColor)),
              ],
            ),
          ),

          // Exit
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SvgPicture.asset("assets/icons/SignOut.svg", height: 20, width: 20),
                const SizedBox(width: 6),
                Expanded(child: Text(exit, overflow: TextOverflow.ellipsis, style: CustomText.memberBodyColor)),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isApproving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                    )
                  : IconButton(
                      icon: const Icon(Icons.check, color: Colors.green, size: 28),
                      onPressed: isRejecting ? null : _approve,
                      tooltip: "Approve",
                    ),
              const SizedBox(width: 8),
              isRejecting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                    )
                  : IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 28),
                      onPressed: isApproving ? null : _reject,
                      tooltip: "Reject",
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

