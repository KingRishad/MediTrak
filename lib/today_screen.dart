import 'package:flutter/material.dart';
import 'main.dart';
import 'add_medicine_screen.dart';

class TodayScreen extends StatefulWidget {
  final List<Medicine> medicines;

  const TodayScreen({super.key, required this.medicines});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {

  IconData getFormIcon(String form) {
    if (form == 'Tablet') return Icons.medication;
    if (form == 'Capsule') return Icons.circle;
    if (form == 'Liquid') return Icons.water_drop;
    if (form == 'Lotion') return Icons.sanitizer;
    if (form == 'Spray') return Icons.air;
    return Icons.medication;
  }

  Color getFormColor(String form) {
    if (form == 'Tablet') return const Color(0xFF4A90D9);
    if (form == 'Capsule') return const Color(0xFFE57373);
    if (form == 'Liquid') return const Color(0xFF81C784);
    if (form == 'Lotion') return const Color(0xFFFFB74D);
    if (form == 'Spray') return const Color(0xFF9575CD);
    return const Color(0xFF4A90D9);
  }

  void openAddMedicineScreen() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
    );
    if (result != null && result is Medicine) {
      setState(() {
        widget.medicines.add(result);
      });
    }
  }

  void toggleTaken(int index) {
    setState(() {
      widget.medicines[index].taken = !widget.medicines[index].taken;
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var weekStart = now.subtract(Duration(days: now.weekday % 7));
    List<String> dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today Medicine',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[600], size: 22),
                    const SizedBox(width: 12),
                    Icon(Icons.link, color: Colors.grey[600], size: 22),
                    const SizedBox(width: 12),
                    Icon(Icons.settings, color: Colors.grey[600], size: 22),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                var day = weekStart.add(Duration(days: index));
                bool isToday = day.day == now.day &&
                    day.month == now.month &&
                    day.year == now.year;

                return Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday ? const Color(0xFF4A90D9) : Colors.grey[500],
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFF4A90D9) : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isToday ? Colors.white : const Color(0xFF2D3142),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.medicines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication_liquid, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No medicines added yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add Med" to get started',
                          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: widget.medicines.length,
                    itemBuilder: (context, index) {
                      var med = widget.medicines[index];
                      Color iconColor = getFormColor(med.form);

                      return Opacity(
                        opacity: med.taken ? 0.5 : 1.0,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  getFormIcon(med.form),
                                  color: iconColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D3142),
                                        decoration: med.taken ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${med.quantity}, ${med.frequency}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                med.time,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => toggleTaken(index),
                                child: Icon(
                                  med.taken ? Icons.check_circle : Icons.check_circle_outline,
                                  color: med.taken ? const Color(0xFF4CAF50) : Colors.grey[400],
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: openAddMedicineScreen,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Med',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
