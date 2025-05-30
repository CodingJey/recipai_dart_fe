import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/image_item.dart';
import '../bloc/ingredient_bloc.dart';
import 'subtype_dropdown_overlay.dart';

class ImageBoxWidget extends StatefulWidget {
  final ImageItem item;
  final bool isSelected;
  final VoidCallback
  onTap; // Called by ImageBoxScreen to dispatch BLoC event for selection

  const ImageBoxWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  _ImageBoxWidgetState createState() => _ImageBoxWidgetState();
}

class _ImageBoxWidgetState extends State<ImageBoxWidget> {
  OverlayEntry? _dropdownOverlayEntry;
  late ValueNotifier<ImageItem> _itemNotifier;

  @override
  void initState() {
    super.initState();
    _itemNotifier = ValueNotifier(widget.item);
  }

  @override
  void didUpdateWidget(covariant ImageBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      _itemNotifier.value = widget.item;
    }
  }

  @override
  void dispose() {
    _itemNotifier.dispose();
    // Ensure overlay is removed if widget is disposed while overlay is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeDropdownOverlay();
    });
    super.dispose();
  }

  void _removeDropdownOverlay() {
    if (_dropdownOverlayEntry != null) {
      // Check mounted status before removing
      if (_dropdownOverlayEntry!.mounted) {
        _dropdownOverlayEntry!.remove();
      }
      _dropdownOverlayEntry = null;
    }
  }

  void _closeDropdown() {
    _removeDropdownOverlay();
  }

  void _openDropdown() {
    if (_dropdownOverlayEntry != null || widget.item.subtypes.isEmpty) return;

    _dropdownOverlayEntry = OverlayEntry(
      builder: (context) => SubtypeDropdownOverlay(
        itemNotifier: _itemNotifier, // Pass the notifier
        onSubtypeToggled: (String subtypeNameToggled) {
          // Dispatch event to BLoC for subtype toggle
          context.read<IngredientBloc>().add(
            ToggleItemSubtypeEvent(widget.item.id, subtypeNameToggled),
          );
        },
        closeDropdown: _closeDropdown,
      ),
    );
    Overlay.of(context).insert(_dropdownOverlayEntry!);
  }

  void _toggleDropdown() {
    if (widget.item.subtypes.isEmpty) return;

    if (_dropdownOverlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    double borderWidth = widget.isSelected ? 3.0 : 0.0;
    double clipRadius = 12.0 - borderWidth;
    String selectedSubtypesText = widget.item.selectedSubtypeNames.join(', ');

    return GestureDetector(
      onTap: widget.onTap, // This callback is provided by ImageBoxScreen
      onLongPress: widget.item.subtypes.isNotEmpty ? _toggleDropdown : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
              spreadRadius: 0,
            ),
          ],
          border: widget.isSelected
              ? Border.all(color: Colors.blueAccent, width: 3)
              : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(clipRadius < 0 ? 0 : clipRadius),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                    if (selectedSubtypesText.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedSubtypesText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (widget.isSelected &&
                        widget.item.selectedSubtypeNames.isEmpty &&
                        widget.item.subtypes.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Choose type(s) (Long-press)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (widget.isSelected &&
                        (widget.item.subtypes.isEmpty ||
                            (widget.item.selectedSubtypeNames.isNotEmpty &&
                                widget.item.subtypes.isNotEmpty)) &&
                        selectedSubtypesText
                            .isEmpty) // Adjusted logic for "Selected" badge
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
