import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation.dart';
import '../providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  
  // Personal details controllers
  final TextEditingController _nameController = TextEditingController(text: 'Jane Doe');
  final TextEditingController _phoneController = TextEditingController(text: '+65 9123 4567');
  final TextEditingController _addressController = TextEditingController(text: '45 Chancery Lane Singapore 309568');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(userReservationsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(fontFamily: 'Epilogue', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar and credentials
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.15),
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text,
                    style: const TextStyle(fontFamily: 'Epilogue', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const Text(
                    'jane.doe@foodrescue.org',
                    style: TextStyle(fontFamily: 'Work Sans', fontSize: 13, color: AppColors.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Personal Info Form Fields
            const Text(
              'Personal Information',
              style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildEditableField('Full Name', _nameController, Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildEditableField('Mobile Phone', _phoneController, Icons.phone_android_outlined),
                    const SizedBox(height: 12),
                    _buildEditableField('Default Address', _addressController, Icons.location_on_outlined, maxLines: 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Rescues horizontal list
            const Text(
              'Recent Completed Rescues',
              style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            reservationsAsync.when(
              data: (reservations) {
                final completed = reservations.where((r) => r.status == 'completed').toList();
                return _buildRecentRescuesRow(completed);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading history'),
            ),
            const SizedBox(height: 24),

            // Preferences / Settings rows
            const Text(
              'App Settings',
              style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications', style: TextStyle(fontFamily: 'Work Sans', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    subtitle: const Text('Alert for time-sensitive deals nearby', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                    value: _notificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.payment, color: AppColors.textPrimary),
                    title: const Text('Payment Methods', style: TextStyle(fontFamily: 'Work Sans', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    subtitle: const Text('NETS, PayLah!, Cards', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.security, color: AppColors.textPrimary),
                    title: const Text('Security & Privacy', style: TextStyle(fontFamily: 'Work Sans', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    subtitle: const Text('Passwords, biometrics, authorizations', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Solid black/dark Logout Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logging out is disabled in this experimental sandbox.'),
                    backgroundColor: AppColors.textPrimary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Work Sans', fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.outline),
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Work Sans', fontSize: 12, color: AppColors.outline),
        alignLabelWithHint: true,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      onSubmitted: (val) {
        setState(() {}); // Refresh displayed name if updated
      },
    );
  }

  Widget _buildRecentRescuesRow(List<Reservation> list) {
    if (list.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Text('No completed rescues yet.', style: TextStyle(fontSize: 12, color: AppColors.outline)),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final res = list[index];
          final item = res.foodItem;
          if (item == null) return const SizedBox.shrink();

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.outlineVariant),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.55),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.businessName,
                          style: const TextStyle(fontSize: 9, color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.impactGreen.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SAVED',
                            style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
