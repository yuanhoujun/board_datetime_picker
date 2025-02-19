import 'package:board_datetime_picker/src/utils/board_datetime_options_extension.dart';
import 'package:board_datetime_picker/src/utils/datetime_util.dart';
import 'package:flutter/material.dart';

import 'ui/board_datetime_contents_state.dart';
import 'ui/parts/focus_node.dart';
import 'ui/parts/header.dart';
import 'ui/picker_calendar_widget.dart';
import 'utils/board_datetime_result.dart';
import 'utils/board_enum.dart';

/// Controller for displaying, hiding, and updating the value of the picker
class BoardDateTimeController {
  // ignore: library_private_types_in_public_api
  final GlobalKey<_SingleBoardDateTimeContentState> _key = GlobalKey();

  void open(DateTimePickerType openType, DateTime val) {
    _key.currentState?.open(date: val, pickerType: openType);
  }

  void openPicker({DateTimePickerType? openType, DateTime? date}) {
    _key.currentState?.open(date: date, pickerType: openType);
  }

  void close() {
    _key.currentState?.close();
  }

  /// Update the picker on the specified date
  void changeDate(DateTime val) {
    _key.currentState?.changeDate(val);
  }

  /// Update the picker on the specified time
  void changeTime(DateTime val) {
    _key.currentState?.changeTime(val);
  }

  /// Update the picker on the specified datetime
  void changeDateTime(DateTime val) {
    _key.currentState?.changeDateTime(val);
  }

  GlobalKey get boardKey => _key;
}


typedef DateTimeBuilderWidget = Widget Function(BuildContext context);

class SingleBoardDateTimeContent<T extends BoardDateTimeCommonResult>
    extends BoardDateTimeContent<T> {
  const SingleBoardDateTimeContent({
    super.key,
    this.onChange,
    this.onResult,
    required super.pickerType,
    required this.initialDate,
    required super.minimumDate,
    required super.maximumDate,
    required super.breakpoint,
    required super.options,
    super.modal = false,
    super.onCloseModal,
    super.keyboardHeightNotifier,
    super.onCreatedDateState,
    super.pickerFocusNode,
    super.onKeyboadClose,
    super.onUpdateByClose
  });

  final void Function(DateTime)? onChange;
  final void Function(T)? onResult;

  final DateTime? initialDate;

  @override
  State<SingleBoardDateTimeContent> createState() =>
      _SingleBoardDateTimeContentState<T>();
}

class _SingleBoardDateTimeContentState<T extends BoardDateTimeCommonResult>
    extends BoardDatetimeContentState<T, SingleBoardDateTimeContent<T>> {
  /// [ValueNotifier] to manage the Datetime under selection
  late ValueNotifier<DateTime> dateState;

  final GlobalKey<BoardDateTimeHeaderState> _headerKey = GlobalKey();

  @override
  DateTime get currentDate => dateState.value;

  @override
  DateTime? get defaultDate => widget.initialDate;

  @override
  void dispose() {
    dateState.removeListener(notify);
    super.dispose();
  }

  void _setFocusNode(bool byPicker) {
    if (byPicker && widget.pickerFocusNode != null) {
      final fn = widget.pickerFocusNode!;
      if (!fn.hasFocus &&
          FocusManager.instance.primaryFocus! is! BoardDateTimeInputFocusNode) {
        fn.requestFocus();
      }
    }
  }

  @override
  void setNewValue(DateTime val, {bool byPicker = false}) {
    dateState.value = val;
    _setFocusNode(byPicker);
  }

  @override
  void onChanged(DateTime date, T result) {
    widget.onChange?.call(date);
    widget.onResult?.call(result);
  }

  @override
  void setupOptions(DateTime d, DateTimePickerType type) {
    super.setupOptions(d, type);
    dateState = ValueNotifier(d);
    dateState.addListener(notify);
    widget.onCreatedDateState?.call(dateState);
    _headerKey.currentState?.setup(dateState, rebuild: true);
  }

  /// Notification of change to caller.
  void notify() {
    for (var element in itemOptions) {
      element.updateList(dateState.value);
    }
    widget.onChange?.call(dateState.value);
    widget.onResult?.call(
      BoardDateTimeCommonResult.init(pickerType, dateState.value) as T,
    );
    changedDate = true;
  }

  /// Reset date.
  /// During this process, re-register the Listener to avoid sending unnecessary notifications.
  void reset() {
    dateState.removeListener(notify);
    dateState.value = defaultDate ?? DateTime.now();
    changeDateTime(dateState.value);
    dateState.addListener(notify);

    notify();
    _setFocusNode(false);
  }

  @override
  Widget build(BuildContext context) {
    if (isSelfKeyboardNotifier) {
      keyboardHeightNotifier.value = MediaQuery.of(context).viewInsets.bottom;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        boxConstraints = constraints;

        return AnimatedBuilder(
          animation: openAnimationController,
          builder: _openAnimationBuilder,
        );
      },
    );
  }

  Widget _openAnimationBuilder(BuildContext context, Widget? child) {
    final animation = openAnimationController.drive(curve).drive(
          Tween<double>(begin: 0.0, end: 1.0),
        );

    final args = PickerCalendarArgs(
      dateState: dateState,
      options: widget.options,
      pickerType: pickerType,
      listOptions: itemOptions,
      minimumDate: widget.minimumDate,
      maximumDate: widget.maximumDate,
      headerBuilder: (ctx) => _header,
      onChangeByCalendar: changeDate,
      onChangeByPicker: onChangeByPicker,
      onKeyboadClose: closeKeyboard,
      keyboardHeightRatio: () => keyboardHeightRatio,
    );

    return SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          axisAlignment: -1.0,
          child: PickerCalendarStandardWidget(
            arguments: args,
            calendarAnimationController: calendarAnimationController,
            calendarAnimation: calendarAnimation,
            pickerFormAnimation: pickerFormAnimation,
          ));
  }

  Widget get _header {
    return BoardDateTimeHeader(
      key: _headerKey,
      wide: isWide,
      dateState: dateState,
      pickerType: pickerType,
      keyboardHeightRatio: keyboardHeightRatio,
      calendarAnimation: calendarAnimation,
      onChangeDate: changeDate,
      onChangTime: changeTime,
      onClose: close,
      backgroundColor: widget.options.getBackgroundColor(context),
      foregroundColor: widget.options.getForegroundColor(context),
      textColor: widget.options.getTextColor(context),
      activeColor: widget.options.getActiveColor(context),
      activeTextColor: widget.options.getActiveTextColor(context),
      languages: widget.options.languages,
      minimumDate: widget.minimumDate ?? DateTimeUtil.defaultMinDate,
      maximumDate: widget.maximumDate ?? DateTimeUtil.defaultMaxDate,
      modal: widget.modal,
      pickerFocusNode: widget.pickerFocusNode,
      actionButtonTypes: widget.options.actionButtonTypes,
    );
  }
}
