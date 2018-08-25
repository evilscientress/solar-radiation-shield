$fn=100;

module stud(height, d1, drill_dia, recess_angle) {
    recess=tan(recess_angle)*height;
    difference() {
        cylinder(h=height, r1=d1/2, r2=d1/2-recess, center=false);
        if (drills) {
            translate([0,0,1]) cylinder(h=height, d=drill_dia);
        }
    }
}

module studs(height=17, d1=12, drill_dia=5.5, studs_outscribe=68, recess_angle=4, drills=true) {
    translate([-studs_outscribe/4, studs_outscribe/4*3*tan(30), 0]) stud(height=height, d1=d1, drill_dia=drill_dia, recess_angle=recess_angle, drills=drills);
    translate([-studs_outscribe/4, -studs_outscribe/4*3*tan(30), 0]) stud(height=height, d1=d1, drill_dia=drill_dia, recess_angle=recess_angle, drills=drills);
    translate([studs_outscribe/2, 0, 0]) stud(height=height, d1=d1, drill_dia=drill_dia, recess_angle=recess_angle, drills=drills);
}

module stud_drills(height=17, drill_dia=5.5, studs_outscribe=68) {
    translate([-studs_outscribe/4, studs_outscribe/4*3*tan(30), 0]) cylinder(h=height, d=drill_dia);
    translate([-studs_outscribe/4, -studs_outscribe/4*3*tan(30), 0]) cylinder(h=height, d=drill_dia);
    translate([studs_outscribe/2, 0, 0]) cylinder(h=height, d=drill_dia);
}

module canopy(d1, angle, height, thickness) {
    r_outer_inner=d1/2-(height-thickness)*tan(angle);
    r_inner_outer=d1/2-thickness*2;
    r_inner_inner=r_inner_outer-(height-thickness*2+0.1)*tan(angle);
    difference() {
        union() {
            cylinder(h=height-thickness, r1=r_outer_inner, d2=d1, center=false);
            translate([0,0,height-thickness]) cylinder(h=thickness, d=d1, center=false);
        };
        translate([0,0,thickness*2])
        cylinder(h=height-thickness*2+.1, r1=r_inner_inner, r2=r_inner_outer, center=false);
    }
}

module shield_top(d1=180, angle=45, height=20, studs_outscribe=68, stud_drill_dia=4.2, thickness=1, overlap=1) {
    union() {
        canopy(d1=d1, angle=angle, height=height, thickness=thickness);
        translate([0,0,thickness*2]) studs(height=height-thickness*2-overlap, drill_dia=stud_drill_dia);
    }
}

module shield_fin(d1=120, angle=45, hole_dia=35, height=18, studs_outscribe=68, stud_drill_dia=5.5, thickness=1, overlap=1) {
    difference() {
        union() {
            canopy(d1=d1, angle=angle, height=height, thickness=thickness);
            translate([0,0,thickness*2]) studs(height=height-thickness*2-overlap, drill_dia=stud_drill_dia, drills=false);
        }
        translate([0,0,-0.1]) cylinder(h=thickness*2+.2, d=hole_dia, center=false);
        translate([0,0,-0.1]) stud_drills(height=height+.2);
    }
}

module base(d1=120, angle=45, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, mount_drill=4.2, thickness=1) {
    r_inner_outer=d1/2-thickness*2;
    r_inner_inner=r_inner_outer-(height-thickness*2+0.1)*tan(angle);
    difference() {
        union() {
            cylinder(h=thickness*2, r=r_inner_inner, center=false);
            translate([0,0,thickness*2]) studs(height=height-thickness*2, drill_dia=stud_drill_dia, drills=false);
            translate([0,0,thickness*2]) cylinder(h=height-thickness*4, d=sensor_hole_dia+thickness*11, center=false);
            translate([0,0,height-thickness*2]) cylinder(h=thickness*4, d=sensor_hole_dia+thickness*7, center=false);
        }
        translate([0,0,-0.1]) cylinder(h=height+thickness*2+.2, d=sensor_hole_dia, center=false);
        translate([0,0,-0.1]) stud_drills(height=height+.2);
        translate([0,0,thickness*2+(height-thickness*4)/2]) rotate([90,0,0]) cylinder(h=sensor_hole_dia+thickness*12, d=mount_drill, center=true);
    }
    
}



/*
difference(){
    shield_fin();
    //shield_top();
    translate([0,150,0]) cube(size=[300,300,300], center=true);
}*/

module full_assembly(d1=120, d2=180, angle=45, hole_dia=35, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, thickness=1, overlap=1, num_fins=10) {
    for(i=[0:num_fins]) {
        if (i==0) {
            shield_top(d1=d2, angle=angle, height=height, studs_outscribe=studs_outscribe);
        } else {
            translate([0,0,(height-overlap)*i])
            shield_fin(d1=d1, angle=angle, hole_dia=hole_dia, height=height, studs_outscribe=studs_outscribe);
        }
    }
    translate([0,0,(height-overlap)*(num_fins+1)]) base(d1=d1, angle=angle, sensor_hole_dia=sensor_hole_dia, height=height, studs_outscribe=studs_outscribe);
}

//full_assembly();
shield_fin(d1=120, d2=180, angle=45, hole_dia=35, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, thickness=1, overlap=1);
//shield_top(d1=180, angle=45, hole_dia=35, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, thickness=1, overlap=1);
//base(d1=120, angle=45, hole_dia=35, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, thickness=1, overlap=1);