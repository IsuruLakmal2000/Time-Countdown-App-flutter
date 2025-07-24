import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Services/CountdownWidgetService.dart';
import 'package:timecountdown/Pages/WidgetPages/WidgetStyleSelectionPage.dart';

class WidgetConfigurationPage extends StatefulWidget {
  const WidgetConfigurationPage({Key? key}) : super(key: key);

  @override
  State<WidgetConfigurationPage> createState() => _WidgetConfigurationPageState();
}

class _WidgetConfigurationPageState extends State<WidgetConfigurationPage> {
  List<CountDownData> _countdowns = [];
  bool _isLoading = true;
  String? _selectedCountdownId;
  String _selectedFrequency = CountdownWidgetService.FREQUENCY_15_MIN;
  
  // Initialize platform detection directly in the variable declaration
  late final bool _isAndroid = Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    _loadCountdowns();
    
    // Fallback timeout to prevent infinite loading
    Timer(const Duration(seconds: 10), () {
      if (_isLoading && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadCountdowns() async {
    try {
      final countdowns = await CountdownWidgetService.getAvailableCountdowns();
      
      if (mounted) {
        setState(() {
          _countdowns = countdowns;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _countdowns = [];
        _isLoading = false;
      });
      // Show error message to user
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
      // Use platform-specific configuration with frequency
      if (_isAndroid || Platform.isAndroid) {
        // For Android, we need a widget ID - get it from the platform
        final widgetId = await CountdownWidgetService.getWidgetId();
        if (widgetId != -1) {
          await CountdownWidgetService.configureAndroidWidgetWithFrequency(widgetId, _selectedCountdownId!, _selectedFrequency);
        } else {
          // Fallback to basic configuration
          await CountdownWidgetService.configureWidget(_selectedCountdownId!);
        }
      } else {
        // For iOS, use the basic configuration (frequency is handled internally)
        await CountdownWidgetService.configureIOSWidget(_selectedCountdownId!);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget configured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to configure widget: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelConfiguration() async {
    try {
      await CountdownWidgetService.cancelConfiguration();
    } catch (e) {
      // Handle error silently or show user-friendly message if needed
    }
  }

  String _formatTimeRemaining(DateTime targetDate) {
    final timeRemaining = CountdownWidgetService.calculateTimeRemaining(targetDate);
    return '${timeRemaining['days']}d ${timeRemaining['hours']}h ${timeRemaining['minutes']}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Select Countdown for Widget',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _cancelConfiguration,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _countdowns.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(child: _buildCountdownList()),
                    // Show frequency selector for Android devices only
                    if (_isAndroid) _buildFrequencySelector(),
                  ],
                ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_off,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Countdowns Available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a countdown in the main app first, then come back to add it as a widget.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                'Go Back to Main App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _countdowns.length,
      itemBuilder: (context, index) {
        final countdown = _countdowns[index];
        final isSelected = _selectedCountdownId == countdown.countDownId;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      Colors.blue.withOpacity(0.3),
                      Colors.blue.withOpacity(0.1),
                    ]
                  : [
                      const Color(0xFF16213E),
                      const Color(0xFF0F172A),
                    ],
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () {
              setState(() {
                _selectedCountdownId = countdown.countDownId;
              });
            },
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.purple.withOpacity(0.8),
                  ],
                ),
              ),
              child: const Icon(
                Icons.timer,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              countdown.countDownTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Target: ${_formatDate(countdown.countDownTargetDate)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Remaining: ${_formatTimeRemaining(countdown.countDownTargetDate)}',
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 28,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.white.withOpacity(0.4),
                    size: 28,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Style Selection Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WidgetStyleSelectionPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(
                Icons.palette,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Widget Style',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Main Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelConfiguration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedCountdownId != null ? _configureWidget : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCountdownId != null 
                        ? Colors.blue 
                        : Colors.grey.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Widget',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Frequency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFrequencyOption(CountdownWidgetService.FREQUENCY_1_MIN, '1 min'),
              const SizedBox(width: 8),
              _buildFrequencyOption(CountdownWidgetService.FREQUENCY_5_MIN, '5 min'),
              const SizedBox(width: 8),
              _buildFrequencyOption(CountdownWidgetService.FREQUENCY_15_MIN, '15 min'),
              const SizedBox(width: 8),
              _buildFrequencyOption(CountdownWidgetService.FREQUENCY_1_HOUR, '1 hour'),
            ],
          ),
        ],
      ),
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
            color: isSelected ? Colors.blue : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
