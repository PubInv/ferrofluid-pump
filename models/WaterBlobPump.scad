// Copyright Robert L. Read, 2022
// Released under CERN Strong-reciprocal Open Hardware License

// This is an attempt to design an a ferrfluid pump that efficiently
// pumps ferrofluid with no moving parts.
// The basic idea is to use a water bubble.abs

// Thanks to  Mike Thompson for ths CC Attribution-NonCommercial-SA 3.0 set of threaded tools
include <Nut_Job_v2.scad>;

SlabHeight = 6;
MagnetHeight = 50;
ww = 1.5; // This is the wall width, assumed to be sturdy enough
// I want to make this a little large to have room for magnet holders...
CircleRadiusIncrease = 1.0;
CircleRadius = 12.5*CircleRadiusIncrease;
a = CircleRadius;
EquilateralAltitude = (2*a) * sqrt(3)/2;
CircumscribedRadius = (CircleRadius * 2) / ( 2 * sin ( 180 / 7 ) );
LuerPosition = CircumscribedRadius+a*4;
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

// ptype = "caps" | "pump";
// ptype = "caps";
ptype = "pump";

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
 
 // make the "pillbox shape" of a rectangle with a cylindrical end.
 module pillBox(r,l,h) {
     color("blue",0.5)
     union () {
         translate([0,-l/2,0])
         cube([r*2,l,h],center=true);
         cylinder(h,r,r,center=true,$fn=40);
     }
 }
 
 // r,l,h should match the mangnet (that is, the interior dimentions!
 module magnetCage(r,l,h,thickness) {
     // A fudge to make sure the magnet fits!
     f = 1.01;
     th = thickness;
     difference() {
         pillBox(th+r,th+l,th+h);
        color("black",0.5)
         union() {
            color("white",0.3)
            pillBox(f*r,f*l,f*h);
                color("red",0.5)
             translate([0,-f*l,0])
            cube([f*r*2,2*f*l,f*h],center=true);
      }
    }

 }
 

//translate([10,0,0])
//color("blue")
// pillBox(3,28,50);
// magnetCage(3,28,50,2);
 
 module replicate_at_points2D(order = 4, r = 10) {
     for (i=[0 : order]) {
        rotate(i * 360 / order) 
            translate([r,0,0]) 
                magnetChamber();
      
     }
 }
 
 module CageOrRing(c,r,l,mh,wall) {
     if (c) {
     magnetCage(r,l,mh,wall);
     } else {
     }
 }
 module replicate_Cage_at_points3D(order = 4, r = 10, l = 10, sh=6, mh=10, wall=1) {
     for (i=[0 : order]) {
        rotate(i * 360 / order) 
            translate([l,0,0]) 
                translate([0,0,(sh+mh)/2])
                    rotate([0,0,90])
                    CageOrRing(true,r,l,mh,wall);
//                    magnetCage(r,l,mh,wall); 
      
     }
 }

  module replicate_Ring_at_points3D(order = 4, r = 10, l = 10, sh=6, mh=10, wall=1) {
     for (i=[0 : order]) {
        rotate(i * 360 / order) 
            translate([l,0,0]) 
                translate([0,0,(sh+mh)/2])
                    rotate([0,0,90])
                    magnetCage(r,l,mh,wall); 
      
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
//     color("blue",0.5)
//     translate([0,a*2,0])
//     rotate(1.5 * 360 / order)
//        translate([x,0,0])
//            magnetChamber();
//     color("blue",0.5)
//     translate([0,-a*2,0])
//     rotate(5.5 * 360 / order)
//        translate([x,0,0])
//            magnetChamber();
     
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
     translate([0.85*a,r+1.5*a,0])
     rotate([0,0,90])
      square([2*a,a],center=true);
     
         color("red") 
     translate([0.85*a,-(r+1.5*a),0])
     rotate([0,0,90])
      square([2*a,a],center=true);
 }
 // we want the waterports to be small tubes we can inject water into
 // and then seal. 
 // 
module waterports(CircumscribedRadius) {
    r = CircumscribedRadius;
    
    order=7;
    rotate(0 * 360 / order) 
    translate([r*1.4,0,0]) 
    rotate([0,90,0])
    difference() {
        BuildFromType("rod");
        cylinder(100,2);
    }
    rotate(4 * 360 / order) 
    translate([r*1.4,0,0]) 
    rotate([0,90,0])
    difference() {
        BuildFromType("rod");
        cylinder(100,2);
    }
}
module waterportCavities(CircumscribedRadius) {
     r = CircumscribedRadius;
    
    order=7;
    rotate(0 * 360 / order) 
      translate([r*1.4,0,0]) 
        rotate([0,90,0])
          cylinder(100,2,$fn=40);
    rotate(4 * 360 / order) 
      translate([r*1.4,0,0]) 
         rotate([0,90,0])
           cylinder(100,2,$fn=40);
}

module caps() {
    
    translate([50,0,0]) 
    union() {
    translate([0,10,0])
    BuildFromType("cap");
    translate([0,-10,0])
    BuildFromType("cap");
    }
}
 
 module interior() {
      linear_extrude(height = SlabHeight - 2*ww, center = true, convexity = 10, twist = 0)
    union() {
        replicate_at_points2D(7,CircumscribedRadius);
        addlocks(CircumscribedRadius);
        connectors(CircumscribedRadius);      
    }
    waterportCavities(CircumscribedRadius);
 }
 
 
 // At this point we must decide:
 // How to make communications between the chambers
 // how to add barbs for water injection
 // How to add luers
 // How to add markings or holders for magnets
 module luer() {
 import("Body1.stl", convexity=3);
 }

module slab() {

    r = CircumscribedRadius+a*3/2;
    color("green",0.7)
    union() {
    cylinder(SlabHeight,r,r,center=true);
        translate([0.85*a,0,0])
    cube([3*a,LuerPosition*1.6,SlabHeight],center=true);
    }
}

module completePump() {
    difference() {
        union() {
           slab();
 //     interiorCircle = a / CircleRadiusIncrease;
 //     replicate_Cage_at_points3D(7,interiorCircle,CircumscribedRadius,SlabHeight,MagnetHeight,1);
        }
        interior();
    }
//    interior();
    translate([0.85 * a,LuerPosition,0]) rotate([90,0,0]) luer();
    translate([0.85 * a,-LuerPosition,0]) rotate([270,0,0]) luer();
    waterports(CircumscribedRadius);
}

// interior();
if (ptype == "pump") {
  completePump();
} else {
  caps();
}



