import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:timecountdown/Pages/PremiumPage/IAPService.dart';

class PremiumPage extends StatefulWidget {
  PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  late IAPService _iapService;
  bool _isPremium = false;

  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();

    _iapService = IAPService();
    _iapService.init();
    _loadProducts();
    _iapService.listenToPurchaseUpdates();
  }

  Future<void> _loadProducts() async {
    _products = await _iapService.getProducts();
    setState(() {});
  }

  //----------

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
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
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 50, right: 50),
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: RichText(
                                      text: TextSpan(
                                    children: [
                                      // WidgetSpan(
                                      //   child: Icon(
                                      //     Icons.attach_money_rounded,
                                      //     color:
                                      //         Color.fromARGB(255, 252, 6, 252),
                                      //     size: 24,
                                      //   ),
                                      // ),
                                      TextSpan(
                                        text:
                                            '${_products.isNotEmpty ? _products.first.price : 'USD 3.49'}',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 252, 6, 252),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "/One-time",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.2,
                                        child: Image.asset(
                                          "assets/Images/unlimited.png", // Replace with your image path
                                          fit: BoxFit.contain,
                                          height: 40,
                                          width: 40,
                                        ),
                                      ),
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Unlimited countdowns",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              height: 1,
                                            ),
                                          ),
                                          Text(
                                            "Create as many countdowns as you want.",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
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
          //ss
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.2,
                      child: Image.asset(
                        "assets/Images/block.png", // Replace with your image path
                        fit: BoxFit.contain,
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ad-free Experience",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        Text(
                          "Enjoy app experience without any ads.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            height: 1,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.2,
                      child: Image.asset(
                        "assets/Images/unlocked.png", // Replace with your image path
                        fit: BoxFit.contain,
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Unlock pro Templates",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        Text(
                          "Access all premium Templates and features.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            height: 1,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "One-time payment, ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: "lifetime access!",
                  style: TextStyle(
                    color:
                        Colors.amber, // You can change the color for emphasis
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold, // Make this part bold if desired
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
                borderRadius:
                    BorderRadius.circular(30), // Optional: rounded corners
              ),
              child: Material(
                borderRadius: BorderRadius.circular(
                    30), // Match the container's border radius
                color:
                    Colors.transparent, // Make the material color transparent
                child: ElevatedButton(
                  onPressed: () {
                    // Implement the purchase logic here
                    // if (_products.isNotEmpty) {
                    //   _iapService.buyProduct(_products.first);
                    // }
                   // _iapService.buyProduct(_products.first);
                  },
                  child: const Text(
                   // "Upgrade to Premium",
                   'coming soon !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .transparent), // Make button background transparent
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(15),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
