import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/mock_data_service.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});
  @override State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  String _from = 'Delhi (DEL)';
  String _to = 'Goa (GOI)';
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  int _passengers = 1;
  bool _searched = false;
  bool _isSearching = false;

  void _search() async {
    setState(() => _isSearching = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() { _isSearching = false; _searched = true; });
  }

  @override
  Widget build(BuildContext context) {
    final flights = MockDataService.getMockFlights();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Flight Booking'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20), color: Colors.white,
            child: Column(children: [
              // From-To
              Row(children: [
                Expanded(child: _buildCitySelector('From', _from, (v) => setState(() => _from = v))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(onTap: () => setState(() { final t = _from; _from = _to; _to = t; }),
                    child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.lightBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.swap_horiz, color: AppColors.primaryBlue, size: 20)))),
                Expanded(child: _buildCitySelector('To', _to, (v) => setState(() => _to = v))),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) setState(() => _date = d);
                  },
                  child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ])))),
                const SizedBox(width: 12),
                Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.person, size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Text('$_passengers Adult${_passengers > 1 ? 's' : ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(onTap: () { if (_passengers > 1) setState(() => _passengers--); },
                      child: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    GestureDetector(onTap: () => setState(() => _passengers++),
                      child: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primaryBlue)),
                  ]))),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(onPressed: _isSearching ? null : _search,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSearching
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Search Flights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            ]),
          ),
          if (_searched) ...[
            Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${flights.length} flights found', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, size: 18), label: const Text('Filter')),
              ])),
            ...flights.map((f) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(f['airline'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(f['code'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(children: [Text(f['departure'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), Text(_from.split(' ')[0], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]),
                  Column(children: [
                    Text(f['duration'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Container(width: 80, height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(vertical: 4)),
                    Text(f['stops'] as String, style: TextStyle(fontSize: 11, color: (f['stops'] as String) == 'Non-stop' ? AppColors.successGreen : AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ]),
                  Column(children: [Text(f['arrival'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), Text(_to.split(' ')[0], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]),
                ]),
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('₹${f['price']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  ElevatedButton(onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking simulated!'), backgroundColor: AppColors.successGreen));
                  }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orangeCTA, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Book', style: TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ]),
            )),
            const SizedBox(height: 20),
          ],
        ]),
      ),
    );
  }

  Widget _buildCitySelector(String label, String value, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
    );
  }
}
