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
number_of_magnets = 3;
chute_wall = 2;
ww = 2; // this is the general wall width
ramp_height = magnet_radius;
// This has to fit inside or magnet..
ramp_length_max = 18;
ramp_length = min(boat_r+port_displacement,ramp_length_max);
chute_inner_w = gap_width;
ramp_displacement = magnet_radius/2;
chute_height = magnet_radius*2;
chute_length = ramp_length + magnet_radius;

chimney_height = 45;

barb_radius = 2.5;
barb_height = 6;
barb_depth = 2;

$fn = 60;

USE_VERTICAL_KNIFE = 0;
USE_LID = 0;


module barb(radius, height, barb_depth) {
    rotate_extrude()
    polygon(points=[
        [radius, 0],
        [radius + barb_depth, height],
        [radius, height],
        [radius + barb_depth, 2*height],
        [radius, 2*height],
        [radius + barb_depth, 3*height],
        [radius, 3*height],
        [radius + barb_depth, 4*height],
        [radius-0.5, 4*height], // Inner wall
        [radius-0.5, 0]
    ]);  
}

module boat() {
    translate([0,0,-boat_h/2])
    difference() {
        cylinder(h = boat_h,r = boat_r,center=true);
        translate([-port_displacement+0.5,0,5.7])
        cylinder(h = boat_h+1,r = fluid_port_r,center=true);    
    }
}

module chute() {
    h = chute_height;
    l = chute_length;
    w = chute_inner_w+chute_wall*2;
    color("red")
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

module old_ramp() {
    color("blue")
    translate([-ramp_displacement,0,0]) {
    rotate([90,0,0])
        linear_extrude(height=chute_inner_w,center=true)
        polygon(points = [[port_displacement,0],[0,ramp_height],[ramp_length,0]]);
    }
}
/* 
In this new model, the outlet ramp consists of three sections: a 1) "wall" that is strongly in the magnet field separating 
the inlet from outlet,
    2) ramp section designed to keep the fluid away from the 
permanent locking magnet and 
    3) a weaker slope to drive the fluid away from the magnets when they are turned off, so they won't suck the fluid back from the outlet.
    This has dimensions:
    magnet_fraction = A fraction of the magnet radius, an adjustable parameter
    ramp_height = a height, likely the expected height of the highest magnet
    lock_avoidance_height = height high enough to get the fluid away form the permanent lock
    lock_avoidance_width = the horizontal displacement used to 
    avoid the magnet, and give thickness to the higher parts
    transport_ramp_height = height of gentle_ramp
    
    
    This can be defined with 5 points as polygon:
    Ax = the origin - magnet_fraction
    Ay = 0
    Bx = Ax
    By = ramp_height
    Cx = lock_avoidance_width
    Cy = lock_avoidance_height
    Dx = Transport_ramp_width
    Dy = transport_ramp_height
    Ex = ramp_width outlet
    
    
*/
module ramp() {
    magnet_fraction = magnet_radius*0.75;
    ramp_height = number_of_magnets*(magnet_radius*2) -magnet_radius;
    A = [0,-magnet_fraction];
    B = [A[0],ramp_height];
    lock_avoidance_height = magnet_radius*2+1;
    lock_avoidance_width = magnet_radius+1; 
    C = [lock_avoidance_width,lock_avoidance_height];
    transport_ramp_width = C[0]+magnet_radius;
    transport_ramp_height = C[1]/2;
    D = [transport_ramp_width,transport_ramp_height];
    E = [ramp_length,0];
  
    color("blue")
    translate([-ramp_displacement,0,0]) {
    rotate([90,0,0])
        linear_extrude(height=chute_inner_w,center=true)
        polygon(points = [A,B,C,D,E]);
    }
}

inlet_translation_vector = [-2.8,-0.1,-4];
module pump() {
    difference(){
        boat();
        translate(inlet_translation_vector)
        rotate([-30,90,0]) 
        cylinder(h = 33,r = 2);
    }
    chute();
    ramp();
}

module chimney(gap, d, ww = 2){
    color("orange");
    gap_adjustment = 2;
    translate([0, 0, chimney_height/2])
    difference() {
        cube([d + 2*ww, gap, chimney_height], center = true);
        // cut away inner part of chimney
        cube([d, (gap - ww)-1, chimney_height + 1], center = true);
    
    // cutaway outlet opening.
        translate([(d + 2*ww)/2, 0, -chimney_height/2 + 1])
        cube([ww*2+0.1, gap, d], center = true);
   }
     
     // lid 
    if (USE_LID) {
        translate([0,0,chimney_height +  ww/2])
        difference() {
            cube([d + 2*ww, gap, ww], center = true);
            cylinder(chimney_height,r=ww/3,center=true); 
        }
    }
}

module magnet_holders(){
    //when looking from +x, top right
    color("green")
    translate([-(magnet_radius+chute_wall), gap_width/2, 0])
    cube([chute_wall, chute_wall, chimney_height]);
    
    //top left
    color("green")
    translate([-(magnet_radius+chute_wall), -(gap_width/2+chute_wall), 0])
    cube([chute_wall, chute_wall, chimney_height]);
    
    //bottom left
    color("green")
    translate([+(magnet_radius), -(gap_width/2+chute_wall), 0])
    cube([chute_wall, chute_wall, chimney_height]);
    
    //bottom right
    color("green")
    translate([+(magnet_radius), (gap_width/2), 0])
    cube([chute_wall, chute_wall, chimney_height]);
}



//module closeramp(){
//    translate([chute_wall*2, -2*chute_wall, chute_wall*3])
//    cube([ramp_length-6, chute_wall*4, chute_wall/1.5]);
//    
//    difference(){
//        translate([chute_length-7.25, -chute_inner_w/2, 0])
//        cube([chute_wall, chute_inner_w, chute_height]);
//        rotate([0, 90, 0])
//        translate([-2, 0, chute_length-(chute_wall*4)])
//        cylinder(chute_wall*3, r=2);
//        }
//    }
    
// 
module outlet_ramp(gap, d, ww = 2) {
    color("orange");
    gap_adjustment = 2;
    x = (ramp_length+ww*2);
    translate([x/2-(magnet_radius+chute_wall), 0, chimney_height/2 ])
    difference() {
        cube([x, gap, chimney_height], center = true);
        // cut away inner part of chimney
        cube([x-ww*2, (gap - ww)-1, chimney_height + 1], center = true);
        // now cut away a port for so the flow can reach the outlet.
        translate([x/2,0,-chimney_height/2+barb_depth])
        cube([ww*2,(gap-ww)-1,barb_depth*2],center = true);
    
    // cutaway outlet opening.
 //       translate([(d + 2*ww)/2, 0, -chimney_height/2 + 1])
  //      cube([ww*2+0.1, gap, d], center = true);
   }
     
     // lid 
    if (USE_LID) {
        translate([0,0,chimney_height +  ww/2])
        difference() {
            cube([d + 2*ww, gap, ww], center = true);
            cylinder(chimney_height,r=ww/3,center=true); 
        }
    }
}



module completePump() {
    pump();

    outlet_ramp(gap_width,magnet_diameter);
 //   chimney(gap_width, magnet_diameter);
    magnet_holders();
    /*dx: -7.61078  dy: -4.44922  dz: 0*/
    /* Inlet */
    /* TODO: This needs to be made a module, and 
    all the magic numbers removed */
    translate([-0.7,0.7,0])
    translate([2*(boat_r)-8,2*14.5-4.65,-4]) rotate([150,90,0])
    barb(barb_radius , barb_height, barb_depth); // Barb
    /* Outlet */
    rotate([90,0,-90])
    translate([0,2,ww*2-(barb_height*4+ramp_length)]) 
    barb(barb_radius , barb_height, barb_depth);
}

if (USE_VERTICAL_KNIFE) {
    difference() {
        completePump();
        translate([-80,-100,97])
        cube([200,200,200],center=true);
    }
} else {
    completePump();
}


// completePump();