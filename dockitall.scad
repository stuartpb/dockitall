//!OpenSCAD
// title      : Dockitall Parametric Charging Dock
// author     : Stuart P. Bentley (@stuartpb)
// version    : 0.2.0
// file       : dockitall.scad

/* [Cosmetic] */

stripe_width = 14;

/* [Measurements] */

// These measurements are based on my Pixel 2 XL in a
// Aeske Ultra slim case, and an Amazon Basics cable.

// The width of the device.
device_width = 80;
// The depth (thickness) of the device.
device_depth = 10;

// The radius of the device's front edges.
device_front_cr = 3;
// The radius of the device's back edges.
device_back_cr = 5;

// The radius of the bottom left and right corners.
device_bottom_cr = 8;

// The width of the front opening for the screen.
screen_width = 72;

// The radius of the corner that will descend to the lip.
screen_cr = 5.5;

// Offset of the port from the center of the bottom.
port_x_offset = 0;
// Y offset is positive ("up") going closer to the face.
port_y_offset = 0;
// Z offset is for the port's inset to things like a phone case,
// raising the plug accordingly.
port_z_offset = 1.5;

// The width of the USB plug.
plug_width = 10.7;
// The depth (thickness) of the USB plug.
plug_depth = 5;
// The roundness of the USB plug (currently only supports plug_depth/2 and 0).
plug_radius = plug_depth/2;
// The length of the plug before tapering off to the cable.
plug_length = 18;
// The diameter of the cable immediately following the end of the plug.
cable_gauge = 3.5;//4.6;

/* [Tolerances] */

// How much extra space to leave around the device.
device_tolerance = .05;
// How much extra space to leave around the through-hole for the plug.
through_tolerance = .1;
// How much extra space to leave around the plug.
plug_tolerance = 0;
// How much extra space to leave around the cable.
cable_tolerance = 0;

/* [Parameters] */

// Whether front and back cuts should be level relative to the base.
flat_cuts = true;

// Whether the cable should be laid into the case from the back.
open_channel = false;

// What angle to recline the phone at (from a straight-up zero degrees).
recline_angle = 15;

// The height of the dock underneath the phone.
// Should be at least as long as the plug, plus room for the cable to turn.
chin_height = 32;

wall_height = 32;
// The height of the lip in front of the device.
lip_height = 10;

// The thickness of the bottom base.
base_thickness = 5;

// The corner radius of the back corner.
base_cr = 2;

// The thickness of the walls.
wall_thickness = 3;

// The radius of the "top" corner.
side_wall_front_cr = 8;
side_wall_back_cr = 3;

back_wall_top_cr = 3;

// How wide of a gap to put in the middle of the lip (eg. for a speaker).
lip_cleft_width = 32;
// The height of the lip within the cleft (ie. beneath the speaker).
lip_cleft_height = 6;

lip_cleft_fillet = 3;
lip_cleft_bevel = 3;

/* [Rendering] */

// Epsilon value for enveloping differences
eps = 1/128;
//$fn=24;

$fa = 1;
$fs = 1;

/* [Hidden] */

/*
Assumptions in the current formulation:

- Back will have a thickness (no epsilon applied for back)
- Back will be taller than walls/lip
- Device is thicker than plug
- Chin is longer than plug
*/

device_depth_total = device_depth + 2*device_tolerance;
dock_depth = device_depth_total + 2*wall_thickness;
device_width_total = device_width + 2*device_tolerance;
dock_width = device_width_total + 2*wall_thickness;
dock_length = wall_height + chin_height;
plug_width_total = plug_width + plug_tolerance;
plug_depth_total = plug_depth + plug_tolerance;
cable_total = cable_gauge + 2*cable_tolerance;

// How much extra length the dock needs to meet the
// XY plane when angled.
chin_hem = tan(recline_angle)*dock_depth/2;

device_carveout_left = -device_width_total/2;
device_carveout_width = device_width_total;
device_carveout_above_lip_depth = device_depth_total + wall_thickness + eps;
device_carveout_above_lip_bottom = chin_height + lip_height;
device_carveout_above_lip_height = wall_height + eps;
device_carveout_cleft_height = lip_height - lip_cleft_height + eps;
plug_carveout_depth = wall_thickness + port_y_offset + device_depth_total/2;

base_length = dock_width * cos(30);

function curve_points(o,d,cw=true) =
  // number of facets for 1/4 circle ($fn if defined)
  let (n=ceil(($fn>0 ? $fn
    // if $fn is not defined, either the maximum under $fa,
    : min(360/$fa,
      // or the number of facets for $fs at this size
      max(abs(d[0]),abs(d[1])) * 2*PI/$fs)
    )/4),xy = ((d[0]>0) == (d[1]>0)) == cw)
  // for each point on the curve,
  [for (i=[(xy?0:n) : (xy?1:-1) : (xy?n:0)])
  // return its coordinate
    [o[0]+sin(90*(i/n))*d[0], o[1]+cos(90*(i/n))*d[1]]];

module round_4corners_rect(w,h,tr_r,br_r,bl_r,tl_r) {
  assert(w>=max(br_r+bl_r,tl_r+tr_r));
  assert(h>=max(tr_r+br_r,bl_r+tl_r));

  if (w>0 && h>0) polygon([
    each (tr_r > 0 ? curve_points([w/2 - tr_r, h/2 - tr_r],
      [tr_r, tr_r]) : [[w/2, h/2]]),
    each (br_r > 0 ? curve_points([w/2 - br_r, -h/2 + br_r],
      [br_r, -br_r]) : [[w/2, -h/2]]),
    each (bl_r > 0 ? curve_points([-w/2 + bl_r, -h/2 + bl_r],
      [-bl_r, -bl_r]) : [[-w/2, -h/2]]),
    each (tl_r > 0 ? curve_points([-w/2 + tl_r, h/2 - tl_r],
      [-tl_r, tl_r]) : [[-w/2, h/2]])
  ]);
}

module round_tbcorners_rect(w,h,t_r,b_r) {
  round_4corners_rect(w,h,t_r,b_r,b_r,t_r);
}
module round_lrcorners_rect(w,h,l_r,r_r) {
  round_4corners_rect(w,h,r_r,r_r,l_r,l_r);
}

module round_corner_rect(w,h,r) {
  round_4corners_rect(w,h,r,r,r,r);
}

module device_cross_section() {
  round_tbcorners_rect(device_width,device_depth,device_back_cr,device_front_cr);
}

module dock_perimeter() {
  difference() {
    offset(delta=device_tolerance + wall_thickness) device_cross_section();
    offset(delta=device_tolerance) device_cross_section();
  }
}

module dock_walls () {
  translate([0,0,-chin_hem])
  linear_extrude(chin_hem+chin_height+wall_height, convexity = 10) dock_perimeter();
}

module dock_face_common () {
  wall_cr = back_wall_top_cr;
  hull () {
    translate([-dock_width/2 + wall_cr, dock_length - wall_cr]) circle(wall_cr);
    translate([dock_width/2 - wall_cr, dock_length - wall_cr]) circle(wall_cr);
    translate([-dock_width/2, flat_cuts ? 0 : -chin_hem])
      square([dock_width,chin_height]);
  }
}

module plughole() {
  round_corner_rect(plug_width,plug_depth,plug_radius);
}

module backhole() {
  rotate([90,0,0])
  multmatrix([[1,0,0,0], [0,1,flat_cuts?-tan(recline_angle):0,0],
      [0,0,1,0],[0,0,0,1]])
  translate([port_x_offset,
    (flat_cuts ? 0 : chin_hem)+ chin_height + plug_depth/2 + through_tolerance,
    -plug_length])
  
    linear_extrude(plug_length)
    offset(delta=through_tolerance)
    plughole();
}

module throughhole() {
  through_r = plug_radius+through_tolerance;
  a = plug_width/2 - plug_radius;
  b = plug_depth/2 - plug_radius;
  hypo = sqrt(a*a+b*b);
  tilt = asin((device_depth_total/2-through_r)/hypo);
  angle = tilt-atan(b/a);
  translate([port_x_offset, port_y_offset, -chin_hem])
    linear_extrude(chin_height + chin_hem + plug_depth)
    union () {
      rotate(angle) offset(delta=through_tolerance) plughole($fn=24);
      rotate(-angle) offset(delta=through_tolerance) plughole($fn=24);
      square([cos(tilt) * 2 * (hypo+through_tolerance),device_depth_total], center=true);
    }
}

module dock_back_face() {
  difference() {
    dock_face_common();
  }
}

module fillet(r,o=eps) {
  polygon([[0,0],each curve_points([r+eps,r+eps],[-r-eps,-r-eps])]);
}

module dock_front_face() {
  difference() {
    dock_face_common();
    translate([0,flat_cuts?chin_hem:0]) {
      translate([0, chin_height+lip_height+wall_height/2+screen_cr/2])
        round_corner_rect(screen_width,wall_height+screen_cr, screen_cr);
      translate([0, chin_height+lip_height])
        round_corner_rect(lip_cleft_width,2*lip_cleft_height, lip_cleft_fillet);
      translate([lip_cleft_width/2, chin_height+lip_height]) mirror([0,1])
        fillet(lip_cleft_bevel);
      translate([-lip_cleft_width/2, chin_height+lip_height]) mirror([1,1])
        fillet(lip_cleft_bevel);
    }
  }
}

module dockblock_faces() {
  rotate([90,0,0])
    multmatrix([[1,0,0,0], [0,1,flat_cuts?-tan(recline_angle):0,0],
      [0,0,1,0],[0,0,0,1]])
    union () {
      linear_extrude(dock_depth/2)
        dock_front_face();
      mirror([0,0,1])
      linear_extrude(dock_depth/2)
        dock_back_face();
    }
}

module dock_chinfill() {
  difference () {
    translate([0,0,-chin_hem])
      linear_extrude(chin_height + chin_hem +
        max(device_front_cr, device_back_cr,device_bottom_cr))
      offset(delta=device_tolerance) device_cross_section();
    intersection () {
      rotate([90,0,90])
        translate([0,0,-dock_width/2])
        linear_extrude(dock_width + 2*eps)
          translate([0,chin_height + wall_height])
          round_lrcorners_rect(device_depth_total+2*eps,2*wall_height,
            device_front_cr,device_back_cr);
      rotate([90,0,0])
        translate([0,0,-dock_depth/2])
        linear_extrude(dock_depth + 2*eps)
          translate([0,chin_height + wall_height])
          round_corner_rect(device_width_total+2*eps,2*wall_height,
            device_bottom_cr);
    }

    // docking plug carveout in chin
    translate([port_x_offset, port_y_offset,chin_height + port_z_offset])
      mirror([0,0,1]) linear_extrude(plug_length + eps)
      offset(delta=plug_tolerance) plughole();
  }
}

module dockblock_profile () {
  hull () {
    translate([0,chin_height + wall_height/2])
      round_lrcorners_rect(dock_depth,wall_height,
        side_wall_front_cr,side_wall_back_cr);
    polygon([[-dock_depth/2,chin_height],[dock_depth/2,chin_height],
      [dock_depth/2,chin_hem],[-dock_depth/2,-chin_hem]]);
  }
}

module dockblock_bounds () {
  rotate([90,0,90])
    translate([0,0,-dock_width/2])
    linear_extrude(dock_width)
      dockblock_profile();
}

module base_footprint () {
  intersection () {
    translate([-dock_width/2, -dock_depth/2, 0])
      polygon([[dock_width/2,base_length],[dock_width,0],[0,0]]);
    union () {
      offset(delta=device_tolerance) device_cross_section();
      translate([-dock_width/2, 0, 0])
        square([dock_width,base_length - dock_depth/2 -
          sqrt(2*device_front_cr*device_front_cr)]);
      translate([0,base_length - dock_depth/2 - 2*device_front_cr])
        circle(device_front_cr);
    }
  }
}

module base_plate() {
  difference() {
    linear_extrude(base_thickness) base_footprint();
    if (open_channel) {
      linear_extrude(base_thickness)
      translate([dock_width/2 - cable_total/2 + port_x_offset, -eps])
        square([cable_total, base_length + eps]);
    }
    rotate([-recline_angle, 0, 0]) throughhole();
    rotate([90,0,0]) mirror([0,0,1]) linear_extrude(base_length) union() {
      translate([0,cable_total/2]) circle(d=cable_total);
      square(cable_total, center=true);
    }
  }
}

module dockblock() {
  difference () {
    union () {
      intersection() {
        dock_walls();
        dockblock_bounds();
        dockblock_faces();
      }
      intersection () {
        dock_chinfill();
        dockblock_bounds();
      }
    }
    throughhole();
  }
}

module dock_assembly () {
  difference () {
    rotate([-recline_angle, 0, 0]) dockblock();
    translate([0,0,-eps]) linear_extrude(base_thickness+eps) base_footprint();
  }
}

module test_dockblock() {
  intersection() {
    translate([-dock_width/2,-dock_depth/2,0]) cube([dock_width,dock_depth,40]);
    translate([0,0,-10]) dockblock();
  }
}

module cable_test() { 
  intersection() {
    base_plate();
    translate([0,20]) cylinder(r=10, h=6);
  }
}

module striping() {
  translate([-150,-150,0]) rotate([45,45,45]) for (offset=[0:2*stripe_width:200]) {
    translate([offset, 0, 0]) cube([stripe_width, 200,200]);
  }
}

module onepiece() {
  union () {
    dock_assembly();
    base_plate();
  }
}

module b_stripes() {
  union () {
    intersection () {
      dock_assembly();
      striping();
    }
  }
}

module a_stripes() {
  difference () {
    dock_assembly();
    striping();
  }
}

module test_wedge () {
  polygon([[0,0],each curve_points([0,0],[-8,-8])]);
  echo([[0,0],each curve_points([0,0],[8,8])]);
}

onepiece();

//a_stripes();
//b_stripes();
//base_plate();

//test_dockblock();
//cable_test();
//test_wedge();
