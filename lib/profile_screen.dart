import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data_storage.dart';
import 'login_screen.dart';
import 'user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
    });

    final fetched = await DataStorage.instance.getUserProfile();

    if (mounted) {
      setState(() {
        userProfile = fetched;
        isLoading = false;
      });
    }
  }

  void _openEditProfileDialog() {
    if (userProfile == null) return;

    final nameController = TextEditingController(text: userProfile!.name);
    final ageController = TextEditingController(text: userProfile!.age);
    final heightController = TextEditingController(text: userProfile!.height);
    final weightController = TextEditingController(text: userProfile!.weight);
    final allergiesController = TextEditingController(text: userProfile!.allergies);
    final emergencyContactController =
        TextEditingController(text: userProfile!.emergencyContact);

    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    String selectedBloodGroup = bloodGroups.contains(userProfile!.bloodGroup)
        ? userProfile!.bloodGroup
        : 'B+';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Edit Profile Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Full Name', nameController, Icons.person_outline),
                    _buildTextField(
                      'Age',
                      ageController,
                      Icons.cake_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildDropdownField(
                      'Blood Group',
                      selectedBloodGroup,
                      bloodGroups,
                      Icons.bloodtype_outlined,
                      (val) {
                        if (val != null) {
                          setBottomSheetState(() {
                            selectedBloodGroup = val;
                          });
                        }
                      },
                    ),
                    _buildTextField('Height', heightController, Icons.height),
                    _buildTextField('Weight', weightController, Icons.monitor_weight_outlined),
                    _buildTextField('Allergies', allergiesController, Icons.warning_amber_rounded),
                    _buildTextField('Emergency Contact', emergencyContactController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final updated = userProfile!.copyWith(
                            name: nameController.text.trim(),
                            age: ageController.text.trim(),
                            bloodGroup: selectedBloodGroup,
                            height: heightController.text.trim(),
                            weight: weightController.text.trim(),
                            allergies: allergiesController.text.trim(),
                            emergencyContact: emergencyContactController.text.trim(),
                          );

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          navigator.pop();

                          setState(() {
                            isLoading = true;
                          });

                          await DataStorage.instance.saveUserProfile(updated);
                          await _loadProfile();

                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Changes Saved'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    String currentValue,
    List<String> items,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    final validValue = items.contains(currentValue) ? currentValue : items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: validValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        items: items.map((bg) {
          return DropdownMenuItem<String>(
            value: bg,
            child: Text(bg),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final profile = userProfile ??
        UserProfile(
          uid: 'unknown',
          email: 'unknown@meditrak.app',
          name: 'User',
        );

    final avatarChar = profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : (profile.email.isNotEmpty ? profile.email[0].toUpperCase() : 'U');

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your health profile',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _openEditProfileDialog,
                    icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.blue,
                      child: Text(
                        avatarChar,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profile.name.isNotEmpty ? profile.name : 'MediTrak User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Health Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              buildInfoCard(Icons.email_outlined, 'Email', profile.email),
              buildInfoCard(Icons.cake_outlined, 'Age', profile.age.isNotEmpty ? profile.age : 'Not specified'),
              buildInfoCard(Icons.bloodtype_outlined, 'Blood Group', profile.bloodGroup.isNotEmpty ? profile.bloodGroup : 'Not specified'),
              buildInfoCard(Icons.height, 'Height', profile.height.isNotEmpty ? profile.height : 'Not specified'),
              buildInfoCard(Icons.monitor_weight_outlined, 'Weight', profile.weight.isNotEmpty ? profile.weight : 'Not specified'),
              buildInfoCard(Icons.warning_amber_rounded, 'Allergies', profile.allergies.isNotEmpty ? profile.allergies : 'None'),
              buildInfoCard(Icons.phone_outlined, 'Emergency Contact', profile.emergencyContact.isNotEmpty ? profile.emergencyContact : 'Not specified'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await DataStorage.instance.setLoggedIn(false);
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String label, String value) {
    return Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
