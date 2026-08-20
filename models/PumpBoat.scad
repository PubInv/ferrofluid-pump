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

include <tray.scad>


PB_VERSION = "0.0.4";


// Here are some major parameters:
// (all sizes in mm)
magnet_weight_g = 40; // this needs to be measured.
fluid_density_g_cm3 = 1.3; // this is just a typical value
material_density_g_cm3 = 1.05; // typical resin print density
neutral_buoyancy_volume_cm3 = magnet_weight_g/(fluid_density_g_cm3 - material_density_g_cm3);
echo(neutral_buoyancy_volume_cm3);
adjusted_buoyancy_volume_cm3 = neutral_buoyancy_volume_cm3*1.25;
boat_w = 60;

boat_y = 50;
boat_w_cm = boat_w/10;
boat_y_cm = boat_y/10;
boat_area_cm2 = boat_w_cm*boat_y_cm;
boat_h = 12;

fluid_port_r = 2; // hole for fluid
port_displacement = 2; // position of hole
magnet_diameter = 6.25+0.25;
magnet_radius = magnet_diameter/2; // radius of magnet cylinders
gap_width = 6.25; // gap in the magnet

magnet_center_height = magnet_radius;
number_of_magnets = 4;
chute_wall = 2;
ww = 2; // this is the general wall width
ramp_height = magnet_radius;
// This has to fit inside or magnet..
ramp_length_max = 18;
ramp_length = min(boat_y/2+port_displacement,ramp_length_max);
chute_inner_w = gap_width;
ramp_displacement = magnet_radius/2;
chute_height = magnet_radius*2;
chute_length = ramp_length + magnet_radius;

chimney_height = 45;
chimney_length = (ramp_length+ww*2);

boat_disp_x = boat_w/2 - chimney_length ;

barb_radius = 2.5;
barb_height = 6;
number_of_barbs = 4;
total_barb_length = barb_height * number_of_barbs;
barb_depth = 2;
barb_outer_radius = barb_radius + barb_depth;

$fn = 60;

USE_CHAMBER=0;

USE_VERTICAL_KNIFE = 0;
USE_LID = 0;
SHOW_PUMP = 1;
SHOW_INLET_TRAY = 1;
SHOW_OUTLET_TRAY = 0;

boat_lip_wall = ww;
boat_lip_height = 2*barb_depth + 1;
boat_lip_outlet_overlap = 0.6;
boat_lip_outlet_flow_w = (gap_width - ww)-1;
boat_lip_outlet_cut_w = max(
    boat_lip_outlet_flow_w,
    gap_width - 2*boat_lip_outlet_overlap
);
inlet_port_x = 0;
inlet_barb_floor_clearance = 3;
inlet_port_z = -boat_h + inlet_barb_floor_clearance + barb_outer_radius;
inlet_channel_inner_y = 0;
inlet_channel_outer_y = boat_y/2 + barb_depth;
inlet_channel_length = inlet_channel_outer_y - inlet_channel_inner_y;
inlet_channel_center_y = (inlet_channel_inner_y + inlet_channel_outer_y)/2;
inlet_barb_base_y = boat_y/2;

chamber_volume_mm3 = 231000;
safety_factor = 1.5;
chamber_radius_mm = 50;
chamber_height_mm = chamber_volume_mm3*safety_factor/(PI*chamber_radius_mm^2);
chamber_wall_mm = 2;

module barb(radius, height, barb_depth) {
    rotate_extrude()
    polygon(points=[
        [radius, 0.0],
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

module barb1(radius, height, barb_depth) {
    rotate_extrude()
    polygon(points=[
        [radius, 0.0],
        [radius + barb_depth, height],
        [radius, height],
        [radius + barb_depth, 2*height],
        [radius, 2*height],
        [radius + barb_depth, 3*height],
        [radius, 3*height],
        [radius + barb_depth, 4*height],
        [radius-0.5, 3.3*height], // Inner wall
        [radius-0.5, 0]
    ]);  
}

module boat_lip() {
    difference() {
        translate([0, 0, boat_lip_height/2])
        cube([boat_w, boat_y, boat_lip_height], center = true);

        translate([0, 0, boat_lip_height/2])
        cube(
            [
                boat_w - 2*boat_lip_wall,
                boat_y - 2*boat_lip_wall,
                boat_lip_height + 1
            ],
            center = true
        );
    }
}

module boat_lip_outlet_cut() {
    translate([boat_w/2 - boat_lip_wall/2, 0, boat_lip_height/2])
    cube(
        [
            boat_lip_wall*4,
            boat_lip_outlet_cut_w,
            boat_lip_height + 0.1
        ],
        center = true
    );
}

module boat() {

    difference() {
        translate([-boat_disp_x,0,0])
        difference() {
            union() {
                translate([0,0,-boat_h/2])
                cube([boat_w, boat_y, boat_h], center = true);

                boat_lip();
            }

            boat_lip_outlet_cut();
        }
            // now remove a sphere fluid reservoir
        reservoir_h = 4.5;
        sphere_mm = 3.3;
        translate([0,0,-reservoir_h/2])
        cylinder(h = reservoir_h, r = sphere_mm, center=true);
        
        translate([0,0,-sphere_mm])
        sphere(r = sphere_mm);
    }
}

module chute() {
    h = chute_height;
    l = chute_length;
    w = chute_inner_w+chute_wall*2;
    echo("chute_inner_w");
    echo(chute_inner_w);
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
    echo("magnet_fraction");
    echo(magnet_fraction);
    ramp_height = number_of_magnets*(magnet_radius*2) -magnet_radius;
    echo("ramp_height");
    echo(ramp_height);
    Am = [ magnet_fraction,0 ];
    A = [0,magnet_fraction/2];
    B = [A[0],ramp_height];
    w = 1;
    Bp = [w,ramp_height];
    lock_avoidance_height = magnet_radius*2+1;
    lock_avoidance_width = magnet_radius/2; 
    C = [lock_avoidance_width,lock_avoidance_height];
    transport_ramp_width = C[0]+magnet_radius*(1/4);
    transport_ramp_height = C[1]/3;
    D = [transport_ramp_width,transport_ramp_height];
    E = [ramp_length/2,0];
  
    color("white")
    translate([1+-(ramp_displacement),0,-1]) 
    rotate([90,0,0])
    linear_extrude(height=chute_inner_w,center=true)
    offset(r=0.1) {
        polygon(points = [Am,A,B,Bp,C,D,E]);
    }
}

module diode_ramp() {
}

module inlet_channel_cut() {
    translate([inlet_port_x, inlet_channel_center_y, inlet_port_z])
    rotate([90,0,0])
    cylinder(h = inlet_channel_length, r = fluid_port_r, center = true);
}

module inlet_barb() {
    translate([inlet_port_x, inlet_barb_base_y + total_barb_length, inlet_port_z])
    rotate([90,0,0])
    barb(barb_radius , barb_height, barb_depth);
}

module pump() {
    difference(){
        boat();
        inlet_channel_cut();
    }
    chute();
    ramp();
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

    
// 
module outlet_ramp(gap, d, ww = 2) {
    color("orange");
    gap_adjustment = 2;

    translate([chimney_length/2-(magnet_radius+chute_wall), 0, chimney_height/2 ])
    difference() {
        cube([chimney_length, gap, chimney_height], center = true);
        // cut away inner part of chimney
        cube([chimney_length-ww*2, (gap - ww)-1, chimney_height + 1], center = true);
        // now cut away a port for so the flow can reach the outlet.
        translate([chimney_length/2,0,-chimney_height/2+barb_depth])
        rotate([0,90,0])       
        cylinder(h=barb_depth*3,r1=barb_radius*0.8,r2= barb_radius*0.8,center = true);
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

module chamber(gap, d, ww = 2){
    chamber_side = chimney_length/2-(magnet_radius+chute_wall);

    difference(){
        translate([chamber_side,0,chimney_height])
            cylinder(chamber_height_mm,r=chamber_radius_mm);
            
        translate([chamber_side,0,chimney_height+chamber_wall_mm])    
            cylinder(chamber_height_mm-2*chamber_wall_mm,r=chamber_radius_mm-chamber_wall_mm);
        
    translate([chamber_side, 0, chimney_height])
        cube([chimney_length-ww*2, (gap - ww)-1, 2*chamber_wall_mm], center = true);
  }
}

module outlet_barb() {
    /* Outlet */
    rotate([90,0,-90])
    translate([0,2,ww*2-(total_barb_length+ramp_length)]) 
    barb(barb_radius , barb_height, barb_depth);
    // now we will fill this space to make sure
    // the outlet port forces the ferfffluid away
}

module outlet_fill() {
    h = ramp_length+barb_height*2+3.5;
    translate([h/2+magnet_diameter-3,0,barb_radius-0.5])
    difference() {
        rotate([0,90,0])
        cylinder(h = h,r = barb_radius,center = true); 
        translate([0,0,-51])
        cube([h*2,100,100],center=true);
        translate([-h/2+3,0,-1])
        rotate([0,90,0])
        cylinder(h = magnet_diameter,r1 = barb_radius*2, r2 = 0,center = true); 
    }
    A = [0,0];
    B = [ramp_length/2+0.5,0];
    C = [ramp_length/2+0.5,barb_radius];
    translate([ramp_length/3-0.8,0,barb_radius*1.75])
    #rotate([90,0,0])
    linear_extrude(height = magnet_diameter,center=true)
    polygon(points = [A,B,C]);
}

module completePump() {
    pump();
    if (USE_CHAMBER) {
        chamber(gap_width,magnet_diameter);
    }

    outlet_ramp(gap_width,magnet_diameter);
    magnet_holders();
    /*dx: -7.61078  dy: -4.44922  dz: 0*/
    /* Inlet */
    /* TODO: This needs to be made a module, and 
    all the magic numbers removed */
    inlet_barb();
    outlet_barb();
    outlet_fill();
}
module outlet_tray() {
    // This should center us
    x = 40;
    y = 40;
    z = 9;
    translate([-x/2,-y/2,-z/2])
    tray([x,y,z], thickness=2, bottom_thickness=2);
}

module inlet_tray() {
    x = 40;
    y = 60;
    z = 25;
    translate([-x/2,-y/2,-barb_outer_radius*2-1])
    difference() {
        tray([x,y,z], thickness=2, bottom_thickness=2);
        //now cut a part away so that the hole in the barb is not obstruced.
        translate([(x+-barb_outer_radius*2)/2,-3,3])
        cube([barb_outer_radius*2,10,barb_outer_radius*2]);
    }
}

if (SHOW_OUTLET_TRAY) {
    translate([43,0,-8])
    outlet_tray();
}
if (SHOW_INLET_TRAY) {
    translate([0,(boat_y+60)/2 + -0.5,-2])
    inlet_tray();
}

if (SHOW_PUMP) {
    if (USE_VERTICAL_KNIFE) {
        difference() {
            completePump();
            translate([0,-100,0])
            cube([200,200,200],center=true);
        }
    } else {
        completePump();
    }
}


// completePump();
