import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0D2B),
                  Color(0xFF1A1A4E),
                  Color(0xFF1E2070),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildStatsGrid(),
                        const SizedBox(height: 28),
                        _sectionTitle('Quick Actions'),
                        const SizedBox(height: 14),
                        _buildQuickActions(context),
                        const SizedBox(height: 28),
                        _sectionTitle('Recent Activity'),
                        const SizedBox(height: 14),
                        _buildRecentActivity(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Spacer(),
          Text(
            'Admin Panel',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            icon: const Icon(Icons.logout, color: Colors.white70, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, Admin',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's what's happening today.",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: [
        _statCard('Total Courts', '8', Icons.sports_tennis, const Color(0xFF4CAF50)),
        _statCard('Today\'s Bookings', '24', Icons.calendar_today, const Color(0xFF2196F3)),
        _statCard('Active Users', '137', Icons.people, const Color(0xFF9C27B0)),
        _statCard('Revenue (RM)', '1,840', Icons.attach_money, const Color(0xFFFF9800)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      _QuickAction('Manage Courts', Icons.sports_tennis, Color(0xFF4CAF50), '/manage-courts'),
      _QuickAction('All Bookings', Icons.event_note, Color(0xFF2196F3), '/all-bookings'),
    ];

    return Row(
      children: [
        Expanded(child: _actionCard(context, actions[0])),
        const SizedBox(width: 14),
        Expanded(child: _actionCard(context, actions[1])),
      ],
    );
  }

  Widget _actionCard(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: () {
        if (action.route != null) Navigator.pushNamed(context, action.route!);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: action.color, size: 20),
            ),
            Text(
              action.label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    const activities = [
      _Activity('Court A · Badminton', 'Booked by Ali Hassan', '10:00 AM', Icons.check_circle, Colors.greenAccent),
      _Activity('Court B · Tennis', 'Cancelled by Nurul Ain', '11:30 AM', Icons.cancel, Colors.redAccent),
      _Activity('Court C · Basketball', 'Booked by Raj Kumar', '1:00 PM', Icons.check_circle, Colors.greenAccent),
      _Activity('Court D · Badminton', 'Booked by Sara Lee', '3:30 PM', Icons.check_circle, Colors.greenAccent),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: List.generate(activities.length, (i) {
          final a = activities[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(a.icon, color: a.color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.court,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            a.detail,
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      a.time,
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (i < activities.length - 1)
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            ],
          );
        }),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String? route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}

class _Activity {
  final String court;
  final String detail;
  final String time;
  final IconData icon;
  final Color color;
  const _Activity(this.court, this.detail, this.time, this.icon, this.color);
}
