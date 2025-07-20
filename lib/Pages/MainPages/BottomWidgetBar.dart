import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarComponents/BottomBar.dart';
import 'package:timecountdown/Component/BottomBarComponents/DimControl.dart';
import 'package:timecountdown/Component/BottomBarComponents/TemplateSelecter.dart';
import 'package:timecountdown/Component/BottomBarItemComponent.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

// ignore: non_constant_identifier_names
Widget BottomWidgetBar(
    BuildContext context ) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);

  switch (widgetStateProvider.renderedWidget) {
    //setting dim bottom bar -------------------------------------------------items -----------
    case 'dim':
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DimControl(),
        ],
      );

    case 'settings':
      return _buildSettingsOnlyBar(context); // Show only settings button when settings is active
    case 'template':
      return TemplateSelector();
    case 'none':
    default:
      return BottomBar();
  }
}

// Helper function to show only the settings button when settings is active
Widget _buildSettingsOnlyBar(BuildContext context) {
  final widgetStateProvider = Provider.of<RenderedWidgetProvider>(context, listen: false);
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      // Empty spacer to maintain layout (where template button was)
      SizedBox(width: 60),
      // Empty spacer to maintain layout (where save button was)  
      SizedBox(width: 200),
      // Only show the settings button (which will become tick button via SettingsBar overlay)
      BottomBarItemComponent(
        context,
        Icons.check, // Show as tick when in settings mode
        'Close',
        'none', // Will close settings when pressed
        () {
          widgetStateProvider.renderedWidget = "none";
        },
        iconSize: 36.0,
      ),
    ],
  );
}
