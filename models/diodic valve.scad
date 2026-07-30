chimney_width = 20;
chimney_height = 40;
wall = 2;
tube_width = 10;
tube_length = 2*chimney_width;
extrude_h = 15;

module chimney_profile(w, h) {
    polygon(points = [
        [0, h/2],
        [0, h],
        [w, h],
        [w, h/3],
        [w+3*wall, 0],
        [w/2, wall]
    ]);
}

module chimney_hollow(w = chimney_width, h = chimney_height, wall = 2) {
    difference() {
        chimney_profile(w, h);
        offset(delta = -wall) chimney_profile(w, h);
    }
}

module tube() {
    polygon(points = [
        [chimney_width+wall, wall],
        [tube_length, wall],
        [tube_length, -tube_width+wall],
        [chimney_width, -tube_width+wall],
        [chimney_width/2, (-tube_width+wall)/2],
        [chimney_width/2, wall],
        [chimney_width/2, 2*wall]
    ]);
}

module tube_hollow() {
    difference() {
        tube();
        offset(delta=-wall) tube();
    }
}

module inside(){
    polygon(points = [
        [chimney_width/2+wall, wall],
        [chimney_width/2+wall, wall/2],
        [chimney_width/2, wall/2],
        [chimney_width/2, (-3/2)*wall],
        [chimney_width/2+10*wall, (-3/2)*wall],
        [chimney_width+2*wall, -wall/2],
        [chimney_width+2*(wall/2), 2*wall],
        [chimney_width/2, 3*wall]
    ]);
    
    polygon(points = [
        [wall, chimney_height],
        [chimney_width-wall, chimney_height],
        [chimney_width-wall, chimney_height-wall],
        [wall, chimney_height-wall]
    ]);
    
    polygon(points = [
        [tube_length-wall, 0],
        [tube_length, 0],
        [tube_length, -(tube_width-2*wall)],
        [tube_length-wall, -(tube_width-2*wall)]
    ]);
}

module all(){
    difference(){
        chimney_hollow(chimney_width, chimney_height    , wall);
        inside();
    }
    difference(){
        tube_hollow();
        inside();
    }
    
    translate([chimney_width/2, wall, 0])
        circle(2, $fn=25);
    
    translate([chimney_width/2, -tube_width+2*wall])
        circle(4, $fn=25);
    
    translate([chimney_width/2, -tube_width+wall])
        circle(6, $fn=25);
}

linear_extrude(height = extrude_h)
    all();