import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/providers.dart';

/// Screen 5: Profile & Settings Screen.
/// Design defense context:
/// - Provides user profile configuration, account status, and system toggles.
/// - Demonstrates data cleanup capabilities by offering a "Reset Sandbox Data" button,
///   which iterates through reservations and purges the database, showcasing complete CRUD lifecycle control.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _ecoModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(userReservationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Info Header Card.
            _buildProfileHeader(),
            const SizedBox(height: 20),

            // Profile Stats.
            reservationsAsync.when(
              data: (reservations) {
                final completedCount = reservations.where((r) => r.status == 'completed').length;
                return _buildStatsRow(reservations.length, completedCount);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Settings Section.
            _buildSettingsList(ref),
            const SizedBox(height: 32),

            // Logo or tagline representing the sandbox environment.
            const Text(
              'FoodRescue Sandbox Environment v1.0.0\nRunning isolated Mock Architecture',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds profile name, email, avatar, and level status card.
  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Avatar.
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            const SizedBox(width: 20),
            // Details.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jane Doe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const Text(
                    'jane.doe@foodrescue.org',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary, width: 0.5),
                    ),
                    child: const Text(
                      'Level 4 Eco-Rescuer',
                      style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds quick badges summarizing reservations.
  Widget _buildStatsRow(int total, int completed) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text('$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Text('Total Claims', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text('$completed', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                const Text('Pickups Completed', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Settings preferences items list.
  Widget _buildSettingsList(WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          // Section Title.
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PREFERENCES',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.0),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Alert me when food is expiring soon', style: TextStyle(fontSize: 11)),
            value: _notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          const Divider(color: AppColors.border, height: 1),
          SwitchListTile(
            title: const Text('Location Services', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Recommend nearby rescue listings', style: TextStyle(fontSize: 11)),
            value: _locationEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _locationEnabled = val),
          ),
          const Divider(color: AppColors.border, height: 1),
          SwitchListTile(
            title: const Text('Weekly Eco-Reports', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Summarize monthly CO2 saving stats via email', style: TextStyle(fontSize: 11)),
            value: _ecoModeEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _ecoModeEnabled = val),
          ),
          
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ADMIN SYSTEM CONTROL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent, letterSpacing: 1.0),
              ),
            ),
          ),
          // Clear reservations data action (Demonstrates CRUD execution).
          ListTile(
            leading: const Icon(Icons.refresh, color: AppColors.secondary),
            title: const Text('Reset Sandbox Data', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Purges all mock reservation records on this device', style: TextStyle(fontSize: 11)),
            onTap: () => _confirmReset(ref),
          ),
          const Divider(color: AppColors.border, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.accent),
            title: const Text('Log Out', style: TextStyle(fontSize: 14)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logging out is disabled in this experimental sandbox.')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Displays warning modal prior to erasing mock collections.
  void _confirmReset(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Purge Reservation Logs?'),
        content: const Text(
          'This will remove all current active and historic reservation entries, resetting them to baseline mock structures. This is useful for presentation demonstrations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Trigger CRUD purges.
              final reservations = ref.read(userReservationsStreamProvider).value ?? [];
              final controller = ref.read(reservationsControllerProvider.notifier);

              for (var res in reservations) {
                await controller.deleteRecord(res.id);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock database reset completed successfully!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Confirm Reset'),
          ),
        ],
      ),
    );
  }
}
