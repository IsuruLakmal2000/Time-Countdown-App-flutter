import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Providers/WidgetProvider.dart';

class WidgetConfigPage extends StatefulWidget {
  const WidgetConfigPage({Key? key}) : super(key: key);

  @override
  State<WidgetConfigPage> createState() => _WidgetConfigPageState();
}

class _WidgetConfigPageState extends State<WidgetConfigPage> {
  static const platform =
      MethodChannel('com.circularx.timecountdown/widget_config');

  List<CountDownData> countdowns = [];
  CountDownData? selectedCountdown;
  int? widgetId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Get widget ID from native
      try {
        final id = await platform.invokeMethod('getWidgetId');
        setState(() {
          widgetId = id as int?;
        });
      } catch (e) {
        print('Could not get widget ID: $e');
        // Widget ID might not be available if opened from widget tap
        // Continue anyway to show countdowns
      }

      // Load countdowns
      final loadedCountdowns = await LocalStorageService.getCountdowns();
      setState(() {
        countdowns = loadedCountdowns;
        isLoading = false;
      });
    } catch (e) {
      print('Error initializing widget config: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _configureWidget() async {
    if (selectedCountdown == null) return;

    try {
      // Update widget through provider
      final widgetProvider =
          Provider.of<WidgetProvider>(context, listen: false);
      await widgetProvider.setCountdownForWidget(selectedCountdown!);

      // Save the specific widget-countdown mapping in native preferences
      // CRITICAL: We invoke this even if widgetId is null.
      // The native Activity (CountdownWidgetConfigureActivity) holds the correct appWidgetId
      // and uses it as a fallback if the one passed here is null/invalid.
      await platform.invokeMethod('configureWidget', {
        'countdownId': selectedCountdown!.countDownId,
        'widgetId': widgetId,
        'frequency': '5min',
      });

      // Also update all widgets to ensure immediate update
      await platform.invokeMethod('updateAllWidgets');

      // Note: The native side normally handles 'finish()' after successful configuration.
      // If we are here, it means the platform channel call returned successfully.
    } catch (e) {
      print('Error configuring widget: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Error: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancelConfiguration() async {
    try {
      await platform.invokeMethod('cancelConfiguration');
    } catch (e) {
      print('Error canceling configuration: $e');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Select Countdown for Widget',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: _cancelConfiguration,
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : countdowns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No countdowns available',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create a countdown in the app first',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.green,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Select a countdown to display on your home screen widget',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: countdowns.length,
                        itemBuilder: (context, index) {
                          final countdown = countdowns[index];
                          final isSelected = selectedCountdown?.countDownId ==
                              countdown.countDownId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedCountdown = countdown;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.white.withOpacity(0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.white.withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        isSelected ? Icons.check : Icons.event,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            countdown.countDownTitle,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _formatDate(
                                                countdown.countDownTargetDate),
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.radio_button_checked,
                                        color: Colors.green,
                                      )
                                    else
                                      Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.white54,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancelConfiguration,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white38),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Cancel'),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: selectedCountdown != null
                                    ? _configureWidget
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child: Text(
                                  'Add Widget',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    final days = difference.inDays;
    if (days > 365) {
      final years = (days / 365).floor();
      return 'in $years year${years > 1 ? 's' : ''}';
    } else if (days > 30) {
      final months = (days / 30).floor();
      return 'in $months month${months > 1 ? 's' : ''}';
    } else if (days > 0) {
      return 'in $days day${days > 1 ? 's' : ''}';
    } else {
      return 'Today';
    }
  }
}
