import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final String outletId;
  final String outletName;
  final String outletType;
  final String location;

  const BookingScreen({
    super.key,
    required this.outletId,
    required this.outletName,
    required this.outletType,
    required this.location,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ---- STEP TRACKER ----
  int _currentStep = 1; // 1 = date/time, 2 = court map, 3 = confirm

  // ---- STEP 1 STATE ----
  DateTime _selectedDate = DateTime.now();
  int _selectedDuration = 1;
  String? _selectedTimeSlot;

  // ---- STEP 2 STATE ----
  String? _selectedCourtId;
  String? _selectedCourtNumber;
  double _selectedCourtPrice = 0;
  List<String> _bookedCourtIds = [];

  // ---- LOADING ----
  bool _isLoading = false;
  bool _isFetchingCourts = false;

  final List<int> _durations = [1, 2, 3, 4];
  final List<String> _timeSlots = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
    '10:00 PM',
    '11:00 PM',
  ];

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String _getEndTime() {
    if (_selectedTimeSlot == null) return '';
    final index = _timeSlots.indexOf(_selectedTimeSlot!);
    final endIndex = index + _selectedDuration;
    if (endIndex >= _timeSlots.length) return 'End of day';
    return _timeSlots[endIndex];
  }

  // ---- FETCH BOOKED COURTS FOR SELECTED DATE + TIME ----
  Future<void> _fetchBookedCourts() async {
    setState(() => _isFetchingCourts = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('outletId', isEqualTo: widget.outletId)
        .where('date', isEqualTo: _formatDate(_selectedDate))
        .where('timeSlot', isEqualTo: _selectedTimeSlot)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    final List<String> booked = snapshot.docs
        .map((doc) => (doc.data())['courtId'] as String)
        .toList();

    setState(() {
      _bookedCourtIds = booked;
      _selectedCourtId = null;
      _selectedCourtNumber = null;
      _isFetchingCourts = false;
    });
  }

  // ---- CONFIRM BOOKING ----
  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('You must be logged in to book.');
        return;
      }

      final double totalPrice = _selectedCourtPrice * _selectedDuration;

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'outletId': widget.outletId,
        'outletName': widget.outletName,
        'courtId': _selectedCourtId,
        'courtNumber': _selectedCourtNumber,
        'date': _formatDate(_selectedDate),
        'timeSlot': _selectedTimeSlot,
        'duration': _selectedDuration,
        'endTime': _getEndTime(),
        'totalPrice': totalPrice,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) _showSuccess(totalPrice);
    } catch (e) {
      _showError('Booking failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(double totalPrice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Booking Submitted!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.outletName}\n'
              'Court $_selectedCourtNumber\n'
              '${_formatDate(_selectedDate)} · $_selectedTimeSlot\n'
              'Duration: $_selectedDuration hour(s)\n'
              'Total: RM ${totalPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6B3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/my-bookings');
                },
                child: const Text('View My Bookings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.outletName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // ---- OUTLET INFO BANNER ----
          Container(
            width: double.infinity,
            color: const Color(0xFF1A6B3C),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  widget.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // ---- STEP INDICATOR ----
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildStepIndicator(1, 'Date & Time'),
                _buildStepDivider(),
                _buildStepIndicator(2, 'Select Court'),
                _buildStepDivider(),
                _buildStepIndicator(3, 'Confirm'),
              ],
            ),
          ),

          // ---- STEP CONTENT ----
          Expanded(
            child: _currentStep == 1
                ? _buildStep1()
                : _currentStep == 2
                ? _buildStep2()
                : _buildStep3(),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // STEP 1 — SELECT DATE & TIME
  // ========================================================
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SELECT DATE
          _buildSectionTitle('Select Date'),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected =
                    _selectedDate.day == date.day &&
                    _selectedDate.month == date.month;
                final dayNames = [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                ];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 52,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A6B3C)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A6B3C)
                            : Colors.black12,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayNames[date.weekday % 7],
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // SELECT DURATION
          _buildSectionTitle('Duration'),
          Row(
            children: _durations.map((dur) {
              final isSelected = _selectedDuration == dur;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDuration = dur),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A6B3C)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A6B3C)
                            : Colors.black12,
                      ),
                    ),
                    child: Text(
                      dur == 1 ? '1 hr' : '$dur hrs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // SELECT START TIME
          _buildSectionTitle('Start Time'),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate the exact width for 3 items per row, accounting for spacing
              final double itemWidth = (constraints.maxWidth - 16) / 3;

              return Wrap(
                spacing: 8, // Horizontal space between boxes
                runSpacing: 8, // Vertical space between rows
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;

                  // 🕒 LIVE TIME FILTERING LOGIC
                  final now = DateTime.now();
                  bool isPast = false;

                  if (_selectedDate.year == now.year &&
                      _selectedDate.month == now.month &&
                      _selectedDate.day == now.day) {
                    final parts = slot.split(' ');
                    final timeParts = parts[0].split(':');
                    int slotHour = int.parse(timeParts[0]);
                    final isPm = parts[1] == 'PM';

                    if (isPm && slotHour != 12) slotHour += 12;
                    if (!isPm && slotHour == 12) slotHour = 0;

                    if (slotHour <= now.hour) {
                      isPast = true;
                    }
                  }

                  // If it's in the past, return a zero-size widget.
                  // Wrap collapses its height automatically!
                  if (isPast) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeSlot = slot),
                    child: Container(
                      width: itemWidth,
                      height: 42, // Keeps the clean, compact asset ratio
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A6B3C)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A6B3C)
                              : Colors.black12,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          slot,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // NEXT BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6B3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _selectedTimeSlot == null
                  ? null
                  : () async {
                      await _fetchBookedCourts();
                      setState(() => _currentStep = 2);
                    },
              child: const Text(
                'Next — Select Court',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ========================================================
  // STEP 2 — VISUAL COURT MAP
  // ========================================================
  Widget _buildStep2() {
    return Column(
      children: [
        // Selected date/time summary
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Color(0xFF1A6B3C),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Color(0xFF1A6B3C),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_selectedTimeSlot · $_selectedDuration hr(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _currentStep = 1),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1A6B3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isFetchingCourts
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1A6B3C)),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('outlets')
                      .doc(widget.outletId)
                      .collection('courts')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A6B3C),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No courts found for this outlet.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    final courts = snapshot.data!.docs;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Legend
                          Row(
                            children: [
                              _buildLegend(Colors.green, 'Available'),
                              const SizedBox(width: 16),
                              _buildLegend(Colors.red, 'Booked'),
                              const SizedBox(width: 16),
                              _buildLegend(const Color(0xFF1A6B3C), 'Selected'),
                            ],
                          ),

                          const SizedBox(height: 12),

                          const Center(
                            child: Text(
                              '[Choose a court]',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A6B3C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ---- COURT VISUAL GRID ----
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount: courts.length,
                            itemBuilder: (context, index) {
                              final data =
                                  courts[index].data() as Map<String, dynamic>;
                              final courtId = courts[index].id;
                              final courtNumber =
                                  data['courtNumber'] ?? '00${index + 1}';
                              final type = data['type'] ?? 'Court';
                              final price =
                                  double.tryParse(
                                    data['pricePerHour'].toString(),
                                  ) ??
                                  0.0;
                              final isBooked = _bookedCourtIds.contains(
                                courtId,
                              );
                              final isSelected = _selectedCourtId == courtId;

                              return _buildCourtBox(
                                courtId: courtId,
                                courtNumber: courtNumber,
                                type: type,
                                price: price,
                                isBooked: isBooked,
                                isSelected: isSelected,
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // NEXT BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedCourtId != null
                                    ? const Color(0xFF1A6B3C)
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _selectedCourtId == null
                                  ? null
                                  : () => setState(() => _currentStep = 3),
                              child: const Text(
                                'Next — Confirm Booking',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ========================================================
  // STEP 3 — CONFIRM BOOKING
  // ========================================================
  Widget _buildStep3() {
    final double totalPrice = _selectedCourtPrice * _selectedDuration;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Booking Summary'),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSummaryRow('Outlet', widget.outletName),
                _buildSummaryRow('Location', widget.location),
                _buildSummaryRow('Court', 'Court $_selectedCourtNumber'),
                _buildSummaryRow('Date', _formatDate(_selectedDate)),
                _buildSummaryRow('Start Time', _selectedTimeSlot ?? ''),
                _buildSummaryRow('End Time', _getEndTime()),
                _buildSummaryRow('Duration', '$_selectedDuration hour(s)'),
                const Divider(),
                _buildSummaryRow(
                  'Total Price',
                  'RM ${totalPrice.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // BACK BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A6B3C),
                side: const BorderSide(color: Color(0xFF1A6B3C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => setState(() => _currentStep = 2),
              child: const Text(
                'Back — Change Court',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // CONFIRM BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6B3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isLoading ? null : _confirmBooking,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ========================================================
  // HELPER WIDGETS
  // ========================================================
  Widget _buildCourtBox({
    required String courtId,
    required String courtNumber,
    required String type,
    required double price,
    required bool isBooked,
    required bool isSelected,
  }) {
    Color borderColor;
    Color bgColor;
    Color iconColor;

    if (isSelected) {
      borderColor = const Color(0xFF1A6B3C);
      bgColor = const Color(0xFF1A6B3C).withValues(alpha: 0.1);
      iconColor = const Color(0xFF1A6B3C);
    } else if (isBooked) {
      borderColor = Colors.red;
      bgColor = Colors.red.withValues(alpha: 0.05);
      iconColor = Colors.red;
    } else {
      borderColor = Colors.green;
      bgColor = Colors.green.withValues(alpha: 0.05);
      iconColor = Colors.green;
    }

    IconData courtIcon;
    switch (type.toLowerCase()) {
      case 'futsal':
        courtIcon = Icons.sports_soccer;
        break;
      case 'basketball':
        courtIcon = Icons.sports_basketball;
        break;
      default:
        courtIcon = Icons.sports_tennis;
    }

    return GestureDetector(
      onTap: isBooked
          ? null
          : () => setState(() {
              if (_selectedCourtId == courtId) {
                _selectedCourtId = null;
                _selectedCourtNumber = null;
                _selectedCourtPrice = 0;
              } else {
                _selectedCourtId = courtId;
                _selectedCourtNumber = courtNumber;
                _selectedCourtPrice = price;
              }
            }),
      child: Column(
        children: [
          Text(
            courtNumber,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFF1A6B3C) : Colors.black45,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2.5 : 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(courtIcon, color: iconColor, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: iconColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'RM${price.toStringAsFixed(0)}/hr',
                    style: TextStyle(
                      fontSize: 9,
                      color: iconColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final bool isActive = _currentStep == step;
    final bool isDone = _currentStep > step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive || isDone
                  ? const Color(0xFF1A6B3C)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : Text(
                      '$step',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.black38,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF1A6B3C) : Colors.black38,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.black12,
        margin: const EdgeInsets.only(bottom: 18),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? const Color(0xFF1A6B3C) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
