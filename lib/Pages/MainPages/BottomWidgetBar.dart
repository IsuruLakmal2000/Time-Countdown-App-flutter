import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarComponents/BottomBar.dart';
import 'package:timecountdown/Component/BottomBarComponents/DimControl.dart';
import 'package:timecountdown/Component/BottomBarComponents/TemplateSelecter.dart';
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

// Helper function to hide bottom bar when settings is active (settings bar includes close button now)
Widget _buildSettingsOnlyBar(BuildContext context) {
  // Return empty container since settings bar now includes the close button
  return Container();
}
