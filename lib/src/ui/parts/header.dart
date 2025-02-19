import 'dart:math';

import 'package:board_datetime_picker/src/board_datetime_options.dart';
import 'package:board_datetime_picker/src/utils/board_datetime_options_extension.dart';
import 'package:board_datetime_picker/src/utils/board_enum.dart';
import 'package:board_datetime_picker/src/utils/datetime_util.dart';
import 'package:flutter/material.dart';

import 'buttons.dart';
import '../board_datetime_contents_state.dart';

class BoardDateTimeHeader extends StatefulWidget {
  const BoardDateTimeHeader({
    super.key,
    required this.wide,
    required this.dateState,
    required this.pickerType,
    required this.keyboardHeightRatio,
    required this.calendarAnimation,
    required this.onChangeDate,
    required this.onChangTime,
    required this.onKeyboadClose,
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
    required this.withTextField,
    required this.pickerFocusNode,
    required this.topMargin,
    required this.onTopActionBuilder,
    required this.actionButtonTypes,
    required this.onReset,
    required this.customCloseButtonBuilder,
  });

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

  /// Keyboard close request
  final void Function() onKeyboadClose;

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

  /// TextField Flag
  final bool withTextField;

  /// Picker FocusNode
  final FocusNode? pickerFocusNode;

  /// Header Top margin
  final double topMargin;

  /// Specify a Widget to be displayed in the action button area externally
  final Widget Function(BuildContext context)? onTopActionBuilder;

  /// List of buttons to select dates.
  final List<BoardDateButtonType> actionButtonTypes;

  /// reset button callback (if use reset)
  final void Function()? onReset;

  /// Custom Close Button Builder
  final CloseButtonBuilder? customCloseButtonBuilder;

  @override
  State<BoardDateTimeHeader> createState() => BoardDateTimeHeaderState();
}

class BoardDateTimeHeaderState extends State<BoardDateTimeHeader> {
  bool isToday = true;
  bool isTomorrow = false;
  bool isYesterday = false;

  late ValueNotifier<DateTime> dateState;

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
  }

  double get height => widget.wide ? 64 : 52;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 15),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [Text("2025年2月18日"), Text("/"), Text("周二")],
              ),
              SizedBox(height: 5),
              Text("14:36")
            ],
          ),
          const Spacer(),
          ElevatedButton(
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

    if (widget.withTextField) {
      return GestureDetector(
        onTapDown: (_) {
          widget.pickerFocusNode?.requestFocus();
        },
        child: child,
      );
    }
    return child;
  }
}

class BoardDateTimeNoneButtonHeader extends StatefulWidget {
  const BoardDateTimeNoneButtonHeader({
    super.key,
    required this.options,
    required this.wide,
    required this.dateState,
    required this.pickerType,
    required this.keyboardHeightRatio,
    required this.calendarAnimation,
    required this.onKeyboadClose,
    required this.onClose,
    required this.modal,
    required this.pickerFocusNode,
    this.customCloseButtonBuilder,
  });

  final BoardDateTimeOptions options;

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

  /// Keyboard close request
  final void Function() onKeyboadClose;

  /// Picker close request
  final void Function() onClose;

  /// Modal Flag
  final bool modal;

  /// Picker FocusNode
  final FocusNode? pickerFocusNode;

  // Custom Close Button Builder
  final CloseButtonBuilder? customCloseButtonBuilder;

  @override
  State<BoardDateTimeNoneButtonHeader> createState() =>
      _BoardDateTimeNoneButtonHeaderState();
}

class _BoardDateTimeNoneButtonHeaderState
    extends State<BoardDateTimeNoneButtonHeader> {
  double get buttonSize => widget.wide ? 40 : 36;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: buttonSize + 8,
      margin: const EdgeInsets.only(top: 12, left: 8, right: 8),
      child: Row(
        children: [
          if (widget.pickerType != DateTimePickerType.time && !widget.wide) ...[
            CustomIconButton(
              icon: Icons.view_day_rounded,
              bgColor: widget.options.getForegroundColor(context),
              fgColor:
                  widget.options.getTextColor(context)?.withValues(alpha: 0.8),
              onTap: () {},
              buttonSize: buttonSize,
              child: Transform.rotate(
                angle: pi * 4 * widget.calendarAnimation.value,
                child: Icon(
                  widget.calendarAnimation.value > 0.5
                      ? Icons.view_day_rounded
                      : Icons.calendar_month_rounded,
                  size: 20,
                ),
              ),
            ),
          ] else ...[
            SizedBox(width: buttonSize),
          ],
          if (widget.keyboardHeightRatio == 0) SizedBox(width: buttonSize + 8),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _title(),
              ),
            ),
          ),
          ..._rightButton(),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: (_) {
        widget.pickerFocusNode?.requestFocus();
      },
      child: child,
    );
  }

  Widget _title() {
    if (widget.options.boardTitle == null ||
        widget.options.boardTitle!.isEmpty) {
      return const SizedBox();
    }
    return FittedBox(
      child: Text(
        widget.options.boardTitle ?? '',
        style: widget.options.boardTitleTextStyle ??
            Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: widget.options.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
      ),
    );
  }

  List<Widget> _rightButton() {
    // Widget? closeKeyboard;

    // if (widget.keyboardHeightRatio == 0) {
    //   closeKeyboard = Visibility(
    //     visible: widget.keyboardHeightRatio == 0,
    //     child: CustomIconButton(
    //       icon: Icons.keyboard_hide_rounded,
    //       bgColor: widget.options.getForegroundColor(context),
    //       fgColor: widget.options.getTextColor(context),
    //       onTap: widget.onKeyboadClose,
    //       buttonSize: buttonSize,
    //     ),
    //   );
    // }

    Widget child = widget.customCloseButtonBuilder?.call(
          context,
          widget.modal,
          widget.onClose,
        ) ??
        (widget.modal
            ? CustomIconButton(
                icon: Icons.check_circle_rounded,
                bgColor: widget.options.getActiveColor(context),
                fgColor: widget.options.getActiveTextColor(context),
                onTap: widget.onClose,
                buttonSize: buttonSize,
              )
            : CustomIconButton(
                icon: Icons.close_rounded,
                bgColor: widget.options.getForegroundColor(context),
                fgColor: widget.options
                    .getTextColor(context)
                    ?.withValues(alpha: 0.8),
                onTap: widget.onClose,
                buttonSize: buttonSize,
              ));

    return [
      // if (closeKeyboard != null) ...[
      //   closeKeyboard,
      //   const SizedBox(width: 8),
      // ],
      child,
    ];
  }
}

class TopTitleWidget extends StatelessWidget {
  const TopTitleWidget({super.key, required this.options});

  final BoardDateTimeOptions options;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 8, right: 8),
      alignment: Alignment.center,
      child: Text(
        options.boardTitle ?? '',
        style: options.boardTitleTextStyle ??
            Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: options.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
        maxLines: 1,
      ),
    );
  }
}
