import 'package:flutter/material.dart';
import 'main.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  var nameController = TextEditingController();
  var doseController = TextEditingController();
  String selectedForm = 'Tablet';
  String selectedQuantity = '2 pills';
  String selectedFrequency = 'Everyday';
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  List<String> quantityOptions = ['1 pill', '2 pills', '3 pills', '4 pills', '5 pills'];
  List<String> frequencyOptions = ['Everyday', 'Once a week', 'Twice a week', 'Every other day'];

  @override
  void dispose() {
    nameController.dispose();
    doseController.dispose();
    super.dispose();
  }

  IconData getFormIcon(String form) {
    if (form == 'Tablet') return Icons.medication;
    if (form == 'Capsule') return Icons.circle;
    if (form == 'Liquid') return Icons.water_drop;
    if (form == 'Lotion') return Icons.sanitizer;
    if (form == 'Spray') return Icons.air;
    return Icons.medication;
  }

  String formatTime(TimeOfDay time) {
    int hour = time.hourOfPeriod;
    if (hour == 0) hour = 12;
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void pickTime() async {
    var picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void saveMedicine() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a pill name')),
      );
      return;
    }

    var medicine = Medicine(
      name: nameController.text.trim(),
      form: selectedForm,
      quantity: selectedQuantity,
      dose: doseController.text.trim(),
      frequency: selectedFrequency,
      time: formatTime(selectedTime),
    );

    Navigator.pop(context, medicine);
  }

  Widget buildFormButton(String form) {
    bool isSelected = selectedForm == form;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedForm = form;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Icon(
              getFormIcon(form),
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            form,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blueGrey.shade900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Medicine',
          style: TextStyle(
            color: Colors.blueGrey.shade900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pill\'s Name',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter pill name',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Medicine Form',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildFormButton('Tablet'),
                buildFormButton('Capsule'),
                buildFormButton('Liquid'),
                buildFormButton('Lotion'),
                buildFormButton('Spray'),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pills Quantity',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedQuantity,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
                            style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade900),
                            items: List.generate(quantityOptions.length, (i) {
                              return DropdownMenuItem<String>(
                                value: quantityOptions[i],
                                child: Text(quantityOptions[i]),
                              );
                            }),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedQuantity = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dose(mg)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: doseController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter dose',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Set Frequency',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFrequency,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade900),
                  items: List.generate(frequencyOptions.length, (i) {
                    return DropdownMenuItem<String>(
                      value: frequencyOptions[i],
                      child: Text(frequencyOptions[i]),
                    );
                  }),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedFrequency = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Schedule Time',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[500], size: 22),
                    const SizedBox(width: 10),
                    Text(
                      formatTime(selectedTime),
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Save Medicine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
