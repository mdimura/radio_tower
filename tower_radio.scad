//!OpenSCAD
//input parameters:
l = 6050; //main pipe length mm
d_out = 33.5; //main pipe outer diameter
w_pipe=3.2; //main pipe wall thickness
l_base=500; //distance between main pipes
l_mnt=1000; //mount pipe length
d_out_mnt=42.3; //mount pipe outer diameter
w_mnt=3.2; //mount pipe wall thickness
num_crosspiece=4; //number of rebars between pipes
d_rebar=10; //rebar diameter
rung_sp=400; //spacing between stairs
h_concrete = 700; //depth of the concrete slab around the anchoring bar
r_concrete = l_base/3; //radius of the concrete slab around the anchoring bar at the level of the surface
l_anchor = 2000; //length of the anchoring bar
z_overlap_anchor = 300; //vertical overlap between the anchoring bar and the carcas
l_gnd= 6000; //length of the grounding bar

$fn=64;

//computed parameters
R_out_base=sqrt(3)/3*l_base; //Circumradius of the base 
R_in_base=R_out_base/2; //Inradius of the base
p1=[R_out_base,0];
p2=[-R_in_base,l_base/2];
p3=[-R_in_base,-l_base/2];
z_block=l-l_mnt+d_out_mnt;

include <Nut_Job.scad>

module vpipe(x, y, z, l, r_out, w) {
    eps=1;
    r_in=r_out-w;
    translate([x,y,z])
    difference()
    {
      cylinder(r=r_out, h=l);
      translate([0,0,-eps]) cylinder(r=r_in, h=l+2*eps);
    }
}

module rebar(r1,r2,r_out) {
    eps=1;
    dr=r2-r1;
    l=sqrt(dr*dr);
    n=cross(dr,[0,0,1]);
    dir=dr[2]>0?-1:1;
    ang=dir*acos(abs(dr[2])/l);
    tr=dir>0?r2:r1;
//    echo ("dr",dr);
//    echo ("l",l);
//    echo ("n",n);
//    echo ("ang",ang);
    color([0,0,1])
    translate(tr) 
        rotate(ang, n)
            cylinder(r=r_out, h=l);
}

module build_reinforcement(p1,p2,l,n_r) {
    dz=l/n_r;
    for (i  = [0: n_r-1]) {
        z=i*dz;
        r1=[p1[0],p1[1],z];
        r2=[p2[0],p2[1],z+dz/2];
        r3=[p1[0],p1[1],z+dz];
        rebar(r1, r2, d_rebar/2);
        rebar(r2, r3, d_rebar/2);
    }
    ztop=l-d_rebar/2;
    rebar([p1[0],p1[1],ztop], [p2[0],p2[1],ztop], d_rebar/2);
    zbtm=d_rebar/2;
    rebar([p1[0],p1[1],zbtm], [p2[0],p2[1],zbtm], d_rebar/2);
}

module build_ladder(p1,p2,l,dz) {
    n_r=round(l/dz);
    for (i  = [0: n_r-1]) {
        z=i*dz;
        r1=[p1[0],p1[1],z];
        r2=[p2[0],p2[1],z];
        rebar(r1, r2, d_rebar/2);
    }
    ztop=l-d_rebar/2;
    rebar([p1[0],p1[1],ztop], [p2[0],p2[1],ztop], d_rebar/2);
}

module build_anchor(p, l, r, z_overlap, h_concrete, r_concrete) {
    r1=[p[0],p[1],z_overlap-l];
    r2=[p[0],p[1],z_overlap];
    rebar(r1,r2,r); 
    color([0.5,0.5,0.5]) translate([p[0],p[1],-h_concrete]) 
        cylinder(h=h_concrete, r1=r, r2=r_concrete);
}

module build_mount() {
    nut_z=l-7;
    nut_shift=d_out_mnt/2+5;
    nut1_xy=-p1/sqrt(p1*p1)*nut_shift;
    nut1_pos=[nut1_xy[0],nut1_xy[1],nut_z];
    nut1_rot_ax=[nut1_xy[1],-nut1_xy[0],0];
    nut2_xy=-p2/sqrt(p2*p2)*nut_shift;
    nut2_pos=[nut2_xy[0],nut2_xy[1],nut_z];
    nut2_rot_ax=[nut2_xy[1],-nut2_xy[0],0];
    block_rot_ax=[1,0,0];
    difference() {
        color([1,0,0]) vpipe(0,0,l-l_mnt,l_mnt,d_out_mnt/2,w_mnt);
        union() {
            translate(nut1_pos) rotate(90,nut1_rot_ax) cylinder(h=w_mnt+7, r=4); //bolt1
            translate(nut2_pos) rotate(90,nut2_rot_ax) cylinder(h=w_mnt+7, r=4); //bolt2
            translate([0,0,z_block]) rotate(90,block_rot_ax) cylinder(h=d_out_mnt*2, r=4, center=true); //block
        }
    }
    lt=l-d_rebar;
    m1t=[p1[0],p1[1],lt];
    m2t=[p2[0],p2[1],lt];
    m3t=[p3[0],p3[1],lt];
    
    lb=l-l_mnt+d_rebar;
    m1b=[p1[0],p1[1],lb];
    m2b=[p2[0],p2[1],lb];
    m3b=[p3[0],p3[1],lb];
    r_in_mnt=d_out_mnt/2-w_mnt;
    difference() {
        union(){
            rebar(m1t,[0,0,lt],d_rebar/2);
            rebar(m2t,[0,0,lt],d_rebar/2);
            rebar(m3t,[0,0,lt],d_rebar/2);
            rebar(m1b,[0,0,lb],d_rebar/2);
            rebar(m2b,[0,0,lb],d_rebar/2);
            rebar(m3b,[0,0,lb],d_rebar/2);
        }
        vpipe(0,0,l-l_mnt,l_mnt,r_in_mnt,r_in_mnt); 
    }
    
    //immob nut
    translate(nut1_pos) rotate(90,nut1_rot_ax)
        hex_nut(nut_diameter,nut_height,nut_thread_step,nut_step_shape_degrees,nut_thread_outer_diameter,nut_resolution);
    translate(nut2_pos) rotate(90,nut2_rot_ax)
        hex_nut(nut_diameter,nut_height,nut_thread_step,nut_step_shape_degrees,nut_thread_outer_diameter,nut_resolution);
    
    //top pipe block
    translate([0,nut_shift+2,z_block]) rotate(90,block_rot_ax) 
        hex_nut(nut_diameter,nut_height,nut_thread_step,nut_step_shape_degrees,nut_thread_outer_diameter,nut_resolution);
    translate([0,-nut_shift-2,z_block]) rotate(-90,block_rot_ax) 
        hex_screw(thread_outer_diameter,thread_step,step_shape_degrees,nut_shift*2.2,resolution,countersink,head_diameter,head_height,non_thread_length,non_thread_diameter);
  
}

module inner_vol() { // for cleanup
    r_in_pipe=d_out/2-w_pipe;
    union() {
        vpipe(p1[0],p1[1],0,l,r_in_pipe,r_in_pipe);
        vpipe(p2[0],p2[1],0,l,r_in_pipe,r_in_pipe);
        vpipe(p3[0],p3[1],0,l,r_in_pipe,r_in_pipe);
     }
}

//render()
union()
{   
    vpipe(p1[0],p1[1],0,l,d_out/2,w_pipe);
    vpipe(p2[0],p2[1],0,l,d_out/2,w_pipe);
    vpipe(p3[0],p3[1],0,l,d_out/2,w_pipe);
    difference(){
        union() { 
            build_reinforcement(p1,p2,l,num_crosspiece);
            build_reinforcement(p2,p3,l,num_crosspiece);
            build_ladder(p3,p1,l,rung_sp);
        }
        inner_vol();
    }

    build_mount();

    //top pipe
    vpipe(0,0,z_block,l,d_out/2,w_pipe);
    
    //anchors
    p1_anc=p1+p1/sqrt(p1*p1)*(d_out/2+d_rebar/2);
    p3_anc=p3+p3/sqrt(p3*p3)*(d_out/2+d_rebar/2);
    build_anchor(p1_anc,l_anchor,d_rebar/2,z_overlap_anchor,h_concrete,r_concrete);
    build_anchor(p3_anc,l_anchor,d_rebar/2,z_overlap_anchor,h_concrete,r_concrete);
    
    //grounding
    p2_gnd=p2+p2/sqrt(p2*p2)*(d_out/2+d_rebar/2);
    build_anchor(p2_gnd,l_gnd,d_rebar/2,z_overlap_anchor,h_concrete,r_concrete);
}