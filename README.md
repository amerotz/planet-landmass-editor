# planet-landmass-editor
A basic editor for equirectangular heightmaps generated with [gc-planet-map-generator](https://github.com/amerotz/gc-planet-map-generator). Works with any 1000 * 500 heightmap too.

# How it works
This program allows you to load a 1000 * 500 grayscale heightmap and to edit it in various ways:
* Change sea level height
* Change height range above sea level (default is 0 - 10,000 m)
* Apply various degrees of blurring to hide artifacts and smooth the map
* Highlight the coastline to ease editing
* Manually add or remove height with a resizable brush (you can create whole new islands with your mouse, or maybe make that mountain a little bit taller etc...)
* Full undo - redo support up to 20 times (if you need more than that just edit the constant `MAX_UNDO` in the code)
* Export the edited map as a full resolution png image.

The software is free and open source.

# Installation
This program is written in [Processing 3.5.4](https://www.processing.org/). You can either download the [Processing editor](https://www.processing.org/download/) and open the sketch from there or try one of the executables (Windows & Linux only). An online version will be available soon. [Java 8 or greater](https://java.com/download/) is required.

# Sample maps
