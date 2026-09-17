import 'package:flutter/material.dart';
import 'main.dart';

class ProgressScreen extends StatelessWidget {
  final List<Medicine> medicines;

  const ProgressScreen({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    int totalCount = medicines.length;
    int takenCount = 0;
    for (var med in medicines) {
      if (med.taken) {
        takenCount = takenCount + 1;
      }
    }

    double progressValue = 0.0;
    if (totalCount > 0) {
      progressValue = takenCount / totalCount;
    }

    String percentText = '0%';
    if (totalCount > 0) {
      int percent = (progressValue * 100).round();
      percentText = '$percent%';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your medication progress',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Icon(
                    Icons.trending_up,
                    size: 48,
                    color: Color(0xFF4A90D9),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Medication Adherence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90D9)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    percentText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$takenCount of $totalCount medicines taken today',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (medicines.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var med = medicines[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            med.taken ? Icons.check_circle : Icons.circle_outlined,
                            color: med.taken ? const Color(0xFF4CAF50) : Colors.grey[400],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              med.name,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ),
                          Text(
                            med.taken ? 'Taken' : 'Not taken',
                            style: TextStyle(
                              fontSize: 13,
                              color: med.taken ? const Color(0xFF4CAF50) : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (medicines.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Add medicines to track progress',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
