import 'dart:math' as math;

import 'package:drongo_app/constants.dart';
import 'package:drongo_app/data_screen.dart';
import 'package:drongo_app/home_screen.dart';
import 'package:drongo_app/scale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'dart:convert';

import 'package:http/http.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.activateLightMode, //userLightMode
    required this.esp32Connected,
    required this.manageLightMode, //handleBrightnessChange
    // required this.openAboutApp,
    required this.devicePowerOn,
    required this.loadDrongoData,
    // required this.addDrongo,
  });

  final bool activateLightMode;
  final bool esp32Connected;
  final bool devicePowerOn;

  final void Function(bool activateLightMode) manageLightMode;
  final void Function(String filePath) loadDrongoData;

  // final void Function() addDrongo;
  // final void Function() openAboutApp;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;

  late String appInfoMessage;

  bool controllerInitialized = false;
  bool showMediumSizeLayout = false;
  bool showLargeSizeLayout = false;

  int screenIndex = CurrentScreen.home.value;
  int _counter = 0;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      value: 0,
      vsync: this,
    );
    railAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width;
    final AnimationStatus status = controller.status;
    if (width > mediumViewPortBreakpoint) {
      if (width > largeViewPortBreakpoint) {
        showMediumSizeLayout = false;
        showLargeSizeLayout = true;
      } else {
        showMediumSizeLayout = true;
        showLargeSizeLayout = false;
      }
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        controller.forward();
      }
    } else {
      showMediumSizeLayout = false;
      showLargeSizeLayout = false;
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        controller.reverse();
      }
    }
    if (!controllerInitialized) {
      controllerInitialized = true;
      controller.value = width > mediumViewPortBreakpoint ? 1 : 0;
    }
  }

  void handleScreenChanged(int screenSelected) {
    setState(() {
      screenIndex = screenSelected;
    });
  }

  Future<void> openAboutApp() async {
    final result = await showPopupCard<String>(
      context: context,
      builder: (context) {
        return PopupCard(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: const PopupCardDetails(),
        );
      },
      offset: const Offset(-8, 60),
      alignment: Alignment.topRight,
      useSafeArea: true,
    );
    if (result == null) return;
    setState(() {
      appInfoMessage = result;
    });
  }

  void incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<Map<String, dynamic>> loadDrongoData(String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    return jsonDecode(jsonString);
  }

  // Future<http.Response> fetchPhotos(http.Client client) async {
  //   return client.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
  // }

  Widget showSelectedScreen(
      CurrentScreen screenSelected, bool showNavBarExample) {
    switch (screenSelected) {
      case CurrentScreen.home:
        return Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: HomeListOne(
                showNavBottomBar: showNavBarExample,
                scaffoldKey: scaffoldKey,
                showSecondList: showMediumSizeLayout || showLargeSizeLayout),
            two: HomeListTwo(
              scaffoldKey: scaffoldKey,
            ),
          ),
        );
      case CurrentScreen.scale:
        return const ScaleScreen();
      //  Expanded(
      //   child: OneTwoTransition(
      //     animation: railAnimation,
      //     one: HomeListOne(
      //         showNavBottomBar: showNavBarExample,
      //         scaffoldKey: scaffoldKey,
      //         showSecondList: showMediumSizeLayout || showLargeSizeLayout),
      //     two: HomeListTwo(
      //       scaffoldKey: scaffoldKey,
      //     ),
      //   ),
      // );
      // return const ScaleScreen();
      case CurrentScreen.data:
        return const DataScreen();
      // return const DataScreen();
      case CurrentScreen.track:
        return Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: HomeListOne(
                showNavBottomBar: showNavBarExample,
                scaffoldKey: scaffoldKey,
                showSecondList: showMediumSizeLayout || showLargeSizeLayout),
            two: HomeListTwo(
              scaffoldKey: scaffoldKey,
            ),
          ),
        );
      // return const TrackScreen();
    }
  }

  PreferredSizeWidget generateAppBar() {
    return AppBar(
      title: screenIndex == 0
          ? const Text('Home')
          : screenIndex == 1
              ? const Text('Scale')
              : screenIndex == 2
                  ? const Text('Data')
                  : const Text('Track'),
      // leading: const BackButton(),
      actions: !showMediumSizeLayout && !showLargeSizeLayout
          ? [
              _LightModeButton(
                //BrightnessButton
                manageLightMode: widget.manageLightMode,
              ),
              _AboutAppButton(
                openAboutApp: openAboutApp,
              )
            ]
          : [Container()],
    );
  }

  Widget _trailingActions() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _LightModeButton(
              //BrightnessButton
              manageLightMode: widget.manageLightMode,
              showTooltipBelow: false,
            ),
          ),
          Flexible(
            child: _AboutAppButton(
              openAboutApp: openAboutApp,
              showTooltipBelow: false,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return NavigationTransition(
          scaffoldKey: scaffoldKey,
          animationController: controller,
          railAnimation: railAnimation,
          appBar: generateAppBar(),
          body: showSelectedScreen(
              CurrentScreen.values[screenIndex], controller.value == 1),
          navigationRail: NavigationRail(
            extended: showLargeSizeLayout,
            destinations: navRailDestinations,
            selectedIndex: screenIndex,
            onDestinationSelected: (index) {
              setState(() {
                screenIndex = index;
                handleScreenChanged(screenIndex);
              });
            },
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: showLargeSizeLayout
                    ? const PopupCardDetails()
                    : _trailingActions(),
              ),
            ),
          ),
          navigationBar: NavigationBars(
            onSelectItem: (index) {
              setState(() {
                screenIndex = index;
                handleScreenChanged(screenIndex);
              });
            },
            selectedIndex: screenIndex,
            // isExampleBar: false,
          ),
        );
      },
    );
  }
}

class _LightModeButton extends StatelessWidget {
  const _LightModeButton({
    required this.manageLightMode,
    this.showTooltipBelow = true,
  });

  final Function manageLightMode;
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'Toggle brightness',
      child: IconButton(
        icon: isLightMode
            ? const Icon(Icons.brightness_6_outlined)
            : const Icon(Icons.brightness_6),
        onPressed: () => manageLightMode(!isLightMode),
      ),
    );
  }
}

class _AboutAppButton extends StatelessWidget {
  //_Material3Button
  const _AboutAppButton({
    required this.openAboutApp, //handleMaterialVersionChange
    this.showTooltipBelow = true,
  });

  final void Function() openAboutApp; //handleMaterialVersionChange
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'About Drongos App',
      child: IconButton(
        icon: const Icon(Icons.info_rounded),
        onPressed: openAboutApp,
      ),
    );
  }
}

class _AddDrongoButton extends StatelessWidget {
  const _AddDrongoButton({
    required this.addDrongo,
    required this.esp32Connected,
    this.showTooltipBelow = true,
  });

  final void Function() addDrongo;
  final bool esp32Connected;
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: addDrongo,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }
}

class _EnlargedTrailingActions extends StatelessWidget {
  const _EnlargedTrailingActions({
    required this.activateLightMode, //userLightMode
    required this.esp32Connected,
    required this.manageLightMode, //handleBrightnessChange
    required this.openAboutApp,
    required this.devicePowerOn,
    required this.addDrongo,
  });

  final void Function(bool activeLightMode) manageLightMode;
  final void Function() openAboutApp;
  final void Function(int) addDrongo;

  final bool activateLightMode;
  final bool esp32Connected;
  final bool devicePowerOn;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final trailingActionsBody = Container(
      constraints: const BoxConstraints.tightFor(width: 250),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Light Mode'),
              Expanded(child: Container()),
              Switch(
                  value: activateLightMode,
                  onChanged: (value) {
                    manageLightMode(value);
                  })
            ],
          ),
          const Divider(),
          _AboutAppActionView(
            //_ExpandedColorSeedAction(
            openAboutApp: openAboutApp,
          ),
        ],
      ),
    );
    return screenHeight > 740
        ? trailingActionsBody
        : SingleChildScrollView(child: trailingActionsBody);
  }
}

class _AboutAppActionView extends StatelessWidget {
  const _AboutAppActionView({
    required this.openAboutApp,
  });

  final void Function() openAboutApp;

  @override
  Widget build(BuildContext context) {
    return const PopupCardDetails();
    //   return ConstrainedBox(
    //     constraints: const BoxConstraints(maxHeight: 200.0),
    //     child: GridView.count(
    //       crossAxisCount: 3,
    //       children:
    //       List.generate(
    //         ColorSeed.values.length,
    //         (i) => IconButton(
    //           icon: const Icon(Icons.radio_button_unchecked),
    //           color: ColorSeed.values[i].color,
    //           isSelected: colorSelected.color == ColorSeed.values[i].color &&
    //               colorSelectionMethod == ColorSelectionMethod.colorSeed,
    //           selectedIcon: const Icon(Icons.circle),
    //           onPressed: () {
    //             handleColorSelect(i);
    //           },
    //           tooltip: ColorSeed.values[i].label,
    //         ),
    //       ),
    //     ),
    //   );
  }
}

class PopupCardDetails extends StatelessWidget {
  const PopupCardDetails({super.key});

  void _logoutPressed(BuildContext context) {
    Navigator.of(context).pop('Logout pressed');
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: math.min(450, MediaQuery.sizeOf(context).width - 16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24.0),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            radius: 36,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: Text(
              'AB',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Able Bradley',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 2.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'able.bradley@gmail.com',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8.0),
          const Divider(),
          TextButton(
            onPressed: () => _logoutPressed(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class NavigationTransition extends StatefulWidget {
  const NavigationTransition(
      {super.key,
      required this.scaffoldKey,
      required this.animationController,
      required this.railAnimation,
      required this.navigationRail,
      required this.navigationBar,
      required this.appBar,
      required this.body});

  final GlobalKey<ScaffoldState> scaffoldKey;
  final AnimationController animationController;
  final CurvedAnimation railAnimation;
  final Widget navigationRail;
  final Widget navigationBar;
  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  State<NavigationTransition> createState() => _NavigationTransitionState();
}

class _NavigationTransitionState extends State<NavigationTransition> {
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;
  late final ReverseAnimation barAnimation;
  bool controllerInitialized = false;
  bool showDivider = false;
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    controller = widget.animationController;
    railAnimation = widget.railAnimation;

    barAnimation = ReverseAnimation(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5),
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        key: widget.scaffoldKey,
        appBar: widget.appBar,
        body: Row(
          children: <Widget>[
            RailTransition(
              animation: railAnimation,
              backgroundColor: colorScheme.surface,
              child: widget.navigationRail,
            ),
            widget.body,
          ],
        ),
        bottomNavigationBar: BarTransition(
          animation: barAnimation,
          backgroundColor: colorScheme.surface,
          child: widget.navigationBar,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Add Drongo',
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          child: const Icon(Icons.add),
        )
        // endDrawer: const NavigationDrawerSection(), //NavigationDrawerSection()
        );
  }
}

final List<NavigationRailDestination> navRailDestinations =
    appRoutingDestinations
        .map(
          (destination) => NavigationRailDestination(
            icon: Tooltip(
              message: destination.label,
              child: destination.icon,
            ),
            selectedIcon: Tooltip(
              message: destination.label,
              child: destination.selectedIcon,
            ),
            label: Text(destination.label),
          ),
        )
        .toList();

class SizeAnimation extends CurvedAnimation {
  SizeAnimation(Animation<double> parent)
      : super(
          parent: parent,
          curve: const Interval(
            0.2,
            0.8,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            0,
            0.2,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

class OffsetAnimation extends CurvedAnimation {
  OffsetAnimation(Animation<double> parent)
      : super(
          parent: parent,
          curve: const Interval(
            0.4,
            1.0,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            0,
            0.2,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

class RailTransition extends StatefulWidget {
  const RailTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Widget child;
  final Color backgroundColor;

  @override
  State<RailTransition> createState() => _RailTransition();
}

class _RailTransition extends State<RailTransition> {
  late Animation<Offset> offsetAnimation;
  late Animation<double> widthAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The animations are only rebuilt by this method when the text
    // direction changes because this widget only depends on Directionality.
    final bool ltr = Directionality.of(context) == TextDirection.ltr;

    widthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));

    offsetAnimation = Tween<Offset>(
      begin: ltr ? const Offset(-1, 0) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: widthAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class BarTransition extends StatefulWidget {
  const BarTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  @override
  State<BarTransition> createState() => _BarTransition();
}

class _BarTransition extends State<BarTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> heightAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          heightFactor: heightAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class OneTwoTransition extends StatefulWidget {
  const OneTwoTransition({
    super.key,
    required this.animation,
    required this.one,
    required this.two,
  });

  final Animation<double> animation;
  final Widget one;
  final Widget two;

  @override
  State<OneTwoTransition> createState() => _OneTwoTransitionState();
}

class _OneTwoTransitionState extends State<OneTwoTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> widthAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    widthAnimation = Tween<double>(
      begin: 0,
      end: mediumViewPortBreakpoint,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: mediumViewPortBreakpoint.toInt(),
          child: widget.one,
        ),
        if (widthAnimation.value.toInt() > 0) ...[
          Flexible(
            flex: widthAnimation.value.toInt(),
            child: FractionalTranslation(
              translation: offsetAnimation.value,
              child: widget.two,
            ),
          )
        ],
      ],
    );
  }
}
