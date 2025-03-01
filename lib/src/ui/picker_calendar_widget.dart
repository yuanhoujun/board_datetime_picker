import 'package:board_datetime_picker/src/options/board_item_option.dart';
import 'package:board_datetime_picker/src/ui/parts/item.dart';
import 'package:board_datetime_picker/src/utils/board_datetime_options_extension.dart';
import 'package:flutter/material.dart';

import '../board_datetime_options.dart';
import '../utils/board_enum.dart';

class PickerCalendarArgs {
  final ValueNotifier<DateTime> dateState;
  final BoardDateTimeOptions options;
  final DateTimePickerType pickerType;
  final List<BoardPickerItemOption> listOptions;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final Widget Function(BuildContext) headerBuilder;
  final void Function(DateTime) onChangeByCalendar;
  final void Function(BoardPickerItemOption, int) onChangeByPicker;
  final double Function() keyboardHeightRatio;
  final void Function(MultiCurrentDateType)? onChangeDateType;
  final void Function() onKeyboadClose;

  const PickerCalendarArgs(
      {required this.dateState,
      required this.options,
      required this.pickerType,
      required this.listOptions,
      required this.minimumDate,
      required this.maximumDate,
      required this.headerBuilder,
      required this.onChangeByCalendar,
      required this.onChangeByPicker,
      required this.keyboardHeightRatio,
      this.onChangeDateType,
      required this.onKeyboadClose});
}

abstract class PickerCalendarWidget extends StatefulWidget {
  const PickerCalendarWidget({
    super.key,
    required this.arguments,
  });

  final PickerCalendarArgs arguments;
}

abstract class PickerCalendarState<T extends PickerCalendarWidget>
    extends State<T> {
  final GlobalKey calendarKey = GlobalKey();

  final double keyboardMenuMaxHeight = 48;

  double get keyboardMenuHeight =>
      keyboardMenuMaxHeight * (1 - args.keyboardHeightRatio());

  PickerCalendarArgs get args => widget.arguments;

  BoardDateTimeOptions get options => args.options;

  ValueNotifier<DateTime> get dateState => args.dateState;

  late DateTime selectedDate;

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    selectedDate = dateState.value;
    dateState.addListener(changeListener);
  }

  void changeListener() {
    setState(() {
      selectedDate = dateState.value;
    });
  }

  bool isSameTime(DateTime current, DateTime other) {
    return current.year == other.year &&
        current.month == other.month &&
        current.day == other.day &&
        current.hour == other.hour &&
        current.minute == other.minute;
  }

  Widget picker({required bool isWide}) {
    final separator = options.separators;

    List<Widget> items = [];

    for (final x in args.listOptions) {
      items.add(
        Expanded(
          flex: x.flex,
          child: ItemWidget(
            key: x.stateKey,
            option: x,
            foregroundColor: args.options.getForegroundColor(context),
            textColor: args.options.textColor,
            onChange: (index) => args.onChangeByPicker(x, index),
            wide: isWide,
            selectedTextColor: args.options.selectedTextColor,
          ),
        ),
      );

      if (separator != null) {
        final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: args.options.getTextColor(context),
            );
        if (separatorTypes.contains(x.type)) {
          items.add(
            separator.dateSeparatorBuilder?.call(context, textStyle) ??
                Text(
                  separator.date.display,
                  style: textStyle,
                ),
          );
        } else if (x.type == DateType.hour) {
          items.add(
            separator.timeSeparatorBuilder?.call(context, textStyle) ??
                Text(
                  separator.time.display,
                  style: textStyle,
                ),
          );
        } else if (x.type == lastYmdDateType &&
            args.pickerType == DateTimePickerType.datetime) {
          items.add(
            separator.dateTimeSeparatorBuilder?.call(context, textStyle) ??
                Text(
                  separator.dateTime.display,
                  style: textStyle,
                ),
          );
        }
      }
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        children: items,
      ),
    );
  }

  bool isSelected(int year, int month, int day, int hour, int minute) {
    return selectedDate.year == year &&
        selectedDate.month == month &&
        selectedDate.day == day &&
        selectedDate.hour == hour &&
        selectedDate.minute == minute;
  }

  /// Function to return a list of DateType to insert a separator from PickerFormat.
  List<DateType> get separatorTypes {
    switch (options.pickerFormat) {
      case PickerFormat.ymd:
        return [DateType.year, DateType.month];
      case PickerFormat.mdy:
        return [DateType.month, DateType.day];
      case PickerFormat.dmy:
        return [DateType.day, DateType.month];
      default:
        return [];
    }
  }

  DateType get lastYmdDateType {
    switch (options.pickerFormat) {
      case PickerFormat.ymd:
        return DateType.day;
      case PickerFormat.mdy:
        return DateType.year;
      case PickerFormat.dmy:
        return DateType.year;
      default:
        return DateType.day;
    }
  }

  void moveFocus(bool next) {
    for (var i = 0; i < args.listOptions.length; i++) {
      final opt = args.listOptions[i];
      if (opt.focusNode.hasFocus) {
        int move = -1;
        if (next) {
          if (i != args.listOptions.length - 1) {
            move = i + 1;
          }
        } else {
          if (i != 0) {
            move = i - 1;
          }
        }
        if (move != -1) {
          args.listOptions[move].focusNode.requestFocus();
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    dateState.removeListener(changeListener);
    super.dispose();
  }
}

class PickerCalendarStandardWidget extends PickerCalendarWidget {
  const PickerCalendarStandardWidget({
    super.key,
    required super.arguments,
    required this.calendarAnimationController,
    required this.calendarAnimation,
    required this.pickerFormAnimation,
  });

  final AnimationController calendarAnimationController;
  final Animation<double> calendarAnimation;
  final Animation<double> pickerFormAnimation;

  @override
  PickerCalendarState<PickerCalendarStandardWidget> createState() =>
      _PickerCalendarStandardWidgetState();
}

class _PickerCalendarStandardWidgetState
    extends PickerCalendarState<PickerCalendarStandardWidget> {
  @override
  void initState() {
    widget.arguments.dateState.addListener(changeListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.calendarAnimationController,
      builder: builder,
    );
  }

  Widget builder(BuildContext context, Widget? child) {
    double height = 200 + (220 * widget.calendarAnimation.value);

    height += keyboardMenuHeight;

    return Container(
      height: height + (args.keyboardHeightRatio() * 172),
      decoration: args.options.backgroundDecoration ??
          BoxDecoration(
            color: args.options.getBackgroundColor(context),
          ),
      // padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SafeArea(
        top: false,
        child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                args.headerBuilder(context),
                Expanded(
                    child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Color(0xfff3f6f6),
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    contents()
                  ],
                )),
              ],
            )
      ),
    );
  }

  Widget contents() {
    return FadeTransition(
      opacity: widget.pickerFormAnimation,
      child: picker(isWide: false),
    );
  }

  @override
  void dispose() {
    widget.arguments.dateState.removeListener(changeListener);
    super.dispose();
  }
}
