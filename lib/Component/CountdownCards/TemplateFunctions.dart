import 'dart:io';
import 'package:flutter/material.dart';

class TemplateFunctions {
  /// Safely loads an image, falling back to a default asset if the file doesn't exist
  static ImageProvider getSafeImageProvider(String imagePath, String fallbackAsset) {
    try {
      // Check if the path starts with 'assets/' (it's an asset)
      if (imagePath.startsWith('assets/')) {
        return AssetImage(imagePath);
      }
      
      // Check if the file exists
      final file = File(imagePath);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        // File doesn't exist, use fallback asset
        print('Image file not found: $imagePath, using fallback: $fallbackAsset');
        return AssetImage(fallbackAsset);
      }
    } catch (e) {
      // Any error, use fallback asset
      print('Error loading image: $imagePath, error: $e, using fallback: $fallbackAsset');
      return AssetImage(fallbackAsset);
    }
  }
  
  /// Creates a safe DecorationImage with error handling
  static DecorationImage getSafeDecorationImage({
    required String imagePath, 
    required String fallbackAsset,
    BoxFit fit = BoxFit.cover,
    ColorFilter? colorFilter,
  }) {
    return DecorationImage(
      image: getSafeImageProvider(imagePath, fallbackAsset),
      fit: fit,
      colorFilter: colorFilter,
    );
  }
}

