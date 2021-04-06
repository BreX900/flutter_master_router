library hub_router;

import 'package:flutter/widgets.dart';
import 'package:hub_router/src/router/hub_router.dart';

export 'src/router/hub_location.dart';
export 'src/router/hub_parser.dart';
export 'src/router/hub_router.dart';
export 'src/utils.dart';
export 'src/widgets/inject_hub.dart';
export 'src/widgets/stack_hub.dart';

extension HubOnBuildContext on BuildContext {
  /// See [Hub] for navigation methods
  Hub get hub => HubDelegate.of(this);
}
