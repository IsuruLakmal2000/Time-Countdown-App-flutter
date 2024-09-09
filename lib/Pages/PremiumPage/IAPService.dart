import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';

class IAPService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  Future<void> init() async {
    // Check if in-app purchases are available
    bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // Handle the case when IAP is not available
    }
  }

  Future<List<ProductDetails>> getProducts() async {
    Set<String> _kIds = {'com.circularx.timecountdown.pro'};
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kIds);

    if (response.error == null && response.productDetails.isNotEmpty) {
      print('prducts available' + response.productDetails.toString());

      return response.productDetails;
    } else {
      // Handle the error
      print('prducts not available');
      return [];
    }
  }

  void listenToPurchaseUpdates() {
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          // Show a loading indicator
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle the error
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          // Grant the ad-free version or premium features
          _grantAccess(purchaseDetails.productID);
          if (purchaseDetails.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchaseDetails);
          }
        }
      }
    });
  }

  void _grantAccess(String productID) async {
    if (productID == 'com.circularx.timecountdown.pro') {
      // Grant ad-free access
      await savePurchaseDetails();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isBuyPremium', true);
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    print('prducts  available ----buy');
    print('product -' + product.id);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

// Check if the user has already purchased the premium on locally
}
