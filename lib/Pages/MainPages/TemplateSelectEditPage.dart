import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarComponents/SettingBar.dart';
import 'package:timecountdown/Pages/MainPages/BottomWidgetBar.dart';
import 'package:timecountdown/Pages/MainPages/ShowSelectedTemplate.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class TemplateSelectEditPage extends StatefulWidget {
  TemplateSelectEditPage({
    super.key,
  });

  @override
  State<TemplateSelectEditPage> createState() => _TemplateSelectEditPageState();
}

class _TemplateSelectEditPageState extends State<TemplateSelectEditPage> {
  // String renderedWidget = "none";
  // double dimCount = 0.8;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider = Provider.of<RenderedWidgetProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.2),
                const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Text(
            'Edit Template',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ShowSelectedTemplate(context),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Bottom controls container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: BottomWidgetBar(context),
            ),
          ),
          // Show vertical settings bar when settings is active
          if (widgetStateProvider.renderedWidget == "settings")
            SettingsBar(),
          // Loading overlay with modern spinner
          if (widgetStateProvider.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.2),
                        const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 252, 6, 252),
                        ),
                        backgroundColor: Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.3),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 252, 6, 252),
                            Color.fromARGB(255, 255, 0, 119),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Saving...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
