asteroidsTest
=============

A demo for Zeptolab

The gole was to develop an Asteroids-based game with no usage of any external libraries/engines/other middleware. 
C++ or Objective-C, OpenGL for rendering.

They key elements of the 'engine' are the Node and the Component. Nodes can be nested, allowing creating any 
hierarchies of nodes. It is possible to find this concept familiar in case of knowledge of Cocos2d or any similar software.
The Node class is a subclass of the Object.

The Component element can be applied to any Object-inheritor with Object::applyComponent method. Most valuable components are:

Delay - call this one if you want to wait a bit before doing anything;
Move../Scale../Rotate.. - transform your object's orientation/size;
CallBlock/ScheduledBlock - execute your lambda-scoped code;
Fade.. - can be applied to Blendable inheritors to transform alpha;
GroupComponent - run several components simultaneously;
SequenceCOmponent - run a group of components one by one.

Retina is not supported by default for simplicity, but can be implemented easily. It's a question of
GlView::setScaleFactor call and the usageof bigger values in a glOrtho() call.
