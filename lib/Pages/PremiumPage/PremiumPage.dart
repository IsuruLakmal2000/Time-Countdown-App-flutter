import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:timecountdown/Pages/MainPages/HomePage.dart';
import 'package:timecountdown/Pages/MainPages/PrivacyPolicy.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Services/RevenueCatService.dart';
import 'package:timecountdown/Theme/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Providers/PremiumProvider.dart';

class PremiumPage extends StatefulWidget {
  final bool fromOnboarding;

  const PremiumPage({super.key, this.fromOnboarding = false});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  Package? _lifetimePackage;
  late AnimationController _shimmerController;
  bool _showCloseButton = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _fetchOfferings();
    
    // Show close button after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showCloseButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _fetchOfferings() async {
    setState(() => _isLoading = true);
    try {
      final packages = await RevenueCatService.getAvailablePackages();
      final lifetime = RevenueCatService.getPackageByProductId(
          packages, RevenueCatService.lifetimeProductId);

      if (mounted) {
        setState(() {
          _lifetimePackage = lifetime;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching offerings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _purchasePremium() async {
    if (_isLoading || _lifetimePackage == null) return;
    setState(() => _isLoading = true);

    try {
      final result =
          await RevenueCatService.purchasePackage(_lifetimePackage!);

      if (result.success) {
        if (!mounted) return;

        await LocalStorageService.updateIsPurchased(true);

        Provider.of<PremiumProvider>(context, listen: false)
            .setPremiumStatus(true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Welcome to Premium!'),
              backgroundColor: AppColors.success,
            ),
          );

          if (widget.fromOnboarding) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      print('Purchase error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final isPremium = await RevenueCatService.restorePurchases();

      if (!mounted) return;

      await LocalStorageService.updateIsPurchased(isPremium);

      Provider.of<PremiumProvider>(context, listen: false)
          .setPremiumStatus(isPremium);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPremium
                ? '✅ Purchases restored successfully!'
                : '🤔 No active purchase found.'),
            backgroundColor: isPremium ? AppColors.success : AppColors.warning,
          ),
        );
        if (isPremium) Navigator.pop(context);
      }
    } catch (e) {
      print('Restore error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _close() {
    if (widget.fromOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;

    if (isPremium) {
      return _buildAlreadyPremiumView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading && _lifetimePackage == null
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentPrimary,
              ),
            )
          : Stack(
              children: [
                // Background gradient glow
                Positioned(
                  top: -120,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentPrimary.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -60,
                  right: -100,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentSecondary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Close button (appears after 3 seconds)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, top: 4),
                          child: AnimatedOpacity(
                            opacity: _showCloseButton ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: AnimatedScale(
                              scale: _showCloseButton ? 1.0 : 0.8,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutBack,
                              child: IconButton(
                                onPressed: _showCloseButton ? _close : null,
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),

                              // Crown icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.accentPrimary.withOpacity(0.2),
                                      AppColors.accentSecondary.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color:
                                        AppColors.accentPrimary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: AppColors.accentPrimary,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppColors.accentGradient
                                        .createShader(bounds),
                                child: const Text(
                                  "Unlock Everything",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "One purchase. Lifetime access. No subscriptions.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Lifetime deal card (moved to top)
                              _buildLifetimeDealCard(),

                              const SizedBox(height: 32),

                              // Feature list (moved below price)
                              _buildFeatureItem(
                                icon: Icons.all_inclusive_rounded,
                                title: "Unlimited Countdowns",
                                subtitle:
                                    "Create as many countdowns as you need",
                              ),
                              _buildFeatureItem(
                                icon: Icons.palette_rounded,
                                title: "All Premium Templates",
                                subtitle:
                                    "Beautiful designs for every occasion",
                              ),
                              _buildFeatureItem(
                                icon: Icons.cloud_upload_rounded,
                                title: "Backup & Restore",
                                subtitle:
                                    "Never lose your countdowns again",
                              ),
                              _buildFeatureItem(
                                icon: Icons.widgets_rounded,
                                title: "Home Screen Widgets",
                                subtitle:
                                    "All widget styles & customization",
                              ),
                              _buildFeatureItem(
                                icon: Icons.block_rounded,
                                title: "No Ads, Ever",
                                subtitle:
                                    "Clean, distraction-free experience",
                                isLast: true,
                              ),

                              const SizedBox(height: 16),

                              // Social proof
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => const Icon(Icons.star_rounded,
                                          color: Colors.amber, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Loved by 10,000+ users",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Extra bottom padding for the fixed CTA
                              const SizedBox(height: 200),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fixed bottom CTA
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomCTA(),
                ),
              ],
            ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.accentPrimary.withOpacity(0.15),
                  AppColors.accentSecondary.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: AppColors.accentPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeDealCard() {
    final price =
        _lifetimePackage?.storeProduct.priceString ?? '\$49.99';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.accentPrimary.withOpacity(0.12),
            AppColors.accentSecondary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.accentPrimary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "💎  LIFETIME DEAL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // One time
          const Text(
            "One-time payment  •  Forever yours",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    final price =
        _lifetimePackage?.storeProduct.priceString ?? '\$49.99';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 1.0],
          colors: [
            AppColors.background.withOpacity(0),
            AppColors.background.withOpacity(0.95),
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CTA button with animated glow
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppColors.accentGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPrimary.withOpacity(
                            0.3 + (_shimmerController.value * 0.15),
                          ),
                          blurRadius: 20 + (_shimmerController.value * 8),
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading ? null : _purchasePremium,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: _isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Text(
                                      "Get Lifetime Access — $price",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Pay once, own it forever",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Restore
              TextButton(
                onPressed: _restorePurchases,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                ),
                child: const Text(
                  "Restore Purchases",
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textTertiary,
                  ),
                ),
              ),

              // Privacy & Terms
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 8),
                    ),
                    child: const Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  const Text(
                    " • ",
                    style:
                        TextStyle(color: AppColors.textDisabled, fontSize: 11),
                  ),
                  TextButton(
                    onPressed: () async {
                      final Uri eulaUrl = Uri.parse(
                          'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                      if (await canLaunchUrl(eulaUrl)) {
                        await launchUrl(eulaUrl,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 8),
                    ),
                    child: const Text(
                      "Terms of Use",
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textDisabled,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyPremiumView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.2),
                        AppColors.accentSecondary.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.accentPrimary,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.accentGradient.createShader(bounds),
                  child: const Text(
                    "You're Premium!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "All features are unlocked.\nEnjoy the full experience!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
