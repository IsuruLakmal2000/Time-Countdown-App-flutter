import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarComponents/BottomBar.dart';
import 'package:timecountdown/Component/BottomBarComponents/DimControl.dart';
import 'package:timecountdown/Component/BottomBarComponents/SettingBar.dart';
import 'package:timecountdown/Component/BottomBarComponents/TemplateSelecter.dart';
import 'package:timecountdown/Mobile%20ads/InterstialAdService.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';

Widget BottomWidgetBar(
    BuildContext context, Interstialadservice interstitialAdService) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);
  final editCountDownProvider =
      Provider.of<Editcountdownprovider>(context, listen: false);
  final userProvider = context.watch<UserProvider>();

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
      return SettingsBar();
    case 'template':
      return TemplateSelector();
    case 'none':
      return BottomBar(interstitialAdService: interstitialAdService);
    default:
      return BottomBar(interstitialAdService: interstitialAdService);
  }
}
