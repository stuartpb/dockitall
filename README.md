# dockitall Parametric Charging Dock

This is a parametric design I made to have a dock I could place my Google Pixel 2 XL into now that I can't just use wireless charging. (I'm still holding out for a Pixel 5 XL that has it.)

## Original phone and cable (not included)

The included model was designed to fit [an AmazonBasics USB-C cable](https://www.amazon.com/gp/product/B01GGKZ1VA/), and a Google Pixel 2 XL in a [slim TPU case](https://www.amazon.com/gp/product/B0756884QS/). The base is designed to fit an ordinary 80cm equilateral triangular anti-slip pad to stick it to your desk - [here](https://www.amazon.com/dp/B07CTQST6R) is a package on Amazon with one.

## Parameters

These parameters (as seen in the SCAD file linked as source):

### The phone / case

- Device with an 80x10mm footprint
  - footprint corners have bevels of 3mm radius around the front and 5mm radius around the back
- device face
  - outside profile has a bottom corner radius of 8mm
  - the front of the device is wrapped around for 4mm (to the edges of a ~72mm screen)
  - the screen has a corner radius of 5.5mm (or less - this is the outer radius we surround)
  - the screen is 10mm from the edge (lip_height)
  - there is a 32mm wide speaker 6mm from the screen (lip_cleft_width,lip_cleft_height)

### The USB cable

- the plug
  - head is 10.7x5mm, with perfectly round corners (or at least close enough to fit)
 - sits 16.5mm beneath the surface (being 18mm long, minus 1.5mm to raise it to where the phone sits in the case)
- cable track going out the back is 4.2 mm

## Etcetera

The baked model has other discretionary parameters not included here.

If you'd like to tweak these before printing to better fit your on-hand hardware, see "Customizing the SCAD file" below.

## Assembly

### Through-hole: hourglass design (default)

This design assumes that your plug is not that much wider than your device is thick: if that isn't the case, when customizing the SCAD file (described below), you might need to go for the "Open channel" design (described in the next section).

To insert the cable in this design, turn it diagonally into the figure-eight-shaped hole in the bottom, push/pull it through (if doing this requires too much force, see "Customizing the SCAD file" to add tolerance to that channel / adjust its size for your cable's head/plug).

### Through-hole: open-channel design

If you customize the model to use the "Open channel" style, then simply push the cable through the hole in the back. If the full plug / head can't get through (to the point that you can pull cable through freely), you may need to customize the plug measurements and try again (see note below about testing modules to perform focused experiments with this).

### Seating the cable and dock

Once the plug is through, rotate it into the horizontal slot, then push/pull it into place until it fits against the bottom of the channel.

Thread the cable through the channel in the base, then place the sticky pad on the base to hold it in place (both the cable in the base, and the base to the desk).

# Print instructions

## Using the models here

A "onepiece" model is included for single-material printing. The parameters of this model (and the MMU models) are rendered here from the parameters described above.

I've tested the MMU version (in an earlier revision with minor differences) on an MK3S/MMU2S, in yellow and black PETG. I used black for both a stripe and the base. (Transitioning between these materials needed a lot of purge to get a clean yellow - I'm still experimenting at around 300mm).

### MMU

MMU owners can use the a_stripes, b_stripes, and base_plate models to print the dock in two different colors of diagonal stripe, as well as the base (which may share a material with one of the stripe colors, if desired).

## Customizing the SCAD file

You'll need a relatively new version of OpenSCAD to be compatible with the implementation of curves used in this file: you can follow the installation instructions / download it from http://www.openscad.org/downloads.html

Once you have OpenSCAD, download "dockitall.scad" from here and open it up.

## Variable customization

The customizable variables are at the top of the file, under Thingiverse-Customizer-like headings.

## Module selection

Module rendering is done by uncommenting a final call at the bottom of the file (under the "Entry points" block heading).

## Test models

If customizing the variables in the model for your own, rather than having to print entire sacrificial drafts as you dial your measurements in, you can print small pieces to test your settings by rendering the test_dockblock and cable_test modules.

When printing test_dockblock, you can customize the region of the model that you test with the test_bottom and test_height parameters.
