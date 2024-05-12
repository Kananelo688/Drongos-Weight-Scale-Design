import 'dart:io';

import 'package:drongo_app/core/utils/icon_image.dart';
import 'package:drongo_app/home_screen.dart';
import 'package:drongo_app/widgets/component_decoration.dart';
import 'package:drongo_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/rendering.dart';

// const rowSplitter = SizedBox(width: 20); //rowDivider
// const colSplitter = SizedBox(height: 10); //colDivider

// If the content of a CustomScrollView does not change, then it's
// safe to cache the heights of each item as they are laid out. The
// sum of the cached heights are returned by an override of
// `SliverChildDelegate.estimateMaxScrollOffset`. The default version
// of this method bases its estimate on the average height of the
// visible items. The override ensures that the scrollbar thumb's
// size, which depends on the max scroll offset, will shrink smoothly
// as the contents of the list are exposed for the first time, and
// then remain fixed.

const horizontalSplitter = SizedBox(
  width: 48,
);

const verticalSplitter = SizedBox(
  height: 48,
);

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

class ScaleListOne extends StatelessWidget {
  //FirstComponentList
  const ScaleListOne({
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
      const ScaleInterface(), //Actions
      colSplitter,
      // const AboutInterface(), //Communication
      // colSplitter,
      // const ScaleInterface(), //Containment
      if (!showSecondList) ...[
        // colSplitter,
        // const ScaleInterface(),
        colSplitter,
        const AboutInterface(),
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

class ScaleListTwo extends StatelessWidget {
  const ScaleListTwo({
    super.key,
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const AboutInterface(), //Actions
      colSplitter,
      // const DataCards(),
      // colSplitter,
      // const Track(),
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

//Scale actions on homepage
class ScaleScreen extends StatelessWidget {
  const ScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentGroupDecoration(label: 'Scale', children: <Widget>[
      ScaleInterface(),
    ]);
  }
}

class ScaleInterface extends StatefulWidget {
  //Buttons
  const ScaleInterface({super.key});

  @override
  State<ScaleInterface> createState() => _ScaleInterfaceState();
}

class _ScaleInterfaceState extends State<ScaleInterface> {
  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'Control and monitoring.',
      tooltipMessage:
          'Turn the scale on/off, zero the mass reading, show battery life, connect to the scale\'s web server to transmit data, check the RFID reader, find out more about the application.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ESP32LargeButtonColumn(),
            horizontalSplitter,
            ScalingLargeButtonColum(),
          ],
        ),
      ),
    );
  }
}

class AboutInterface extends StatefulWidget {
  //Buttons
  const AboutInterface({super.key});

  @override
  State<AboutInterface> createState() => _AboutInterfaceState();
}

class _AboutInterfaceState extends State<AboutInterface> {
  @override
  Widget build(BuildContext context) {
    return const ComponentDecoration(
      label: 'More information.',
      tooltipMessage:
          'Information about the scale is broken down into pop-ups the are activated by pressing the buttons.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InstructionsButtonColumn(),
            horizontalSplitter,
            ImageButtonColumn(),
          ],
        ),
      ),
    );
  }
}

const double narrowScreenWidthThreshold = 450;

class ESP32LargeButtonColumn extends StatelessWidget {
  const ESP32LargeButtonColumn({super.key});

  void initBLE() async {
    // first, check if bluetooth is supported by your hardware
// Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // cancel to prevent duplicate listeners
    subscription.cancel();
  }

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.power_settings_new,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Power',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter, //rowDivider
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.battery_4_bar,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Battery',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter, //rowDivider
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.download,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Download',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}

class ScalingLargeButtonColum extends StatelessWidget {
  const ScalingLargeButtonColum({super.key});

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.wifi_tethering,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Connect',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter, //rowDivider
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.exposure_zero,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Reset',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter, //rowDivider
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.description,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'About',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}

class InstructionsButtonColumn extends StatelessWidget {
  const InstructionsButtonColumn({super.key});

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.integration_instructions,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Instructions',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter, //rowdivider
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.note_add_sharp,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Notes',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter, //rowdivider
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.group_add,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Group 24',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}

class ImageButtonColumn extends StatelessWidget {
  const ImageButtonColumn({super.key});

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.center_focus_strong_rounded,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Scalio',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter,
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.health_and_safety_rounded,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'Safety',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ),
            verticalSplitter,
            LargeScaleButtonDecorations(
              actionIcon: Icon(
                Icons.account_balance,
                color: isBright
                    ? lightTheme.colorScheme.onPrimary
                    : darkTheme.colorScheme.onPrimary,
                size: 54,
              ),
              actionLabel: 'UCT',
              labelColor: isBright ? Colors.white : Colors.black,
              buttonColor: isBright
                  ? lightTheme.colorScheme.primary
                  : darkTheme.colorScheme.primary,
            ) //rowDivider
          ],
        ),
      ),
    );
  }
}

class LargeScaleButtonDecorations extends StatelessWidget {
  const LargeScaleButtonDecorations({
    super.key,
    required this.actionIcon,
    required this.actionLabel,
    required this.labelColor,
    required this.buttonColor,
    // required this.actionFunction,
  });

  final Icon actionIcon;
  final String actionLabel;
  final Color labelColor;
  final Color buttonColor;
  // final void Function() actionFunction;
  // final String actionFunction;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        // onTap: actionFunction,
        child: Container(
          decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: const BorderRadius.all(Radius.circular(8.0))),
          height: 100,
          width: 100,
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: actionIcon,
                ),
              ),
              Text(
                actionLabel,
                style: TextStyle(color: labelColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
