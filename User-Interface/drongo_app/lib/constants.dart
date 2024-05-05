import 'package:flutter/material.dart';

const double narrowViewPortThreshold = 450; //narrowScreenWidthThreshold

const double mediumViewPortBreakpoint = 1000; //mediumWidthBreakpoint
const double largeViewPortBreakpoint = 1500; //largeWidthBreakpoint

const double transitionLength = 500;

enum CurrentScreen {
  //ScreenSelected
  home(0),
  scale(1),
  data(2),
  track(3);

  const CurrentScreen(this.value);
  final int value;
}

enum ColorSeed {
  baseColor('Drongos Main Color', Colors.green),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}
