import 'package:flutter/material.dart';
import 'crisscross_core/slats.dart';

/// Useful function to generate the next capital letter in the alphabet for slat identifier keys
String nextCapitalLetter(String current) {
  int len = current.length;
  List<int> chars = current.split('').map((c) => c.codeUnitAt(0) - 'A'.codeUnitAt(0)).toList();

  for (int i = len - 1; i >= 0; i--) {
    if (chars[i] < 25) {
      chars[i]++;
      return String.fromCharCodes(chars.map((e) => 'A'.codeUnitAt(0) + e));
    } else {
      chars[i] = 0;
    }
  }
  // If all characters are 'Z', add 'A' to the beginning.
  return 'A${String.fromCharCodes(chars.map((e) => 'A'.codeUnitAt(0) + e))}';
}


/// State management for the design of the current megastructure
class DesignState extends ChangeNotifier {
  // good for distinguishing layers quickly, but user can change colours
  List<String> colorPalette = ['#ebac23', '#b80058', '#008cf9', '#006e00', '#00bbad', '#d163e6', '#b24602', '#ff9287', '#5954d6', '#00c6f8', '#878500', '#00a76c', '#bdbdbd'];

  // main properties for each design layer
  Map<String,Map<String, dynamic>> layerMap = {
    'A':{
      "direction": 'horizontal', // slat default direction
      'order': 0, // draw order - has to be updated when layers are moved
      'top_helix': 'H5', // not in use for now
      'bottom_helix': 'H2', // not in use for now
      'slat_count': 0, // used to give an id to a new slat
      "color": Color(int.parse('0xFFebac23')) // default slat color
    },
    'B': {
      "direction": 'vertical',
      'slat_count': 0,
      'top_helix': 'H5',
      'bottom_helix': 'H2',
      'order': 1,
      "color": Color(int.parse('0xFFb80058'))
    },
  };

  // main slat container
  Map<String, Slat> slats = {};

  // to highlight on grid painter
  List<String> selectedSlats = [];

  // default values for new layers and slats
  String selectedLayerKey = 'A';
  String nextLayerKey = 'C';
  int nextColorIndex = 2;
  int slatAddCount = 1;

  // useful to keep track of occupancy and speed up grid checks
  Map<String, Map<Offset, String>> occupiedGridPoints = {};

  /// Adds slats to the design
  void addSlats(Offset position, String layer, Map<int, Map<int, Offset>> slatCoordinates) {
    for (var slat in slatCoordinates.entries){
      slats['$layer-I${layerMap[layer]?["slat_count"]}'] = Slat('$layer-I${layerMap[layer]?["slat_count"]}', layer, slat.value);
      // add the slat to the list by adding a map of all coordinate offsets to the slat ID
      occupiedGridPoints.putIfAbsent(layer, () => {});
      occupiedGridPoints[layer]?.addAll({for (var offset in slat.value.values) offset : '$layer-I${layerMap[layer]?["slat_count"]}'});
      layerMap[layer]?["slat_count"] += 1;
    }
    notifyListeners();
  }

  /// Updates the position of a slat
  void updateSlatPosition(String slatID, Map<int, Offset> slatCoordinates) {
    // also need to remove old positions from occupiedGridPoints and add new ones
    String layer = slatID.split('-')[0];
    occupiedGridPoints[layer]?.removeWhere((key, value) => value == slatID);
    slats[slatID]?.updateCoordinates(slatCoordinates);
    occupiedGridPoints[layer]?.addAll({for (var offset in slatCoordinates.values) offset : slatID});
    notifyListeners();
  }

  /// Updates the active layer
  void updateActiveLayer(String value) {
    selectedLayerKey = value;
    notifyListeners();
  }

  /// Updates the number of slats to be added with the next 'add' click
  void updateSlatAddCount(int value) {
    slatAddCount = value;
    notifyListeners();
  }

  /// Updates the color of a layer
  void updateColor(String layer, Color color) {
    layerMap[layer] = {
      ...?layerMap[layer],
      "color": color,
    };
    notifyListeners();
  }

  /// Removes a slat from the design
  void removeSlat(String ID){
    String layer = ID.split('-')[0];
    slats.remove(ID);
    occupiedGridPoints[layer]?.removeWhere((key, value) => value == ID);
    layerMap[layer]?["slat_count"] -= 1;
    notifyListeners();
  }

  /// Selects or deselects a slat
  void selectSlat(String ID){
    if (selectedSlats.contains(ID)){
      selectedSlats.remove(ID);
    } else {
      selectedSlats.add(ID);
    }
    notifyListeners();
  }

  /// Clears all selected slats
  void clearSelection(){
    selectedSlats = [];
    notifyListeners();
  }

  /// Rotates the direction of a layer from horizontal to vertical or vice versa
  void rotateLayerDirection(){
    if (layerMap[selectedLayerKey]?['direction'] == 'horizontal'){
      layerMap[selectedLayerKey]?['direction'] = 'vertical';
    }
    else{
      layerMap[selectedLayerKey]?['direction'] = 'horizontal';
    }

    notifyListeners();
  }

  /// flips the H2-H5 direction of a layer (currently unused)
  void flipLayer(String layer){
    if (layerMap[layer]?['top_helix'] == 'H5'){
      layerMap[layer]?['top_helix'] = 'H2';
      layerMap[layer]?['bottom_helix'] = 'H5';
    }
    else{
      layerMap[layer]?['top_helix'] = 'H5';
      layerMap[layer]?['bottom_helix'] = 'H2';
    }
    notifyListeners();
  }

  /// Deletes a layer from the design entirely
  void deleteLayer(String layer){

    if (!layerMap.containsKey(layer)) return; // Ensure the layer exists before deleting

    layerMap.remove(layer); // Remove the layer

    // Sort the remaining keys based on their current 'order' values
    final sortedKeys = layerMap.keys.toList()
      ..sort((a, b) => layerMap[a]!['order'].compareTo(layerMap[b]!['order']));

    // Reassign 'order' values to maintain sequence
    for (int i = 0; i < sortedKeys.length; i++) {
      layerMap[sortedKeys[i]]!['order'] = i;
    }

    // Update selectedLayerKey if needed TODO: do not allow the deletion of the last layer or else deal with a null system...
    if (selectedLayerKey == layer) {
      selectedLayerKey = (sortedKeys.isEmpty ? null : sortedKeys.last)!;
    }

    // removes all slats from the deleted layer
    slats.removeWhere((key, value) => value.layer == layer);
    occupiedGridPoints.remove(layer);

    notifyListeners();
  }

  /// Reorders the positions of the layers based on a new order
  void reOrderLayers(List<String> newOrder){
    for (int i = 0; i < newOrder.length; i++) {
      layerMap[newOrder[i]]!['order'] = i; // Assign new order values
    }
    notifyListeners();
  }

  /// Adds an entirely new layer to the design
  void addLayer(){

    // if last last layerMap value has direction horizontal, next direction should be vertical and vice versa
    String newDirection;
    if (layerMap.values.last['direction'] == 'horizontal'){
      newDirection = 'vertical';
    }
    else{
      newDirection = 'horizontal';
    }

    layerMap[nextLayerKey] = {
      "direction": newDirection,
      'slat_count': 0,
      'top_helix': 'H5',
      'bottom_helix': 'H2',
      'order': layerMap.length,
      "color": Color(int.parse('0xFF${colorPalette[nextColorIndex].substring(1)}'))
    };

    if (nextColorIndex == colorPalette.length - 1){
      nextColorIndex = 0;
    }
    else{
      nextColorIndex += 1;
    }

    nextLayerKey = nextCapitalLetter(nextLayerKey);
    notifyListeners();
  }
}

/// State management for the action mode of the app
class ActionState extends ChangeNotifier {
String slatMode = 'Add';
void updateSlatMode(String value) {
  slatMode = value;
  notifyListeners();
}
}