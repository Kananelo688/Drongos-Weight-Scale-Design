import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// An implementation of [FlutterEspBleProvPlatform] that uses method channels.
class MethodChannelFlutterEspBleProv extends FlutterEspBleProvPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_esp_ble_prov');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<String>> scanBleDevices(String prefix) async {
    final args = {'prefix': prefix};
    final raw =
        await methodChannel.invokeMethod<List<Object?>>('scanBleDevices', args);
    final List<String> devices = [];
    if (raw != null) {
      devices.addAll(raw.cast<String>());
    }
    return devices;
  }

  @override
  Future<List<String>> scanWifiNetworks(
      String deviceName, String proofOfPossession) async {
    final args = {
      'deviceName': deviceName,
      'proofOfPossession': proofOfPossession,
    };
    final raw = await methodChannel.invokeMethod<List<Object?>>(
        'scanWifiNetworks', args);
    final List<String> networks = [];
    if (raw != null) {
      networks.addAll(raw.cast<String>());
    }
    return networks;
  }

  @override
  Future<bool?> provisionWifi(String deviceName, String proofOfPossession,
      String ssid, String passphrase) async {
    final args = {
      'deviceName': deviceName,
      'proofOfPossession': proofOfPossession,
      'ssid': ssid,
      'passphrase': passphrase
    };
    return await methodChannel.invokeMethod<bool?>('provisionWifi', args);
  }
}

abstract class FlutterEspBleProvPlatform extends PlatformInterface {
  /// Constructs a FlutterEspBleProvPlatform.
  FlutterEspBleProvPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterEspBleProvPlatform _instance = MethodChannelFlutterEspBleProv();

  /// The default instance of [FlutterEspBleProvPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterEspBleProv].
  static FlutterEspBleProvPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterEspBleProvPlatform] when
  /// they register themselves.
  static set instance(FlutterEspBleProvPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<String>> scanBleDevices(String prefix) {
    throw UnimplementedError('scanBleDevices has not been implemented.');
  }

  Future<List<String>> scanWifiNetworks(
      String deviceName, String proofOfPossession) {
    throw UnimplementedError('scanWifiNetworks has not been implemented.');
  }

  Future<bool?> provisionWifi(String deviceName, String proofOfPossession,
      String ssid, String passphrase) {
    throw UnimplementedError('provisionWifi has not been implemented');
  }
}

class FlutterEspBleProv {
  /// Initiates a scan of BLE devices with the given [prefix].
  ///
  /// ESP32 Arduino demo defaults this value to "PROV_"
  Future<List<String>> scanBleDevices(String prefix) {
    return FlutterEspBleProvPlatform.instance.scanBleDevices(prefix);
  }

  /// Scan the available WiFi networks for the given [deviceName] and
  /// [proofOfPossession] string.

  /// This library uses SECURITY_1 by default which insists on a
  /// [proofOfPossession] string. ESP32 Arduino demo defaults this value to
  /// "abcd1234"
  Future<List<String>> scanWifiNetworks(
      String deviceName, String proofOfPossession) {
    return FlutterEspBleProvPlatform.instance
        .scanWifiNetworks(deviceName, proofOfPossession);
  }

  /// Provision the named WiFi network at [ssid] with the given [passphrase] for
  /// the named device [deviceName] and [proofOfPossession] string.
  Future<bool?> provisionWifi(String deviceName, String proofOfPossession,
      String ssid, String passphrase) {
    return FlutterEspBleProvPlatform.instance
        .provisionWifi(deviceName, proofOfPossession, ssid, passphrase);
  }

  /// Returns the native platform version
  Future<String?> getPlatformVersion() {
    return FlutterEspBleProvPlatform.instance.getPlatformVersion();
  }
}
