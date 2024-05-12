import 'dart:convert';

import 'package:drongo_app/local_providers/scaledata.dart';
import 'package:drongo_app/widgets/component_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Widget splitter = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400; //narrow viewport width

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

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

    // Widget drongoDataNotice() => RichText(
    //       textAlign: TextAlign.center,
    //       text: TextSpan(
    //         style: Theme.of(context).textTheme.bodySmall,
    //         children: const [
    //           TextSpan(
    //               text: 'Add new drongo data or sort the collection'
    //                   'by weight, temperature or date recorded.'
    //                   ' Collection of drongo data is sorted by ID by default.'),
    //         ],
    //       ),
    //     );

    Widget schemeLabel(String dataSortingHeading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(
          dataSortingHeading,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    Widget schemeView(ThemeData theme) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: DataSchemeView(
          colorScheme: theme.colorScheme,
          sortingOrder: 0,
        ),
      );
    }

    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < narrowScreenWidthThreshold) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // drongoDataNotice(),
                // splitter,
                const SearchAnchors(),
                // splitter,
                schemeLabel('Captured Drongo Data'),
                Theme.of(context).brightness == Brightness.dark
                    ? schemeView(darkTheme)
                    : schemeView(lightTheme),
                // splitter,
                // splitter,
                // schemeLabel('Dark ColorScheme'),
                // schemeView(darkTheme),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  const SearchAnchors(),
                  // drongoDataNotice(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            schemeLabel('Captured Drongo Data'),
                            Theme.of(context).brightness == Brightness.dark
                                ? schemeView(darkTheme)
                                : schemeView(lightTheme),
                          ],
                        ),
                      ),
                      // Expanded(
                      //   child: Column(
                      //     children: [
                      //       schemeLabel('Dark ColorScheme'),
                      //       schemeView(darkTheme),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}

class DrongoGroupedData extends StatelessWidget {
  const DrongoGroupedData({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
        // child:
        //     FutureBuilder<List<ScaleData>>(future: loadScaleData(), builder: context, scaleData),
      ),
    );
  }
}

class DataChip extends StatelessWidget {
  const DataChip({
    super.key,
    required this.index,
    required this.color,
    required this.value,
    this.onColor,
  });

  final Color color;
  final Color? onColor;
  final String value;
  final int index;

  static Color contrastColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    switch (brightness) {
      case Brightness.dark:
        return Colors.white;
      case Brightness.light:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color labelColor = onColor ?? contrastColor(color);
    String label = 'Variable ';

    switch (index) {
      case 0:
        label = 'RFID ';
      case 1:
        label = 'Estimate Mass: ';
      case 2:
        label = 'Date: ';
      case 3:
        label = 'Time: ';
      case 4:
        label = 'Location: ';
      default:
        label = 'RFID: ';
    }

    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: labelColor, fontWeight: FontWeight.bold))),
            Expanded(child: Text(value, style: TextStyle(color: labelColor))),
          ],
        ),
      ),
    );
  }
}

class DataSchemeView extends StatefulWidget {
  const DataSchemeView({
    super.key,
    required this.sortingOrder,
    required this.colorScheme,
  });
  final int sortingOrder;
  final ColorScheme colorScheme;

  @override
  State<DataSchemeView> createState() => _DataSchemeViewState();
}

class _DataSchemeViewState extends State<DataSchemeView> {
  // const DataSchemeViewState({super.key, required this.colorScheme});
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

class SearchAnchors extends StatefulWidget {
  const SearchAnchors({super.key});

  @override
  State<SearchAnchors> createState() => _SearchAnchorsState();
}

class _SearchAnchorsState extends State<SearchAnchors> {
  String? selectedColor;
  List<DataItem> searchHistory = <DataItem>[];

  Iterable<Widget> getHistoryList(SearchController controller) {
    return searchHistory.map((color) => ListTile(
          leading: const Icon(Icons.history),
          title: Text(color.label),
          trailing: IconButton(
              icon: const Icon(Icons.call_missed),
              onPressed: () {
                controller.text = color.label;
                controller.selection =
                    TextSelection.collapsed(offset: controller.text.length);
              }),
          onTap: () {
            controller.closeView(color.label);
            handleSelection(color);
          },
        ));
  }

  Iterable<Widget> getSuggestions(SearchController controller) {
    final String input = controller.value.text;
    return DataItem.values
        .where((color) => color.label.contains(input))
        .map((filteredColor) => ListTile(
              leading: CircleAvatar(backgroundColor: filteredColor.color),
              title: Text(filteredColor.label),
              trailing: IconButton(
                  icon: const Icon(Icons.call_missed),
                  onPressed: () {
                    controller.text = filteredColor.label;
                    controller.selection =
                        TextSelection.collapsed(offset: controller.text.length);
                  }),
              onTap: () {
                controller.closeView(filteredColor.label);
                handleSelection(filteredColor);
              },
            ));
  }

  void handleSelection(DataItem color) {
    setState(() {
      selectedColor = color.label;
      if (searchHistory.length >= 5) {
        searchHistory.removeLast();
      }
      searchHistory.insert(0, color);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchAnchor.bar(
            barHintText: 'Search',
            suggestionsBuilder: (context, controller) {
              if (controller.text.isEmpty) {
                if (searchHistory.isNotEmpty) {
                  return getHistoryList(controller);
                }
                return <Widget>[
                  const Center(
                    child: Text('No search history.',
                        style: TextStyle(color: Colors.grey)),
                  )
                ];
              }
              return getSuggestions(controller);
            },
          ),
        ),
      ],
    );
  }
}

enum DataItem {
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

  const DataItem(this.label, this.color);
  final String label;
  final Color color;
}
