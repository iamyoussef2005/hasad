import 'package:flutter/material.dart';

enum ProduceCategory {
  all,
  vegetables,
  leafyGreens,
  fruits,
  citrus,
  herbs;

  String getLocalizedName(String lang) {
    switch (this) {
      case ProduceCategory.all:
        return lang == 'ar' ? 'الكل' : 'All';
      case ProduceCategory.vegetables:
        return lang == 'ar' ? 'خضار' : 'Vegetables';
      case ProduceCategory.leafyGreens:
        return lang == 'ar' ? 'ورقيات' : 'Leafy Greens';
      case ProduceCategory.fruits:
        return lang == 'ar' ? 'فواكه' : 'Fruits';
      case ProduceCategory.citrus:
        return lang == 'ar' ? 'حمضيات' : 'Citrus';
      case ProduceCategory.herbs:
        return lang == 'ar' ? 'أعشاب' : 'Herbs';
    }
  }

  IconData get icon {
    switch (this) {
      case ProduceCategory.all:
        return Icons.grid_view_rounded;
      case ProduceCategory.vegetables:
        return Icons.eco_rounded;
      case ProduceCategory.leafyGreens:
        return Icons.grass_rounded;
      case ProduceCategory.fruits:
        return Icons.apple_rounded;
      case ProduceCategory.citrus:
        return Icons.wb_sunny_rounded;
      case ProduceCategory.herbs:
        return Icons.spa_rounded;
    }
  }
}

enum ProduceUnit {
  kg,
  box,
  piece,
  bundle;

  String getLocalized(String lang) {
    switch (this) {
      case ProduceUnit.kg:
        return lang == 'ar' ? 'كغ' : 'kg';
      case ProduceUnit.box:
        return lang == 'ar' ? 'صندوق' : 'box';
      case ProduceUnit.piece:
        return lang == 'ar' ? 'حبة' : 'pc';
      case ProduceUnit.bundle:
        return lang == 'ar' ? 'ربطة' : 'bundle';
    }
  }
}
