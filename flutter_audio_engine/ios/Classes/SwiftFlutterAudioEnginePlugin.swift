import AVFoundation
import Flutter
import UIKit

enum PlayerStatus: Int {
  case NOT_INITIALIZED = -4
  case INITIALIZED = -3
  case READY = -2
  case STOPPED = -1
  case PAUSED = 0
  case RESUMED = 1
}

public class SwiftFlutterAudioEnginePlugin: NSObject, FlutterPlugin, FlutterStreamHandler, StreamingDelegate {
  public func streamer(_: Streaming, failedDownloadWithError error: Error, forURL _: URL) {}

  public func streamer(_: Streaming, updatedDownloadProgress progress: Float, forURL _: URL) {
    if Float(streamer.duration ?? 0) * progress >= 20.0 {
      onPlayerReady()
    }
  }

  public func streamer(_: Streaming, changedState state: StreamingState) {
    if state == .stopped {
      if playerStatus == .NOT_INITIALIZED || playerStatus == .INITIALIZED {
        updatePlayerStatus(as: .INITIALIZED)
        return
      }
    }
    updatePlayerStatus(to: state)
  }

  public func streamer(_: Streaming, updatedCurrentTime _: TimeInterval) {}

  public func streamer(_: Streaming, updatedDuration _: TimeInterval) {}

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    let arg = arguments as? String
    if arg == "forStatus" {
      playerStatusEventSink = events
    } else if arg == "forPosition" {
      playerPositionEventSink = events
    }
    return nil
  }

  public func onCancel(withArguments _: Any?) -> FlutterError? {
    playerStatusEventSink = nil
    playerPositionEventSink = nil
    return nil
  }

  lazy var streamer: TimePitchStreamer = {
    let streamer = TimePitchStreamer()
    streamer.delegate = self
    return streamer
  }()

  var displayLink: CADisplayLink!

  var playerStatusEventSink: FlutterEventSink!
  var playerPositionEventSink: FlutterEventSink!

  var playerStatus: PlayerStatus = PlayerStatus.NOT_INITIALIZED

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_audio_engine", binaryMessenger: registrar.messenger())

    let playerStatusChannel = FlutterEventChannel(name: "borhnn/playerStatus", binaryMessenger: registrar.messenger())
    let playerPositionChannel = FlutterEventChannel(name: "borhnn/playerPosition", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterAudioEnginePlugin()
    playerStatusChannel.setStreamHandler(instance)
    playerPositionChannel.setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? NSDictionary
    switch call.method {
    case "getCurrentPosition":
      result(Int(streamer.currentTime ?? 0))
    case "initPlayer":
      let string = args?["fileURL"] as! String
      initPlayer(fileUrl: string, result)
    case "play":
      executePlay(result)
    case "pause":
      executePause(result)
    case "setPlayerSpeed":
      let newRate = args?["playbackRate"] as! NSNumber
      setPlayerSpeed(newRate)
    case "setPlayerPitch":
      let halfStepDelta = args?["halfstepDelta"] as! Float
      setPlayerSemitoneDelta(semitoneDelta: halfStepDelta)
    case "stop":
      executeStop(result)
    case "setVolume":
      let newVolume = args?["volume"] as! NSNumber
      setVolume(newVolume)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  fileprivate func initPlayer(fileUrl: String, _ result: (Any?) -> Void) {
    do {
      try initPlayer(url: URL(string: fileUrl) ?? URL(fileURLWithPath: "NO NO NO NO"), result: result)
    } catch {
      result(FlutterError(code: "AUDIO_ENGINE_FAILURE", message: error.localizedDescription, details: nil))
    }
    let displayLink = CADisplayLink(target: self, selector: #selector(fireTimer))
    displayLink.add(to: .current, forMode: .defaultRunLoopMode)
  }

  func initPlayer(url: URL, result _: FlutterResult) throws {
    updatePlayerStatus(as: .NOT_INITIALIZED)
    setupAudioSession()
    resetPitch(self)
    resetRate(self)
    streamer.url = url
    updatePlayerStatus(as: .INITIALIZED)
  }

  func setupAudioSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      if #available(iOS 11.0, *) {
        try session.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, routeSharingPolicy: .default, options: [.allowBluetoothA2DP, .defaultToSpeaker])
      } else {
        try session.setCategory(AVAudioSessionCategoryPlayback, with: [.allowBluetoothA2DP, .defaultToSpeaker])
      }
      try session.setActive(true)
    } catch {
      NSLog("Failed to activate audio session: %@", error.localizedDescription)
    }
    NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListener(notification:)), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: streamer.engine)
  }

  @IBAction func resetPitch(_: Any) {
    let pitch: Float = 0
    streamer.pitch = pitch
  }

  fileprivate func setPlayerSemitoneDelta(semitoneDelta: Float) {
    let newRate = semitoneDelta * 100
    streamer.pitch = newRate
  }

  @IBAction func resetRate(_: Any) {
    let rate: Float = 1
    streamer.rate = rate
  }

  fileprivate func setPlayerSpeed(_ newRate: NSNumber) {
    streamer.rate = newRate.floatValue
  }

  @objc func fireTimer() {
    let durationDouble = (streamer.currentTime ?? 0) * 1000
    let currentTimeInt = Int(durationDouble)
    if currentTimeInt > 0 {
      playerPositionEventSink?(currentTimeInt)
    }
  }

  fileprivate func onPlayerReady() {
    do {
      try streamer.seek(to: 0.0)
    } catch {
      NSLog("unable to seek")
    }
    updatePlayerStatus(as: .READY)
  }

  fileprivate func executePlay(_: (Any?) -> Void) {
    play()
    updatePlayerStatus()
  }

  fileprivate func play() {
    streamer.play()
  }

  fileprivate func onPlayerResume() {
    updatePlayerStatus(as: .RESUMED)
  }

  fileprivate func executePause(_: (Any?) -> Void) {
    pause()
    updatePlayerStatus()
  }

  fileprivate func pause() {
    streamer.pause()
  }

  fileprivate func onPlayerPaused() {
    playerStatus = PlayerStatus.PAUSED
    playerStatusEventSink?(playerStatus.rawValue)
  }

  fileprivate func executeStop(_: FlutterResult) {
    stop()
    updatePlayerStatus()
    onPlayerStopped()
  }

  fileprivate func stop() {
    streamer.stop()
  }

  fileprivate func onPlayerStopped() {
    displayLink?.invalidate()
    displayLink = nil
    updatePlayerStatus(as: .STOPPED)
  }

  @objc func audioRouteChangeListener(notification _: NSNotification) {
    displayLink?.invalidate()
    if playerStatus == PlayerStatus.RESUMED {
      pause()
      play()
    }
    do {
      try streamer.seek(to: streamer.currentTime ?? 0.0)
    } catch {}
    displayLink = CADisplayLink(target: self, selector: #selector(fireTimer))
    displayLink.add(to: .current, forMode: .defaultRunLoopMode)
  }

  fileprivate func setVolume(_ newVolume: NSNumber) {
    streamer.volume = newVolume.floatValue
  }

  fileprivate func updatePlayerStatus(to state: StreamingState? = nil, as status: PlayerStatus? = nil) {
    let prevStatus = playerStatus

    let newState: StreamingState = state ?? streamer.state
    var newStatus: PlayerStatus
    switch newState {
    case .stopped:
      newStatus = .STOPPED
    case .paused:
      newStatus = .PAUSED
    case .playing:
      newStatus = .RESUMED
    }
    newStatus = status ?? newStatus

    if newStatus == .INITIALIZED {
      if prevStatus == .NOT_INITIALIZED {
        playerStatus = newStatus
      } else {
        NSLog("Illegal Status: prev: %d, new: %d", prevStatus.rawValue, newStatus.rawValue)
      }
    } else if newStatus == .READY {
      if prevStatus == .INITIALIZED || prevStatus == .READY {
        playerStatus = newStatus
      } else {
        NSLog("Illegal Status: prev: %d, new: %d", prevStatus.rawValue, newStatus.rawValue)
      }
    } else if newStatus == .STOPPED {
      if prevStatus == .READY || prevStatus == .RESUMED || prevStatus == .PAUSED || prevStatus == .STOPPED {
        playerStatus = newStatus
      } else {
        NSLog("Illegal Status: prev: %d, new: %d", prevStatus.rawValue, newStatus.rawValue)
      }
    } else if newStatus == .PAUSED {
      if prevStatus == .PAUSED || prevStatus == .RESUMED {
        playerStatus = newStatus
      } else {
        NSLog("Illegal Status: prev: %d, new: %d", prevStatus.rawValue, newStatus.rawValue)
      }
    } else if newStatus == .RESUMED {
      if prevStatus == .PAUSED || prevStatus == .READY {
        playerStatus = newStatus
      } else {
        NSLog("Illegal Status: prev: %d, new: %d", prevStatus.rawValue, newStatus.rawValue)
      }
    } else if newStatus == .NOT_INITIALIZED {
      if true {
        playerStatus = newStatus
      } else {
        NSLog("Illegal Status: prev: %d, new: %d", prevStatus.rawValue, newStatus.rawValue)
      }
    } else {
      NSLog("Illegal new Status: %f", newStatus.rawValue)
    }
    playerStatusEventSink?(playerStatus.rawValue)
  }
}
