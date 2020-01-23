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
screen_width = 70;

// The radius of the corner that will descend to the lip.
screen_cr = 6;

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
cable_gauge = 4.6;

/* [Tolerances] */

// How much extra space to leave around the device.
device_tolerance = 0;
// How much extra space to leave around the through-hole for the plug.
through_tolerance = 1;
// How much extra space to leave around the plug.
plug_tolerance = 0.1;
// How much extra space to leave around the cable.
cable_tolerance = 0;

/* [Parameters] */

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

lip_cleft_inside_fillet = 3;
lip_cleft_outside_fillet = 3;

/* [Rendering] */

// Epsilon value for enveloping differences
eps = 1/128;
$fn = 30;

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

module plughole() {
  round_corner_rect(plug_width,plug_depth,plug_radius);
}

module round_4corners_rect(w,h,tr_r,br_r,bl_r,tl_r) {

  // assuming all round corners and no corners with a diameter
  // greater than a dimension of the rect
  assert(min(w,h)>=2*max(tr_r,br_r,bl_r,tl_r));
  assert(0<max(tr_r,br_r,bl_r,tl_r));

  // a simple hulling variant (ie. passing first condition/assumption)
  // that could handle square corners (ie. failing second test)
  // could do this test
  //assert(min(w,h)>=max(tr_r+br_r,br_r+bl_r,bl_r+tl_r,tl_r+tr_r))
  // it could be still used safely with the 2-circle-and-square path,
  // because all 4 corners need to be equal for those

  // note that these tests assume we don't have any
  // diameter-greater-than-dimension corners
  if (h==tl_r+bl_r && h==tr_r+br_r) hull () {
    translate([-w/2 + tr_r, 0]) circle(tr_r);
    translate([w/2 - tr_r, 0]) circle(tr_r);
  }
  else if (w==tl_r+tr_r && w==bl_r+br_r) hull () {
    translate([0,-h/2 + tr_r]) circle(tr_r);
    translate([0,h/2 - tr_r]) circle(tr_r);
  } else hull() {
    translate([w/2-tr_r,h/2-tr_r]) circle(tr_r);
    translate([w/2-br_r,-h/2+br_r]) circle(br_r);
    translate([-w/2+bl_r,-h/2+bl_r]) circle(bl_r);
    translate([-w/2+tl_r,h/2-tl_r]) circle(tl_r);
  }
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
    offset(r=device_tolerance + wall_thickness) device_cross_section();
    offset(r=device_tolerance) device_cross_section();
  }
}

module dock_walls () {
  translate([0,0,-chin_hem])
  linear_extrude(chin_hem+chin_height+wall_height, convexity = 10) dock_perimeter();
}

// TODO: Consider a "flat cuts" option to intersect a (scaled) projection
//   of the front and back extruded along the Y axis, so that the edge is
// all printed as one layer
// (not counting any curves, eg. along the XZ or YZ axis, of course)
// (ie. you'd have to be careful to put in certain contours on the
// side intersections to prevent angles from becoming even pointer than
// 90 degree blunt corners/edges this way

// Maybe it just uses some kind of skew matrix

flat_cuts = true;

module dock_face_common () {
  wall_cr = back_wall_top_cr;
  hull () {
    translate([-dock_width/2 + wall_cr, dock_length - wall_cr]) circle(wall_cr);
    translate([dock_width/2 - wall_cr, dock_length - wall_cr]) circle(wall_cr);
    translate([-dock_width/2, flat_cuts ? 0 : -chin_hem])
      square([dock_width,chin_height]);
  }
}

module backhole() {
  rotate([90,0,0])
  multmatrix([[1,0,0,0], [0,1,flat_cuts?-tan(recline_angle):0,0],
      [0,0,1,0],[0,0,0,1]])
  translate([port_x_offset,
    (flat_cuts ? 0 : chin_hem)+ chin_height + plug_depth/2 + through_tolerance,
    -plug_length])
  
    linear_extrude(plug_length)
    offset(r=through_tolerance)
    plughole();
}

module dock_back_face() {
  difference() {
    dock_face_common();
    translate([0,flat_cuts?0:chin_hem]) {
      translate([-cable_total/2 + port_x_offset, -chin_hem]) 
        square([cable_total, chin_height+chin_hem+eps]);
    }
  }
}

module fillet(r,o=eps) {
  difference() {
    translate([-o,-o]) square(r+o);
    translate([r,r]) circle(r);
  }
}

module dock_front_face() {
  difference() {
    dock_face_common();
    translate([0,flat_cuts?chin_hem:0]) {
      translate([0, chin_height+lip_height+wall_height/2+screen_cr/2])
        round_corner_rect(screen_width,wall_height+screen_cr, screen_cr);
      translate([0, chin_height+lip_height])
        round_corner_rect(lip_cleft_width,2*lip_cleft_height, lip_cleft_inside_fillet);
      translate([lip_cleft_width/2, chin_height+lip_height]) mirror([0,1])
        fillet(lip_cleft_outside_fillet);
      translate([-lip_cleft_width/2, chin_height+lip_height]) mirror([1,1])
        fillet(lip_cleft_outside_fillet);
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
      offset(r=device_tolerance) device_cross_section();
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
    // cable track carveout
    translate([0,0,-chin_hem]) linear_extrude(chin_height + chin_hem + plug_depth)
      translate([port_x_offset, port_y_offset-cable_total/2 + dock_depth/2]) 
      round_corner_rect(cable_total, dock_depth, cable_total/2);
    // docking plug carveout in chin
    translate([port_x_offset, port_y_offset,chin_height + port_z_offset])
      mirror([0,0,1]) linear_extrude(plug_length + eps)
      offset(r=plug_tolerance) plughole();
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

module dockblock() {
  rotate([-recline_angle, 0, 0]) difference () {
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
    backhole();
  }
}

module base() {
  difference() {
  translate([-dock_width/2, -dock_depth/2, 0]) linear_extrude(base_thickness)
    difference() {
        polygon([[dock_width/2,base_length],[dock_width,0],[0,0]]);
      
      // delete any part of the base that may extend out the front
      square([dock_width, dock_depth]);
      
      translate([dock_width/2 - cable_total/2 + port_x_offset, -eps])
        square([cable_total, base_length + eps]);
    }
    rotate([-recline_angle, 0, 0]) dockblock_bounds();
  }
}

module test_dockblock() {
  intersection() {
    translate([-dock_width/2,-dock_depth/2,0]) cube([dock_width,dock_depth,30]);
    translate([0,0,-25]) new_dockblock();
  }
}

module striping() {
  translate([-150,-150,0]) rotate([45,45,45]) for (offset=[0:2*stripe_width:200]) {
    translate([offset, 0, 0]) cube([stripe_width, 200,200]);
  }
}

module onepiece() {
  union () {
    dockblock();
    base();
  }
}

module b_stripes() {
  union () {
    intersection () {
      dockblock();
      striping();
    }
  }
}

module a_stripes() {
  difference () {
    dockblock();
    striping();
  }
}

onepiece();
//a_stripes();
//b_stripes();
//base();

//test_dockblock();
