import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  return runApp(_App());
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const _HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final Random _random = Random();
  final Stopwatch _stopwatch = Stopwatch();
  final GlobalKey _textGestureWidgetKey = GlobalKey();

  late List<_ChartDataModel> _dataSource;
  late Color _color;

  int _chartExecutionTime = 0;
  bool _canRebuild = false;
  UniqueKey? _chartKey;

  Color _effectiveColor() {
    final Color newColor = Colors.accents[_random.nextInt(14)];
    if (_color == newColor) {
      return _effectiveColor();
    }
    _color = newColor;
    return newColor;
  }

  void _onPersistentFrameCallback(Duration timeStamp) {
    if (_stopwatch.isRunning) {
      _chartExecutionTime = _stopwatch.elapsedMilliseconds;
    }
  }

  void _handleTap() {
    _canRebuild = !_canRebuild;
    if (_canRebuild) {
      setState(() {
        _chartKey = UniqueKey();
      });
    } else {
      (_textGestureWidgetKey.currentContext!.findRenderObject()!
              as _GestureRenderBox)
          ._update(_chartExecutionTime);
    }
  }

  @override
  void initState() {
    double baseValue = 100;
    _dataSource = <_ChartDataModel>[];
    for (int i = 0; i <= 1000000; i++) {
      if (_random.nextDouble() > 0.5) {
        baseValue += _random.nextDouble();
      } else {
        baseValue -= _random.nextDouble();
      }
      _dataSource.add(_ChartDataModel(i, baseValue));
    }

    _color = Colors.accents[_random.nextInt(14)];

    SchedulerBinding.instance
        .addPersistentFrameCallback(_onPersistentFrameCallback);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _stopwatch
      ..stop()
      ..reset()
      ..start();

    return Scaffold(
      body: Stack(
        children: [
          SfCartesianChart(
            key: _chartKey,
            primaryXAxis: const NumericAxis(),
            primaryYAxis: const NumericAxis(),
            series: <CartesianSeries<_ChartDataModel, num>>[
              FastLineSeries(
                dataSource: _dataSource,
                xValueMapper: (_ChartDataModel data, int index) => data.x,
                yValueMapper: (_ChartDataModel data, int index) => data.y,
                animationDuration: 0,
                color: _effectiveColor(),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _TextGestureWidget(
              key: _textGestureWidgetKey,
              onTap: _handleTap,
              text: !_canRebuild
                  ? 'Execution Time : $_chartExecutionTime ms'
                  : 'Calculating time...',
              opposedTextPosition: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartDataModel {
  _ChartDataModel(this.x, this.y);

  final num x;
  final num y;
}

class _TextGestureWidget extends LeafRenderObjectWidget {
  const _TextGestureWidget({
    Key? key,
    required this.onTap,
    required this.text,
    required this.opposedTextPosition,
  }) : super(key: key);

  final VoidCallback onTap;
  final String text;
  final bool opposedTextPosition;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _GestureRenderBox()
      .._onTap = onTap
      .._opposedTextPosition = opposedTextPosition
      .._themeData = Theme.of(context)
      .._text = text
      .._gestureSettings = MediaQuery.of(context).gestureSettings;
  }

  @override
  void updateRenderObject(
      BuildContext context, _GestureRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      .._onTap = onTap
      .._opposedTextPosition = opposedTextPosition
      .._themeData = Theme.of(context)
      .._text = text
      .._gestureSettings = MediaQuery.of(context).gestureSettings;
  }
}

class _GestureRenderBox extends RenderBox {
  _GestureRenderBox() {
    _tapGestureRecognizer = TapGestureRecognizer();
    _textPainter = TextPainter()..textDirection = TextDirection.ltr;
  }

  late TapGestureRecognizer _tapGestureRecognizer;
  late TextPainter _textPainter;
  late TextStyle _textStyle;
  late bool _opposedTextPosition;
  late Color _fillColor;

  set _themeData(ThemeData value) {
    _fillColor = value.colorScheme.primary;
    _textStyle = value.textTheme.bodyLarge!.copyWith(color: _fillColor);
  }

  set _text(String value) {
    _textPainter.text = TextSpan(text: value, style: _textStyle);
  }

  set _onTap(VoidCallback value) {
    _tapGestureRecognizer.onTap = value;
  }

  set _gestureSettings(DeviceGestureSettings? gestureSettings) {
    _tapGestureRecognizer.gestureSettings = gestureSettings;
  }

  void _update(int elapsedMilliseconds) {
    _textPainter.text = TextSpan(
      text: 'Execution Time : $elapsedMilliseconds ms',
      style: _textStyle,
    );
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, HitTestEntry<HitTestTarget> entry) {
    if (event is PointerDownEvent) {
      _tapGestureRecognizer.addPointer(event);
    }
  }

  @override
  void performLayout() {
    size = const Size(50, 50);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect bounds = paintBounds.shift(offset);
    final double dia = bounds.height;
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(5), Radius.circular(dia / 2)),
      Paint()..color = _fillColor,
    );

    context.canvas.drawCircle(
      bounds.center,
      dia / 5,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    if (_textPainter.text != null) {
      _textPainter.layout();
      final double opposed = _opposedTextPosition ? dia : -_textPainter.width;
      _textPainter.paint(
        context.canvas,
        Offset(
            offset.dx + opposed, offset.dy + dia / 2 - _textPainter.height / 2),
      );
    }
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }
}
