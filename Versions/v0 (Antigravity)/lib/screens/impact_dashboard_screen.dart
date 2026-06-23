import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/reservation.dart';
import '../providers/providers.dart';

/// Screen 4: Impact Dashboard Screen.
/// Design defense context:
/// - Designated Gemini AI Engine integration page.
/// - Calculates aggregate sustainability metrics (meals rescued, CO2 offset, savings) in real-time.
/// - Connects to [geminiInsightsProvider] to show automatically refreshed tips.
/// - Implements a fully interactive conversational chat box, querying [geminiServiceProvider]
///   to allow users to ask for tailored recipes and storage guides.
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
    // Insert initial welcome message from assistant.
    _messages.add({
      'sender': 'ai',
      'text': 'Hi! I\'m your Gemini food rescue assistant. Ask me: \n• *"What recipe can I make?"*\n• *"How do I keep avocados fresh?"*'
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  /// Send message to mock Gemini AI service.
  void _sendMessage(String text, List<Reservation> reservations) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
    });
    _chatController.clear();

    // Query our Gemini service provider.
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
      appBar: AppBar(
        title: const Text('My Environmental Impact'),
      ),
      body: reservationsAsync.when(
        data: (reservations) {
          // Calculate stats.
          final completed = reservations.where((r) => r.status == 'completed').toList();
          final mealsRescued = completed.fold<int>(0, (sum, r) => sum + r.reservedQuantity);
          final co2OffsetKg = mealsRescued * 1.8; // Standard EPA conversion metric: 1.8kg CO2 per meal saved.
          final moneySaved = completed.fold<double>(0.0, (sum, r) {
            final listing = r.foodItem;
            if (listing == null) return sum;
            final itemSavings = (listing.originalPrice - listing.discountedPrice) * r.reservedQuantity;
            return sum + itemSavings;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsGrid(mealsRescued, co2OffsetKg, moneySaved),
                const SizedBox(height: 24),
                
                const Text(
                  'Gemini Smart Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildAiInsightsCard(aiInsightsAsync),
                const SizedBox(height: 24),

                const Text(
                  'Ask Gemini Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                _buildChatConsole(reservations),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  /// Builds a responsive grid of stats cards with smooth gradients and custom badges.
  Widget _buildMetricsGrid(int meals, double co2, double savings) {
    return Row(
      children: [
        // Meals Saved Card
        Expanded(
          child: _buildMetricCard(
            title: 'Meals Rescued',
            value: '$meals',
            subtitle: 'Portions saved',
            icon: Icons.eco,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        // CO2 Saved Card
        Expanded(
          child: _buildMetricCard(
            title: 'CO₂ Avoided',
            value: '${co2.toStringAsFixed(1)} kg',
            subtitle: 'Landfill offset',
            icon: Icons.co2,
            color: AppColors.impactGreen,
          ),
        ),
        const SizedBox(width: 12),
        // Money Saved Card
        Expanded(
          child: _buildMetricCard(
            title: 'Money Saved',
            value: '\$${savings.toStringAsFixed(2)}',
            subtitle: 'Eco-discounts',
            icon: Icons.savings_outlined,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  /// Builds individual metric panel.
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Renders static insights generated automatically by Gemini.
  Widget _buildAiInsightsCard(AsyncValue<String> insightsAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: insightsAsync.when(
        data: (insights) => _renderMarkdown(insights),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (err, _) => Text(
          'Error loading AI insights: $err',
          style: const TextStyle(color: AppColors.accent),
        ),
      ),
    );
  }

  /// Renders conversation chat view.
  Widget _buildChatConsole(List<Reservation> reservations) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Message Log.
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAi ? AppColors.background : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isAi ? 0 : 12),
                        bottomRight: Radius.circular(isAi ? 12 : 0),
                      ),
                      border: Border.all(
                        color: isAi ? AppColors.border : AppColors.primary.withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAi ? 'Gemini AI' : 'You',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAi ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        isAi
                            ? _renderMarkdown(msg['text'] ?? '')
                            : Text(
                                msg['text'] ?? '',
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Gemini is composing cooking tips...', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
              ),
            ),

          const Divider(color: AppColors.border, height: 1),
          // Chat Input.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Ask Gemini how to cook sourdough...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onSubmitted: (val) => _sendMessage(val, reservations),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () => _sendMessage(_chatController.text, reservations),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A basic, lightweight markdown renderer for clean, structured textual outputs
  /// without introducing external package bloat.
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ));
      } else if (line.startsWith('####')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
          child: Text(
            line.replaceAll('####', '').trim(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary),
          ),
        ));
      } else if (line.startsWith('-') || line.startsWith('•')) {
        // Parse bold highlights inside bullets
        final bulletText = line.substring(1).trim();
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              Expanded(child: _renderInlineFormatting(bulletText)),
            ],
          ),
        ));
      } else if (line.startsWith('1.') || line.startsWith('2.') || line.startsWith('3.')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${line.substring(0, 2)} ', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              Expanded(child: _renderInlineFormatting(line.substring(2).trim())),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: _renderInlineFormatting(line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  /// Parses basic markdown inline bolding (`**bold**` or `*bold*`).
  Widget _renderInlineFormatting(String text) {
    final List<TextSpan> spans = [];
    final regExp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
    int lastIndex = 0;

    for (var match in regExp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
        ));
      }

      final boldText1 = match.group(1);
      final boldText2 = match.group(2);
      final boldText = boldText1 ?? boldText2 ?? '';

      spans.add(TextSpan(
        text: boldText,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
