import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookSlotScreen extends StatefulWidget {
  final String courtId;
  final String courtName;
  final String courtType;
  final String location;
  final double pricePerHour;
  final bool isAvailable;

  const BookSlotScreen({
    super.key,
    required this.courtId,
    required this.courtName,
    required this.courtType,
    required this.location,
    required this.pricePerHour,
    required this.isAvailable,
  });

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedDuration = 1;
  String? _selectedTimeSlot;
  bool _isLoading = false;

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
  ];

  List<String> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    final String dateStr = _formatDate(_selectedDate);

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('courtId', isEqualTo: widget.courtId)
        .where('date', isEqualTo: dateStr)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    final List<String> booked = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      booked.add(data['timeSlot']);
    }

    setState(() {
      _bookedSlots = booked;
      _selectedTimeSlot = null;
    });
  }

  Future<void> _confirmBooking() async {
    if (_selectedTimeSlot == null) {
      _showError('Please select a time slot');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('You must be logged in to book.');
        return;
      }

      final String dateStr = _formatDate(_selectedDate);
      final double totalPrice = widget.pricePerHour * _selectedDuration;

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'courtId': widget.courtId,
        'courtName': widget.courtName,
        'courtType': widget.courtType,
        'location': widget.location,
        'date': dateStr,
        'timeSlot': _selectedTimeSlot,
        'duration': _selectedDuration,
        'totalPrice': totalPrice,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSuccess();
      }
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

  void _showSuccess() {
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
              'Your booking for ${widget.courtName} on '
              '${_formatDate(_selectedDate)} at '
              '$_selectedTimeSlot has been submitted.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A6B),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book a Slot',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // ---- AVAILABILITY BANNER ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: widget.isAvailable
                ? Colors.green.shade500
                : Colors.red.shade500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isAvailable
                      ? 'Court is Available for Booking'
                      : 'Court is Currently Unavailable',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ---- SCROLLABLE CONTENT ----
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- COURT INFO CARD ----
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
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1A3A6B,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.courtType.toLowerCase() == 'futsal'
                                ? Icons.sports_soccer
                                : widget.courtType.toLowerCase() == 'basketball'
                                ? Icons.sports_basketball
                                : Icons.sports_tennis,
                            color: const Color(0xFF1A3A6B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.courtName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.courtType} · ${widget.location}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'RM ${widget.pricePerHour.toStringAsFixed(0)} / hour',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1A3A6B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: widget.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.isAvailable
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: widget.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---- SELECT DATE ----
                  _buildSectionTitle('Select Date'),
                  SizedBox(
                    height: 72,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
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
                          onTap: () {
                            setState(() => _selectedDate = date);
                            _fetchBookedSlots();
                          },
                          child: Container(
                            width: 52,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1A3A6B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1A3A6B)
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
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
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

                  // ---- DURATION ----
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
                                  ? const Color(0xFF1A3A6B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1A3A6B)
                                    : Colors.black12,
                              ),
                            ),
                            child: Text(
                              dur == 1 ? '1 hr' : '$dur hrs',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // ---- START TIME ----
                  _buildSectionTitle('Start Time'),
                  Row(
                    children: [
                      _buildLegend(Colors.grey.shade200, 'Booked'),
                      const SizedBox(width: 12),
                      _buildLegend(
                        const Color(0xFF1A3A6B).withValues(alpha: 0.1),
                        'Available',
                      ),
                      const SizedBox(width: 12),
                      _buildLegend(const Color(0xFF1A3A6B), 'Selected'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _timeSlots[index];
                      final isBooked = _bookedSlots.contains(slot);
                      final isSelected = _selectedTimeSlot == slot;

                      Color bgColor;
                      Color textColor;
                      if (isSelected) {
                        bgColor = const Color(0xFF1A3A6B);
                        textColor = Colors.white;
                      } else if (isBooked) {
                        bgColor = Colors.grey.shade200;
                        textColor = Colors.black38;
                      } else {
                        bgColor = const Color(
                          0xFF1A3A6B,
                        ).withValues(alpha: 0.1);
                        textColor = const Color(0xFF1A3A6B);
                      }

                      return GestureDetector(
                        onTap: isBooked || !widget.isAvailable
                            ? null
                            : () => setState(() => _selectedTimeSlot = slot),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ---- BOOKING SUMMARY ----
                  if (_selectedTimeSlot != null) ...[
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
                          _buildSummaryRow('Court', widget.courtName),
                          _buildSummaryRow('Date', _formatDate(_selectedDate)),
                          _buildSummaryRow(
                            'Time',
                            '$_selectedTimeSlot → ${_getEndTime()}',
                          ),
                          _buildSummaryRow(
                            'Duration',
                            '$_selectedDuration hour(s)',
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            'Total',
                            'RM ${(widget.pricePerHour * _selectedDuration).toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ---- CONFIRM BUTTON ----
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isAvailable
                            ? const Color(0xFF1A3A6B)
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: widget.isAvailable && !_isLoading
                          ? _confirmBooking
                          : null,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.isAvailable
                                  ? 'Confirm Booking'
                                  : 'Court Unavailable',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black12),
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
              color: isBold ? const Color(0xFF1A3A6B) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
