// File: PumpBoat.scad
// Copyright Robert L. Read, 2025
// Released under CERN Strong-reciprocal Open Hardware License

// An attempt to make the simplest ferrofluid pump I can imagine.
// The idea is place a switch electromagnent on a "boat" 
// that floats on a "sea" of ferrofluid.
// The magnet raises ferrofluid.
// When the magnet is switched off, the fluid falls
// onto a ramp which causes the fluid to flow in one direction.

// This pump will raise the fluid only about 1cm, so obviously
// it will be a low-pressure pump, with relatively low flow.
// Nonetheless, I believe it is intriguing as a pump that 
// has no moving parts.


// Here are some major parameters:
// (all sizes in mm)
magnet_weight_g = 40; // this needs to be measured.
fluid_density_g_cm3 = 1.3; // this is just a typical value
material_density_g_cm3 = 1.05; // typical resin print density
neutral_buoyancy_volume_cm3 = magnet_weight_g/(fluid_density_g_cm3 - material_density_g_cm3);
echo(neutral_buoyancy_volume_cm3);
adjusted_buoyancy_volume_cm3 = neutral_buoyancy_volume_cm3*1.25;
boat_r = 25; // boat radius.
boat_r_cm = boat_r/10;
boat_area_cm2 = PI*boat_r_cm*boat_r_cm;
boat_h = adjusted_buoyancy_volume_cm3 / boat_area_cm2;
echo(boat_h);

fluid_port_r = 2; // hole for fluid
port_displacement = 2; // position of hole
magnet_diameter = 6.25+0.25;
magnet_radius = magnet_diameter/2; // radius of magnet cylinders
gap_width = 6.25; // gap in the magnet

magnet_center_height = magnet_radius;
chute_wall = 2;
ramp_height = magnet_radius;
ramp_length = boat_r+port_displacement;
chute_inner_w = gap_width;
ramp_displacement = magnet_radius/2;
chute_height = magnet_radius*2;
chute_length = ramp_length + magnet_radius;

$fn = 60;

module boat() {
    translate([0,0,-boat_h/2])
    difference() {
        cylinder(h = boat_h,r = boat_r,center=true);
        translate([-port_displacement,0,0])
        cylinder(h = boat_h+1,r = fluid_port_r,center=true);
    }
}

module chute() {
    h = chute_height;
    l = chute_length;
    w = chute_inner_w+chute_wall*2;
    color("pink")
    translate([l/2+-magnet_radius+-port_displacement,0,h/2])
    difference() {
        cube([l,w,h],center=true);
        translate([chute_wall,0,0])
        cube([l,chute_inner_w,h+1],center=true);
        translate([-l/2+chute_wall+magnet_radius,0,0])
        rotate([90,0,0])
        cylinder(h=w*10,r = magnet_radius,center=true);
        translate([-l/2+chute_wall+magnet_radius,0,h/2])
        cube([magnet_radius*2,w+1,h],center=true);
    }
}

module ramp() {
    color("blue")
    translate([-ramp_displacement,0,0]) {
    rotate([90,0,0])
        linear_extrude(height=chute_inner_w,center=true)
        polygon(points = [[port_displacement,0],[0,ramp_height],[ramp_length,0]]);
    }
}

module pump() {
    boat();
    chute();
    ramp();
}

pump();