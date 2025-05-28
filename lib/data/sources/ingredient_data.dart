import '../models/image_item.dart';

// Initial data for available ingredients
// This could eventually come from an API or local database
final List<ImageItem> initialAvailableItems = [
  ImageItem(
    id: 1,
    name: "Chicken",
    imageUrl: "assets/images/chicken.png",
    subtypeFileBasenames: [
      "chicken_breast",
      "chicken_thigh",
      "chicken_wings",
      "whole_chicken",
      "ground_chicken",
    ],
  ),
  ImageItem(
    id: 2,
    name: "Egg",
    imageUrl: "assets/images/egg.png",
    subtypeFileBasenames: [
      "boiled_egg",
      "fried_egg",
      "scrambled_egg",
      "poached_egg",
    ],
  ),
  // Add other items here if you uncomment them in the original code
  // ImageItem(
  //     id: 3, name: "Milk", imageUrl: "assets/images/milk.png",
  //     subtypeFileBasenames: ["whole_milk", "skim_milk", "almond_milk", "soy_milk", "oat_milk"],
  // ),
  // ... and so on
];
