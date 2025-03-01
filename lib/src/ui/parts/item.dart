import 'dart:async';

import 'package:board_datetime_picker/src/options/board_item_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'focus_node.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({
    super.key,
    required this.option,
    required this.onChange,
    required this.foregroundColor,
    required this.textColor,
    required this.selectedTextColor,
    required this.wide
  });

  final BoardPickerItemOption option;
  final void Function(int) onChange;
  final Color foregroundColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final bool wide;

  @override
  State<ItemWidget> createState() => ItemWidgetState();
}

class ItemWidgetState extends State<ItemWidget>
    with SingleTickerProviderStateMixin {
  final double itemSize = 44;
  final duration = const Duration(milliseconds: 200);
  final borderRadius = BorderRadius.circular(12);

  /// ScrollController
  late FixedExtentScrollController scrollController;

  /// TextField Controller
  late TextEditingController textController;

  /// Correction Animation Controller
  late AnimationController correctAnimationController;
  late Animation<Color?> correctColor;

  /// Picker list
  Map<int, int> map = {};

  int selectedIndex = 0;

  /// Timer for debouncing process
  Timer? debouceTimer;
  Timer? wheelDebouceTimer;

  /// Number of items to display in the list
  int get wheelCount => widget.wide ? 7 : 5;

  final pickerFocusNode = PickerWheelItemFocusNode();

  void setMap({Map<int, int>? newMap}) {
    map = newMap ?? widget.option.itemMap;
  }

  int getWheelIndex(int index) {
   return index;
  }

  /// Notify caller of changed index
  void callbackOnChange(int index) {
    widget.onChange(index);
  }

  @override
  void initState() {
    setMap();
    selectedIndex = getWheelIndex(widget.option.selectedIndex);
    scrollController = FixedExtentScrollController(
      initialItem: selectedIndex,
    );
    textController = TextEditingController(text: '${map[selectedIndex]}');
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );

    widget.option.focusNode.addListener(focusListener);

    correctAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    correctColor = ColorTween(
      begin: widget.foregroundColor,
      end: Colors.redAccent.withValues(alpha: 0.8),
    ).animate(correctAnimationController);

    correctAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        correctAnimationController.reverse();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    widget.option.focusNode.removeListener(focusListener);
    scrollController.dispose();
    textController.dispose();
    super.dispose();
  }

  void focusListener() {
    changeText(textController.text, toDefault: true);
  }

  void onChange(int index) {
    setState(() {
      selectedIndex = index;
    });

    void setText() {
      final text = '${map[selectedIndex]}';
      if (textController.text != text) {
        textController.text = text;
      }
      debouceTimer?.cancel();
      debouceTimer = null;
    }

    // Debounce process to prevent inadvertent text updates when in focus
    if (widget.option.focusNode.hasFocus) {
      debouceTimer?.cancel();
      // Ignore empty characters as they do not need to be scrolled.
      if (textController.text != '') {
        debouceTimer = Timer(const Duration(milliseconds: 300), setText);
      }
    } else {
      setText();
    }
  }

  void toAnimateChange(int index, {bool button = false}) {
    if (!widget.option.itemMap.keys.contains(index)) return;
    selectedIndex = getWheelIndex(index);
    scrollController.animateToItem(
      index,
      duration: duration,
      curve: Curves.easeIn,
    );
  }

  void updateState(Map<int, int> newMap, int newIndex) {
    if (!mounted) return;

    bool needAnimation = false;
    setState(() {
      // 表示する数字が同じ場合はアニメーションしない
      final oldValue = map[selectedIndex];

      setMap(newMap: newMap);
      final newWheelIndex = getWheelIndex(newIndex);
      if (selectedIndex != newWheelIndex) {
        selectedIndex = newWheelIndex;

        final newValue = map[newWheelIndex];

        if (oldValue != newValue) {
          needAnimation = true;
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      if (needAnimation) {
        scrollController.animateToItem(
          selectedIndex,
          duration: duration,
          curve: Curves.easeIn,
        );
      } else {
        scrollController.jumpToItem(selectedIndex);
      }
    });
  }

  void _updateFocusNode() {
    final pf = FocusManager.instance.primaryFocus;
    if (pf is! PickerItemFocusNode && pf is! BoardDateTimeInputFocusNode) {
      pickerFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: correctAnimationController,
                    builder: (context, child) {
                      return Material(
                        color: correctColor.value,
                        borderRadius: borderRadius,
                        child: SizedBox(
                          height: itemSize,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: NotificationListener(
                      child: SizedBox(
                        height: itemSize * wheelCount,
                        child: GestureDetector(
                          child: Focus(
                            focusNode: pickerFocusNode,
                            child: ListWheelScrollView.useDelegate(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemExtent: itemSize,
                              diameterRatio: 8,
                              perspective: 0.01,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              onSelectedItemChanged: onChange,
                              childDelegate: ListWheelChildListDelegate(
                                children: [
                                  for (final i in map.keys) _item(i),
                                ],
                              ),
                            ),
                          ),
                          onTapDown: (details) {
                            _updateFocusNode();
                          },
                          onTapUp: (details) {
                            double clickOffset;
                           clickOffset = details.localPosition.dy -
                                  (itemSize * wheelCount / 2);
                            final currentIndex = scrollController.selectedItem;
                            final indexOffset =
                                (clickOffset / itemSize).round();
                            final newIndex = currentIndex + indexOffset;
                            toAnimateChange(newIndex);

                            _updateFocusNode();
                          },
                        ),
                      ),
                      onNotification: (info) {
                        if (info is ScrollEndNotification) {
                          // Change callback
                          callbackOnChange(selectedIndex);
                        }
                        return true;
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: null,
                      borderRadius: borderRadius,
                      child: SizedBox(
                        height: itemSize,
                        width: double.infinity,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Converts input text to an index
  int? _convertTextToIndex(String text) {
    try {
      final data = int.parse(text);

      // Get index from input value
      int index = -1;
      for (final key in map.keys) {
        if (map[key]! == data) {
          index = key;
          break;
        }
      }
      return index;
    } catch (_) {
      return null;
    }
  }

  /// Converts input text into an index and performs change notifications
  void changeText(String text, {bool toDefault = false}) {
    var index = _convertTextToIndex(text);

    // If non-numeric or empty, set to the first value
    if (index == null) {
      index = selectedIndex;
      textController.text = map[index]!.toString();
    }

    if (toDefault) {
      if (index == selectedIndex) return;
      if (index < 0) {
        index = selectedIndex;
        textController.text = map[index]!.toString();

        // If corrected, animation is performed
        correctAnimationController.forward();
      }
    } else {
      if (index < 0) return;
    }

    // Animated wheel movement
    toAnimateChange(index);
    // Change callback
    callbackOnChange(index);
  }

  /// Processing when text is changed
  void onChangeText(String text) {
    wheelDebouceTimer?.cancel();

    final index = _convertTextToIndex(text);
    if (index == null || index < 0) return;
    // Animated wheel movement
    wheelDebouceTimer = Timer(
      const Duration(milliseconds: 200),
      () {
        wheelDebouceTimer?.cancel();
        wheelDebouceTimer = null;
        toAnimateChange(index);
      },
    );
  }

  Widget _item(int i) {
    TextStyle? textStyle = Theme.of(context).textTheme.bodyLarge;

    if (selectedIndex == i) {
      textStyle = textStyle?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: widget.selectedTextColor,
      );
    } else {
      textStyle = textStyle?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: widget.textColor,
      );
    }

    return Center(
      child: Text(
        '${map[i]}',
        style: textStyle,
      ),
    );
  }
}

class AllowTextInputFormatter extends TextInputFormatter {
  AllowTextInputFormatter(this.list);

  final List<int> list;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    try {
      final value = int.parse(newValue.text);

      if (!list.contains(value)) {
        final x = list.where(
          (x) => x.toString().contains(newValue.text),
        );
        if (x.isEmpty) {
          return oldValue;
        }
      }
    } catch (_) {
      return oldValue;
    }
    return newValue;
  }
}
