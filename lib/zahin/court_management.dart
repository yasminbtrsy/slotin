import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CourtType { badminton, tennis, basketball, futsal }

enum CourtStatus { available, maintenance, booked }

class _Court {
  String id;
  String name;
  CourtType type;
  String location;
  CourtStatus status;
  double pricePerHour;

  _Court({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.status,
    required this.pricePerHour,
  });
}

class ManageCourtsScreen extends StatefulWidget {
  const ManageCourtsScreen({super.key});

  @override
  State<ManageCourtsScreen> createState() => _ManageCourtsScreenState();
}

class _ManageCourtsScreenState extends State<ManageCourtsScreen> {
  final List<_Court> _courts = [
    _Court(id: '1', name: 'Court A', type: CourtType.badminton, location: 'Block 1, Level 2', status: CourtStatus.available, pricePerHour: 15),
    _Court(id: '2', name: 'Court B', type: CourtType.tennis, location: 'Block 2, Outdoor', status: CourtStatus.booked, pricePerHour: 20),
    _Court(id: '3', name: 'Court C', type: CourtType.basketball, location: 'Block 3, Level 1', status: CourtStatus.maintenance, pricePerHour: 25),
    _Court(id: '4', name: 'Court D', type: CourtType.badminton, location: 'Block 1, Level 3', status: CourtStatus.available, pricePerHour: 15),
    _Court(id: '5', name: 'Court E', type: CourtType.futsal, location: 'Block 4, Outdoor', status: CourtStatus.available, pricePerHour: 30),
  ];

  void _showCourtDialog({_Court? court}) {
    final nameController = TextEditingController(text: court?.name ?? '');
    final locationController = TextEditingController(text: court?.location ?? '');
    final priceController = TextEditingController(
      text: court != null ? court.pricePerHour.toStringAsFixed(0) : '',
    );
    var selectedType = court?.type ?? CourtType.badminton;
    var selectedStatus = court?.status ?? CourtStatus.available;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A4E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            court == null ? 'Add New Court' : 'Edit Court',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameController, 'Court Name', 'e.g. Court A'),
                const SizedBox(height: 14),
                _dialogField(locationController, 'Location', 'e.g. Block 1, Level 2'),
                const SizedBox(height: 14),
                _dialogField(priceController, 'Price per Hour (RM)', 'e.g. 15', isNumber: true),
                const SizedBox(height: 14),
                _dialogDropdown<CourtType>(
                  label: 'Court Type',
                  value: selectedType,
                  items: CourtType.values,
                  itemLabel: _typeName,
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 14),
                _dialogDropdown<CourtStatus>(
                  label: 'Status',
                  value: selectedStatus,
                  items: CourtStatus.values,
                  itemLabel: _statusName,
                  onChanged: (v) => setDialogState(() => selectedStatus = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                setState(() {
                  if (court == null) {
                    _courts.add(_Court(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      type: selectedType,
                      location: locationController.text.trim(),
                      status: selectedStatus,
                      pricePerHour: double.tryParse(priceController.text) ?? 0,
                    ));
                  } else {
                    court.name = nameController.text.trim();
                    court.type = selectedType;
                    court.location = locationController.text.trim();
                    court.status = selectedStatus;
                    court.pricePerHour =
                        double.tryParse(priceController.text) ?? court.pricePerHour;
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text(
                court == null ? 'Add' : 'Save',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A4E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Court',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this court?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() => _courts.removeWhere((c) => c.id == id));
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        '${_courts.length} courts total',
                        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
                      ),
                      const Spacer(),
                      _legend(Colors.greenAccent, 'Available'),
                      const SizedBox(width: 14),
                      _legend(Colors.orangeAccent, 'Booked'),
                      const SizedBox(width: 14),
                      _legend(Colors.redAccent, 'Maintenance'),
                    ],
                  ),
                ),
                Expanded(
                  child: _courts.isEmpty
                      ? Center(
                          child: Text(
                            'No courts yet. Tap + to add one.',
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _courts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _courtCard(_courts[i]),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourtDialog(),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
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
            'Court Management',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _courtCard(_Court court) {
    final statusColor = switch (court.status) {
      CourtStatus.available => Colors.greenAccent,
      CourtStatus.booked => Colors.orangeAccent,
      CourtStatus.maintenance => Colors.redAccent,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_typeIcon(court.type), color: const Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      court.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusName(court.status),
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_typeName(court.type)} · ${court.location}',
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  'RM ${court.pricePerHour.toStringAsFixed(0)}/hr',
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _showCourtDialog(court: court),
                icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () => _confirmDelete(court.id),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _dialogDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A4E),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              items: items
                  .map((item) => DropdownMenuItem(value: item, child: Text(itemLabel(item))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  IconData _typeIcon(CourtType type) => switch (type) {
        CourtType.badminton => Icons.sports_tennis,
        CourtType.tennis => Icons.sports,
        CourtType.basketball => Icons.sports_basketball,
        CourtType.futsal => Icons.sports_soccer,
      };

  String _typeName(CourtType type) => switch (type) {
        CourtType.badminton => 'Badminton',
        CourtType.tennis => 'Tennis',
        CourtType.basketball => 'Basketball',
        CourtType.futsal => 'Futsal',
      };

  String _statusName(CourtStatus s) => switch (s) {
        CourtStatus.available => 'Available',
        CourtStatus.maintenance => 'Maintenance',
        CourtStatus.booked => 'Booked',
      };
}
