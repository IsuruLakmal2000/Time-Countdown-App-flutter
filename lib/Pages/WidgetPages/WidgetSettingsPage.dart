import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetSettingsPage extends StatefulWidget {
  const WidgetSettingsPage({Key? key}) : super(key: key);

  @override
  State<WidgetSettingsPage> createState() => _WidgetSettingsPageState();
}

class _WidgetSettingsPageState extends State<WidgetSettingsPage> {
  String _selectedFrequency = '15min';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFrequency();
  }

  Future<void> _loadFrequency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        // Default to 15 minutes if not set
        _selectedFrequency =
            prefs.getString('global_widget_frequency') ?? '15min';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFrequency(String frequency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('global_widget_frequency', frequency);

      // Also update WidgetService if needed or trigger an update
      // For now, saving to prefs is enough as the native side pulls from there

      setState(() {
        _selectedFrequency = frequency;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update frequency saved'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error saving frequency: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving frequency: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        title: const Text('Widget Settings',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Frequency',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose how often the widget updates. More frequent updates may consume more battery.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildRadioOption(
                          '1 Minute (High Battery Usage)', '1min'),
                      _buildRadioOption('5 Minutes', '5min'),
                      _buildRadioOption('15 Minutes (Recommended)', '15min'),
                      _buildRadioOption('30 Minutes', '30min'),
                      _buildRadioOption('1 Hour', '1hour'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRadioOption(String title, String value) {
    final isSelected = _selectedFrequency == value;
    return InkWell(
      onTap: () => _saveFrequency(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.white54,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
