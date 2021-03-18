# planet-landmass-editor
A basic editor for equirectangular heightmaps generated with [gc-planet-map-generator](https://github.com/amerotz/gc-planet-map-generator). Works with any 1000 * 500 heightmap too.

# How it works
This program allows you to load a 1000 * 500 grayscale heightmap and to edit it in various ways:
* Change sea level height
* Change height range above sea level (default is 0 - 10,000 m)
* Apply various degrees of blurring to hide artifacts and smooth the map
* Highlight the coastline to ease editing
* Horizontal shifting
* Manually add or remove height with a resizable brush (you can create whole new islands with your mouse, or maybe make that mountain a little bit taller etc...)
* Inverting land and ocean
* Full undo - redo support up to 20 times (if you need more than that just edit the constant `MAX_UNDO` in the code)
* Export the edited map as a full resolution png image.

The software is free and open source.

# Installation
This program is written in [Processing 3.5.4](https://www.processing.org/). You can either download the [Processing editor](https://www.processing.org/download/) and open the sketch from there or try one of the executables (Windows & Linux only). An online version will be available soon. [Java 8 or greater](https://java.com/download/) is required.

# Walkthrough
This is the map we're starting with. It has been generated with [gc-planet-map-generator](https://github.com/amerotz/gc-planet-map-generator) (25,000 iterations).

![25,000 iterations](/images/25000 iterations)

Now we change the sea level to 8600 m above the lowest point (full height range is 0 - 20,000 m, height above sea level goes 0 - 10,000 m).

![Sea Level](/images/sea level)

Let's say the tallest mountain is roughly the same height as Everest and set the maximum height to 8823 m. Also, let's pretend the coastline is entirely made of 1 km high cliffs from which you can face the void between you and the ocean (minimum height above sea level = 1176 m).

![Height range](/images/height range)

Let's blur the map to smooth things out.

![Blur](/images/blur)

The coastline is hard to distinguish. We can highlight it.

![Coastline highlighting](/images/coastline)

Wouldn't it be nice if that ocean was right in the center of the map? Let's shift it a bit.

What about a small island in that ocean? We can switch to edit mode!

Also, there's too much land on the left. We can draw a little lake.

Don't like the shape? Just undo it.

Better. Wonder what it looks like inverted?

It looked better before. Let's invert it again and save the map.

## Final result
