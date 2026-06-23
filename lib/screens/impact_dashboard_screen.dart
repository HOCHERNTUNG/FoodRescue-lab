import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation.dart';
import '../providers/providers.dart';

class ImpactDashboardScreen extends ConsumerStatefulWidget {
  const ImpactDashboardScreen({super.key});

  @override
  ConsumerState<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends ConsumerState<ImpactDashboardScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'ai',
      'text': 'Hi! I\'m your Gemini Eco-Assistant. Ask me about your sustainability impact, recipe ideas, or storage tips!'
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage(String text, List<Reservation> reservations) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
    });
    _chatController.clear();

    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.chatWithAssistant(text, reservations);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'sender': 'ai', 'text': response});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(userReservationsStreamProvider);
    final aiInsightsAsync = ref.watch(geminiInsightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Impact Dashboard',
          style: TextStyle(fontFamily: 'Epilogue', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: reservationsAsync.when(
        data: (reservations) {
          // Calculate aggregate sustainability metrics
          final completed = reservations.where((r) => r.status == 'completed').toList();
          final mealsSaved = completed.fold<int>(0, (sum, r) => sum + r.reservedQuantity);
          final totalWeightKg = completed.fold<double>(0.0, (sum, r) => sum + r.weightSavedKg);
          final co2OffsetKg = completed.fold<double>(0.0, (sum, r) => sum + r.co2ReducedKg);
          final waterSavedLiters = completed.fold<double>(0.0, (sum, r) => sum + r.waterSavedLiter);
          final moneySaved = completed.fold<double>(0.0, (sum, r) => sum + r.financialSavings);

          // Get the dynamic AI messages from individual rescues if any
          final latestAiMessage = completed.isNotEmpty ? completed.first.aiMessage : '';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Primary Metrics Grid (Meals & Weight)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Meals Saved',
                        '$mealsSaved',
                        'Portions rescued',
                        Icons.eco,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        'Total Weight',
                        '${totalWeightKg.toStringAsFixed(1)} kg',
                        'Food weight saved',
                        Icons.scale_outlined,
                        AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Environmental Impact (CO2 Reduced, Water Saved)
                const Text(
                  'Environmental Footprint Offset',
                  style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildImpactSubCard(
                        'CO₂ Reduced',
                        '${co2OffsetKg.toStringAsFixed(1)} kg',
                        'Greenhouse offset',
                        Icons.co2,
                        AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImpactSubCard(
                        'Water Saved',
                        '${waterSavedLiters.toStringAsFixed(0)} L',
                        'Water footprints',
                        Icons.water_drop_outlined,
                        AppColors.mapBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // AI evaluation insights
                const Text(
                  'Gemini Eco-Evaluation',
                  style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildAiInsightsCard(aiInsightsAsync, latestAiMessage),
                const SizedBox(height: 24),

                // 3. Simple Bar Chart for Monthly Savings
                const Text(
                  'Monthly Financial Savings',
                  style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildSavingsBarChart(moneySaved),
                const SizedBox(height: 24),

                // 4. Community Leaderboard
                const Text(
                  'Community Eco-Leaderboard',
                  style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildLeaderboardList(mealsSaved),
                const SizedBox(height: 24),

                // 5. Interactive Assistant Console
                const Text(
                  'Ask Gemini AI Assistant',
                  style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildChatConsole(reservations),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactSubCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsCard(AsyncValue<String> insightsAsync, String latestAiMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (latestAiMessage.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Text(
                  'LATEST RESCUE FOOTPRINT EVALUATION',
                  style: TextStyle(fontFamily: 'Work Sans', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              latestAiMessage,
              style: const TextStyle(fontFamily: 'Work Sans', fontSize: 13, height: 1.4, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
          ],
          const Row(
            children: [
              Icon(Icons.insights, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Text(
                'GEMINI GENERAL ECO-INSIGHTS',
                style: TextStyle(fontFamily: 'Work Sans', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          insightsAsync.when(
            data: (insights) => _renderMarkdown(insights),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
            error: (err, _) => Text('Could not generate insights: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsBarChart(double userSavings) {
    final double maxVal = userSavings > 50 ? userSavings : 80;
    
    // Mock monthly data (with current user saving mapped to June)
    final monthlyData = [
      {'month': 'Jan', 'val': 15.50},
      {'month': 'Feb', 'val': 24.00},
      {'month': 'Mar', 'val': 42.50},
      {'month': 'Apr', 'val': 35.00},
      {'month': 'May', 'val': 58.00},
      {'month': 'Jun (You)', 'val': userSavings},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lifetime Savings', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  '\$${(175.0 + userSavings).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.map((data) {
                final val = data['val'] as double;
                final heightRatio = (val / maxVal).clamp(0.05, 1.0);
                final double barHeight = 100 * heightRatio;
                final isCurrent = data['month'].toString().contains('You');

                return Column(
                  children: [
                    Text('\$${val.toStringAsFixed(0)}', style: TextStyle(fontSize: 9, color: isCurrent ? AppColors.primary : AppColors.outline, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary : AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['month'].toString(),
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(int userRescues) {
    final leaderboard = [
      {'rank': '1', 'name': 'GreenWarrior🇸🇬', 'rescues': 42, 'isMe': false},
      {'rank': '2', 'name': 'SourdoughSaver', 'rescues': 29, 'isMe': false},
      {'rank': '3', 'name': 'Jane Doe (You)', 'rescues': 3 + userRescues, 'isMe': true},
      {'rank': '4', 'name': 'ZeroWasteKing', 'rescues': 14, 'isMe': false},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaderboard.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final row = leaderboard[index];
          final isMe = row['isMe'] as bool;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isMe ? AppColors.primary : AppColors.outlineVariant,
              child: Text(
                row['rank'].toString(),
                style: TextStyle(
                  color: isMe ? AppColors.onPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              row['name'].toString(),
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                color: isMe ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            trailing: Text(
              '${row['rescues']} Rescues',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatConsole(List<Reservation> reservations) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAi = msg['sender'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAi ? AppColors.background : AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Gemini is writing recipe hacks...', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.outline)),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Ask recipes ("bread pudding", "avocado storage")...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 12),
                    onSubmitted: (val) => _sendMessage(val, reservations),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, size: 20, color: AppColors.primary),
                  onPressed: () => _sendMessage(_chatController.text, reservations),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderMarkdown(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('###')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            line.replaceAll('###', '').trim(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ));
      } else if (line.startsWith('-') || line.startsWith('•')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  line.substring(1).replaceAll('**', '').trim(),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                ),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            line.replaceAll('**', '').trim(),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
