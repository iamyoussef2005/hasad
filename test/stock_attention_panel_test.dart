import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenstock/data/repositories/mock_produce_data.dart';
import 'package:greenstock/presentation/screens/dashboard/widgets/stock_attention_panel.dart';

void main() {
  final base = MockProduceData.getInitialProduce().first;
  final items = [
    base.copyWith(
      id: 'low',
      nameEn: 'Apples',
      nameAr: 'تفاح',
      currentStock: 1,
      minStockThreshold: 10,
      freshnessScore: 0.9,
    ),
    base.copyWith(
      id: 'risk',
      nameEn: 'Tomatoes',
      nameAr: 'بندورة',
      currentStock: 100,
      minStockThreshold: 1,
      freshnessScore: 0.2,
    ),
  ];

  Future<void> mount(
    WidgetTester tester, {
    String lang = 'en',
    double width = 390,
    double scale = 1,
    bool dark = false,
  }) async {
    tester.view.physicalSize = Size(width, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1200),
            textScaler: TextScaler.linear(scale),
          ),
          child: Directionality(
            textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              body: SingleChildScrollView(
                child: StockAttentionPanel(items: items, lang: lang),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'filters and search update results, clearing search restores alerts',
    (tester) async {
      await mount(tester);
      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Tomatoes'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Freshness'));
      await tester.pumpAndSettle();
      expect(find.text('Apples'), findsNothing);
      expect(find.text('Tomatoes'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'nothing');
      await tester.pumpAndSettle();
      expect(find.text('No matching alerts'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Tomatoes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'purchase list copies only low-stock items and suggested quantities',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await mount(tester);
      await tester.tap(find.text('Copy suggested purchase list'));
      await tester.pumpAndSettle();
      expect(copied, contains('Apples: 19.0'));
      expect(copied, isNot(contains('Tomatoes')));
      expect(find.text('Purchase list copied'), findsOneWidget);
    },
  );

  for (final config in [
    (320.0, 1.0, false),
    (390.0, 1.6, true),
    (1100.0, 1.0, true),
  ]) {
    testWidgets('Arabic layout at width ${config.$1}, scale ${config.$2}', (
      tester,
    ) async {
      await mount(
        tester,
        lang: 'ar',
        width: config.$1,
        scale: config.$2,
        dark: config.$3,
      );
      expect(find.text('مركز المتابعة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
