import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board DateTime Picker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 235, 235, 241),
        useMaterial3: false,
      ),
      // home: const Home(),
      home: const MySampleApp(),
    );
  }
}

class MySampleApp extends StatefulWidget {
  const MySampleApp({super.key});

  @override
  State<MySampleApp> createState() => _MySampleAppState();
}

class _MySampleAppState extends State<MySampleApp> {
  final scrollController = ScrollController();
  final controller = BoardDateTimeController();

  final ValueNotifier<DateTime> builderDate = ValueNotifier(DateTime.now());

  @override
  Widget build(BuildContext context) {
    Widget scaffold() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Board DateTime Picker Example'),
        ),
        backgroundColor: const Color.fromARGB(255, 245, 245, 250),
        body: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 560,
              ),
              child: Column(
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(250, 40)),
                      onPressed: () {
                        _showDateTimePicker();
                      },
                      child: const Text("时间选择器"))
                ],
              ),
            ),
          ),
        ),
      );
    }

    return scaffold();
  }

  void _showDateTimePicker() async {
    final result = await showBoardDateTimePicker(
      context: context,
      pickerType: DateTimePickerType.datetime,
      radius: 0,
      // initialDate: DateTime.now(),
      // minimumDate: DateTime.now().add(const Duration(days: 1)),
      options: BoardDateTimeOptions(
        backgroundColor: Colors.white,
        languages: const BoardPickerLanguages.en(),
        startDayOfWeek: DateTime.sunday,
        pickerFormat: PickerFormat.ymd,
        // boardTitle: 'Board Picker',
        // pickerSubTitles: BoardDateTimeItemTitles(year: 'year'),
        foregroundColor: Colors.transparent,
        topMargin: 0,
        activeColor: Colors.red,
        activeTextColor: Colors.yellow,
        actionButtonTypes: [BoardDateButtonType.today],
        useAmpm: true,
        selectedTextColor: Colors.blue,
        textColor: Colors.grey,
        selectedItemBackgroundColor: Colors.red,
        separators: BoardDateTimePickerSeparators(
          date: PickerSeparator.slash,
          dateTimeSeparatorBuilder: (context, defaultTextStyle) {
            return Container(
              height: 4,
              width: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
          time: PickerSeparator.colon,
          timeSeparatorBuilder: (context, defaultTextStyle) {
            return Container(
              height: 8,
              width: 4,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        ),
      ),
      // Specify if you want changes in the picker to take effect immediately.
      valueNotifier: null,
      controller: controller,
      onTopActionBuilder: (context) {
        return Container(
          height: 40,
          width: double.infinity,
          color: Colors.red,
        );
      },
    );
    if (result != null) {
      // date.value = result;
      print('result: $result');
    }
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SectionWidget({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, left: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Material(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      ],
    );
  }
}

class PickerItemWidget extends StatelessWidget {
  PickerItemWidget({
    super.key,
    required this.pickerType,
    this.customCloseButtonBuilder,
  });

  final DateTimePickerType pickerType;

  final Widget Function(
    BuildContext context,
    bool isModal,
    void Function() onClose,
  )? customCloseButtonBuilder;

  final ValueNotifier<DateTime> date = ValueNotifier(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final controller = BoardDateTimeController();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await showBoardDateTimePicker(
              context: context,
              pickerType: pickerType,
              // initialDate: DateTime.now(),
              // minimumDate: DateTime.now().add(const Duration(days: 1)),
              options: const BoardDateTimeOptions(
                languages: BoardPickerLanguages.en(),
                startDayOfWeek: DateTime.sunday,
                pickerFormat: PickerFormat.ymd,
                // boardTitle: 'Board Picker',
                // pickerSubTitles: BoardDateTimeItemTitles(year: 'year'),
                // separators: BoardDateTimePickerSeparators(
                //   date: PickerSeparator.slash,
                //   dateTimeSeparatorBuilder: (context, defaultTextStyle) {
                //     return Container(
                //       height: 4,
                //       width: 8,
                //       decoration: BoxDecoration(
                //         color: Colors.red,
                //         borderRadius: BorderRadius.circular(2),
                //       ),
                //     );
                //   },
                //   time: PickerSeparator.colon,
                //   timeSeparatorBuilder: (context, defaultTextStyle) {
                //     return Container(
                //       height: 8,
                //       width: 4,
                //       decoration: BoxDecoration(
                //         color: Colors.blue,
                //         borderRadius: BorderRadius.circular(2),
                //       ),
                //     );
                //   },
                // ),
              ),
              // Specify if you want changes in the picker to take effect immediately.
              valueNotifier: date,
              controller: controller
              // onTopActionBuilder: (context) {
              //   return Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     child: Wrap(
              //       alignment: WrapAlignment.center,
              //       spacing: 8,
              //       children: [
              //         IconButton(
              //           onPressed: () {
              //             controller.changeDateTime(
              //                 date.value.add(const Duration(days: -1)));
              //           },
              //           icon: const Icon(Icons.arrow_back_rounded),
              //         ),
              //         IconButton(
              //           onPressed: () {
              //             controller.changeDateTime(DateTime.now());
              //           },
              //           icon: const Icon(Icons.stop_circle_rounded),
              //         ),
              //         IconButton(
              //           onPressed: () {
              //             controller.changeDateTime(
              //                 date.value.add(const Duration(days: 1)));
              //           },
              //           icon: const Icon(Icons.arrow_forward_rounded),
              //         ),
              //       ],
              //     ),
              //   );
              // },
              );
          if (result != null) {
            date.value = result;
            print('result: $result');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Material(
                color: pickerType.color,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      pickerType.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pickerType.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: date,
                builder: (context, data, _) {
                  return Text(
                    BoardDateFormat(pickerType.formatter(
                      withSecond: DateTimePickerType.time == pickerType,
                    )).format(data),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PickerMultiSelectionItemWidget extends StatelessWidget {
  PickerMultiSelectionItemWidget({
    super.key,
    required this.pickerType,
    this.customCloseButtonBuilder,
  });

  final DateTimePickerType pickerType;

  final Widget Function(
    BuildContext context,
    bool isModal,
    void Function() onClose,
  )? customCloseButtonBuilder;

  final ValueNotifier<DateTime> start = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> end = ValueNotifier(
    DateTime.now().add(const Duration(days: 7)),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Material(
                color: pickerType.color,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      pickerType.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pickerType.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ValueListenableBuilder(
                    valueListenable: start,
                    builder: (context, data, _) {
                      return Text(
                        BoardDateFormat(pickerType.format).format(data),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder(
                    valueListenable: end,
                    builder: (context, data, _) {
                      return Text(
                        '~ ${BoardDateFormat(pickerType.format).format(data)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PickerBuilderItemWidget extends StatelessWidget {
  const PickerBuilderItemWidget({
    super.key,
    required this.pickerType,
    required this.date,
    required this.onOpen,
  });

  final DateTimePickerType pickerType;
  final ValueNotifier<DateTime> date;
  final void Function() onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          onOpen.call();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Material(
                color: pickerType.color,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      pickerType.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pickerType.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: date,
                builder: (context, data, _) {
                  return Text(
                    BoardDateFormat(pickerType.format).format(data),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateTimePickerTypeExtension on DateTimePickerType {
  String get title {
    switch (this) {
      case DateTimePickerType.date:
        return 'Date';
      case DateTimePickerType.datetime:
        return 'DateTime';
      case DateTimePickerType.time:
        return 'Time';
    }
  }

  IconData get icon {
    switch (this) {
      case DateTimePickerType.date:
        return Icons.date_range_rounded;
      case DateTimePickerType.datetime:
        return Icons.date_range_rounded;
      case DateTimePickerType.time:
        return Icons.schedule_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DateTimePickerType.date:
        return Colors.blue;
      case DateTimePickerType.datetime:
        return Colors.orange;
      case DateTimePickerType.time:
        return Colors.pink;
    }
  }

  String get format {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return 'HH:mm';
    }
  }

  String formatter({bool withSecond = false}) {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return withSecond ? 'HH:mm:ss' : 'HH:mm';
    }
  }
}
