---
layout: post
title: "Optical Illusions in Matplotlib"
date: 2012-09-26 07:27
comments: true
categories: 
---
A while ago I posted some information on the new matplotlib animation
package (see my tutorial
[here](/blog/2012/08/18/matplotlib-animation-tutorial) and
a followup post [here](/blog/2012/09/05/quantum-python)).  In them, I show
how easy it is to  use matplotlib to create simple animations.

This morning I came across this cool optical illusion on
[gizmodo](http://gizmodo.com/5945194/this-optical-trick-is-annoying-the-hell-out-of-me)

<!-- more -->

[{% img /images/original_illusion.gif %}](http://gizmodo.com/5945194/this-optical-trick-is-annoying-the-hell-out-of-me)

It intrigued me, so I decided to see if I could create it using matplotlib.
Using my previous template and a bit of geometry, I was able to finish it
before breakfast!  Here's the code:

{% include_code  Optical Illusion animate_square.py %}

And here's the result:

{% video /downloads/videos/animate_square.mp4 360 270 /downloads/videos/animate_square.png %}

This just confirms my suspicion that a few lines of python really can do
anything.