import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:timecountdown/Services/RevenueCatService.dart';
import '../../Providers/PremiumProvider.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool _isLoading = false;
  int _selectedIndex = 1; // Default to yearly (index 1)
  Package? _monthlyPackage;
  Package? _yearlyPackage;
  Package? _lifetimePackage;

  @override
  void initState() {
    print("Initializing PremiumPage");
    super.initState();
    _fetchOfferings();
    // No need to check for premium here, the provider will handle it
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final packages = await RevenueCatService.getAvailablePackages();

      // Filter packages based on identifiers defined in the service
      final monthly = RevenueCatService.getPackageByProductId(
          packages, RevenueCatService.monthlyProductId);
      final yearly = RevenueCatService.getPackageByProductId(
          packages, RevenueCatService.yearlyProductId);
      final lifetime = RevenueCatService.getPackageByProductId(
          packages, RevenueCatService.lifetimeProductId);

      if (mounted) {
        setState(() {
          _monthlyPackage = monthly;
          _yearlyPackage = yearly;
          _lifetimePackage = lifetime;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching offerings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectPackage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper function to calculate monthly price from yearly price
  String _getMonthlyPrice(Package? yearlyPackage) {
    if (yearlyPackage == null) return '\$1.67';

    // Attempt to calculate based on actual price if available
    try {
      // Logic from user provided service could be used, or custom logic:
      final priceString = yearlyPackage.storeProduct.priceString;

      // Extract numeric value from price string for rough calculation fallback
      final RegExp priceRegex = RegExp(r'[\d,]+\.?\d*');
      final Match? match = priceRegex.firstMatch(priceString);

      if (match != null) {
        final String numericPart = match.group(0)!.replaceAll(',', '');
        final double yearlyPrice = double.tryParse(numericPart) ?? 19.99;
        final double monthlyPrice = yearlyPrice / 12;

        // Get currency symbol from original string
        final String currencySymbol = priceString.substring(0, match.start);

        return '$currencySymbol${monthlyPrice.toStringAsFixed(2)}';
      }
      return '\$1.67';
    } catch (e) {
      return '\$1.67';
    }
  }

  Future<void> _purchasePremium() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      Package? packageToPurchase;
      if (_selectedIndex == 0) packageToPurchase = _monthlyPackage;
      if (_selectedIndex == 1) packageToPurchase = _yearlyPackage;
      if (_selectedIndex == 2) packageToPurchase = _lifetimePackage;

      if (packageToPurchase != null) {
        final result =
            await RevenueCatService.purchasePackage(packageToPurchase);

        if (result.success) {
          if (!mounted) return;
          // Update the provider
          Provider.of<PremiumProvider>(context, listen: false)
              .setPremiumStatus(true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Premium purchased successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Go back to the previous screen
          }
        } else {
          // Show error if available or just log
          if (result.error != null && mounted) {
            // Optional: Show specific error to user if desired
            // print('Purchase failed: ${result.error}');
          }
        }
      }
    } catch (e) {
      // Only log the error, don't show a snackbar for cancellation
      print('Purchase error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final isPremium = await RevenueCatService.restorePurchases();

      if (!mounted) return;
      Provider.of<PremiumProvider>(context, listen: false)
          .setPremiumStatus(isPremium);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPremium
                ? '✅ Purchases restored successfully!'
                : '🤔 No active premium subscription found.'),
            backgroundColor: isPremium ? Colors.green : Colors.orange,
          ),
        );
        if (isPremium) {
          Navigator.pop(context); // Go back if restore was successful
        }
      }
    } catch (e) {
      print('Restore error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  //----------

  @override
  Widget build(BuildContext context) {
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;

    if (isPremium) {
      // ...existing premium user view...
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 100),
              const SizedBox(height: 20),
              const Text(
                "You are a Premium User!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "All features are unlocked.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : Stack(
              children: [
                // Scrollable content
                SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/Images/cafe.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.only(bottom: 160),
                      child: Column(
                        children: [
                          // Close Button
                          Padding(
                            padding: const EdgeInsets.only(right: 20, top: 50, left: 20),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                          // Top spacing to push content down
                          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                          // Main Content
                          Column(
                                children: [
                                  // Title with padding
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child: const Text(
                                      "Upgrade to Premium",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 48, 238),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40),
                                    child: const Text(
                                      "Unlock all premium features and content without restrictions.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  const Text(
                                    "Choose Your Plan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Subscription Selection Cards
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Column(
                                      children: [
                                        // Monthly Package
                                        _buildPlanCard(
                                          index: 0,
                                          title: 'Monthly Plan',
                                          subtitle: 'Flexible monthly billing',
                                          price: _monthlyPackage?.storeProduct.priceString ?? '\$4.99',
                                          period: 'per month',
                                        ),
                                        // Yearly Package
                                        _buildPlanCardWithBadge(
                                          index: 1,
                                          title: 'Yearly Plan',
                                          subtitle: 'Best value - billed annually',
                                          price: _yearlyPackage?.storeProduct.priceString ?? '\$19.99',
                                          period: 'per year',
                                          monthlyPrice: _getMonthlyPrice(_yearlyPackage),
                                          badge: 'Save 58%',
                                        ),
                                        // Lifetime Package
                                        _buildPlanCard(
                                          index: 2,
                                          title: 'Lifetime Access',
                                          subtitle: 'One-time payment',
                                          price: _lifetimePackage?.storeProduct.priceString ?? '\$49.99',
                                          period: 'forever',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Features Section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildFeature("assets/Images/unlimited.png", "Unlimited\nCountdowns"),
                                        _buildFeature("assets/Images/unlocked.png", "Pro\nTemplates"),
                                        _buildFeatureIcon(Icons.backup, "Backup &\nRestore"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                          // Bottom spacing for visual balance
                          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                // Fixed bottom button overlay - sticks to bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.98),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      top: 24,
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _selectedIndex == 0
                                      ? "Monthly subscription, "
                                      : _selectedIndex == 1
                                          ? "Yearly subscription, "
                                          : "Lifetime access, ",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    height: 1.3,
                                  ),
                                ),
                                TextSpan(
                                  text: _selectedIndex == 0
                                      ? "cancel anytime!"
                                      : _selectedIndex == 1
                                          ? "best value!"
                                          : "pay once, use forever!",
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 252, 6, 252),
                                  Color.fromARGB(255, 255, 0, 119),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: _purchasePremium,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Upgrade to Premium",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _restorePurchases,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            ),
                            child: const Text(
                              "Restore Purchases",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper widget to build compact plan cards
  Widget _buildPlanCard({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required String period,
  }) {
    return GestureDetector(
      onTap: () => _selectPackage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _selectedIndex == index
              ? LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.25),
                    const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: _selectedIndex == index
                ? const Color.fromARGB(255, 252, 6, 252)
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          color: _selectedIndex == index ? null : Colors.white.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedIndex == index
                      ? const Color.fromARGB(255, 252, 6, 252)
                      : Colors.grey,
                  width: 2,
                ),
                color: _selectedIndex == index
                    ? const Color.fromARGB(255, 252, 6, 252)
                    : Colors.transparent,
              ),
              child: _selectedIndex == index
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 252, 6, 252),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for yearly plan with badge and monthly breakdown
  Widget _buildPlanCardWithBadge({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required String monthlyPrice,
    required String badge,
  }) {
    return GestureDetector(
      onTap: () => _selectPackage(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: _selectedIndex == index
                  ? LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.25),
                        const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: _selectedIndex == index
                    ? const Color.fromARGB(255, 252, 6, 252)
                    : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
              color: _selectedIndex == index ? null : Colors.white.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedIndex == index
                          ? const Color.fromARGB(255, 252, 6, 252)
                          : Colors.grey,
                      width: 2,
                    ),
                    color: _selectedIndex == index
                        ? const Color.fromARGB(255, 252, 6, 252)
                        : Colors.transparent,
                  ),
                  child: _selectedIndex == index
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 252, 6, 252),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        monthlyPrice,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      'per month',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -6,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 252, 6, 252),
                    Color.fromARGB(255, 255, 0, 119),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for feature with image
  Widget _buildFeature(String imagePath, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for feature with icon
  Widget _buildFeatureIcon(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.amber, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
