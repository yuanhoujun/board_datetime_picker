import 'dart:math';

import 'package:board_datetime_picker/src/board_datetime_options.dart';
import 'package:board_datetime_picker/src/utils/board_datetime_options_extension.dart';
import 'package:board_datetime_picker/src/utils/board_enum.dart';
import 'package:board_datetime_picker/src/utils/datetime_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'buttons.dart';

class BoardDateTimeHeader extends StatefulWidget {
  const BoardDateTimeHeader(
      {super.key,
      required this.wide,
      required this.dateState,
      required this.pickerType,
      required this.keyboardHeightRatio,
      required this.calendarAnimation,
      required this.onChangeDate,
      required this.onChangTime,
      required this.onClose,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.textColor,
      required this.activeColor,
      required this.activeTextColor,
      required this.languages,
      required this.minimumDate,
      required this.maximumDate,
      required this.modal,
      required this.pickerFocusNode,
      required this.actionButtonTypes});

  /// Wide mode display flag
  final bool wide;

  /// [ValueNotifier] to manage the Datetime under selection
  final ValueNotifier<DateTime> dateState;

  /// Display picker type.
  final DateTimePickerType pickerType;

  /// Animation that detects and resizes the keyboard display
  final double keyboardHeightRatio;

  /// Animation to show/hide the calendar
  final Animation<double> calendarAnimation;

  /// Callback on date change
  final void Function(DateTime) onChangeDate;

  /// Callback on datetime change
  final void Function(DateTime) onChangTime;

  /// Picker close request
  final void Function() onClose;

  /// Picker Background Color
  /// default is `Theme.of(context).scaffoldBackgroundColor`
  final Color backgroundColor;

  /// Picket Foreground Color
  /// default is `Theme.of(context).cardColor`
  final Color foregroundColor;

  /// Picker Text Color
  final Color? textColor;

  /// Active Color
  final Color activeColor;

  /// Active Text Color
  final Color activeTextColor;

  /// Class for specifying language information to be used in the picker
  final BoardPickerLanguages languages;

  /// Minimum Date
  final DateTime minimumDate;

  /// Maximum Date
  final DateTime maximumDate;

  /// Modal Flag
  final bool modal;

  /// Picker FocusNode
  final FocusNode? pickerFocusNode;

  /// List of buttons to select dates.
  final List<BoardDateButtonType> actionButtonTypes;

  @override
  State<BoardDateTimeHeader> createState() => BoardDateTimeHeaderState();
}

class BoardDateTimeHeaderState extends State<BoardDateTimeHeader> {
  bool isToday = true;
  bool isTomorrow = false;
  bool isYesterday = false;

  late ValueNotifier<DateTime> dateState;
  late DateTime currentDate;

  @override
  void initState() {
    setup(widget.dateState);
    super.initState();
  }

  @override
  void dispose() {
    dateState.removeListener(changeListener);
    super.dispose();
  }

  void changeListener() {
    setState(() => judgeDay());
  }

  void setup(ValueNotifier<DateTime> state, {bool rebuild = false}) {
    dateState = state;
    currentDate = dateState.value;
    dateState.addListener(changeListener);
    if (rebuild) {
      changeListener();
    } else {
      judgeDay();
    }
  }

  void judgeDay() {
    final now = DateTime.now();
    isToday = dateState.value.compareDate(now);
    isTomorrow = dateState.value.compareDate(now.addDay(1));
    isYesterday = dateState.value.compareDate(now.addDay(-1));
    currentDate = dateState.value;
  }

  double get height => widget.wide ? 64 : 52;

  @override
  Widget build(BuildContext context) {
     final locale = Localizations.localeOf(context);
  final dateFormatter = DateFormat.yMMMMd(locale.toString());
  final timeFormatter = DateFormat.Hm(locale.toString());
  final weekdayFormatter = DateFormat.EEEE(locale.toString()); // 格式化星期几

  final formattedDate = dateFormatter.format(currentDate);
  final formattedTime = timeFormatter.format(currentDate);
    final formattedWeekday = weekdayFormatter.format(currentDate); // 获取星期几

  
    final child = SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 15),
           Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [Text(formattedDate), Text("/"), Text(formattedWeekday)],
              ),
              SizedBox(height: 5),
              Text(formattedTime)
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              elevation: 0
            ),
              onPressed: () {
                final now = DateTime.now();
                widget.onChangeDate(now);
                widget.onChangTime(now);
              },
              child: const Text("当前时间")),
          const SizedBox(width: 15),
        ],
      ),
    );

    return child;
  }
}