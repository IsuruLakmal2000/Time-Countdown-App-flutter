import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import '../../Providers/PremiumProvider.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool _isLoading = false;
  int _selectedIndex = 1; // Default to yearly (index 1)
  Offerings? _offerings;
  Package? _monthlyPackage;
  Package? _yearlyPackage;

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
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        setState(() {
          _offerings = offerings;
          _monthlyPackage = offerings.current?.monthly;
          _yearlyPackage = offerings.current?.annual;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching offerings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectPackage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper function to get appropriate font size based on currency
  double _getPriceFontSize(String? priceString) {
    if (priceString == null) return 24.0;
    // Check if price starts with $ (USD)
    if (priceString.startsWith('\$')) {
      return 24.0; // Normal size for USD
    } else {
      return 20.0; // Smaller size for other currencies
    }
  }

  // Helper function to calculate monthly price from yearly price
  String _getMonthlyPrice(String? yearlyPriceString) {
    if (yearlyPriceString == null) return '\$1.67';
    
    // Extract numeric value from price string
    final RegExp priceRegex = RegExp(r'[\d,]+\.?\d*');
    final Match? match = priceRegex.firstMatch(yearlyPriceString);
    
    if (match != null) {
      final String numericPart = match.group(0)!.replaceAll(',', '');
      final double yearlyPrice = double.tryParse(numericPart) ?? 19.99;
      final double monthlyPrice = yearlyPrice / 12;
      
      // Get currency symbol from original string
      final String currencySymbol = yearlyPriceString.substring(0, match.start);
      
      return '$currencySymbol${monthlyPrice.toStringAsFixed(2)}';
    }
    
    return '\$1.67'; // fallback
  }

  Future<void> _purchasePremium() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      Package? packageToPurchase =
          _selectedIndex == 0 ? _monthlyPackage : _yearlyPackage;
      if (packageToPurchase != null) {
        final customerInfo = await Purchases.purchasePackage(packageToPurchase);
        final isPremium =
            customerInfo.entitlements.all["pro"]?.isActive ?? false;
        if (isPremium) {
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
      final customerInfo = await Purchases.restorePurchases();
      final isPremium =
          customerInfo.entitlements.all["pro"]?.isActive ?? false;

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
                child: const Text("Continue"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Center(
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/Images/cafe.jpg",
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.8),
                                  Colors.black.withOpacity(1),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20, top: 40),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white70,
                                    size: 35,
                                  )),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Upgrade to Premium",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 48, 238),
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    const Text(
                                      "Unlock all premium features and content without restrictions.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    // Premium Subscription Title
                                    const Text(
                                      "Choose Your Plan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Subscription Selection Cards
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Column(
                                        children: [
                                          // Monthly Package - Show RevenueCat package or fallback
                                          GestureDetector(
                                            onTap: () => _selectPackage(0),
                                            child: AnimatedContainer(
                                              duration: Duration(milliseconds: 200),
                                              width: double.infinity,
                                              padding: EdgeInsets.all(20),
                                              margin: EdgeInsets.only(bottom: 16),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                gradient: _selectedIndex == 0 
                                                    ? LinearGradient(
                                                        colors: [
                                                          Color.fromARGB(255, 252, 6, 252).withOpacity(0.2),
                                                          Color.fromARGB(255, 255, 0, 119).withOpacity(0.2),
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      )
                                                    : null,
                                                border: Border.all(
                                                  color: _selectedIndex == 0 
                                                      ? Color.fromARGB(255, 252, 6, 252)
                                                      : Colors.grey.withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                color: _selectedIndex == 0 
                                                    ? null
                                                    : Colors.white.withOpacity(0.05),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: _selectedIndex == 0 
                                                                ? Color.fromARGB(255, 252, 6, 252)
                                                                : Colors.grey,
                                                            width: 2,
                                                          ),
                                                          color: _selectedIndex == 0 
                                                              ? Color.fromARGB(255, 252, 6, 252)
                                                              : Colors.transparent,
                                                        ),
                                                        child: _selectedIndex == 0 
                                                            ? Icon(
                                                                Icons.check,
                                                                color: Colors.white,
                                                                size: 16,
                                                              )
                                                            : null,
                                                      ),
                                                      SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Monthly Plan',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              'Flexible monthly billing',
                                                              style: TextStyle(
                                                                color: Colors.white70,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            _monthlyPackage?.storeProduct.priceString ?? '\$4.99',
                                                            style: TextStyle(
                                                              color: Color.fromARGB(255, 252, 6, 252),
                                                              fontSize: _getPriceFontSize(_monthlyPackage?.storeProduct.priceString),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            'per month',
                                                            style: TextStyle(
                                                              color: Colors.white70,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        
                                          // Yearly Package - Show RevenueCat package or fallback
                                          GestureDetector(
                                            onTap: () => _selectPackage(1),
                                            child: Stack(
                                              children: [
                                                AnimatedContainer(
                                                  duration: Duration(milliseconds: 200),
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(20),
                                                  margin: EdgeInsets.only(bottom: 16),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    gradient: _selectedIndex == 1 
                                                        ? LinearGradient(
                                                            colors: [
                                                              Color.fromARGB(255, 252, 6, 252).withOpacity(0.2),
                                                              Color.fromARGB(255, 255, 0, 119).withOpacity(0.2),
                                                            ],
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                          )
                                                        : null,
                                                    border: Border.all(
                                                      color: _selectedIndex == 1 
                                                          ? Color.fromARGB(255, 252, 6, 252)
                                                          : Colors.grey.withOpacity(0.4),
                                                      width: 2,
                                                    ),
                                                    color: _selectedIndex == 1 
                                                        ? null
                                                        : Colors.white.withOpacity(0.05),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 24,
                                                            height: 24,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              border: Border.all(
                                                                color: _selectedIndex == 1 
                                                                    ? Color.fromARGB(255, 252, 6, 252)
                                                                    : Colors.grey,
                                                                width: 2,
                                                              ),
                                                              color: _selectedIndex == 1 
                                                                  ? Color.fromARGB(255, 252, 6, 252)
                                                                  : Colors.transparent,
                                                            ),
                                                            child: _selectedIndex == 1 
                                                                ? Icon(
                                                                    Icons.check,
                                                                    color: Colors.white,
                                                                    size: 16,
                                                                  )
                                                                : null,
                                                          ),
                                                          SizedBox(width: 16),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'Yearly Plan',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 20,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 8),
                                                                  
                                                                  ],
                                                                ),
                                                                SizedBox(height: 4),
                                                                Text(
                                                                  'Best value - billed annually',
                                                                  style: TextStyle(
                                                                    color: Colors.white70,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Text(
                                                                _yearlyPackage?.storeProduct.priceString ?? '\$19.99',
                                                                style: TextStyle(
                                                                  color: Color.fromARGB(255, 252, 6, 252),
                                                                  fontSize: _getPriceFontSize(_yearlyPackage?.storeProduct.priceString),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                'per year',
                                                                style: TextStyle(
                                                                  color: Colors.white70,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                              SizedBox(height: 4),
                                                              ShaderMask(
                                                                shaderCallback: (bounds) => LinearGradient(
                                                                  colors: [
                                                                    Colors.amber,
                                                                    Colors.orange,
                                                                  ],
                                                                  begin: Alignment.topLeft,
                                                                  end: Alignment.bottomRight,
                                                                ).createShader(bounds),
                                                                child: Text(
                                                                  _getMonthlyPrice(_yearlyPackage?.storeProduct.priceString),
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'per month',
                                                                style: TextStyle(
                                                                  color: Colors.grey,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Popular badge
                                                Positioned(
                                                  top: -8,
                                                  left: 20,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color.fromARGB(255, 252, 6, 252),
                                                          Color.fromARGB(255, 255, 0, 119),
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      'Save 58%',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        

                                        ],
                                      ),
                                    ),
                                    // Features Section
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Unlimited Feature
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(25),
                                                  ),
                                                  child: Image.asset(
                                                    "assets/Images/unlimited.png",
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "Unlimited\nCountdowns",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Pro Templates Feature
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(25),
                                                  ),
                                                  child: Image.asset(
                                                    "assets/Images/unlocked.png",
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "Pro\nTemplates",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Backup Feature
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(25),
                                                  ),
                                                  child: Icon(
                                                    Icons.backup,
                                                    color: Colors.amber,
                                                    size: 24,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "Backup &\nRestore",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _selectedIndex == 0 ? "Monthly subscription, " : "Yearly subscription, ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: _selectedIndex == 0 ? "cancel anytime!" : "best value!",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                    child: Container(
                      width: double.infinity, // Makes the button full width
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 252, 6, 252), // Start color
                            Color.fromARGB(255, 255, 0, 119), // End color
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                            30), // Optional: rounded corners
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(
                            30), // Match the container's border radius
                        color: Colors
                            .transparent, // Make the material color transparent
                        child: ElevatedButton(
                          onPressed: _purchasePremium,
                          child: const Text(
                            "Upgrade to Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors
                                    .transparent), // Make button background transparent
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.all(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Restore Purchases Button
                  TextButton(
                    onPressed: _restorePurchases,
                    child: const Text(
                      "Restore Purchases",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ), // Close Column
            ), // Close SingleChildScrollView
    );
  }
}
