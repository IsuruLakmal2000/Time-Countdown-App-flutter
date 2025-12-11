import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

// Purchase Result class
class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  PurchaseResult({
    required this.success,
    this.customerInfo,
    this.error,
  });
}

class RevenueCatService {
  // Test Mode Flag
  static const bool isTestMode = false;

  // RevenueCat API Keys
  static const String _appleApiKey = 'appl_NsiZfSrVfgdJwEVKRRIzfVZrjiU';
  static const String _googleApiKey = 'goog_olOAnQcQvdhSNeRGbIDWNoXJOoi';

  // Product IDs for iOS (from App Store Connect)
  static String get monthlyProductId => Platform.isIOS
      ? 'timecountdown_pro_1'
      : 'premium_plan:timecountdown-pro-monthly'; // Updated with our mock IDs for now
  static String get yearlyProductId => Platform.isIOS
      ? 'timecountdown_pro_yearly'
      : 'premium_plan:timecountdown-pro-yearly'; // Updated with our mock IDs for now
  static String get lifetimeProductId => Platform.isIOS
      ? 'timecountdown_pro_lifetime'
      : 'com.circularx.timecountdown.pro'; // Updated with our mock IDs for now

  // Entitlement identifier
  static const String entitlementID =
      'pro'; // Changed from 'premium' to 'pro' to match previous code

  // Track initialization status
  static bool _isInitialized = false;

  // Check if RevenueCat is initialized
  static bool get isInitialized => _isInitialized;

  // Singleton pattern (Optional, but keeping to maintain user's pattern if needed)
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // Initialize RevenueCat
  static Future<void> initialize() async {
    if (isTestMode) {
      print("RevenueCatService: Initialized in TEST MODE");
      _isInitialized = true;
      return;
    }

    try {
      late PurchasesConfiguration configuration;

      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else {
        return;
      }

      await Purchases.configure(configuration);

      // Enable debug logs (disable in production)
      await Purchases.setLogLevel(LogLevel.debug);

      _isInitialized = true;
      print('RevenueCat initialized successfully');
    } catch (e) {
      _isInitialized = false;
      print('Failed to initialize RevenueCat: $e');
      // In production we might not want to rethrow to prevent app crash on init,
      // but purely for this service logic it's fine.
    }
  }

  // Get available packages
  static Future<List<Package>> getAvailablePackages() async {
    if (isTestMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      // Return mock packages
      return _getMockPackages();
    }

    try {
      // Check if RevenueCat is properly initialized
      if (!_isInitialized) {
        print('RevenueCat not initialized, attempting to initialize...');
        await initialize();
      }

      final offerings = await Purchases.getOfferings();

      final offering = offerings.current;

      if (offering != null && offering.availablePackages.isNotEmpty) {
        return List<Package>.from(offering.availablePackages);
      }

      return [];
    } catch (e) {
      print('Error getting packages: $e');
      return [];
    }
  }

  // Purchase a package
  static Future<PurchaseResult> purchasePackage(Package package) async {
    if (isTestMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      print(
          "RevenueCatService: Mock purchase successful for ${package.storeProduct.identifier}");
      return PurchaseResult(success: true);
    }

    try {
      // Check if RevenueCat is properly initialized
      if (!_isInitialized) {
        print('RevenueCat not initialized, cannot purchase package');
        return PurchaseResult(
          success: false,
          error: 'Service not initialized',
        );
      }

      final customerInfo = await Purchases.purchasePackage(package);
      final isActive =
          customerInfo.entitlements.all[entitlementID]?.isActive ?? false;

      return PurchaseResult(
        success: isActive,
        customerInfo: customerInfo,
      );
    } catch (e) {
      print('Error purchasing package: $e');
      return PurchaseResult(
        success: false,
        error: handlePurchaseError(e),
      );
    }
  }

  // Restore purchases
  static Future<bool> restorePurchases() async {
    if (isTestMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      print("RevenueCatService: Mock restore successful");
      return true;
    }

    try {
      // Check if RevenueCat is properly initialized
      if (!_isInitialized) {
        print('RevenueCat not initialized, cannot restore purchases');
        return false;
      }

      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementID]?.isActive ?? false;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }

  // Check if user has premium access
  static Future<bool> isPremiumUser() async {
    if (isTestMode) {
      return false; // Default to false in test mode to allow testing upgrade flow
    }

    try {
      // Check if RevenueCat is properly initialized
      if (!_isInitialized) {
        return false;
      }

      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementID]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    if (isTestMode) return null;

    try {
      if (!_isInitialized) {
        return null;
      }
      return await Purchases.getCustomerInfo();
    } catch (e) {
      return null;
    }
  }

  // Get package by product ID
  static Package? getPackageByProductId(
      List<Package> packages, String productId) {
    try {
      return packages.firstWhere(
        (package) => package.storeProduct.identifier == productId,
      );
    } catch (e) {
      return null;
    }
  }

  // Format price for display
  static String formatPrice(Package package) {
    try {
      return package.storeProduct.priceString;
    } catch (e) {
      return 'Price unavailable';
    }
  }

  // Get subscription period
  static String getSubscriptionPeriod(Package package) {
    try {
      final productId = package.storeProduct.identifier;
      if (productId.contains('weekly')) {
        return 'week';
      } else if (productId.contains('monthly')) {
        return 'month';
      } else if (productId.contains('yearly') || productId.contains('annual')) {
        return 'year';
      }
      return 'subscription';
    } catch (e) {
      return 'subscription';
    }
  }

  // Calculate savings percentage (comparing to monthly)
  static String calculateSavings(
      Package yearlyPackage, Package monthlyPackage) {
    try {
      final yearlyPrice = yearlyPackage.storeProduct.price;
      final monthlyPrice = monthlyPackage.storeProduct.price * 12;

      if (monthlyPrice > 0) {
        final savings =
            ((monthlyPrice - yearlyPrice) / monthlyPrice * 100).round();
        return '$savings%';
      }
      return '0%';
    } catch (e) {
      return '0%';
    }
  }

  // Handle purchase errors
  static String handlePurchaseError(dynamic error) {
    if (error is PurchasesError) {
      switch (error.code) {
        case PurchasesErrorCode.purchaseCancelledError:
          return 'Purchase was cancelled';
        case PurchasesErrorCode.purchaseNotAllowedError:
          return 'Purchase not allowed';
        case PurchasesErrorCode.purchaseInvalidError:
          return 'Purchase invalid';
        case PurchasesErrorCode.productNotAvailableForPurchaseError:
          return 'Product not available';
        case PurchasesErrorCode.networkError:
          return 'Network error. Please check your connection';
        case PurchasesErrorCode.receiptAlreadyInUseError:
          return 'Receipt already in use';
        case PurchasesErrorCode.missingReceiptFileError:
          return 'Missing receipt file';
        case PurchasesErrorCode.paymentPendingError:
          return 'Payment is pending';
        case PurchasesErrorCode.storeProblemError:
          return 'Store problem. Please try again later';
        default:
          return 'Purchase failed: ${error.message}';
      }
    }
    return 'An unexpected error occurred';
  }

  // MOCK DATA GENERATION
  static List<Package> _getMockPackages() {
    // Note: Constructing simplified mock objects.
    // In a real scenario we might need to rely on a wrapper if Package constructor is restrictive,
    // but assuming standard usage for now.

    // Creating Mock StoreProducts
    final monthlyProduct = StoreProduct(monthlyProductId,
        "Monthly Subscription", "Pro Monthly", 4.99, "\$4.99", "USD");

    final yearlyProduct = StoreProduct(yearlyProductId, "Yearly Subscription",
        "Pro Yearly", 19.99, "\$19.99", "USD");

    final lifetimeProduct = StoreProduct(lifetimeProductId, "Lifetime Access",
        "Pro Lifetime", 49.99, "\$49.99", "USD");

    // Creating Mock Packages
    final monthlyPackage = Package(
      "monthly",
      PackageType.monthly,
      monthlyProduct,
      PresentedOfferingContext("default", null, null),
    );

    final yearlyPackage = Package(
      "annual",
      PackageType.annual,
      yearlyProduct,
      PresentedOfferingContext("default", null, null),
    );

    final lifetimePackage = Package(
      "lifetime",
      PackageType.lifetime,
      lifetimeProduct,
      PresentedOfferingContext("default", null, null),
    );

    return [monthlyPackage, yearlyPackage, lifetimePackage];
  }
}
