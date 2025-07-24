import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Services/CountdownWidgetService.dart';

class AndroidMultiWidgetConfigurationPage extends StatefulWidget {
  const AndroidMultiWidgetConfigurationPage({Key? key}) : super(key: key);

  @override
  State<AndroidMultiWidgetConfigurationPage> createState() => _AndroidMultiWidgetConfigurationPageState();
}

class _AndroidMultiWidgetConfigurationPageState extends State<AndroidMultiWidgetConfigurationPage> {
  List<CountDownData> _countdowns = [];
  Map<int, String> _widgetConfiguration = {};
  Map<int, String> _widgetFrequencyConfiguration = {};
  bool _isLoading = true;
  
  // Track which widget is currently being configured
  int? _configuringWidgetIndex;
  String? _selectedCountdownId;
  String _selectedFrequency = CountdownWidgetService.FREQUENCY_15_MIN;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('Loading countdowns and Android widget configuration...');
      
      // Load available countdowns
      final countdowns = await CountdownWidgetService.getAvailableCountdowns();
      
      // Load current Android widget configuration
      final widgetConfig = await CountdownWidgetService.getAndroidWidgetConfiguration();
      
      // Load current frequency configuration
      final frequencyConfig = await CountdownWidgetService.getAndroidWidgetFrequencyConfiguration();
      
      print('Loaded ${countdowns.length} countdowns');
      print('Current Android widget configuration: $widgetConfig');
      print('Current Android frequency configuration: $frequencyConfig');
      
      setState(() {
        _countdowns = countdowns;
        _widgetConfiguration = widgetConfig;
        _widgetFrequencyConfiguration = frequencyConfig;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading Android widget data: $e');
      setState(() {
        _countdowns = [];
        _widgetConfiguration = {};
        _widgetFrequencyConfiguration = {};
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _configureWidget(int widgetIndex, String countdownId) async {
    try {
      await CountdownWidgetService.configureAndroidWidgetWithFrequency(widgetIndex, countdownId, _selectedFrequency);
      
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
            content: Text('Android Widget $widgetIndex configured successfully!'),
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
    final timeRemaining = CountdownWidgetService.calculateTimeRemaining(targetDate);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Configure Android Widgets',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _countdowns.isEmpty
              ? _buildEmptyState()
              : _configuringWidgetIndex != null
                  ? _buildCountdownSelector()
                  : _buildWidgetList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
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
    );
  }

  Widget _buildWidgetList() {
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
                Icons.android,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Configure each Android widget individually. Each widget can display a different countdown with custom update frequency.',
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
            itemCount: allWidgetIndices.length,
            itemBuilder: (context, index) {
              final widgetIndex = allWidgetIndices[index];
              final isConfigured = _widgetConfiguration.containsKey(widgetIndex);
              final countdownId = _widgetConfiguration[widgetIndex];
              final frequency = _widgetFrequencyConfiguration[widgetIndex] ?? 'Not set';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
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
                      _selectedFrequency = _widgetFrequencyConfiguration[widgetIndex] ?? CountdownWidgetService.FREQUENCY_15_MIN;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
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

  Widget _buildCountdownSelector() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a2a),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                      ? Border.all(color: Colors.green, width: 2)
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
                          color: Colors.green,
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
        // Frequency selector
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a2a),
            borderRadius: BorderRadius.circular(12),
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
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCountdownId != null && _configuringWidgetIndex != null
                  ? () => _configureWidget(_configuringWidgetIndex!, _selectedCountdownId!)
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
        ),
      ],
    );
  }
}
