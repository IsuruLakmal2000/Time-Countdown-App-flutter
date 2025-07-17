import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Services/CountdownWidgetService.dart';
import 'package:timecountdown/Providers/PremiumProvider.dart';
import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';

class WidgetStyleSelectionPage extends StatefulWidget {
  const WidgetStyleSelectionPage({Key? key}) : super(key: key);

  @override
  State<WidgetStyleSelectionPage> createState() => _WidgetStyleSelectionPageState();
}

class _WidgetStyleSelectionPageState extends State<WidgetStyleSelectionPage> {
  String _selectedStyle = CountdownWidgetService.STYLE_GLASS;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStyle();
  }

  Future<void> _loadCurrentStyle() async {
    try {
      final currentStyle = await CountdownWidgetService.getWidgetStyle();
      final isPremium = Provider.of<PremiumProvider>(context, listen: false).isPremium;
      
      // If current style is premium but user doesn't have premium, reset to neomorphism
      if (_isPremiumStyle(currentStyle) && !isPremium) {
        await CountdownWidgetService.setWidgetStyle(CountdownWidgetService.STYLE_NEOMORPHISM);
        setState(() {
          _selectedStyle = CountdownWidgetService.STYLE_NEOMORPHISM;
          _isLoading = false;
        });
      } else {
        setState(() {
          _selectedStyle = currentStyle;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading widget style: $e');
      setState(() {
        _selectedStyle = CountdownWidgetService.STYLE_NEOMORPHISM; // Default to free style
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStyle(String style) async {
    // Check if style requires premium and user doesn't have it
    final isPremium = Provider.of<PremiumProvider>(context, listen: false).isPremium;
    
    if (_isPremiumStyle(style) && !isPremium) {
      _showPremiumRequiredDialog(style);
      return;
    }
    
    try {
      await CountdownWidgetService.setWidgetStyle(style);
      setState(() {
        _selectedStyle = style;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Widget style updated to ${getStyleDisplayName(style)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating widget style: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update widget style'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isPremiumStyle(String style) {
    // Only Neomorphism is free, all others require premium
    return style != CountdownWidgetService.STYLE_NEOMORPHISM;
  }

  void _showPremiumRequiredDialog(String style) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Premium Required',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The ${getStyleDisplayName(style)} widget style is a premium feature.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Upgrade to premium to unlock:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'All premium widget styles',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Unlimited countdowns',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Pro templates & themes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 252, 6, 252),
                    Color.fromARGB(255, 255, 0, 119),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PremiumPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String getStyleDisplayName(String style) {
    switch (style) {
      case CountdownWidgetService.STYLE_GLASS:
        return 'Glass Effect';
      case CountdownWidgetService.STYLE_GRADIENT:
        return 'Gradient';
      case CountdownWidgetService.STYLE_SUNSET:
        return 'Sunset';
      case CountdownWidgetService.STYLE_NEOMORPHISM:
        return 'Neomorphism';
      default:
        return 'Glass Effect';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Style'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Widget Style',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Select the visual style for your countdown widget on the home screen.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Premium Notice
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 252, 6, 252).withOpacity(0.1),
                                Color.fromARGB(255, 255, 0, 119).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color.fromARGB(255, 252, 6, 252).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Free vs Premium Styles',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Neomorphism style is free • All other styles require premium',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Glass Effect Style Option
                        _buildStyleOption(
                          title: 'Glass Effect',
                          description: 'Transparent glass effect with blur and frosted borders',
                          style: CountdownWidgetService.STYLE_GLASS,
                          previewColor: Colors.white.withOpacity(0.2),
                          borderColor: Colors.white.withOpacity(0.3),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Gradient Style Option
                        _buildStyleOption(
                          title: 'Gradient',
                          description: 'Beautiful gradient background with modern colors',
                          style: CountdownWidgetService.STYLE_GRADIENT,
                          previewColor: const Color(0xFF667eea),
                          borderColor: Colors.purple.withOpacity(0.5),
                          isGradient: true,
                          gradientColors: [
                            const Color(0xFF667eea),
                            const Color(0xFF764ba2),
                            const Color(0xFFf093fb),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Sunset Gradient Style Option
                        _buildStyleOption(
                          title: 'Sunset',
                          description: 'Warm sunset gradient with pink and orange tones',
                          style: CountdownWidgetService.STYLE_SUNSET,
                          previewColor: const Color(0xFFff9a9e),
                          borderColor: Colors.pink.withOpacity(0.5),
                          isGradient: true,
                          gradientColors: [
                            const Color(0xFFff9a9e),
                            const Color(0xFFfecfef),
                            const Color(0xFFff6b6b),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Neomorphism Style Option
                        _buildStyleOption(
                          title: 'Neomorphism',
                          description: 'Dark background with soft shadow and highlight effects',
                          style: CountdownWidgetService.STYLE_NEOMORPHISM,
                          previewColor: const Color(0xFF2C2C2E),
                          borderColor: Colors.grey.withOpacity(0.3),
                        ),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                
                // Fixed Done Button at Bottom
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStyleOption({
    required String title,
    required String description,
    required String style,
    required Color previewColor,
    required Color borderColor,
    bool isGradient = false,
    List<Color>? gradientColors,
  }) {
    final isSelected = _selectedStyle == style;
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;
    final isStylePremium = _isPremiumStyle(style);
    final isLocked = isStylePremium && !isPremium;
    
    return GestureDetector(
      onTap: () => _updateStyle(style),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFF2C2C2E).withOpacity(0.5) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Preview Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isGradient ? null : previewColor,
                    gradient: isGradient ? LinearGradient(
                      colors: gradientColors ?? [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                        const Color(0xFFf093fb),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                    boxShadow: style == CountdownWidgetService.STYLE_NEOMORPHISM
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(4, 4),
                              blurRadius: 8,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              offset: const Offset(-2, -2),
                              blurRadius: 6,
                            ),
                          ]
                        : style == CountdownWidgetService.STYLE_GRADIENT
                        ? [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ]
                        : style == CountdownWidgetService.STYLE_SUNSET
                        ? [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '15',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: style == CountdownWidgetService.STYLE_NEOMORPHISM 
                                    ? const Color(0xFFE5E5E7) 
                                    : Colors.white,
                                shadows: style == CountdownWidgetService.STYLE_GRADIENT || style == CountdownWidgetService.STYLE_SUNSET
                                    ? [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            Text(
                              'Days',
                              style: TextStyle(
                                fontSize: 10,
                                color: style == CountdownWidgetService.STYLE_NEOMORPHISM 
                                    ? const Color(0xFFA1A1A6) 
                                    : Colors.white70,
                                shadows: style == CountdownWidgetService.STYLE_GRADIENT || style == CountdownWidgetService.STYLE_SUNSET
                                    ? [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lock overlay for premium styles
                      if (isLocked)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock,
                              color: Colors.white.withOpacity(0.8),
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.white.withOpacity(0.6) : Colors.white,
                            ),
                          ),
                          if (isStylePremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 252, 6, 252),
                                    Color.fromARGB(255, 255, 0, 119),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocked ? Colors.grey[400]?.withOpacity(0.6) : Colors.grey[400],
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Upgrade to premium to unlock',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Selection Indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : (isLocked ? Colors.grey.withOpacity(0.5) : Colors.grey),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
