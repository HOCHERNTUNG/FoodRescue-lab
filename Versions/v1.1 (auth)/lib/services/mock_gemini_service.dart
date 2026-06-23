import '../models/reservation.dart';
import 'gemini_service.dart';

/// MockGeminiService simulates AI processing without consuming API credits or failing offline.
/// Presentation defense context:
/// - Provides intelligent, context-aware responses by scanning active/historical reservations.
/// - Demonstrates how raw text prompts are formatted before dispatching.
/// - Simulates a 1.2-second network call latency, showcasing async progress indicators.
class MockGeminiService implements GeminiService {
  @override
  Future<String> generateImpactInsights(List<Reservation> reservations) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (reservations.isEmpty) {
      return "### Welcome to your FoodRescue AI Assistant! 🌿\n\n"
          "Once you start claiming surplus food, I will analyze your inventory to:\n"
          "1. Suggest **recipe creations** using your rescued ingredients.\n"
          "2. Offer **preservation hacks** to maximize shelf-life.\n"
          "3. Quantify your positive **CO₂ offset** and ecological contribution.\n\n"
          "Try reserving some sourdough toast or pastries from the Marketplace tab first!";
    }

    // Analyze reservations to give context-aware responses
    final pendingItems = reservations.where((r) => r.status == 'pending').toList();
    final hasAvocado = pendingItems.any((r) => r.foodItem?.name.toLowerCase().contains('avocado') ?? false);
    final hasBakery = pendingItems.any((r) => r.foodItem?.category.toLowerCase() == 'bakery');

    final buffer = StringBuffer();
    buffer.writeln("### Gemini Eco-Insights & Food Prep Guide 🤖\n");
    buffer.writeln("Based on your **${pendingItems.length} active rescues**, here is your personalized strategy:\n");

    if (hasAvocado) {
      buffer.writeln("#### 🥑 Avocado Preservation Hack");
      buffer.writeln("- **Storage:** Keep the avocado toast boxes refrigerated. If you have plain avocados, store them next to lemons to slow oxidation.\n"
          "- **Prep Tip:** Turn avocado portions into a quick guacamole spread by adding fresh lime, salt, and red pepper flakes.");
    }

    if (hasBakery) {
      buffer.writeln("#### 🥐 Bakery Reheating Trick");
      buffer.writeln("- **Storage:** Wrap pastries in foil and freeze if you won't eat them within 24 hours.\n"
          "- **Revival:** Sprinkle a few drops of water on the croissant and bake at 350°F (175°C) for 4 minutes to restore the crisp, flakey texture.");
    }

    buffer.writeln("\n#### 🌍 Your Carbon Offset Estimate");
    final mealsCount = reservations.length * 2.5; // dummy multiplier
    final co2Saved = mealsCount * 1.8; // kg of CO2
    buffer.writeln("By preventing this food from going to landfill, you have mitigated approximately **${co2Saved.toStringAsFixed(1)} kg of CO₂ equivalents**. This is comparable to charging a smartphone **${(co2Saved * 120).round()} times**!");

    return buffer.toString();
  }

  @override
  Future<String> chatWithAssistant(String message, List<Reservation> reservations) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final cleanMsg = message.toLowerCase();

    if (cleanMsg.contains('hello') || cleanMsg.contains('hi')) {
      return "Hello! I am your FoodRescue AI Companion. Ask me how to store, prepare, or recycle your surplus items!";
    }

    if (cleanMsg.contains('recipe')) {
      return "#### 🧑‍🍳 Rescued Ingredient Recipe: Bread Pudding Delight\n\n"
          "If you have leftover **Bakery pastries** or **Sourdough bread**:\n"
          "1. Tear the bread/pastries into bite-sized chunks.\n"
          "2. Whisk 2 eggs, 1 cup of milk, a dash of sugar, and cinnamon in a bowl.\n"
          "3. Toss the bread chunks in the custard mixture and let soak for 10 minutes.\n"
          "4. Bake at 375°F (190°C) for 25-30 minutes until golden brown.\n\n"
          "*Eco-Impact:* Prevents baked starch waste which accounts for 12% of household landfills!";
    }

    if (cleanMsg.contains('storage') || cleanMsg.contains('keep')) {
      return "#### 🧊 Pro Preservation Guidelines\n\n"
          "- **Leafy Greens:** Wrap in a dry paper towel and place in a sealed container to absorb excess humidity.\n"
          "- **Berries:** Wash in a diluted vinegar bath (1 part vinegar, 3 parts water) to kill mold spores, dry completely, and refrigerate.";
    }

    return "Interesting! While I'm in experimental mock sandbox mode, I've logged this prompt. Try asking me for a **'recipe'** or **'storage'** tips, and I'll display context-aware guides based on your claimed foods.";
  }
}
