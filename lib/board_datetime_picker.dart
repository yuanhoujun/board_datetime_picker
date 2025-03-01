library board_datetime_picker;

import 'package:intl/intl.dart';

export 'src/board_datetime_builder.dart'
    show BoardDateTimeController, BoardDateTimeBuilder;
export 'src/board_datetime_options.dart'
    show
        BoardDateTimeOptions,
        BoardDateButtonType,
        BoardPickerLanguages,
        BoardPickerCustomOptions,
        PickerFormat,
        BoardDateTimeItemTitles,
        BoardPickerWeekendOptions,
        BoardDateTimePickerSeparators,
        PickerSeparator,
        PickerSeparatorBuilder;
export 'src/board_datetime_widget.dart'
    show
        showBoardDateTimePicker,
        showBoardDateTimePickerForDateTime,
        showBoardDateTimePickerForDate,
        showBoardDateTimePickerForTime;
export 'src/ui/parts/focus_node.dart' show BoardDateTimeInputFocusNode;
export 'src/utils/board_datetime_result.dart';
export 'src/utils/board_enum.dart'
    show DateTimePickerType, MultiCurrentDateType;

class BoardDateFormat {
  BoardDateFormat(this.f);
  final String f;
  String format(DateTime d, [String? locale]) {
    return DateFormat(f, locale).format(d);
  }
}
