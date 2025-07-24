import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Services/CountdownWidgetService.dart';

class IOSWidgetConfigurationPage extends StatefulWidget {
  const IOSWidgetConfigurationPage({Key? key}) : super(key: key);

  @override
  State<IOSWidgetConfigurationPage> createState() => _IOSWidgetConfigurationPageState();
}

class _IOSWidgetConfigurationPageState extends State<IOSWidgetConfigurationPage> {
  List<CountDownData> _countdowns = [];
  bool _isLoading = true;
  String? _selectedCountdownId;

  @override
  void initState() {
    super.initState();
    _loadCountdowns();
  }

  Future<void> _loadCountdowns() async {
    try {
      print('Loading countdowns for iOS widget configuration...');
      final countdowns = await CountdownWidgetService.getAvailableCountdowns();
      print('Loaded ${countdowns.length} countdowns');
      setState(() {
        _countdowns = countdowns;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading countdowns: $e');
      setState(() {
        _countdowns = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load countdowns: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _configureWidget() async {
    if (_selectedCountdownId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a countdown'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (Platform.isIOS) {
        await CountdownWidgetService.configureIOSWidget(_selectedCountdownId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Widget configured successfully! Your widgets will update shortly.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Close the configuration page after a delay
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    } catch (e) {
      print('Error configuring iOS widget: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to configure widget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeRemaining(DateTime targetDate) {
    final timeRemaining = CountdownWidgetService.calculateTimeRemaining(targetDate);
    return '${timeRemaining['days']}d ${timeRemaining['hours']}h ${timeRemaining['minutes']}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Configure Widget',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _countdowns.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Active Countdowns',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create a countdown to display in widgets',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select a countdown to display in your widgets. All widgets will show the selected countdown.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _countdowns.length,
                        itemBuilder: (context, index) {
                          final countdown = _countdowns[index];
                          final isSelected = _selectedCountdownId == countdown.countDownId;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF3a3a3a)
                                  : const Color(0xFF2a2a2a),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                countdown.countDownTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTimeRemaining(countdown.countDownTargetDate),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Target: ${countdown.countDownTargetDate.day}/${countdown.countDownTargetDate.month}/${countdown.countDownTargetDate.year}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                    )
                                  : const Icon(
                                      Icons.radio_button_unchecked,
                                      color: Colors.grey,
                                    ),
                              onTap: () {
                                setState(() {
                                  _selectedCountdownId = countdown.countDownId;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedCountdownId != null ? _configureWidget : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Configure Widget',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
