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
        translate([0,0,-0.1]) stud_drills(height=height+.2, drill_dia=stud_drill_dia);
    }
}

module base(d1=120, angle=45, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, mount_drill=4.2, thickness=1, baseplate_thickness=5) {
    r_inner_outer=d1/2-thickness*2;
    r_inner_inner=r_inner_outer-(height-thickness*2+0.1)*tan(angle);
    difference() {
        union() {
            cylinder(h=thickness*2, r=r_inner_inner, center=false);
            translate([0,0,thickness*2]) studs(height=height-thickness*2, drill_dia=stud_drill_dia, drills=false);
            translate([0,0,thickness*2]) cylinder(h=height-thickness*3, d=sensor_hole_dia+thickness*11, center=false);
            translate([0,0,height-thickness]) cylinder(h=thickness+baseplate_thickness, d=sensor_hole_dia+thickness*7, center=false);
        }
        translate([0,0,-0.1]) cylinder(h=height+baseplate_thickness+.2, d=sensor_hole_dia, center=false);
        translate([0,0,-0.1]) stud_drills(height=height+.2, drill_dia=stud_drill_dia);
        translate([0,0,thickness*2+(height-thickness*3)/2]) rotate([90,0,0]) cylinder(h=sensor_hole_dia+thickness*12, d=mount_drill, center=true);
    }
    
}

module struct(length, width, height, angle=45) {
    recess=height/tan(45);
    polyhedron(points=[[0,0,0], [0,width,0], [length,width,0], [length,0,0], 
                                   [0,0,height], [0,width,height], [length-recess,width,height], [length-recess,0,height] ],
                       faces=[[0,3,2,1], [0,4,7,3], [0,1,5,4], [1,2,6,5], [2,3,7,6],[4,5,6,7]]);
}

module rounded_corner_negative(height, r) {
    difference() {
        cube([r,r,height]);
        translate([0,0,-.1]) cylinder(r=r, h=height+.2);
    }
}

module mount_vertical_base(d1, angle, sensor_hole_dia, height, studs_outscribe, stud_drill_dia, thickness, baseplate_thickness, mount_distance, arm_width, mount_height, arm_length) {
    r_inner_outer=d1/2-thickness*2;
    r_inner_inner=r_inner_outer-(height-thickness*2+0.1)*tan(angle);
    
    union() {
        difference() {
            union() {
                cylinder(h=baseplate_thickness, r=r_inner_inner, center=false);
                translate([-arm_length, arm_width/-2, 0]) cube([arm_length, arm_width, baseplate_thickness]);
                translate([-arm_length, arm_width/-2+arm_width*.2, baseplate_thickness])
                    struct(arm_length-r_inner_inner+20, baseplate_thickness, baseplate_thickness);
                translate([-arm_length, arm_width/2-baseplate_thickness-arm_width*.2, baseplate_thickness])
                    struct(arm_length-r_inner_inner+20, baseplate_thickness, baseplate_thickness);
                translate([-arm_length, arm_width/-2+arm_width*.2, baseplate_thickness])
                    struct(mount_height-baseplate_thickness, baseplate_thickness, mount_height-baseplate_thickness);
                translate([-arm_length, arm_width/2-baseplate_thickness-arm_width*.2, baseplate_thickness])
                    struct(mount_height-baseplate_thickness, baseplate_thickness, mount_height-baseplate_thickness);
            }
            translate([0,0,-0.1]) cylinder(h=baseplate_thickness+.2, d=sensor_hole_dia+thickness*9, center=false);
            translate([0,0,-0.1]) stud_drills(height=baseplate_thickness+.2, drill_dia=stud_drill_dia);
            translate([-arm_length+(mount_height-baseplate_thickness)/2-7, 0, (mount_height-baseplate_thickness)/2+baseplate_thickness-1]) 
            rotate([90,0,0]) cylinder(h=arm_width, d=4.5, center=true);
        }
    }
    
}

module mount_vertical_edge(d1=120, angle=45, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, mount_drill=4.2, thickness=1, baseplate_thickness=5, mount_distance=140, arm_width=50, mount_height=40, ziptie_width=9, ziptie_thickness=2) {
    arm_length=mount_distance-baseplate_thickness*2;
    triangle_width=arm_width-10;
    triangle_height=triangle_width/2/tan(45);
    difference() {
        union() {
        mount_vertical_base(d1=d1, angle=angle, sensor_hole_dia=sensor_hole_dia, height=height, 
            studs_outscribe=studs_outscribe, stud_drill_dia=stud_drill_dia, thickness=thickness, 
            baseplate_thickness=baseplate_thickness, mount_distance=mount_distance, arm_width=arm_width,
            arm_length=arm_length, mount_height=mount_height);
            translate([-mount_distance-triangle_height, arm_width/-2, 0])
            cube([mount_distance-arm_length+triangle_height, arm_width, mount_height]);
        }
        translate([-mount_distance-triangle_height,0, -0.1]) 
        polyhedron(points=[[0,-triangle_width/2,0], [triangle_height,0,0], [0,triangle_width/2,0], 
                                         [0,-triangle_width/2,mount_height+.2], [triangle_height,0,mount_height+.2], [0,triangle_width/2,mount_height+.2]],
                            faces=[[0,1,2], [0,2,5,3], [0,3,4,1], [1,4,5,2],[3,5,4]]);
        for (i = [baseplate_thickness*1.5, mount_height-baseplate_thickness-ziptie_width]) {
            translate([-mount_distance-triangle_height-.1-2,triangle_width/2+2, i]) rotate([0,0,-31.3])
            cube([mount_distance-arm_length+triangle_height+10, ziptie_thickness, ziptie_width]);
            translate([-mount_distance-triangle_height-.1-2,-triangle_width/2-2.3-ziptie_thickness, i]) rotate([0,0, 31.3])
            cube([mount_distance-arm_length+triangle_height+10, ziptie_thickness, ziptie_width]);
            translate([-arm_length-6,0, i]) rotate([0,0,-45])
            rounded_corner_negative(height=ziptie_width, r=6);
        }
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
//shield_fin(d1=120, d2=180, angle=45, hole_dia=35, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, thickness=1, overlap=1);
//shield_top(d1=180, angle=45, hole_dia=35, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=4.2, thickness=1, overlap=1);
//base(d1=120, angle=45, hole_dia=35, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, thickness=1, overlap=5);

mount_vertical_edge(d1=120, angle=45, sensor_hole_dia=25, height=18, studs_outscribe=68, stud_drill_dia=5.5, mount_drill=4.2, thickness=1, baseplate_thickness=5, mount_distance=140, arm_width=50, mount_height=40);


