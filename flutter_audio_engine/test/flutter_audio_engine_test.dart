import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audio_engine/flutter_audio_engine.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_audio_engine');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterAudioEngine.platformVersion, '42');
  });
}
