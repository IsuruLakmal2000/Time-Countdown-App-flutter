import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class DimControl extends StatelessWidget {
  DimControl({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Slider(
            value: widgetStateProvider.dimCount,
            onChanged: (value) {
              widgetStateProvider.dimCount = value;
            },
            min: 0,
            max: 1,
          ),
        ),
        IconButton(
          onPressed: () {
            widgetStateProvider.renderedWidget = "settings";
          },
          icon: const Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
