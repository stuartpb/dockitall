//!OpenSCAD
// title      : Dockitall Parametric Charging Dock
// author     : Stuart P. Bentley (@stuartpb)
// version    : 0.1.0
// file       : dockitall.scad

/* [Cosmetic] */

stripe_width = 10;

/* [Measurements] */

// These measurements are based on my Pixel 2 XL in a
// Aeske Ultra slim case, and an Amazon Basics cable.

// The width of the device.
device_width = 80;
// The depth (thickness) of the device.
device_depth = 10;

// The radius of the device's front edges.
device_front_cr = 2;
// The radius of the device's back edges.
device_back_cr = 2;

// The radius of the orner that will descend to the lip.
screen_bottom_cr = 4;

// Offset of the port from the center of the bottom.
port_x_offset = 0;
// Y offset is positive ("up") going closer to the face.
port_y_offset = 0;

// The width of the USB plug.
plug_width = 10.7;
// The depth (thickness) of the USB plug.
plug_depth = 5;
// The roundness of the USB plug (currently only supports plug_depth/2 and 0).
plug_radius = plug_depth/2;
// The length of the plug before tapering off to the cable.
plug_length = 18;
// The diameter of the cable immediately following the end of the plug.
cable_gauge = 4.6;

/* [Tolerances] */

// How much extra space to leave around the device (and through-hole for plug).
device_tolerance = 1;
// How much extra space to leave around the plug.
plug_tolerance = 0;
// How much extra space to leave around the cable.
cable_tolerance = 0;

/* [Parameters] */

// What angle to recline the phone at (from a straight-up zero degrees).
recline_angle = 15;

// The height of the dock underneath the phone.
// Should be at least as long as the plug, plus room for the cable to turn.
chin_height = 32;

back_wall_length = 32;
left_wall_length = back_wall_length;
right_wall_length = left_wall_length;
// The height of the lip in front of the device.
lip_height = 10;

// The thickness of the bottom base.
base_thickness = 5;

// The thickness of the walls.
wall_thickness = 3;

// How wide of a gap to put in the middle of the lip (eg. for a speaker).
lip_cleft_width = 32;
// The height of the lip within the cleft (ie. beneath the speaker).
lip_cleft_height = 4;

/* [Rendering] */

// Epsilon value for enveloping differences
eps = 1/128;
$fn = 90;

/* [Hidden] */

/*
Assumptions in the current formulation:

- Back will have a thickness (no epsilon applied for back)
- Back will be taller than walls/lip
- Device is thicker than plug
- Chin is longer than plug
*/

device_depth_total = device_depth + 2*device_tolerance;
dock_depth = device_depth_total + wall_thickness + wall_thickness;
device_width_total = device_width + 2*device_tolerance;
dock_width = device_width_total + wall_thickness + wall_thickness;
dock_length = back_wall_length + chin_height;
plug_width_total = plug_width + plug_tolerance;
plug_depth_total = plug_depth + plug_tolerance;
cable_total = cable_gauge + 2*cable_tolerance;

device_carveout_left = -device_width_total/2 -
  (wall_thickness ? 0 : eps);
device_carveout_width = device_width_total +
  (wall_thickness ? 0 : eps) + (wall_thickness ? 0 : eps);
device_carveout_above_lip_depth = device_depth_total + wall_thickness + eps;
device_carveout_above_lip_bottom = chin_height + lip_height;
device_carveout_above_lip_height = back_wall_length + eps;
device_carveout_cleft_height = lip_height - lip_cleft_height + eps;
plug_carveout_depth = wall_thickness + port_y_offset + device_depth_total/2;

left_wall_cut = back_wall_length - left_wall_length;
right_wall_cut = back_wall_length - right_wall_length;

base_length = dock_width * cos(30);

module plughole() {
  union () {
    square([plug_width - 2*plug_radius, plug_depth], center=true);
    translate([-plug_width/2 + plug_radius, 0]) circle(r=plug_radius);
    translate([plug_width/2 - plug_radius, 0]) circle(r=plug_radius);
  }
}

module cs_right_corners() {
  translate([device_width/2-device_back_cr, device_depth/2-device_back_cr])
    circle(r=device_back_cr);
  translate([device_width/2-device_front_cr, -device_depth/2+device_front_cr])
    circle(r=device_front_cr);
}

module cross_section() {
  hull() {
    cs_right_corners();
    mirror([1,0,0]) cs_right_corners();
  }
}

module dock_walls() {
  difference() {
    offset(r=device_tolerance + wall_thickness) cross_section();
    offset(r=device_tolerance) cross_section();
  }
}

module dockblock() {
  difference () {
    // starting block
    translate([-dock_width/2, 0, 0]) linear_extrude(dock_depth) square([dock_width, dock_length]);

    // face carveout down to lip
    translate([device_carveout_left, device_carveout_above_lip_bottom, wall_thickness])
      linear_extrude(device_carveout_above_lip_depth)
      square([device_carveout_width, device_carveout_above_lip_height]);

    // carveout behind lip
    translate([device_carveout_left, chin_height, wall_thickness])
      linear_extrude(device_depth_total)
      square([device_carveout_width, lip_height + eps]);

    // left wall height carveout
    if (left_wall_cut && wall_thickness)
      translate([-dock_width/2 - eps, chin_height + left_wall_length, wall_thickness])
        linear_extrude(device_carveout_above_lip_depth)
        square([wall_thickness + 2*eps, left_wall_cut + eps]);

    // right wall height carveout
    if (right_wall_cut && wall_thickness)
      translate([dock_width/2 - wall_thickness - eps,
        chin_height + right_wall_length, wall_thickness])
          linear_extrude(device_carveout_above_lip_depth)
          square([wall_thickness + 2*eps, right_wall_cut + eps]);

    // lip cleft carveout
    translate([-lip_cleft_width/2, chin_height + lip_cleft_height, wall_thickness])
      linear_extrude(device_carveout_above_lip_depth)
      square([lip_cleft_width, device_carveout_cleft_height]);

    // cable track carveout
    translate([-cable_total/2 + port_x_offset, 0, -eps]) linear_extrude(plug_carveout_depth + eps)
      square([cable_total, chin_height + 2*eps]);

    // through-hole plug carveout in back
    translate([port_x_offset, chin_height + plug_depth/2 + cable_tolerance, -eps])
      linear_extrude(wall_thickness + 2*eps)
      offset(r=device_tolerance) plughole();

    // docking plug carveout in chin
    translate([0, chin_height + eps, plug_carveout_depth])
      rotate([90, 0, 0]) linear_extrude(plug_length + eps)
      translate([port_x_offset, port_y_offset])
      offset(r=plug_tolerance) plughole();

    // cable below plug carveout
    translate([0, chin_height + eps, plug_carveout_depth])
      rotate([90, 0, 0]) linear_extrude(chin_height + eps)
      translate([port_x_offset, port_y_offset]) circle(d = cable_total);
  }
}

module base() {
  translate([-dock_width/2, -base_length/2 - dock_depth / cos(recline_angle), 0]) linear_extrude(base_thickness)
    difference() {
      polygon([[dock_width/2,base_length],[dock_width,0],[0,0]]);
      // don't cut into the chin
      square([dock_width, dock_depth / cos(recline_angle)]);
      translate([dock_width/2 - cable_total/2 + port_x_offset, -eps])
        square([cable_total, base_length + eps]);
    }
}

module striping() {
  translate([-150,-150,0]) rotate([45,45,45]) for (offset=[0:2*stripe_width:200]) {
    translate([offset, 0, 0]) cube([stripe_width, 200,200]);
  }
}

module dockplus() {
  union () {
    translate([0, -base_length/2, 0]) rotate([90 - recline_angle, 0, 0])
      dockblock();
  }
  // frontal foot between base and dock
  translate([dock_width/2, -base_length/2, 0]) rotate([90, 0, -90]) linear_extrude(dock_width)
    polygon([[-eps, 0],
      [dock_depth / cos(recline_angle), 0],
      [dock_depth * cos(recline_angle), dock_depth * sin(recline_angle)]]);
}

module onepiece() {
  union () {
    dockplus();
    base();
  }
}

module basestripes() {
  union () {
    intersection () {
      dockplus();
      striping();
    }
    base();
  }
}

module offstripes() {
  difference () {
    dockplus();
    striping();
    base();
  }
}

//onepiece();

//dockblock();
dock_walls();
