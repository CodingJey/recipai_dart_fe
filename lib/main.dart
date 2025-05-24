import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipAI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Start animation
    _animationController.forward();

    // Navigate to main screen after 1 second
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ImageBoxScreen(),
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[600]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[400]!, Colors.red[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),

                      SizedBox(height: 30),

                      // App Name
                      Text(
                        'RecipAI',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 4),
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12),

                      // Tagline
                      Text(
                        'AI-Powered Recipe Discovery',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Model class for our items (like a TypeScript interface)
class ImageItem {
  final String name;
  final String imageUrl;
  final int id;

  ImageItem({required this.name, required this.imageUrl, required this.id});
}

// Main screen (StatefulWidget = component with state)
class ImageBoxScreen extends StatefulWidget {
  @override
  _ImageBoxScreenState createState() => _ImageBoxScreenState();
}

class _ImageBoxScreenState extends State<ImageBoxScreen> {
  // State variables (like component properties in Angular)
  List<ImageItem> availableItems = [
    ImageItem(id: 1, name: "chicken", imageUrl: "./assets/images/chicken.png"),
    ImageItem(id: 2, name: "egg", imageUrl: "./assets/images/egg.png"),
    ImageItem(id: 3, name: "milk", imageUrl: "./assets/images/milk.png"),
    ImageItem(id: 4, name: "rice", imageUrl: "./assets/images/rice.png"),
    ImageItem(id: 5, name: "steak", imageUrl: "./assets/images/steak.png"),
  ];

  List<ImageItem> selectedItems = [];

  // Method to add item to selected list (like event handlers in Angular)
  void addToSelected(ImageItem item) {
    setState(() {
      if (!selectedItems.any((selectedItem) => selectedItem.id == item.id)) {
        selectedItems.add(item);
      }
    });
  }

  // Method to remove item from selected list
  void removeFromSelected(ImageItem item) {
    setState(() {
      selectedItems.removeWhere((selectedItem) => selectedItem.id == item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.red[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Colors.grey[50],
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'RecipAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    offset: Offset(1, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[600]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Selected items horizontal scroll section
          Container(
            height: 120,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: selectedItems.isEmpty
                ? Center(
                    child: Text(
                      'Click on items below to add them here',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      return SelectedImageBox(
                        item: selectedItems[index],
                        onRemove: () =>
                            removeFromSelected(selectedItems[index]),
                      );
                    },
                  ),
          ),

          // Available items grid section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: availableItems.length,
                      itemBuilder: (context, index) {
                        final item = availableItems[index];
                        final isSelected = selectedItems.any(
                          (selectedItem) => selectedItem.id == item.id,
                        );

                        return ImageBox(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => addToSelected(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Image Box Component (like Angular component)
class ImageBox extends StatelessWidget {
  final ImageItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const ImageBox({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(2, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: Offset(1, 1),
              spreadRadius: 0,
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.blue, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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

// Selected Image Box Component for horizontal scroll
class SelectedImageBox extends StatelessWidget {
  final ImageItem item;
  final VoidCallback onRemove;

  const SelectedImageBox({Key? key, required this.item, required this.onRemove})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
