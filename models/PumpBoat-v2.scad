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
boat_r = 25; // original boat radius, still used by older placement math.
boat_x = 2*boat_r;
boat_y = 2*boat_r;
boat_x_cm = boat_x/10;
boat_y_cm = boat_y/10;
boat_area_cm2 = boat_x_cm*boat_y_cm;
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
number_of_barbs = 4;
total_barb_length = barb_height * number_of_barbs;
barb_depth = 2;
barb_outer_radius = barb_radius + barb_depth;

$fn = 60;

USE_VERTICAL_KNIFE = 0;
USE_LID = 0;
SHOW_PUMP = 1;
SHOW_TRAY = 0;
SHOW_INLET_TRAY = 1;
SHOW_OUTLET_TRAY = 1;
SHOW_FLUID_VOLUME = 0;
TRAY_ONLY = 0;
TRAY_PART = 0; // 0 = both trays, 1 = inlet tray, 2 = outlet tray

tray_wall = 2;
tray_floor = 2;
tray_freeboard = 4;
tray_clearance = 6;
tray_bottom_clearance = 3;
tray_inner_r = 2*boat_r + tray_clearance;
tray_outer_r = tray_inner_r + tray_wall;
tray_fluid_depth = boat_h + tray_bottom_clearance;
tray_total_h = tray_fluid_depth + tray_floor + tray_freeboard;
outlet_tray_angle = 60;
outlet_tray_direction = -12;
tray_joint_gap = 0.4;
tray_split_r = boat_r + tray_clearance/2;
inlet_tray_cut_r = tray_split_r - tray_joint_gap/2;
outlet_tray_inner_r = tray_split_r + tray_joint_gap/2;
tray_side_wall_angle = tray_wall*180/(PI*tray_split_r);
tray_arc_steps = 24;
outlet_edge_relief_angle = 24;
outlet_edge_relief_direction = 0;
outlet_edge_lip_z = 0;
boat_lip_wall = ww;
boat_lip_height = 2*barb_depth + 1;
boat_lip_outlet_overlap = 0.5;
boat_lip_outlet_flow_w = (gap_width - ww)-1;
boat_lip_outlet_cut_w = max(
    boat_lip_outlet_flow_w,
    gap_width - 2*boat_lip_outlet_overlap
);
inlet_port_x = 0;
inlet_barb_floor_clearance = 1;
inlet_port_z = -boat_h + inlet_barb_floor_clearance + barb_outer_radius;
inlet_channel_inner_y = 0;
inlet_channel_outer_y = boat_y/2 + barb_depth;
inlet_channel_length = inlet_channel_outer_y - inlet_channel_inner_y;
inlet_channel_center_y = (inlet_channel_inner_y + inlet_channel_outer_y)/2;
inlet_barb_base_y = boat_y/2;


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

module boat_lip() {
    difference() {
        translate([0, 0, boat_lip_height/2])
        cube([boat_x, boat_y, boat_lip_height], center = true);

        translate([0, 0, boat_lip_height/2])
        cube(
            [
                boat_x - 2*boat_lip_wall,
                boat_y - 2*boat_lip_wall,
                boat_lip_height + 1
            ],
            center = true
        );
    }
}

module boat_lip_outlet_cut() {
    translate([boat_x/2 - boat_lip_wall/2, 0, boat_lip_height/2])
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
        union() {
            translate([0,0,-boat_h/2])
            cube([boat_x, boat_y, boat_h], center = true);

            boat_lip();
        }

        translate([-port_displacement+0.5,0,5.7])
        cylinder(h = boat_h+1,r = fluid_port_r,center=true);

        boat_lip_outlet_cut();
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
    inlet_barb();
    /* Outlet */
    rotate([90,0,-90])
    translate([0,2,ww*2-(total_barb_length+ramp_length)]) 
    barb(barb_radius , barb_height, barb_depth);
}

function arc_points(r, start_angle, end_angle, steps) =
    [for (i = [0:steps])
        let (a = start_angle + (end_angle - start_angle)*i/steps)
        [r*cos(a), r*sin(a)]];

module sector_2d(r, angle, direction = 0, steps = tray_arc_steps) {
    polygon(points = concat(
        [[0, 0]],
        arc_points(r, direction - angle/2, direction + angle/2, steps)
    ));
}

module annular_sector_2d(
    outer_r,
    inner_r,
    angle,
    direction = 0,
    steps = tray_arc_steps
) {
    polygon(points = concat(
        arc_points(outer_r, direction - angle/2, direction + angle/2, steps),
        arc_points(inner_r, direction + angle/2, direction - angle/2, steps)
    ));
}

module tray_shell() {
    difference() {
        translate([0, 0, -tray_fluid_depth - tray_floor])
        linear_extrude(height = tray_total_h)
        children(0);

        translate([0, 0, -tray_fluid_depth])
        linear_extrude(height = tray_fluid_depth + tray_freeboard + 1)
        children(1);
    }
}

module tray_fluid() {
    color([0, 0.12, 0.12, 0.35])
    translate([0, 0, -tray_fluid_depth])
    linear_extrude(height = tray_fluid_depth)
    children(0);
}

module lowered_outlet_edge_cut(inner_r, outer_r) {
    translate([0, 0, outlet_edge_lip_z])
    linear_extrude(height = tray_freeboard - outlet_edge_lip_z + 1)
    annular_sector_2d(
        outer_r,
        inner_r,
        outlet_edge_relief_angle,
        outlet_edge_relief_direction
    );
}

module inlet_tray_footprint() {
    difference() {
        circle(r = tray_outer_r);
        annular_sector_2d(
            tray_outer_r + 1,
            inlet_tray_cut_r,
            outlet_tray_angle,
            outlet_tray_direction
        );
    }
}

module inlet_tray_cavity() {
    difference() {
        circle(r = tray_inner_r);
        annular_sector_2d(
            tray_inner_r + 1,
            max(0.1, inlet_tray_cut_r - tray_wall),
            outlet_tray_angle + 2*tray_side_wall_angle,
            outlet_tray_direction
        );
    }
}

module outlet_tray_footprint() {
    annular_sector_2d(
        tray_outer_r,
        outlet_tray_inner_r,
        outlet_tray_angle,
        outlet_tray_direction
    );
}

module outlet_tray_cavity() {
    annular_sector_2d(
        tray_inner_r,
        outlet_tray_inner_r + tray_wall,
        outlet_tray_angle - 2*tray_side_wall_angle,
        outlet_tray_direction
    );
}

module inlet_fluid_tray() {
    color("lightcyan")
    difference() {
        tray_shell() {
            inlet_tray_footprint();
            inlet_tray_cavity();
        }
        lowered_outlet_edge_cut(
            max(0.1, inlet_tray_cut_r - tray_wall - 0.2),
            inlet_tray_cut_r + 0.2
        );
    }
}

module outlet_fluid_tray() {
    color("lightskyblue")
    difference() {
        tray_shell() {
            outlet_tray_footprint();
            outlet_tray_cavity();
        }
        lowered_outlet_edge_cut(
            outlet_tray_inner_r - 0.2,
            outlet_tray_inner_r + tray_wall + 0.2
        );
    }
}

module inlet_fluid_volume() {
    tray_fluid()
    inlet_tray_cavity();
}

module outlet_fluid_volume() {
    tray_fluid()
    outlet_tray_cavity();
}

module fluid_volume() {
    if (SHOW_INLET_TRAY) {
        inlet_fluid_volume();
    }
    if (SHOW_OUTLET_TRAY) {
        outlet_fluid_volume();
    }
}

module fluid_tray() {
    if (SHOW_INLET_TRAY) {
        inlet_fluid_tray();
    }
    if (SHOW_OUTLET_TRAY) {
        outlet_fluid_tray();
    }
}

module selected_tray_part() {
    if (TRAY_PART == 1) {
        inlet_fluid_tray();
    } else if (TRAY_PART == 2) {
        outlet_fluid_tray();
    } else {
        fluid_tray();
    }
}

module selected_fluid_volume() {
    if (TRAY_PART == 1) {
        inlet_fluid_volume();
    } else if (TRAY_PART == 2) {
        outlet_fluid_volume();
    } else {
        fluid_volume();
    }
}

module completePumpWithTray() {
    if (SHOW_TRAY) {
        selected_tray_part();
    }
    if (SHOW_FLUID_VOLUME) {
        selected_fluid_volume();
    }
    if (SHOW_PUMP) {
        completePump();
    }
}

if (TRAY_ONLY) {
    selected_tray_part();
} else if (USE_VERTICAL_KNIFE) {
    difference() {
        completePumpWithTray();
        translate([-80,-100,97])
        cube([200,200,200],center=true);
    }
} else {
    completePumpWithTray();
}


// completePump();
