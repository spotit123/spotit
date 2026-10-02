import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/l10n.dart';
import '../models/bar.dart';
import '../models/booking.dart';
import '../services/db_service.dart';
import '../services/share_service.dart';

class BookingScreen extends StatefulWidget {
  final Bar bar;

  const BookingScreen({
    super.key,
    required this.bar,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  int _guestCount = 2;
  String _selectedTime = '21:00';
  final List<String> _timeSlots = ['20:00', '20:30', '21:00', '21:30', '22:00', '22:30'];
  final bool _joinPriorityList = false;
  final _requestsController = TextEditingController();

  @override
  void dispose() {
    _requestsController.dispose();
    super.dispose();
  }

  void _confirmBooking() async {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      barId: widget.bar.id,
      barName: widget.bar.name,
      barImageUrl: widget.bar.imageUrl,
      date: '${_selectedDate.day}/${_selectedDate.month}',
      time: _selectedTime,
      guestCount: _guestCount,
      specialRequests: _requestsController.text,
      joinPriorityList: _joinPriorityList,
    );

    await DbService.addBooking(booking);

    if (!mounted) return;

    // Show confirmation modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                tr('book.savedTitle'),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tr('book.savedBody', {
                  'guests': _guestCount,
                  'date': '${_selectedDate.day}/${_selectedDate.month}',
                  'time': _selectedTime,
                  'name': widget.bar.name,
                }),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              if (widget.bar.phone != 'N/D') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: widget.bar.phone.replaceAll(' ', ''))),
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text(tr('book.call'), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => shareOnWhatsApp(
                    '${tr('book.whatsappMsg', {
                      'name': widget.bar.name,
                      'date': '${_selectedDate.day}/${_selectedDate.month}',
                      'time': _selectedTime,
                      'guests': _guestCount,
                    })}\n📍 ${widget.bar.address}\n${mapsLink(widget.bar)}',
                  ),
                  icon: const Icon(Icons.share, size: 18, color: Color(0xFF25D366)),
                  label: Text(tr('book.whatsapp'),
                      style: GoogleFonts.poppins(color: const Color(0xFF25D366), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF25D366)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Close booking screen and return true
                  },
                  child: Text(tr('book.close'), style: GoogleFonts.poppins(color: Colors.grey[400], fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0066FF),
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bar = widget.bar;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Premium dark theme background
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('book.title'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Circle Avatar Bar Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        bar.imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Venue Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bar.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${bar.rating} (${bar.reviewCount} recensioni)',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Live Capacity
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tr('book.crowd', {'n': bar.crowdDensity}),
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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

              const SizedBox(height: 24),
              Text(
                tr('book.details'),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Date & Guest Pickers Row
              Row(
                children: [
                  // Date Picker Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Color(0xFF0066FF), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr('book.date'),
                                    style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 11),
                                  ),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}',
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Guests Picker Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people_outline, color: Color(0xFF0066FF), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _guestCount,
                                dropdownColor: const Color(0xFF131B2E),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                isExpanded: true,
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                items: List.generate(10, (index) => index + 1).map((val) {
                                  return DropdownMenuItem<int>(
                                    value: val,
                                    child: Text('$val Persone'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _guestCount = val!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('book.selectTime'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    tr('book.peak'),
                    style: GoogleFonts.poppins(
                      color: Colors.pink[400],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time slots grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _timeSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),
              Text(
                tr('book.prefs'),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Special Requests text field
              Text(
                tr('book.special'),
                style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _requestsController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: tr('book.specialHint'),
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF131B2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 20),


              const SizedBox(height: 32),

              // Bottom Booking Action Sheet Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('book.free'),
                          style: GoogleFonts.poppins(
                            color: Colors.greenAccent[400],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tr('book.noCost'),
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.confirmation_num_outlined, size: 18),
                      label: Text(
                        tr('book.confirm'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
