import 'package:flutter/widgets.dart';

abstract class HubLocation {
  /// Ex. /products/:productId/*
  /// ':' Replace it with value. The values is saved in queryParameters
  /// '*' Accept all segments after this keyword
  String get bluePath;

  /// You can add your Provider her
  Widget buildHub(BuildContext context, Widget child) => child;

  /// You can build page with
  ///  - [MaterialPage]
  ///  - [CupertinoPage]
  ///  - [DevicePage]
  Page buildPage(BuildContext context);

  @visibleForTesting
  HubLocation setData(HubLocationData data) => this;
  @visibleForTesting
  HubLocationData getData() => HubLocationData();

  @override
  String toString() => '$runtimeType(bluePath:$bluePath)';
}

@visibleForTesting
class HubLocationData {
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const HubLocationData({
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, String>{},
  });

  HubLocationData clone() {
    return HubLocationData(
      pathParameters: Map.of(pathParameters),
      queryParameters: Map.of(queryParameters),
    );
  }

  HubLocationData copyWith({
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
  }) {
    return HubLocationData(
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
    );
  }
}

@visibleForTesting
class HubLocationEntry {
  final HubLocation location;
  final HubLocationData data;

  HubLocationEntry(this.location, this.data);
}
