import '../crisscross_core/slats.dart';
import 'package:flutter/material.dart';

class SlatUndoStack {
  final List<Map<String, Slat>> _history = [];
  final List<Map<String, Map<Offset, String>>> _gridHistory = [];
  final List<Map<String, Map<String, dynamic>>> _layerHistory = [];
  final List<Map<String, dynamic>> _layerMetaData = [];

  int _currentIndex = -1;
  static const int _maxHistory = 50;

  void saveState(Map<String, Slat> slats, Map<String,
      Map<Offset, String>> occupiedGridPoints,
      Map<String, Map<String, dynamic>> layerMap,
      Map<String, dynamic> layerMetaData,
      ) {

    // If we are in the middle of history, remove future states
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
      _gridHistory.removeRange(_currentIndex + 1, _gridHistory.length);
      _layerHistory.removeRange(_currentIndex + 1, _layerHistory.length);
      _layerMetaData.removeRange(_currentIndex + 1, _layerMetaData.length);
    }

    // Add new state
    _history.add(Map.fromEntries(slats.entries.map((e) => MapEntry(e.key, e.value.copy()))));
    _gridHistory.add({
      for (var entry in occupiedGridPoints.entries)
        entry.key: Map.from(entry.value)
    });
    _layerHistory.add(Map.fromEntries(layerMap.entries.map((e) => MapEntry(e.key, Map.from(e.value)))));
    _layerMetaData.add(Map.from(layerMetaData));

    // Trim history if it exceeds the max limit
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
      _gridHistory.removeAt(0);
      _layerHistory.removeAt(0);
      _layerMetaData.removeAt(0);
    } else {
      _currentIndex++;
    }
  }

  Map<String, dynamic>? undo() {
    if (_currentIndex > -1) {
      _currentIndex--;

      Map<String, Map<Offset, String>> gridState = {
        for (var entry in _gridHistory[_currentIndex+1].entries)
          entry.key: Map.from(entry.value)
      };

      Map<String, Map<String, dynamic>> layerState = {
        for (var entry in _layerHistory[_currentIndex+1].entries)
          entry.key: Map.from(entry.value)
      };

      return {
        'slats': Map.fromEntries(_history[_currentIndex+1].entries.map((e) => MapEntry(e.key, e.value.copy()))),
        'occupiedGridPoints': gridState,
        'layerMap': layerState,
        'layerMetaData': Map.from(_layerMetaData[_currentIndex+1]),
      };
    }
    return null; // No more undo steps
  }
}