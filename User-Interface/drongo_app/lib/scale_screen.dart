import 'package:flutter/material.dart';

class ScaleScreen extends StatelessWidget {
  const ScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color shadowColor = Theme.of(context).colorScheme.shadow;
    Color surfaceTint = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20, 16.0, 0),
              child: Text(
                'Scale Power Actions and Status View',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          ScaleActionsGrid(
            surfaceTintColor: surfaceTint,
            shadowColor: Colors.transparent,
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                child: Text(
                  'Drongo Mass Acquisition Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ]),
          ),
          ScaleActionsGrid(
            shadowColor: shadowColor,
            surfaceTintColor: surfaceTint,
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                child: Text(
                  'Scale Connectivity and About',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ]),
          ),
          ScaleActionsGrid(shadowColor: shadowColor),
        ],
      ),
    );
  }
}

const double narrowScreenWidthThreshold = 450;

class ScaleActionsGrid extends StatelessWidget {
  //ElevationGrid
  const ScaleActionsGrid({super.key, this.shadowColor, this.surfaceTintColor});

  final Color? shadowColor;
  final Color? surfaceTintColor;

  List<ScaleActionCard> elevationCards(
      Color? shadowColor, Color? surfaceTintColor) {
    return elevations
        .map(
          (elevationInfo) => ScaleActionCard(
            info: elevationInfo,
            shadowColor: shadowColor,
            surfaceTint: surfaceTintColor,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverLayoutBuilder(builder: (context, constraints) {
        if (constraints.crossAxisExtent < narrowScreenWidthThreshold) {
          return SliverGrid.count(
            crossAxisCount: 3,
            children: elevationCards(shadowColor, surfaceTintColor),
          );
        } else {
          return SliverGrid.count(
            crossAxisCount: 6,
            children: elevationCards(shadowColor, surfaceTintColor),
          );
        }
      }),
    );
  }
}

class ScaleActionCard extends StatefulWidget {
  const ScaleActionCard(
      // {super.key, required this.info, this.shadowColor, this.surfaceTint});
      {super.key,
      required this.scaleActionIcon,
      required this.scaleActionLabel,
      required this.scaleConnected,
      required this.scalePowerOn,
      required this.handleScaleAction});

  // final ScaleActionInfo info;
  final Icon scaleActionIcon;
  final String scaleActionLabel;
  final bool scalePowerOn, scaleConnected;
  final void Function() handleScaleAction;

  @override
  State<ScaleActionCard> createState() => _ScaleActionCardState();
}

class _ScaleActionCardState extends State<ScaleActionCard> {
  // late double _elevation;
  

  Future<void> startUpChecker() async {
    if (widget.scalePowerOn) {
    } else {

    }
  }

  @override
  void initState() {
    super.initState();
    // _elevation = widget.info.scaleActionElevation;
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(4.0));
    final Color color = Theme.of(context).colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: borderRadius,
        elevation: _elevation,
        color: color,
        shadowColor: widget.shadowColor,
        surfaceTintColor: widget.surfaceTint,
        type: MaterialType.card,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Level ${widget.info.scaleActionIcon}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '${widget.info.scaleActionElevation.toInt()} dp',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              if (widget.surfaceTint != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${widget.info.scaleActionLabel}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// class ScaleActionInfo {
//   const ScaleActionInfo(
//       this.scaleActionIcon, this.scaleActionElevation, this.scaleActionLabel);
//   final Icon scaleActionIcon; //level
//   final double scaleActionElevation;
//   final String scaleActionLabel; //overlayPercentage
// }

// const List<ScaleActionInfo> elevations = <ScaleActionInfo>[
//   ScaleActionInfo(Icon(Icons.power_settings_new), 6.472, "Power"),
//   // ScaleActionInfo(1, 1.0, 5),
//   ScaleActionInfo(Icon(Icons.b), 6.472, 8),
//   // ScaleActionInfo(3, 6.0, 11),
//   ScaleActionInfo(4, 6.472, 12),
//   // ScaleActionInfo(5, 12.0, 14),
// ];
