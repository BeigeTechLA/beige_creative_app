import 'package:beige_creative_app/core/network/dio_client.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';

class _Probe extends ConsumerWidget {
  const _Probe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(dioClientProvider);
    return Text(
      'baseUrl=${client.dio.options.baseUrl}',
      textDirection: TextDirection.ltr,
    );
  }
}

void main() {
  testWidgets('pumpProviderApp honors dioClientProvider override',
      (tester) async {
    final overrideDio = Dio(BaseOptions(baseUrl: 'https://override.example/'));
    final overrideClient = DioClient.withDio(overrideDio);

    await tester.pumpProviderApp(
      const _Probe(),
      overrides: [
        dioClientProvider.overrideWithValue(overrideClient),
      ],
    );

    expect(find.text('baseUrl=https://override.example/'), findsOneWidget);
  });
}
