import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool showUpcoming = true;

  static const Color primaryGreen = Color(0xFF1A6B3C);
  static const Color lightGreen = Color(0xFFE3F3EA);
  static const Color softBackground = Color(0xFFF7F7F7);

  Stream<QuerySnapshot> _bookingStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  DateTime? _parseBookingDate(String dateText) {
    try {
      final parts = dateText.split('-');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  bool _isUpcoming(Map<String, dynamic> data) {
    final status = data['status']?.toString().toLowerCase() ?? '';
    final dateText = data['date']?.toString() ?? '';
    final bookingDate = _parseBookingDate(dateText);

    if (status == 'completed' || status == 'cancelled') {
      return false;
    }

    if (bookingDate == null) {
      return true;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingOnlyDate = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
    );

    return bookingOnlyDate.isAtSameMomentAs(today) ||
        bookingOnlyDate.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Row(
              children: [
                _buildTabButton(
                  label: 'Upcoming',
                  selected: showUpcoming,
                  onTap: () {
                    setState(() {
                      showUpcoming = true;
                    });
                  },
                ),
                const SizedBox(width: 10),
                _buildTabButton(
                  label: 'Past',
                  selected: !showUpcoming,
                  onTap: () {
                    setState(() {
                      showUpcoming = false;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _bookingStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading bookings.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final upcoming = _isUpcoming(data);
                  return showUpcoming ? upcoming : !upcoming;
                }).toList();

                filteredDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aDate = _parseBookingDate(aData['date']?.toString() ?? '');
                  final bDate = _parseBookingDate(bData['date']?.toString() ?? '');

                  if (aDate == null || bDate == null) return 0;

                  return showUpcoming
                      ? aDate.compareTo(bDate)
                      : bDate.compareTo(aDate);
                });

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      showUpcoming
                          ? 'No upcoming bookings yet.'
                          : 'No past bookings yet.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;

                    return _buildBookingCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primaryGreen : softBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> data) {
    final outletName = data['outletName']?.toString() ?? 'Unknown Outlet';
    final courtNumber = data['courtNumber']?.toString() ?? '-';
    final date = data['date']?.toString() ?? '-';
    final timeSlot = data['timeSlot']?.toString() ?? '-';
    final endTime = data['endTime']?.toString() ?? '-';
    final duration = data['duration']?.toString() ?? '-';
    final status = data['status']?.toString() ?? 'pending';

    final totalPriceValue = data['totalPrice'];
    final totalPrice = totalPriceValue is num
        ? totalPriceValue.toDouble()
        : double.tryParse(totalPriceValue.toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_tennis, color: primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  outletName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.meeting_room_outlined, 'Court $courtNumber'),
          _buildInfoRow(Icons.calendar_today_outlined, date),
          _buildInfoRow(Icons.access_time, '$timeSlot - $endTime'),
          _buildInfoRow(Icons.timelapse, '$duration hour(s)'),
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'RM ${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final lower = status.toLowerCase();

    Color background;
    Color textColor;
    String label;

    if (lower == 'confirmed') {
      background = lightGreen;
      textColor = primaryGreen;
      label = 'Confirmed';
    } else if (lower == 'cancelled') {
      background = const Color(0xFFFFE0E0);
      textColor = Colors.red;
      label = 'Cancelled';
    } else if (lower == 'completed') {
      background = Colors.grey.shade200;
      textColor = Colors.black54;
      label = 'Completed';
    } else {
      background = const Color(0xFFFFF0D6);
      textColor = const Color(0xFFB36B00);
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}