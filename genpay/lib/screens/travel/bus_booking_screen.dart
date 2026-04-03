import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';

class BusBookingScreen extends StatefulWidget {
  const BusBookingScreen({super.key});
  @override State<BusBookingScreen> createState() => _BusBookingScreenState();
}

class _BusBookingScreenState extends State<BusBookingScreen> {
  String _from = 'Mumbai';
  String _to = 'Pune';
  DateTime _date = DateTime.now().add(const Duration(days: 3));
  bool _searched = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _buses = [];

  void _search() async {
    setState(() => _isSearching = true);
    try {
      final result = await ApiService.searchBuses(
        origin: _from,
        destination: _to,
        date: '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
        busType: 'AC_SLEEPER',
      );
      _buses = result.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      _buses = [];
    }
    setState(() {
      _isSearching = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bus Booking'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20), color: Colors.white,
            child: Column(children: [
              Row(children: [
                Expanded(child: TextField(
                  decoration: InputDecoration(labelText: 'From', hintText: _from, prefixIcon: const Icon(Icons.location_on, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(onTap: () => setState(() { final t = _from; _from = _to; _to = t; }),
                    child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.lightBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.swap_vert, color: AppColors.primaryBlue, size: 20)))),
                Expanded(child: TextField(
                  decoration: InputDecoration(labelText: 'To', hintText: _to, prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                  if (d != null) setState(() => _date = d);
                },
                child: Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryBlue), const SizedBox(width: 8),
                    Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(fontWeight: FontWeight.w600))]))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(onPressed: _isSearching ? null : _search,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSearching
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Search Buses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            ]),
          ),
          if (_searched) ...[
            Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('${_buses.length} buses found', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            ..._buses.map((b) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text((b['operator'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                  Row(children: [const Icon(Icons.star, color: AppColors.warningYellow, size: 16), const SizedBox(width: 2),
                    Text('${b['rating'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
                ]),
                const SizedBox(height: 4),
                Text((b['bus_type'] ?? '').toString(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_formatTime((b['departure_time'] ?? '').toString()), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(_from, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  Text('${b['duration_minutes']}m', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_formatTime((b['arrival_time'] ?? '').toString()), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(_to, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ]),
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Rs ${b['price']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                    Text('${b['available_seats']} seats left', style: TextStyle(fontSize: 12, color: ((b['available_seats'] ?? 0) as int) < 10 ? AppColors.errorRed : AppColors.successGreen, fontWeight: FontWeight.w500)),
                  ]),
                  ElevatedButton(onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bus booking simulated!'), backgroundColor: AppColors.successGreen));
                  }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orangeCTA, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Select Seat', style: TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ]),
            )),
            const SizedBox(height: 20),
          ],
        ]),
      ),
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (_) {
      return raw;
    }
  }
}
