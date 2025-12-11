import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Services/CountdownWidgetService.dart';
import 'package:timecountdown/Providers/PremiumProvider.dart';
import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';
import 'package:timecountdown/Model/CountDownData.dart';

class WidgetStyleSelectionPage extends StatefulWidget {
  const WidgetStyleSelectionPage({Key? key}) : super(key: key);

  @override
  State<WidgetStyleSelectionPage> createState() =>
      _WidgetStyleSelectionPageState();
}

class _WidgetStyleSelectionPageState extends State<WidgetStyleSelectionPage> {
  String _selectedStyle = CountdownWidgetService.STYLE_GLASS;
  bool _isLoading = true;

  // Android widget configuration
  List<CountDownData> _countdowns = [];
  Map<int, String> _widgetConfiguration = {};
  Map<int, String> _widgetFrequencyConfiguration = {};
  int? _configuringWidgetIndex;
  String? _selectedCountdownId;
  String _selectedFrequency = CountdownWidgetService.FREQUENCY_15_MIN;

  @override
  void initState() {
    super.initState();
    _loadCurrentStyle();
    if (Platform.isAndroid) {
      _loadAndroidWidgetData();
    }
  }

  Future<void> _loadCurrentStyle() async {
    try {
      final currentStyle = await CountdownWidgetService.getWidgetStyle();
      final isPremium =
          Provider.of<PremiumProvider>(context, listen: false).isPremium;

      // If current style is premium but user doesn't have premium, reset to neomorphism
      if (_isPremiumStyle(currentStyle) && !isPremium) {
        await CountdownWidgetService.setWidgetStyle(
            CountdownWidgetService.STYLE_NEOMORPHISM);
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
        _selectedStyle =
            CountdownWidgetService.STYLE_NEOMORPHISM; // Default to free style
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAndroidWidgetData() async {
    if (!Platform.isAndroid) return;

    try {
      print('Loading countdowns and Android widget configuration...');

      // Load available countdowns
      final countdowns = await CountdownWidgetService.getAvailableCountdowns();

      // Load current Android widget configuration
      final widgetConfig =
          await CountdownWidgetService.getAndroidWidgetConfiguration();

      // Load current frequency configuration
      final frequencyConfig =
          await CountdownWidgetService.getAndroidWidgetFrequencyConfiguration();

      print('Loaded ${countdowns.length} countdowns');
      print('Current Android widget configuration: $widgetConfig');
      print('Current Android frequency configuration: $frequencyConfig');

      setState(() {
        _countdowns = countdowns;
        _widgetConfiguration = widgetConfig;
        _widgetFrequencyConfiguration = frequencyConfig;
      });
    } catch (e) {
      print('Error loading Android widget data: $e');
      setState(() {
        _countdowns = [];
        _widgetConfiguration = {};
        _widgetFrequencyConfiguration = {};
      });
    }
  }

  Future<void> _configureAndroidWidget(
      int widgetIndex, String countdownId) async {
    try {
      await CountdownWidgetService.configureAndroidWidgetWithFrequency(
          widgetIndex, countdownId, _selectedFrequency);

      setState(() {
        _widgetConfiguration[widgetIndex] = countdownId;
        _widgetFrequencyConfiguration[widgetIndex] = _selectedFrequency;
        _configuringWidgetIndex = null;
        _selectedCountdownId = null;
        _selectedFrequency = CountdownWidgetService.FREQUENCY_15_MIN;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Android Widget $widgetIndex configured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error configuring Android widget: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to configure Android widget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeRemaining(DateTime targetDate) {
    final timeRemaining =
        CountdownWidgetService.calculateTimeRemaining(targetDate);
    return '${timeRemaining['days']}d ${timeRemaining['hours']}h ${timeRemaining['minutes']}m';
  }

  String _getCountdownTitle(String countdownId) {
    final countdown = _countdowns.firstWhere(
      (c) => c.countDownId == countdownId,
      orElse: () => CountDownData(
        countDownId: countdownId,
        countDownTempId: '',
        countDownTitle: 'Unknown Countdown',
        countDownTargetDate: DateTime.now(),
        countDownDim: 0.0,
        countDownCreatedDate: DateTime.now(),
        countDownImage: '',
      ),
    );
    return countdown.countDownTitle;
  }

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case CountdownWidgetService.FREQUENCY_1_MIN:
        return 'Every 1 minute';
      case CountdownWidgetService.FREQUENCY_5_MIN:
        return 'Every 5 minutes';
      case CountdownWidgetService.FREQUENCY_15_MIN:
        return 'Every 15 minutes';
      case CountdownWidgetService.FREQUENCY_1_HOUR:
        return 'Every 1 hour';
      default:
        return 'Every 15 minutes';
    }
  }

  Widget _buildAndroidWidgetConfigurationSection() {
    if (_configuringWidgetIndex != null) {
      return _buildAndroidCountdownSelector();
    } else {
      return _buildAndroidWidgetList();
    }
  }

  Widget _buildAndroidWidgetList() {
    // Show configured widgets and option to add more
    List<int> allWidgetIndices = [];

    // Add all configured widget indices
    allWidgetIndices.addAll(_widgetConfiguration.keys);

    // Add next available index for new widget
    if (allWidgetIndices.isEmpty) {
      allWidgetIndices.add(1);
    } else {
      final maxIndex = allWidgetIndices.reduce((a, b) => a > b ? a : b);
      allWidgetIndices.add(maxIndex + 1);
    }
    allWidgetIndices.sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Android Widget Configuration',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure each Android widget individually. Each widget can display a different countdown with custom update frequency.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        if (_countdowns.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.timer_off,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No Active Countdowns',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create a countdown to display in widgets',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...allWidgetIndices.map((widgetIndex) {
            final isConfigured = _widgetConfiguration.containsKey(widgetIndex);
            final countdownId = _widgetConfiguration[widgetIndex];
            final frequency =
                _widgetFrequencyConfiguration[widgetIndex] ?? 'Not set';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
                border: isConfigured
                    ? Border.all(color: Colors.green, width: 1)
                    : Border.all(color: Colors.grey, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isConfigured ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$widgetIndex',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Android Widget $widgetIndex',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConfigured
                          ? 'Showing: ${_getCountdownTitle(countdownId!)}'
                          : 'Tap to configure',
                      style: TextStyle(
                        color: isConfigured ? Colors.white70 : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    if (isConfigured) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Updates: ${_getFrequencyDisplayName(frequency)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Icon(
                  isConfigured ? Icons.edit : Icons.add,
                  color: isConfigured ? Colors.green : Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    _configuringWidgetIndex = widgetIndex;
                    _selectedCountdownId = countdownId;
                    _selectedFrequency =
                        _widgetFrequencyConfiguration[widgetIndex] ??
                            CountdownWidgetService.FREQUENCY_15_MIN;
                  });
                },
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildAndroidCountdownSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  _configuringWidgetIndex = null;
                  _selectedCountdownId = null;
                  _selectedFrequency = CountdownWidgetService.FREQUENCY_15_MIN;
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Configure Android Widget $_configuringWidgetIndex',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Countdown selection
        const Text(
          'Select Countdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        ..._countdowns.map((countdown) {
          final isSelected = _selectedCountdownId == countdown.countDownId;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3a3a3a)
                  : const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected ? Border.all(color: Colors.green, width: 2) : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                countdown.countDownTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    _formatTimeRemaining(countdown.countDownTargetDate),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Target: ${countdown.countDownTargetDate.day}/${countdown.countDownTargetDate.month}/${countdown.countDownTargetDate.year}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                      size: 20,
                    ),
              onTap: () {
                setState(() {
                  _selectedCountdownId = countdown.countDownId;
                });
              },
            ),
          );
        }).toList(),

        const SizedBox(height: 20),

        // Frequency selector
        const Text(
          'Update Frequency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFrequencyOption(
                CountdownWidgetService.FREQUENCY_1_MIN, '1 min'),
            const SizedBox(width: 8),
            _buildFrequencyOption(
                CountdownWidgetService.FREQUENCY_5_MIN, '5 min'),
            const SizedBox(width: 8),
            _buildFrequencyOption(
                CountdownWidgetService.FREQUENCY_15_MIN, '15 min'),
            const SizedBox(width: 8),
            _buildFrequencyOption(
                CountdownWidgetService.FREQUENCY_1_HOUR, '1 hour'),
          ],
        ),

        const SizedBox(height: 20),

        // Configure button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _selectedCountdownId != null && _configuringWidgetIndex != null
                    ? () => _configureAndroidWidget(
                        _configuringWidgetIndex!, _selectedCountdownId!)
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Configure Android Widget $_configuringWidgetIndex',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyOption(String frequency, String label) {
    final isSelected = _selectedFrequency == frequency;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFrequency = frequency;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : const Color(0xFF3a3a3a),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.green, width: 2)
                : Border.all(color: Colors.grey, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _updateStyle(String style) async {
    // Check if style requires premium and user doesn't have it
    final isPremium =
        Provider.of<PremiumProvider>(context, listen: false).isPremium;

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
          content:
              Text('Widget style updated to ${getStyleDisplayName(style)}'),
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
                                Colors.green.withOpacity(0.1),
                                Colors.lightGreen.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
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
                          description:
                              'Transparent glass effect with blur and frosted borders',
                          style: CountdownWidgetService.STYLE_GLASS,
                          previewColor: Colors.white.withOpacity(0.2),
                          borderColor: Colors.white.withOpacity(0.3),
                        ),

                        const SizedBox(height: 20),

                        // Gradient Style Option
                        _buildStyleOption(
                          title: 'Gradient',
                          description:
                              'Beautiful gradient background with modern colors',
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
                          description:
                              'Warm sunset gradient with pink and orange tones',
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
                          description:
                              'Dark background with soft shadow and highlight effects',
                          style: CountdownWidgetService.STYLE_NEOMORPHISM,
                          previewColor: const Color(0xFF2C2C2E),
                          borderColor: Colors.grey.withOpacity(0.3),
                        ),

                        // Android Widget Configuration Section
                        if (Platform.isAndroid) ...[
                          const SizedBox(height: 40),
                          _buildAndroidWidgetConfigurationSection(),
                        ],

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
          color: isLocked
              ? const Color(0xFF2C2C2E).withOpacity(0.5)
              : const Color(0xFF2C2C2E),
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
                    gradient: isGradient
                        ? LinearGradient(
                            colors: gradientColors ??
                                [
                                  const Color(0xFF667eea),
                                  const Color(0xFF764ba2),
                                  const Color(0xFFf093fb),
                                ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
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
                                color: style ==
                                        CountdownWidgetService.STYLE_NEOMORPHISM
                                    ? const Color(0xFFE5E5E7)
                                    : Colors.white,
                                shadows: style ==
                                            CountdownWidgetService
                                                .STYLE_GRADIENT ||
                                        style ==
                                            CountdownWidgetService.STYLE_SUNSET
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
                                color: style ==
                                        CountdownWidgetService.STYLE_NEOMORPHISM
                                    ? const Color(0xFFA1A1A6)
                                    : Colors.white70,
                                shadows: style ==
                                            CountdownWidgetService
                                                .STYLE_GRADIENT ||
                                        style ==
                                            CountdownWidgetService.STYLE_SUNSET
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
                              color: isLocked
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.white,
                            ),
                          ),
                          if (isStylePremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                          color: isLocked
                              ? Colors.grey[400]?.withOpacity(0.6)
                              : Colors.grey[400],
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
                      color: isSelected
                          ? Colors.blue
                          : (isLocked
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.grey),
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
