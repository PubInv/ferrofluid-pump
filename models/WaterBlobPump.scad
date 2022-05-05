// Copyright Robert L. Read, 2022
// Released under CERN Strong-reciprocal Open Hardware License

// This is an attempt to design an a ferrfluid pump that efficiently
// pumps ferrofluid with no moving parts.
// The basic idea is to use a water bubble.abs

SlabHeight = 6;
ww = 1.5; // This is the wall width, assumed to be sturdy enough
CircleRadius = 12.5;
a = CircleRadius;
EquilateralAltitude = (2*a) * sqrt(3)/2;
CircumscribedRadius = (CircleRadius * 2) / ( 2 * sin ( 180 / 7 ) );
LuerPosition = CircumscribedRadius+a*6;
echo("a =");
echo(a);
echo("EquilateralAltitude");
echo(EquilateralAltitude);
HeptagonRadius = 10;
InternalAngleDeg = 360 / 7;

PI = 3.14152;
echo("CircumscribedRadius");
echo(CircumscribedRadius);


GapHeight = 3.0;
Thickness = 1.0;

// First we will create the 7-point geometry that is the basis of the approach

 module regular_polygon(order = 4, r=1){
     angles=[ for (i = [0:order-1]) i*(360/order) ];
     coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
     polygon(coords);
 }
 
 
 // Replicate a shape at a given radius and repeat with
 // rotation to create order number of objects
 module magnetChamber() {
     circle(CircleRadius);
 }
 
 module replicate_at_points(order = 4, r = 10) {
     for (i=[0 : order]) {
        rotate(i * 360 / order) 
            translate([r,0,0]) 
                magnetChamber();
     }
 }
 
 module addlocks(r,order = 7) {
     radiusAtMidPoint = sqrt(CircumscribedRadius^2 -  a^2);
     echo("Radius AtMidPoint");
     echo(radiusAtMidPoint);
     x = radiusAtMidPoint + EquilateralAltitude;
     echo(x);
     color("red",0.5)
     rotate(1.5 * 360 / order)
     translate([x,0,0])
        magnetChamber();
     color("red",0.5)
     rotate(5.5 * 360 / order)
     translate([x,0,0])
        magnetChamber();
     // Now I add the source and the drain
     color("blue",0.5)
     translate([0,a*2,0])
     rotate(1.5 * 360 / order)
        translate([x,0,0])
            magnetChamber();
     color("blue",0.5)
     translate([0,-a*2,0])
     rotate(5.5 * 360 / order)
        translate([x,0,0])
            magnetChamber();
     
 }

 module connectors(r, order=7) {
     difference() {
         circle(r*1.1);
         circle(r*0.8);
     }
     color("gray")
     rotate(1.5 * 360 / order) 
        translate([r*1.5,0,0]) 
     square([2*a,a],center=true);
          color("gray")
     rotate(5.5 * 360 / order) 
        translate([r*1.5,0,0]) 
     square([2*a,a],center=true);
        
    color("red") 
     translate([0.85*a,r+2*a,0])
     rotate([0,0,90])
      square([2*a,a],center=true);
         color("red") 
     translate([0.85*a,-(r+2*a),0])
     rotate([0,0,90])
      square([2*a,a],center=true);
 }
 

 
 module interior() {
      linear_extrude(height = SlabHeight - 2*ww, center = true, convexity = 10, twist = 0)
 union() {
    replicate_at_points(7,CircumscribedRadius);
    addlocks(CircumscribedRadius);
    connectors(CircumscribedRadius);
 }
 }
 
 // At this point we must decide:
 // How to make communications between the chambers
 // how to add barbs for water injection
 // How to add luers
 // How to add markings or holders for magnets
 module luer() {
 import("Body1.stl", convexity=3);
 }
translate([0.85 * a,LuerPosition,0]) rotate([90,0,0]) luer();
translate([0.85 * a,-LuerPosition,0]) rotate([270,0,0]) luer();
module slab() {

    r = CircumscribedRadius+a*3/2;
    color("green",0.3)
    union() {
    cylinder(SlabHeight,r,r,center=true);
        translate([0.85*a,0,0])
    cube([3*a,LuerPosition*1.8,SlabHeight],center=true);
    }
}

module completePump() {
difference() {
    slab();
    interior();
}
}

//interior();
completePump();