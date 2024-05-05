import 'dart:convert';

import 'package:drongo_app/core/utils/icon_image.dart';
import 'package:drongo_app/data_screen.dart';
import 'package:drongo_app/local_providers/scaledata.dart';
// import 'package:drongo_app/widgets/button.dart';
import 'package:drongo_app/widgets/component_decoration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart';

const rowSplitter = SizedBox(width: 20); //rowDivider
const colSplitter = SizedBox(height: 10); //colDivider
const lowestSpacing = 3.0; //tinySpacing
const lowSpacing = 10.0; //smallSpacing
const double cWidth = 115; //cardWidth
const double widthLimit = 450; //widthConstraint

class HomeListOne extends StatelessWidget {
  //FirstComponentList
  const HomeListOne({
    super.key,
    required this.showNavBottomBar,
    required this.scaffoldKey,
    required this.showSecondList,
  });

  final bool showNavBottomBar;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool showSecondList;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const Scale(), //Actions
      colSplitter,
      const Data(), //Communication
      colSplitter,
      const Track(), //Containment
      if (!showSecondList) ...[
        colSplitter,
        const Data(),
        colSplitter,
        const Track(),
      ],
    ];
    List<double?> heights = List.filled(children.length, null);

    // Fully traverse this list before moving on.
    return FocusTraversalGroup(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: showSecondList
                ? const EdgeInsetsDirectional.only(end: lowSpacing)
                : EdgeInsets.zero,
            sliver: SliverList(
              delegate: BuildSlivers(
                heights: heights,
                builder: (context, index) {
                  return _CacheHeight(
                    heights: heights,
                    index: index,
                    child: children[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeListTwo extends StatelessWidget {
  const HomeListTwo({
    super.key,
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const DataCards(),
      colSplitter,
      const Track(),
    ];
    List<double?> heights = List.filled(children.length, null);

    // Fully traverse this list before moving on.
    return FocusTraversalGroup(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.only(end: lowSpacing),
            sliver: SliverList(
              delegate: BuildSlivers(
                heights: heights,
                builder: (context, index) {
                  return _CacheHeight(
                    heights: heights,
                    index: index,
                    child: children[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// If the content of a CustomScrollView does not change, then it's
// safe to cache the heights of each item as they are laid out. The
// sum of the cached heights are returned by an override of
// `SliverChildDelegate.estimateMaxScrollOffset`. The default version
// of this method bases its estimate on the average height of the
// visible items. The override ensures that the scrollbar thumb's
// size, which depends on the max scroll offset, will shrink smoothly
// as the contents of the list are exposed for the first time, and
// then remain fixed.
class _CacheHeight extends SingleChildRenderObjectWidget {
  const _CacheHeight({
    super.child,
    required this.heights,
    required this.index,
  });

  final List<double?> heights;
  final int index;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCacheHeight(
      heights: heights,
      index: index,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderCacheHeight renderObject) {
    renderObject
      ..heights = heights
      ..index = index;
  }
}

class _RenderCacheHeight extends RenderProxyBox {
  _RenderCacheHeight({
    required List<double?> heights,
    required int index,
  })  : _heights = heights,
        _index = index,
        super();

  List<double?> _heights;
  List<double?> get heights => _heights;
  set heights(List<double?> value) {
    if (value == _heights) {
      return;
    }
    _heights = value;
    markNeedsLayout();
  }

  int _index;
  int get index => _index;
  set index(int value) {
    if (value == index) {
      return;
    }
    _index = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();
    heights[index] = size.height;
  }
}

// The heights information is used to override the `estimateMaxScrollOffset` and
// provide a more accurate estimation for the max scroll offset.
class BuildSlivers extends SliverChildBuilderDelegate {
  BuildSlivers({
    required NullableIndexedWidgetBuilder builder,
    required this.heights,
  }) : super(builder, childCount: heights.length);

  final List<double?> heights;

  @override
  double? estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    return heights.reduce((sum, height) => (sum ?? 0) + (height ?? 0))!;
  }
}

//Scale actions on homepage
class Scale extends StatelessWidget {
  const Scale({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Scale', children: <Widget>[
      ScaleActions(),
    ]);
  }
}

class ScaleActions extends StatefulWidget {
  //Buttons
  const ScaleActions({super.key});

  @override
  State<ScaleActions> createState() => _ScaleActionsState();
}

class _ScaleActionsState extends State<ScaleActions> {
  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Control and monitoring',
      tooltipMessage:
          'Turn the scale on/off, zero the mass reading, show battery life, connect to the scale\'s web server to transmit data, check the RFID reader, find out more about the application.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ESP32StateButtons(),
            rowSplitter,
            rowSplitter,
            ScalingButtons(),
          ],
        ),
      ),
    );
  }
}

class ESP32StateButtons extends StatelessWidget {
  const ESP32StateButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FilledButton.icon(
              onPressed: () {},
              label: const Text('Power'),
              icon: const Icon(Icons.power_settings_new),
              // icon: const Icon(Icons.add),
            ),
            colSplitter,
            FilledButton.icon(
              onPressed: () {},
              label: const Text('Battery'),
              icon: const Icon(Icons.battery_4_bar_rounded),
            ),
            colSplitter,
            FilledButton.icon(
                onPressed: () {},
                label: const Text('Download'),
                icon: const Icon(Icons.download)),
          ],
        ),
      ),
    );
  }
}

class ScalingButtons extends StatelessWidget {
  const ScalingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FilledButton.icon(
              onPressed: () {},
              label: const Text('Reset'),
              icon: const Icon(Icons.exposure_zero),
            ),
            colSplitter,
            FilledButton.icon(
              onPressed: () {},
              label: const Text('Pair'),
              icon: const Icon(Icons.wifi_tethering),
            ),
            colSplitter,
            FilledButton.icon(
              onPressed: () {},
              label: const Text('About'),
              icon: const Icon(Icons.description),
            )
          ],
        ),
      ),
    );
  }
}

class Data extends StatelessWidget {
  const Data({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Data', children: <Widget>[
      DataCards(),
    ]);
  }
}

//Data section on homepage
class DataCards extends StatelessWidget {
  const DataCards({super.key});

  // Widget schemeView(ThemeData theme) {
  //   return Expanded(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 15),
  //       child: DataSchemeView(
  //         colorScheme: theme.colorScheme,
  //         sortingOrder: 0,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Color selectedColor = Theme.of(context).primaryColor;
    ThemeData lightTheme = ThemeData(
      colorSchemeSeed: selectedColor,
      brightness: Brightness.light,
    );
    ThemeData darkTheme = ThemeData(
      colorSchemeSeed: selectedColor,
      brightness: Brightness.dark,
    );
    bool isBright =
        Theme.of(context).brightness == Brightness.light ? true : false;
    // return ComponentGroupDecoration(label: 'Data', children: <Widget>[
    //   DataView(
    //     colorScheme: isBright ? lightTheme.colorScheme : darkTheme.colorScheme,
    //   ),
    // isBright ? schemeView(lightTheme) : schemeView(darkTheme);
    // ]);
    return ComponentDecoration(
      label: 'Data viewing and sorting',
      tooltipMessage: 'View data collected from Scalio.',
      child: Column(
        children: [
          DataView(
            colorScheme:
                isBright ? lightTheme.colorScheme : darkTheme.colorScheme,
          ),
        ],
      ),
    );
  }
}

class DataView extends StatefulWidget {
  //Buttons
  const DataView({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  List drongos = [];
  List<Widget> items = [];

  Future<void> loadScaleJson() async {
    final String response =
        await rootBundle.loadString('assets/local_data/drongo_data.json');
    final scaleData = await json.decode(response);
    setState(() {
      drongos = scaleData["drongos"];
      // print("..number of items ${_items.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    loadScaleJson();
  }

  @override
  Widget build(BuildContext context) {
    // loadScaleJson();
    items = List<Widget>.generate(
        (drongos.length ~/ 2).toInt(),
        (int index) => DrongoGroupedData(children: [
              DataChip(
                  index: 0,
                  color: widget.colorScheme.primary,
                  value: drongos[index]['tagID'].toString(),
                  onColor: widget.colorScheme.onPrimary),
              DataChip(
                  index: 1,
                  color: widget.colorScheme.onPrimary,
                  value: drongos[index]['mass'].toString(),
                  onColor: widget.colorScheme.primary),
              DataChip(
                  index: 2,
                  color: widget.colorScheme.onPrimary,
                  value: drongos[index]['date'].toString(),
                  onColor: widget.colorScheme.primary),
              DataChip(
                  index: 3,
                  color: widget.colorScheme.onPrimary,
                  value: drongos[index]['time'].toString(),
                  onColor: widget.colorScheme.primary),
              DataChip(
                  index: 4,
                  color: widget.colorScheme.onPrimary,
                  value: '---',
                  onColor: widget.colorScheme.primary),
            ]),
        growable: true);

    if (items.isNotEmpty) {
      return Column(
        children: items,
      );
    } else {
      return Column(children: [
        DrongoGroupedData(children: [
          DataChip(
              index: 0,
              color: widget.colorScheme.primary,
              value: "No Data Avaliable",
              onColor: widget.colorScheme.onPrimary),
          DataChip(
              index: 1,
              color: widget.colorScheme.onPrimary,
              value: '---',
              onColor: widget.colorScheme.primary),
          DataChip(
              index: 2,
              color: widget.colorScheme.onPrimary,
              value: '---',
              onColor: widget.colorScheme.primary),
          DataChip(
              index: 3,
              color: widget.colorScheme.onPrimary,
              value: '---',
              onColor: widget.colorScheme.primary),
          DataChip(
              index: 4,
              color: widget.colorScheme.onPrimary,
              value: '---',
              onColor: widget.colorScheme.primary),
        ]),
      ]);
    }
  }
}

// class DataListView extends StatefulWidget {
//   DataListView({
//     super.key,
//     required this.drongoCard,
//   });

//   final DrongoGroupedData drongoCard;

//   @override
//   State<DataListView> createState() => _DataListViewState();
// }

// class _DataListViewState extends State<DataListView> {
//   @override
//   Widget build(BuildContext context) {
//     Color selectedColor = Theme.of(context).primaryColor;
//     ThemeData lightTheme = ThemeData(
//       colorSchemeSeed: selectedColor,
//       brightness: Brightness.light,
//     );
//     ThemeData darkTheme = ThemeData(
//       colorSchemeSeed: selectedColor,
//       brightness: Brightness.dark,
//     );
//   }
// }

//Data section on homepage
class Track extends StatelessWidget {
  const Track({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Track', children: <Widget>[
      TrackMapView(),
    ]);
  }
}

class TrackMapView extends StatefulWidget {
  //Buttons
  const TrackMapView({super.key});

  @override
  State<TrackMapView> createState() => _TrackMapViewState();
}

class _TrackMapViewState extends State<TrackMapView> {
  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Most recent drongo location(s)',
      tooltipMessage:
          'Track the most recently spotted drongo using previous locations..',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // ESP32StateButtons(),
            // ScalingButtons(),
          ],
        ),
      ),
    );
  }
}

class NavigationBars extends StatefulWidget {
  const NavigationBars(
      {super.key,
      this.onSelectItem,
      required this.selectedIndex,
      this.hideNavBar = false
      // required this.isExampleBar,
      // this.isBadgeExample = false,
      });

  final void Function(int)? onSelectItem;
  final int selectedIndex;
  final bool hideNavBar;
  // final bool isExampleBar;
  // final bool isBadgeExample;

  @override
  State<NavigationBars> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBars> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant NavigationBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    // App NavigationBar should get first focus.
    Widget navigationBar = Focus(
      autofocus: !widget.hideNavBar,
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (!widget.hideNavBar) widget.onSelectItem!(index);
        },
        destinations: appRoutingDestinations,
      ),
    );

    // if (widget.isExampleBar && widget.isBadgeExample) {
    //   navigationBar = ComponentDecoration(
    //       label: 'Badges',
    //       tooltipMessage: 'Use Badge or Badge.count',
    //       child: navigationBar);
    // } else if (widget.isExampleBar) {
    //   navigationBar = ComponentDecoration(
    //       label: 'Navigation bar',
    //       tooltipMessage: 'Use NavigationBar',
    //       child: navigationBar);
    // }

    return navigationBar;
  }
}

// class NavigationDrawers extends StatelessWidget {
//   const NavigationDrawers({super.key, required this.scaffoldKey});
//   final GlobalKey<ScaffoldState> scaffoldKey;

//   @override
//   Widget build(BuildContext context) {
//     return ComponentDecoration(
//       label: 'Navigation drawer',
//       tooltipMessage:
//           'Use NavigationDrawer. For modal navigation drawers, see Scaffold.endDrawer',
//       child: Column(
//         children: [
//           const SizedBox(height: 520, child: NavigationDrawerSection()),
//           colSplitter,
//           colSplitter,
//           TextButton(
//             child: const Text('Show modal navigation drawer',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             onPressed: () {
//               scaffoldKey.currentState!.openEndDrawer();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class NavigationDrawerSection extends StatefulWidget {
//   const NavigationDrawerSection({super.key});

//   @override
//   State<NavigationDrawerSection> createState() =>
//       _NavigationDrawerSectionState();
// }

// class _NavigationDrawerSectionState extends State<NavigationDrawerSection> {
//   int navDrawerIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return NavigationDrawer(
//       onDestinationSelected: (selectedIndex) {
//         setState(() {
//           navDrawerIndex = selectedIndex;
//         });
//       },
//       selectedIndex: navDrawerIndex,
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
//           child: Text(
//             'Mail',
//             style: Theme.of(context).textTheme.titleSmall,
//           ),
//         ),
//         ...destinations.map((destination) {
//           return NavigationDrawerDestination(
//             label: Text(destination.label),
//             icon: destination.icon,
//             selectedIcon: destination.selectedIcon,
//           );
//         }),
//         const Divider(indent: 28, endIndent: 28),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
//           child: Text(
//             'Labels',
//             style: Theme.of(context).textTheme.titleSmall,
//           ),
//         ),
//         ...labelDestinations.map((destination) {
//           return NavigationDrawerDestination(
//             label: Text(destination.label),
//             icon: destination.icon,
//             selectedIcon: destination.selectedIcon,
//           );
//         }),
//       ],
//     );
//   }
// }

List<NavigationDestination> appRoutingDestinations = [
  const NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.home_outlined),
    label: 'Home',
    selectedIcon: Icon(Icons.home),
  ),
  const NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.balance_outlined),
    label: 'Scale',
    selectedIcon: Icon(Icons.balance_rounded),
  ),
  const NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.leaderboard_outlined),
    label: 'Data',
    selectedIcon: Icon(Icons.leaderboard),
  ),
  const NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.share_location),
    label: 'Track',
    selectedIcon: Icon(Icons.share_location),
  ),
];

enum ColorItem {
  red('red', Colors.red),
  orange('orange', Colors.orange),
  yellow('yellow', Colors.yellow),
  green('green', Colors.green),
  blue('blue', Colors.blue),
  indigo('indigo', Colors.indigo),
  violet('violet', Color(0xFF8F00FF)),
  purple('purple', Colors.purple),
  pink('pink', Colors.pink),
  silver('silver', Color(0xFF808080)),
  gold('gold', Color(0xFFFFD700)),
  beige('beige', Color(0xFFF5F5DC)),
  brown('brown', Colors.brown),
  grey('grey', Colors.grey),
  black('black', Colors.black),
  white('white', Colors.white);

  const ColorItem(this.label, this.color);
  final String label;
  final Color color;
}
