import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'shared_app_state.dart';
import 'rating_indicator.dart';
import 'honeycomb_pictogram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SideBarTools extends StatefulWidget {
  const SideBarTools({super.key});

  @override
  State<SideBarTools> createState() => _SideBarToolsState();
}

List<String> getOrderedKeys(Map<String, Map<String, dynamic>> layerMap) {
  return layerMap.keys.toList()
    ..sort((a, b) => layerMap[b]!['order'].compareTo(layerMap[a]!['order']));
}

class _SideBarToolsState extends State<SideBarTools> {
  int slatAddCount = 1;
  int uniqueHandleCount = 32;
  TextEditingController slatAddTextController = TextEditingController(text: '1');
  TextEditingController handleAddTextController = TextEditingController(text: '32');
  bool isCollapsed = false;
  bool collapseAnimation = false;
  String slatModelSelection = 'Add';
  bool preventSelfComplementarySlats = true;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<DesignState>();
    var actionState = context.watch<ActionState>();
    var serverState = context.watch<ServerState>();

    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: 0,
      top: 0,
      onEnd: () {
        setState(() {
          collapseAnimation = !collapseAnimation;
        });
      },
      width: isCollapsed ? 70 : 330,
      // Change width based on collapse state
      // Sidebar width
      child: Material(
        elevation: 8,
        child: Container(
          width: isCollapsed ? 70 : 330,
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hamburger icon to toggle sidebar
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Hamburger button
                      Flexible(
                          child: IconButton(
                        icon: Icon(isCollapsed ? Icons.menu : Icons.close),
                        onPressed: () {
                          setState(() {
                            isCollapsed = !isCollapsed;
                          });
                        },
                      )),
                      // Additional buttons (only visible when sidebar is expanded)
                      Visibility(
                        visible: !isCollapsed && !collapseAnimation,
                        child: Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () {
                                appState.importNewDesign();
                              },
                              icon: Icon(Icons.upload, size: 18),
                              label: Text("Import"),
                              style: ElevatedButton.styleFrom(
                                padding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(width: 10),
                            FilledButton.icon(
                              onPressed: () {
                                appState.exportCurrentDesign();
                              },
                              icon: Icon(Icons.download, size: 18),
                              label: Text("Export"),
                              style: ElevatedButton.styleFrom(
                                padding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            
                Visibility(
                  visible: !isCollapsed && !collapseAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Divider(thickness: 2, color: Colors.grey.shade300),
                      Text("Slat Design",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(
                        "Slat Edit Mode", // Title above the segmented button
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 5),
                      SegmentedButton<String>(
                        segments: const <ButtonSegment<String>>[
                          ButtonSegment<String>(
                              value: "Add",
                              label: Text('Add'),
                              icon: Icon(Icons.add_circle_outline)),
                          ButtonSegment<String>(
                              value: "Delete",
                              label: Text('Delete'),
                              icon: Icon(Icons.delete_outline)),
                          ButtonSegment<String>(
                              value: 'Move',
                              label: Text('Move'),
                              icon: Icon(Icons.pan_tool)),
                        ],
                        selected: <String>{slatModelSelection},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            slatModelSelection = newSelection.first;
                            actionState.updateSlatMode(slatModelSelection);
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: slatAddTextController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Number of Slats to Draw',
                              ),
                              textInputAction: TextInputAction.done,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onSubmitted: (value) {
                                int? newValue = int.tryParse(value);
                                if (newValue != null &&
                                    newValue >= 1 &&
                                    newValue <= 32) {
                                  slatAddCount = newValue;
                                  slatAddTextController.text = slatAddCount.toString();
                                } else if (newValue != null && newValue < 1) {
                                  slatAddCount = 1;
                                  slatAddTextController.text = '1';
                                } else {
                                  slatAddCount = 32;
                                  slatAddTextController.text = '32';
                                }
                                appState.updateSlatAddCount(slatAddCount);
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () {
                              if (slatAddCount < 32) {
                                slatAddCount++;
                                slatAddTextController.text = slatAddCount.toString();
                                appState.updateSlatAddCount(slatAddCount);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () {
                              if (slatAddCount > 1) {
                                slatAddCount--;
                                slatAddTextController.text = slatAddCount.toString();
                                appState.updateSlatAddCount(slatAddCount);
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ActionChip(
                            label: Text('1'),
                            onPressed: () {
                              slatAddCount = 1;
                              slatAddTextController.text = slatAddCount.toString();
                              appState.updateSlatAddCount(slatAddCount);
                            },
                          ),
                          SizedBox(width: 10),
                          ActionChip(
                            label: Text('8'),
                            onPressed: () {
                              slatAddCount = 8;
                              slatAddTextController.text = slatAddCount.toString();
                              appState.updateSlatAddCount(slatAddCount);
                            },
                          ),
                          SizedBox(width: 10),
                          ActionChip(
                            label: Text('16'),
                            onPressed: () {
                              slatAddCount = 16;
                              slatAddTextController.text = slatAddCount.toString();
                              appState.updateSlatAddCount(slatAddCount);
                            },
                          ),
                          SizedBox(width: 10),
                          ActionChip(
                            label: Text('32'),
                            onPressed: () {
                              slatAddCount = 32;
                              slatAddTextController.text = slatAddCount.toString();
                              appState.updateSlatAddCount(slatAddCount);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text("Press 'Alt' to rotate slat draw direction!",
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600)),
                      CheckboxListTile(
                        title: const Text('Display Assembly Handles'),
                        value: actionState.displayAssemblyHandles,
                        onChanged: (bool? value) {
                          setState(() {
                            actionState.setAssemblyHandleDisplay(value ?? false);
                          });
                        },
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          appState.clearAll();
                        },
                        icon: Icon(Icons.cleaning_services, size: 18),
                        label: Text("Clear All"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Red background
                          foregroundColor: Colors.white, // White text
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded edges
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Divider(thickness: 2, color: Colors.grey.shade300),
                      Text("Layer Manager",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: min(
                            // Height for 5 items, approximating a row having a height of 85
                              5 * 85.0,
                              // If fewer than 5 items, shrink to fit content
                              getOrderedKeys(appState.layerMap).length * 85.0
                          ),
                        ),
                        child: ReorderableListView(
                          shrinkWrap: false,
                          buildDefaultDragHandles: false,
                          onReorder: (int oldIndex, int newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex--; // Adjust index when moving down
                            }
                            setState(() {
                              // Extract and sort keys based on their current 'order' values
                              final sortedKeys = getOrderedKeys(appState.layerMap);
            
                              // Remove and reinsert the moved key
                              final movedKey = sortedKeys.removeAt(oldIndex);
                              sortedKeys.insert(newIndex, movedKey);
            
                              // Pass the reordered keys to reOrderLayers
                              appState.reOrderLayers(sortedKeys.reversed.toList());
            
                            });
                          },
                          children: getOrderedKeys(appState.layerMap).map((key) {
                            var entry = appState.layerMap[key]!;
                            int index = appState.layerMap.length - (entry['order'] as int) - 1; // done to counteract the reversed order system of the layer sorter
                            bool isSelected = key == appState.selectedLayerKey;
            
                            return Material(
                              key: ValueKey(key),
                              child: Stack(
                                children: [ListTile(
                                  tileColor: isSelected
                                      ? Colors.blue.shade100.withValues(alpha: 0.2) // Darker blue when selected
                                      : Colors.white, // White when not selected
                                  selected: isSelected,
                                  selectedTileColor: Colors.blue.shade200.withValues(alpha: 0.2), // Add this
                                  selectedColor: Colors.black, // Add this to keep text black when selected
                                  onTap: () {
                                    setState(() {
                                      appState.updateActiveLayer(key);
                                    });
                                  },
                                  leading: ReorderableDragStartListener(
                                        index: index,
                                        child: Icon(Icons.drag_handle,
                                            color: Colors.black),
                                      ),
                                  title: Row(
                                    children: [
                                      Expanded(child: Text("L${entry['order']+1}")),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(entry['top_helix'], style: TextStyle(fontSize: 12),),
                                          SizedBox(height: 30),
                                          Text(entry['bottom_helix'], style: TextStyle(fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Container(width: 30,
                                          alignment: Alignment.center,
                                          child: HoneycombCustomPainterWidget(color: entry["color"])),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Popup color picker
                                      SizedBox(width: 8),
                                      PopupMenuButton(
                                        constraints: BoxConstraints(
                                          minWidth: 200,
                                          // Set min width to prevent overflow
                                          maxWidth: 780, // Adjust as needed
                                        ),
                                        offset: Offset(0, 40),
                                        // Position below the button
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem(
                                              child: ColorPicker(
                                                pickerColor: entry["color"],
                                                onColorChanged: (color) {
                                                  setState(() {
                                                    appState.updateColor(key, color);
                                                  });
                                                },
                                                pickerAreaHeightPercent: 0.5,
                                              ),
                                            ),
                                          ];
                                        },
                                        child: Container(
                                          width: 35, // Width of the rectangle
                                          height: 20, // Height of the rectangle
                                          decoration: BoxDecoration(
                                            color: entry["color"],
                                            // Use the color from the list
                                            border: Border.all(
                                                color: Colors.black, width: 1),
                                            borderRadius: BorderRadius.circular(4), // Optional rounded corners
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.autorenew, color: Colors.blue),
                                        onPressed: () {
                                          setState(() {
                                            appState.flipLayer(key);
                                          });
                                        },
                                        constraints: BoxConstraints(minWidth: 35, minHeight: 35), // Adjust width/height
                                        padding: EdgeInsets.zero, // Remove default padding
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            appState.deleteLayer(key);
                                          });
                                        },
                                        constraints: BoxConstraints(minWidth: 35, minHeight: 35), // Adjust width/height
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                                  Positioned(
                                    bottom: 4,
                                    right: 20,
                                    child: Text(
                                      "Layer ID: $key",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ]
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            appState.addLayer();
                          });
                        },
                        label: Text("Add Layer"),
                        icon: Icon(Icons.add),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(thickness: 2, color: Colors.grey.shade300),
                      // SizedBox(height: 10),
                      Text("Assembly Handles",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(
                        "Handle Generation", // Title above the segmented button
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              appState.generateRandomAssemblyHandles(uniqueHandleCount, preventSelfComplementarySlats);
                              actionState.setAssemblyHandleDisplay(true);
                            },
                            icon: Icon(Icons.shuffle, size: 18),
                            label: Text("Randomize"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (!kIsWeb) {
                                actionState.activateEvolveMode();
                              } else {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title:
                                              const Text('Assembly Handle Evolution'),
                                          content: const Text('To run assembly handle evolution, please download the desktop version of the app! (LINK TBC)'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ));
                              }
                            },
                            icon: Icon(Icons.auto_awesome, size: 18),
                            label: Text("Evolve"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Handle library size", style: TextStyle(fontSize: 16)),
                          SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(right: 25.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: handleAddTextController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onSubmitted: (value) {
                                    int? newValue = int.tryParse(value);
                                    if (newValue != null &&
                                        newValue >= 1 &&
                                        newValue <= 997) {
                                      uniqueHandleCount = newValue;
                                      handleAddTextController.text = uniqueHandleCount.toString();
                                    } else if (newValue != null && newValue < 1) {
                                      uniqueHandleCount = 1;
                                      handleAddTextController.text = '1';
                                    } else {
                                      uniqueHandleCount = 997;
                                      handleAddTextController.text = '997';
                                    }
                                    serverState.updateEvoParam('number_unique_handles', uniqueHandleCount.toString());
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0), // Reduces spacing
                        title: const Text('Reset current handles', textAlign: TextAlign.center),
                        value: true,
                        onChanged: (bool? value) {
                          setState(() {});
                        },
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0), // Reduces spacing
                        title: const Text('Prevent self-complementary slats', textAlign: TextAlign.center),
                        value: preventSelfComplementarySlats,
                        onChanged: (bool? value) {
                          setState(() {
                            preventSelfComplementarySlats = value ?? false;
                            serverState.updateEvoParam("split_sequence_handles", preventSelfComplementarySlats.toString());
                          });
                        },
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          appState.cleanAllHandles();
                        },
                        icon: Icon(Icons.delete_sweep, size: 18),
                        label: Text("Delete all handles"),
                        style: ElevatedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Design Hamming Score",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 20),
                              HammingIndicator(value: 0.0),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {},
                            label: Text("Recalculate Score"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
