import 'package:flutter/material.dart';
import '../../../data/models/image_item.dart';
import '../../../data/models/subtype_detail.dart'; // Ensure this points to the updated (name-only) SubtypeDetail

class SubtypeDropdownOverlay extends StatefulWidget {
  final ValueNotifier<ImageItem> itemNotifier;
  final Function(String subtypeNameToggled) onSubtypeToggled;
  final VoidCallback closeDropdown;

  const SubtypeDropdownOverlay({
    super.key,
    required this.itemNotifier,
    required this.onSubtypeToggled,
    required this.closeDropdown,
  });

  @override
  State<SubtypeDropdownOverlay> createState() => _SubtypeDropdownOverlayState();
}

class _SubtypeDropdownOverlayState extends State<SubtypeDropdownOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubtypeTap(SubtypeDetail subtypeDetail) {
    widget.onSubtypeToggled(subtypeDetail.name);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ValueListenableBuilder<ImageItem>(
      valueListenable: widget.itemNotifier,
      builder: (context, currentItem, child) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.closeDropdown,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, animatedChild) {
                    return FadeTransition(
                      opacity: _opacityAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        alignment: Alignment.center,
                        child: animatedChild,
                      ),
                    );
                  },
                  child: Material(
                    elevation: 16.0,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                        minWidth: 300,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Select type(s) for ${currentItem.name}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.textTheme.titleLarge?.color ??
                                  Colors.grey[850],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: currentItem
                                  .subtypes
                                  .length, // Subtypes now only have 'name'
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Colors.grey[300],
                              ),
                              itemBuilder: (context, index) {
                                final subtypeDetail = currentItem
                                    .subtypes[index]; // This is the updated SubtypeDetail
                                final bool isSubtypeSelected = currentItem
                                    .selectedSubtypeNames
                                    .contains(subtypeDetail.name);

                                return CheckboxListTile(
                                  key: ValueKey(subtypeDetail.name),
                                  title: Text(
                                    subtypeDetail.name, // Display the name
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSubtypeSelected
                                          ? theme.primaryColorDark
                                          : theme.textTheme.bodyLarge?.color,
                                      fontWeight: isSubtypeSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  value: isSubtypeSelected,
                                  onChanged: (bool? newValue) {
                                    _handleSubtypeTap(subtypeDetail);
                                  },
                                  // No 'secondary' widget for an image
                                  activeColor: theme.primaryColor,
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  tileColor: isSubtypeSelected
                                      ? theme.primaryColor.withOpacity(0.08)
                                      : Colors.transparent,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: widget.closeDropdown,
                              child: const Text("Done"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
