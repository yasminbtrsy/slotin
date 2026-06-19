import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = snapshot.data?.docs ?? [];

            final total = bookings.length;
            final upcoming = bookings.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Confirmed' || data['status'] == 'Pending';
            }).length;

            final completed = bookings.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Completed';
            }).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _dashboardCard(
                  title: 'Total Bookings',
                  value: total.toString(),
                  icon: Icons.calendar_month,
                ),

                _dashboardCard(
                  title: 'Upcoming Bookings',
                  value: upcoming.toString(),
                  icon: Icons.event_available,
                ),

                _dashboardCard(
                  title: 'Completed Bookings',
                  value: completed.toString(),
                  icon: Icons.check_circle_outline,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: bookings.isEmpty
                      ? const Center(child: Text('No booking activity yet'))
                      : ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final data = bookings[index].data()
                                as Map<String, dynamic>;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE2F6EF),
                                child: Icon(
                                  Icons.sports_tennis,
                                  color: Color(0xFF1A6B3C),
                                ),
                              ),
                              title: Text(data['courtName'] ?? 'Court booking'),
                              subtitle: Text(
                                '${data['bookingDate'] ?? ''} • ${data['startTime'] ?? ''}',
                              ),
                              trailing: Text(
                                data['status'] ?? 'Pending',
                                style: const TextStyle(
                                  color: Color(0xFF1A6B3C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE2F6EF),
            child: Icon(icon, color: const Color(0xFF1A6B3C)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}