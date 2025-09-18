// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    FiltersRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FiltersScreen(),
      );
    },
    GroupSelectionRoute.name: (routeData) {
      final args = routeData.argsAs<GroupSelectionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: GroupSelectionScreen(
          key: args.key,
          selectedEntity: args.selectedEntity,
          onSelectedEntityChanged: args.onSelectedEntityChanged,
        ),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsScreen(),
      );
    },
    TimetableRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TimetableScreen(),
      );
    },
  };
}

/// generated route for
/// [FiltersScreen]
class FiltersRoute extends PageRouteInfo<void> {
  const FiltersRoute({List<PageRouteInfo>? children})
      : super(
          FiltersRoute.name,
          initialChildren: children,
        );

  static const String name = 'FiltersRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [GroupSelectionScreen]
class GroupSelectionRoute extends PageRouteInfo<GroupSelectionRouteArgs> {
  GroupSelectionRoute({
    Key? key,
    required SelectedEntity? selectedEntity,
    required void Function(SelectedEntity?) onSelectedEntityChanged,
    List<PageRouteInfo>? children,
  }) : super(
          GroupSelectionRoute.name,
          args: GroupSelectionRouteArgs(
            key: key,
            selectedEntity: selectedEntity,
            onSelectedEntityChanged: onSelectedEntityChanged,
          ),
          initialChildren: children,
        );

  static const String name = 'GroupSelectionRoute';

  static const PageInfo<GroupSelectionRouteArgs> page =
      PageInfo<GroupSelectionRouteArgs>(name);
}

class GroupSelectionRouteArgs {
  const GroupSelectionRouteArgs({
    this.key,
    required this.selectedEntity,
    required this.onSelectedEntityChanged,
  });

  final Key? key;

  final SelectedEntity? selectedEntity;

  final void Function(SelectedEntity?) onSelectedEntityChanged;

  @override
  String toString() {
    return 'GroupSelectionRouteArgs{key: $key, selectedEntity: $selectedEntity, onSelectedEntityChanged: $onSelectedEntityChanged}';
  }
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TimetableScreen]
class TimetableRoute extends PageRouteInfo<void> {
  const TimetableRoute({List<PageRouteInfo>? children})
      : super(
          TimetableRoute.name,
          initialChildren: children,
        );

  static const String name = 'TimetableRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
