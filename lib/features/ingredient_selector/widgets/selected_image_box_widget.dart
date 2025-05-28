import 'package:flutter/material.dart';
import '../../../../data/models/image_item.dart'; // Updated import

class SelectedImageBox extends StatelessWidget {
  final ImageItem item;
  final VoidCallback onRemove;

  const SelectedImageBox({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    String selectedSubtypesText = item.selectedSubtypeNames.join(', ');

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(1, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onRemove,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(item.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha((0.75 * 255).round()),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.4 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                        size: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 1,
                                color: Colors.black.withAlpha(
                                  (0.5 * 255).round(),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selectedSubtypesText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Text(
                              selectedSubtypesText,
                              style: TextStyle(
                                color: Colors.white.withAlpha(
                                  (0.9 * 255).round(),
                                ),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    blurRadius: 1,
                                    color: Colors.black.withAlpha(
                                      (0.5 * 255).round(),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
