funnelWidth = 2; //2 or 3 times 6.35 mm, or 1/2 inch
funnelHeight = 0.5;
funnelThickness=0.05;
extrudeHeight = 2;

module shearX_Z(s) {
    multmatrix([
        [1, 0, s, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0]
    ])
    children();
}

module funnelCupFrame(w,h,t,e){
    translate([0,0,e/2])
    linear_extrude(height = e,convexity = 3, scale=4,center=true)
    difference() {
        square([w,w],center=true);
        offset(delta = -t) square([w,w],center=true);
    }
}

module funnelOutlet (w,t){
    translate([-w/2,0,0])
    rotate([-90,0,0])
    translate([0,0,-w/2])
    rotate_extrude(angle=90, convexity=10,$fn=100) 
    difference() {
        square([w,w]);
        offset(delta = -t) square([w,w]);
    }
    
}

module outletPipe(w,t,e){
    translate([-w/2,0,-w/2])
    rotate([0,-90,0]) 
    linear_extrude(height = e, scale = 0.5)
    difference() {
        square([w,w],center=true);
        offset(delta = -t) square([w,w],center=true);
    }
}


module funnel() {

shearX_Z(1.5)
funnelCupFrame(w=funnelWidth,h=funnelHeight,t=funnelThickness, e= extrudeHeight);

funnelOutlet(w=funnelWidth, t=funnelThickness);

outletPipe(w=funnelWidth, t=funnelThickness, e= extrudeHeight);

}

funnel();

