# flame01

A new Flutter project.

## Getting Started

1. Project Setup:

# Setting up the Asset Folder:
* Create a new directory in your project called assets/, and within it, subdirectories for images, audio, etc. :
/assets
/images
/audio
/animations

# Register these directories in your pubspec.yaml so they can be accessed by Flutter:
assets:
- assets/images/
- assets/audio/
- assets/animations/

# File Structure:

* Organize your Dart files into folders to manage your code effectively. A basic structure might be:
/lib
/components
/screens
/game
/utilities

* /components: 
- This folder is for custom game objects that will be used within your game world. 
- Each object is usually a subclass of Component or one of its subclasses (PositionComponent, SpriteComponent, AnimationComponent, etc.).
- For example:Player.dart,Enemy.dart,PowerUp.dart,Obstacle.dart,...

* /screens :
- Screens represent various “screens” or “views” that appear in the game, such as menus, settings, the game playfield, and game over screens. 
- They manage the layout and transition between different parts of the game.
- For example: MenuScreen.dart,GameScreen.dart,PauseScreen.dart,GameOverScreen.dart,...

* /game
- The game folder generally contains the main game controller and any other necessary infrastructure that ties the game together, 
controlling the overall game state, rules, and progression.
- For example: MyGame.dart, LevelController.dart, GameController.dart,...

* /utilities
- A folder for code and classes that provide support and utility functions which don’t fall into the component or screen classifications. 
- It can contain helper functions, constants, enums, and extensions that are used throughout the project.
- For example: Assets.dart,Extensions.dart,Constants.dart,...


# Image attribution
<a href="https://www.freepik.com/free-vector/gunshot-animation-black-background-cartoon-illustration-set-orange-gun-flashes-with-fire-smoke-explosive-effect-bullet-trace-explosion-weapon-blast-burst-concept_29119192.htm#query=fire%20sprite&position=9&from_view=keyword&track=ais&uuid=88814d0c-68e9-4375-9ea6-21129edeb660">Image by pch.vector</a> on Freepik

