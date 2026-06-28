import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
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

  void _sendMessage(String text, WidgetRef ref) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
    });
    _chatController.clear();

    // Consume the user's current reservations list for AI context
    final reservations = ref.read(userReservationsStreamProvider).value ?? [];
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
    final userProfileAsync = ref.watch(userProfileStreamProvider);
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
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: AppColors.outline.withAlpha(128)),
                  const SizedBox(height: 16),
                  const Text(
                    'No impact statistics available yet.\nTry seeding or completing a claim!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final mealsSaved = user.mealsSaved;
          final totalWeightKg = user.totalWeightSaved;
          
          // Calculations based on standard ratios
          final co2OffsetKg = totalWeightKg * 1.8; // 1.8 kg CO2 per kg food saved
          final waterSavedLiters = mealsSaved * 3.0; // 3.0 Liters per meal
          final moneySaved = mealsSaved * 9.50; // average financial savings per meal rescued

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Primary Metrics Grid (Meals & Weight) - Pulling directly from Firestore users table
                // 1. Primary Metrics Grid (Meals & Weight) - Bento grid circular progress gauges
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Meals Saved',
                        '$mealsSaved',
                        'Portions rescued',
                        Icons.eco,
                        AppColors.primary,
                        (mealsSaved / 20.0).clamp(0.0, 1.0),
                        '${((mealsSaved / 20.0).clamp(0.0, 1.0) * 100).toInt()}%',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        'Total Weight',
                        '${totalWeightKg.toStringAsFixed(1)} kg',
                        'Food weight saved',
                        Icons.scale_outlined,
                        Colors.orangeAccent,
                        (totalWeightKg / 15.0).clamp(0.0, 1.0),
                        '${((totalWeightKg / 15.0).clamp(0.0, 1.0) * 100).toInt()}%',
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
                  'Gemini Eco-Evaluation & Tips',
                  style: TextStyle(fontFamily: 'Epilogue', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildAiInsightsCard(aiInsightsAsync, user.aiMessage),
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
                _buildChatConsole(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color, double progress, String percentText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      color: color,
                      backgroundColor: color.withAlpha(25),
                    ),
                  ),
                  Text(
                    percentText,
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 11,
              color: AppColors.outline,
            ),
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Epilogue',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 10,
              color: AppColors.outline,
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
        border: Border.all(color: AppColors.primary.withAlpha(77), width: 1.5),
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.primary.withAlpha(13)],
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
                  'AI RESCUE FOOTPRINT EVALUATION',
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
                'GEMINI ECO-INSIGHTS HACKS',
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
    
    final monthlyData = [
      {'month': 'Jan', 'val': 15.50},
      {'month': 'Feb', 'val': 24.00},
      {'month': 'Mar', 'val': 42.50},
      {'month': 'Apr', 'val': 35.00},
      {'month': 'May', 'val': 58.00},
      {'month': 'Jun (You)', 'val': userSavings},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Money Saved',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${(175.0 + userSavings).toStringAsFixed(2)} Total',
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: monthlyData.map((data) {
              final val = data['val'] as double;
              final heightRatio = (val / maxVal).clamp(0.08, 1.0);
              final double barHeight = 100 * heightRatio;
              final isCurrent = data['month'].toString().contains('You');

              return Column(
                children: [
                  Text(
                    '\$${val.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 10,
                      color: isCurrent ? AppColors.primary : AppColors.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 28,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: isCurrent
                          ? const LinearGradient(
                              colors: [AppColors.primary, Colors.orangeAccent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : LinearGradient(
                              colors: [AppColors.outlineVariant, AppColors.outlineVariant.withAlpha(120)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(100),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
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
    );
  }

  Widget _buildLeaderboardList(int userRescues) {
    final leaderboard = [
      {'rank': '1', 'name': 'GreenWarrior🇸🇬', 'rescues': 42, 'isMe': false},
      {'rank': '2', 'name': 'SourdoughSaver', 'rescues': 29, 'isMe': false},
      {'rank': '3', 'name': 'Jane Doe (You)', 'rescues': 3 + userRescues, 'isMe': true},
      {'rank': '4', 'name': 'ZeroWasteKing', 'rescues': 14, 'isMe': false},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaderboard.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final row = leaderboard[index];
          final isMe = row['isMe'] as bool;
          final rank = row['rank'].toString();
          
          Widget rankWidget;
          if (rank == '1') {
            rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 24);
          } else if (rank == '2') {
            rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 24);
          } else if (rank == '3' && !isMe) {
            rankWidget = const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 24);
          } else {
            rankWidget = CircleAvatar(
              radius: 12,
              backgroundColor: isMe ? AppColors.primary : AppColors.outlineVariant,
              child: Text(
                rank,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 10,
                  color: isMe ? Colors.black : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListTile(
            leading: rankWidget,
            title: Text(
              row['name'].toString(),
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                color: isMe ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary.withAlpha(30) : AppColors.background,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${row['rescues']} Rescues',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 11,
                  fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                  color: isMe ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatConsole() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                      color: isAi ? AppColors.background : AppColors.primary.withAlpha(38),
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
                      filled: false,
                      hintText: 'Ask recipes ("bread pudding", "avocado storage")...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 12),
                    onSubmitted: (val) => _sendMessage(val, ref),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, size: 20, color: AppColors.primary),
                  onPressed: () => _sendMessage(_chatController.text, ref),
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
