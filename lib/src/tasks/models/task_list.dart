import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../tasks.dart';

/// A Todo list.
///
/// Analogous to a `Calendar` object from the Google Calendar API.
class TaskList extends Equatable {
  /// Identifier of the calendar.
  final String id;

  final int index;

  final List<Task> items;

  /// True if local changes have been synced to remote server.
  final bool synced;

  final String title;

  TaskList({
    required List<Task> items,
    required this.id,
    required this.index,
    this.synced = false,
    required this.title,
  }) : items = TaskListValidator.tasksInOrder(items);

  @override
  List<Object> get props {
    return [
      id,
      index,
      items,
      synced,
      title,
    ];
  }

  TaskList copyWith({
    String? id,
    int? index,
    List<Task>? items,
    bool? synced,
    String? title,
  }) {
    return TaskList(
      id: id ?? this.id,
      index: index ?? this.index,
      items: items ?? this.items,
      synced: synced ?? this.synced,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'index': index,
      'items': items.map((x) => x.toMap()).toList(),
      'synced': synced,
      'title': title,
    };
  }

  factory TaskList.fromMap(Map<String, dynamic> map) {
    return TaskList(
      id: map['id'] ?? '',
      index: map['index']?.toInt() ?? -1,
      items: List<Task>.from(map['items']?.map((x) => Task.fromMap(x))),
      synced: map['synced'] ?? false,
      title: map['title'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskList.fromJson(String source) =>
      TaskList.fromMap(json.decode(source));

  /// Task from [oldIndex] is moved to [newIndex].
  ///
  /// Task indexes are recalculated and the updated [TaskList] is returned.
  TaskList reorderTasks(int oldIndex, int newIndex) {
    final updatedTasks = List<Task>.from(items);
    final topLevelTasks = updatedTasks
        .where((element) => element.parent == null && !element.deleted)
        .toList();

    for (var task in topLevelTasks) {
      updatedTasks.remove(task);
    }

    final task = topLevelTasks.removeAt(oldIndex);
    topLevelTasks.insert(newIndex, task);

    for (var i = 0; i < topLevelTasks.length; i++) {
      topLevelTasks[i] = topLevelTasks[i].copyWith(index: i);
    }

    updatedTasks.addAll(topLevelTasks);

    return copyWith(items: updatedTasks);
  }

  @override
  String toString() {
    return 'TaskList(id: $id, index: $index, items: $items, synced: $synced, title: $title)';
  }
}

extension TaskListHelper on List<TaskList> {
  List<TaskList> copy() => List<TaskList>.from(this);

  List<TaskList> sorted() {
    sort((a, b) => a.index.compareTo(b.index));
    return this;
  }
}
