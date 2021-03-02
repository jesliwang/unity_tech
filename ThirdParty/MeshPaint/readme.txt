=== Mesh Painter ===

Developed by: Best Unity Solutions
Email: bestunitysolutions@gmail.com
Sample textures are comercial use royalty-free

Mesh Painter is a tool that allows you to easily paint an custom imported mesh.

== Description ==

With this tool you can easily create your own meshes, import then into unity and paint it. Just select the brush and start painting

Features:

Start painting quickly.
	-easy setup
	-simple user interface
	-select the brush and paint
Undo/Redo supported
	-paint safe
Use custom brushes
	-loads user created brushes
Custom shaders supported
	-create your own shader to make amazing effects
Keyboard shortcuts
	-Use keys '[' and ']' to change brush size while painting
Mobile ready
	-fast shader.
	-low memory usage. You can compress splatmap

== Starting Guide ==

To start painting, import to the scene the desired mesh, add to the gameobject the "MeshPainter" component.
The settings inspector will be displayed, create a new material and select one of the MeshPaint group shaders. Apply the material to the mesh,
set a new Splatmap, and configure up to 4 detail textures.

Click on the 'Paint' button in the inspector and select a brush and a Detail, go to the scene view, press and hold the Command or Control key, click 'LMB' and drag 
over the selected mesh.

Mesh Painter depends of a mesh collider to detects the user clicks, fourtunately, it takes care of this for you
if you need to add others colliders no problem, Mesh Painter will manage this. You can disable this feature in settings

Remember that you can compress the splatmap after painting, or before the app release.

For mobile, please use shaders from "meshPainter/mobile"

== Custom Brushes ==

To paint with a custom brush just add a 64x64 or 128x128 texture to "CustomBrushes" directory
then they will be displayed at brushes list

== TIPS ==

Remember to normalize the model UV mapping

== Changelog ==

= 1.0 =
* initial release

= 1.1 =
* Bug fixes
* Use CPU brush scale for older unity versions

= 1.2 =
* Bug fixes
* Added Support for unity 4.6.x

= 1.3 =
* Bug fixes
* Bucket Fill Tool

= 2.0 =
* Support for up to 12 detail textures
* Support for configure normal map
* Added 12 custom shaders
* Bug fixes

= 2.1 =
* Bug fixes

= 2.2 =
* Unity 5.5 Fixes

= 2.3 =
* Unity 5.6 Fixes

= 2.4 =
* Unity 2017 Fixes