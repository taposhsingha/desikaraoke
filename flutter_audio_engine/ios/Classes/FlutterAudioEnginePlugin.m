#import "FlutterAudioEnginePlugin.h"
#import <flutter_audio_engine/flutter_audio_engine-Swift.h>

@implementation FlutterAudioEnginePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAudioEnginePlugin registerWithRegistrar:registrar];
}
@end
