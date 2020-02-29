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
device_front_edge_bevel = 3;
// The radius of the device's back edges.
device_back_edge_bevel = 5;

// The radius of the bottom left and right corners.
device_bottom_corner_radius = 8;

// The width of the front opening for the screen.
screen_width = 72;

// The radius of the corner that will descend to the lip.
screen_corner_radius = 5.5;

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

// Whether top surfaces should be flat / parallel to the base.
level_tops = false;

// Whether the cable should be laid into the case from the back.
// (Deprecated; not currently implemented.)
open_channel = false;

// What angle to recline the phone at (from a straight-up zero degrees).
recline_angle = 15;

// The height of the dock underneath the phone.
// Should be at least as long as the plug, plus room for the cable to turn.
chin_height = 32;

// The height of the lip in front of the device.
lip_height = 10;

// The thickness of the bottom base.
base_thickness = 5;

// The corner radius of the back corner.
base_corner_radius = device_front_edge_bevel;

// The thickness of the walls.
wall_thickness = 3;

// The radius of the "top" corner.
cheek_front_edge_bevel = 8;
cheek_back_edge_bevel = 3;

// How wide of a gap to put in the middle of the lip (eg. for a speaker).
lip_cleft_width = 32;
// The height of the lip within the cleft (ie. beneath the speaker).
lip_cleft_height = 6;

lip_cleft_fillet = 3;
lip_cleft_bevel = 3;

// The height above the lip that the cheek extends around the front.
front_cheek_height = (screen_width-lip_cleft_width)/2;
front_cheek_bevel = 3;
front_top_corner_bevel = 5;
// The radius of the curve from the back to the front cheeks.
front_fillet = 2;

back_height = 50;
back_cheek_height = back_height;

back_top_corner_bevel = 3;
side_back_corner_bevel = 3;

/* [Testing] */

// The region to render when printing a test dockblock.
test_bottom = 10;
test_height = 40;

/* [Rendering] */

// Epsilon value for enveloping differences
eps = 1/128;
//$fn=24;

$fa = 1;
$fs = 1;

/* [Hidden] */

device_depth_total = device_depth + 2*device_tolerance;
dock_depth = device_depth_total + 2*wall_thickness;
device_width_total = device_width + 2*device_tolerance;
dock_width = device_width_total + 2*wall_thickness;
dock_length = back_height + chin_height;
plug_width_total = plug_width + plug_tolerance;
plug_depth_total = plug_depth + plug_tolerance;
cable_total = cable_gauge + 2*cable_tolerance;

// How much extra length the dock needs to meet the
// XY plane when angled.
chin_hem = tan(recline_angle)*dock_depth/2;

base_length = dock_width * cos(30);

function curve_points(o,d,cw=true) =
  (abs(d[0]) > 0 && abs(d[1]) > 0) ?
    // number of facets for 1/4 circle ($fn if defined)
    (let (n=ceil(($fn>0 ? $fn
      // if $fn is not defined, either the maximum under $fa,
      : min(360/$fa,
        // or the number of facets for $fs at this size
        max(abs(d[0]),abs(d[1])) * 2*PI/$fs)
      )/4),xy = ((d[0]>0) == (d[1]>0)) == cw)
    // for each point on the curve,
    [for (i=[(xy?0:n) : (xy?1:-1) : (xy?n:0)])
    // return its coordinate
      [o[0]+sin(90*(i/n))*d[0], o[1]+cos(90*(i/n))*d[1]]]) : [o];

module round_4corners_rect(w,h,tr_r,br_r,bl_r,tl_r) {
  assert(w>=max(br_r+bl_r,tl_r+tr_r));
  assert(h>=max(tr_r+br_r,bl_r+tl_r));

  if (w>0 && h>0) polygon([
    each curve_points(
      [w/2 - tr_r, h/2 - tr_r], [tr_r, tr_r]),
    each curve_points(
      [w/2 - br_r, -h/2 + br_r], [br_r, -br_r]),
    each curve_points(
      [-w/2 + bl_r, -h/2 + bl_r], [-bl_r, -bl_r]),
    each curve_points(
      [-w/2 + tl_r, h/2 - tl_r], [-tl_r, tl_r])
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
  round_tbcorners_rect(device_width,device_depth,device_back_edge_bevel,device_front_edge_bevel);
}

module dock_perimeter() {
  difference() {
    offset(delta=device_tolerance + wall_thickness) device_cross_section();
    offset(delta=device_tolerance) device_cross_section();
  }
}

module dock_walls () {
  translate([0,0,-chin_hem])
  linear_extrude(2*chin_hem+dock_length, convexity = 10) dock_perimeter();
}

module plughole() {
  round_corner_rect(plug_width,plug_depth,plug_radius);
}

module backhole() {
  rotate([90,0,0])
  multmatrix([[1,0,0,0], [0,1,level_tops?-tan(recline_angle):0,0],
      [0,0,1,0],[0,0,0,1]])
  translate([port_x_offset,
    (level_tops ? 0 : chin_hem)+ chin_height + plug_depth/2 + through_tolerance,
    -plug_length])
  
    linear_extrude(plug_length)
    offset(delta=through_tolerance)
    plughole();
}

module throughhole() {
  if (plug_width + 2*through_tolerance > device_depth_total) {
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
  } else {
    translate([port_x_offset, port_y_offset, -chin_hem])
      linear_extrude(chin_height + chin_hem + plug_depth)
        rotate(90) offset(delta=through_tolerance) plughole($fn=24);
  }
}

module dock_back_face() {
  translate([0,dock_length/2])
    round_tbcorners_rect(dock_width,dock_length,back_top_corner_bevel,0);
}

module fillet(r,o=eps) {
  polygon([[0,0],each curve_points([r+eps,r+eps],[-r-eps,-r-eps])]);
}

function reverse(a) = [for (i=[len(a)-1:-1:0]) a[i]];

function front_face_side_points(x) = [
    each curve_points(
      [x*(lip_cleft_width/2-lip_cleft_fillet),
        chin_height+lip_height-lip_cleft_fillet],
      [x*(lip_cleft_fillet),-lip_cleft_fillet],cw=x<0),
    each curve_points(
      [x*(lip_cleft_width/2+lip_cleft_bevel),
        chin_height+lip_height-lip_cleft_bevel],
      [x*(-lip_cleft_bevel),lip_cleft_bevel],cw=x>0),
    each curve_points(
      [x*(screen_width/2-screen_corner_radius),
        chin_height+lip_height+screen_corner_radius],
      [x*screen_corner_radius,-screen_corner_radius],cw=x<0),
    each curve_points(
      [x*(screen_width/2+front_cheek_bevel),
        chin_height+lip_height+front_cheek_height-front_cheek_bevel],
      [x*(-front_cheek_bevel),front_cheek_bevel],cw=x>0),
    [x*dock_width/2,chin_height+lip_height+front_cheek_height],
    [x*dock_width/2,-chin_hem]
];

module dock_front_face() {
  translate([0,level_tops?chin_hem:0]) polygon([
    each front_face_side_points(1),
    each reverse(front_face_side_points(-1))
  ]);
}

module dockblock_faces() {
  rotate([90,0,0])
    multmatrix([[1,0,0,0], [0,1,level_tops?-tan(recline_angle):0,0],
      [0,0,1,0],[0,0,0,1]])
    union () {
      linear_extrude(dock_depth/2)
        dock_front_face();
      mirror([0,0,1])
      linear_extrude(dock_depth/2)
        dock_back_face();
      // ensure full side walls for front fillet
      translate([0,0,-dock_depth/2]) linear_extrude(dock_depth) {
        translate([-dock_width/2,0])
          square([wall_thickness,dock_length-back_top_corner_bevel]);
        translate([dock_width/2-wall_thickness,0])
          square([wall_thickness,dock_length-back_top_corner_bevel]);
      }
    }
}

module dock_chinfill() {
  difference () {
    translate([0,0,-chin_hem])
      linear_extrude(chin_height + chin_hem +
        max(device_front_edge_bevel, device_back_edge_bevel,device_bottom_corner_radius))
      offset(delta=device_tolerance) device_cross_section();
    intersection () {
      rotate([90,0,90])
        translate([0,0,-dock_width/2])
        linear_extrude(dock_width + 2*eps)
          translate([0,dock_length])
          round_lrcorners_rect(device_depth_total+2*eps,2*back_height,
            device_front_edge_bevel,device_back_edge_bevel);
      rotate([90,0,0])
        translate([0,0,-dock_depth/2])
        linear_extrude(dock_depth + 2*eps)
          translate([0,chin_height + back_height])
          round_corner_rect(device_width_total+2*eps,2*back_height,
            device_bottom_corner_radius);
    }

    // docking plug carveout in chin
    translate([port_x_offset, port_y_offset,chin_height + port_z_offset])
      mirror([0,0,1]) linear_extrude(plug_length + eps)
      offset(delta=plug_tolerance) plughole();
  }
}

module dockblock_profile () {
  polygon([
    [dock_depth/2,level_tops?0:chin_hem],
    [-dock_depth/2,level_tops?0:-chin_hem],
    each curve_points(
      [-dock_depth/2+front_cheek_bevel,chin_height+lip_height+front_cheek_height-front_cheek_bevel],
      [-front_cheek_bevel,front_cheek_bevel], cw=true),
    each curve_points(
      [-front_fillet,chin_height+lip_height+front_cheek_height+front_fillet],
      [front_fillet,-front_fillet],cw=false),
    each curve_points(
      [front_top_corner_bevel,dock_length-front_top_corner_bevel],
      [-front_top_corner_bevel,front_top_corner_bevel],cw=true),
    each curve_points(
      [dock_depth/2-side_back_corner_bevel,dock_length-side_back_corner_bevel],
      [side_back_corner_bevel,side_back_corner_bevel],cw=true)
    ]);
}

module dockblock_bounds () {
  multmatrix([[1,0,0,0], [0,1,0,0],
    [0,level_tops?tan(recline_angle):0,1,0],[0,0,0,1]])
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
          sqrt(2*device_front_edge_bevel*device_front_edge_bevel)]);
      translate([0,base_length - dock_depth/2 - 2*device_front_edge_bevel])
        circle(base_corner_radius);
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
    translate([-dock_width/2,-dock_depth/2,0])
      cube([dock_width,dock_depth,test_height]);
    translate([0,0,-test_bottom]) dockblock();
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

/* Single-material model */
onepiece();

/* Multi-material model */
//a_stripes();
//b_stripes();
//base_plate();

/* Test pieces */
//test_dockblock();
//cable_test();
