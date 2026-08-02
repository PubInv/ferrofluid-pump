chimney_width = 20;
chimney_height = 40;
wall = 2;
tube_width = 10;
tube_length = 2*chimney_width;
extrude_h = 15;

magnet_diameter = 6.25+0.25;
magnet_radius = magnet_diameter/2; // radius of magnet cylinders
// remove this in when integrating code in make pump file
qm_mm = magnet_radius / 2;

chimney_height_qms = 15;

$fn = 100;

// An attempt to make a "faucet shape".
module faucet_hook() {
   
   b_mm = (3/4)*qm_mm; // this is a basic quantity we use for this shape
   pylon_width_mm = (1/2)*b_mm;
   channel_width_mm = (4/4)*b_mm;
   hook_width_mm = (1/2)*b_mm;
   
   inner_hook_height_mm = hook_width_mm + channel_width_mm;
    
    // this is the main inlet valve, from which 
    // which we intersect with the +y, -x quadrant
    // to make it easier to use
    intersection() {
        translate([0,100])
        square([200,200],center = true);
        union() {
            difference() {
                inlet_curve_outer_radius = hook_width_mm + channel_width_mm + pylon_width_mm;
                circle(inlet_curve_outer_radius);
            
                difference() {
                    inlet_curve_inner_radius = channel_width_mm + pylon_width_mm;
                    circle(inlet_curve_inner_radius);
                        
                    inlet_curve_core_radius = pylon_width_mm;
                    circle(inlet_curve_core_radius);
                }
            }
        }
    }
    
    
    // now add a rounding curve at the edge to 
    // 
    translate([pylon_width_mm * 3/2 +channel_width_mm,0])
    circle(pylon_width_mm/2);
    
    polygon(points = [
        [b_mm*1.35,inner_hook_height_mm],
        [-b_mm*2,b_mm*5],
        [-b_mm*2,inner_hook_height_mm]
    ]);
    polygon(points = [
        [-b_mm*2,inner_hook_height_mm],
        [-b_mm*1.0,inner_hook_height_mm],
        [-b_mm*2,0]
    ]);
    // create the pylon
    translate([0,-(b_mm*50/2)])
    square([pylon_width_mm*2,b_mm*50],center=true);
}


module chimney_back_wall() {
    // Start at the most critical, the edge of the fluid
    theta = 30;
    dx = qm_mm*cos(theta);
    dy = qm_mm*sin(theta);
    polygon(points = [
        [-qm_mm*2,qm_mm*2.25+dy],
        [-qm_mm*2,qm_mm*(chimney_height_qms-2)],
        [-qm_mm*2,qm_mm*2]
    ]
    );
}

module chimney_front_wall() {
    translate([qm_mm*3,qm_mm*2.5])
    circle(qm_mm);
    start = [qm_mm*2,qm_mm*2.5];
    polygon(points = [
        start,
        [qm_mm*2,qm_mm*(chimney_height_qms+1.5)],
        [qm_mm*4,qm_mm*(chimney_height_qms+1.5)],
        [qm_mm*4,qm_mm],
        [qm_mm*2.7,qm_mm*1.55],
        start
        ]
    );
    translate([-(qm_mm/2+qm_mm*2),(qm_mm*chimney_height_qms+qm_mm*3)/2])
    square([qm_mm,qm_mm*chimney_height_qms],center=true);
}

module inlet_curve() {
   inlet_curve_center_x_mm = 0;
   inlet_curve_center_y_mm = 0;
    
    // this is the main inlet valve, from which 
    // which we intersect with the +y, -x quadrant
    // to make it easier to use
    intersection() {
        translate([-100,100])
        square([200,200],center = true);
        union() {
            difference() {
                inlet_curve_outer_radius = 3.5*qm_mm;
                circle(inlet_curve_outer_radius);
            
                difference() {
                    inlet_curve_inner_radius = 2.5*qm_mm;
                    circle(inlet_curve_inner_radius);
                        
                    inlet_curve_core_radius = 1.5*qm_mm;
                    circle(inlet_curve_core_radius);
                }
            }
        }
    }
    // now add a rounding curve at the edge to 
    // 
    translate([0,qm_mm*2.85])
    circle(qm_mm/3);
}
module outlet_ramp() {
    polygon([[0,0],
    [0,qm_mm*1.5],
    [qm_mm*4,0]
    ]);
}
// Note: We have to understand the coordinate 
// system of the pump. The x=0 coordinate is
// centered on the center of the magnets.
// The y coordinate is the bottom of the lowest
// magnet.
// Note: this is being produced in "positive form",
// with material NOT present where the ferrofluid will be.
module diodic_valve(){
// Chimney
//    difference(){
//        chimney_hollow(chimney_width, chimney_height    , wall);
//        inside();
//    }
    
// // outlet portion
//    difference(){
//        tube_hollow();
//        inside();
//    }
    
//    translate([0, wall, 0])
//        circle(2, $fn=25);
    
//    translate([0, -tube_width+2*wall])
//        circle(4, $fn=25);
    translate([-qm_mm,qm_mm*10])
    faucet_hook();

    chimney_back_wall();
    chimney_front_wall();
    
    outlet_ramp();
 
}

// linear_extrude(height = extrude_h)
//    all();

diodic_valve();



