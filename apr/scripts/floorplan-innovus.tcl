# if no IOs
#floorPlan -s [lindex $design_size 0 ] [lindex $design_size 1 ] $design_io_border $design_io_border $design_io_border $design_io_border -flip s -coreMarginsBy die
# If IOs
#floorPlan -s [lindex $design_size 0 ] [lindex $design_size 1 ] 10 10 10 10 -flip s -coreMarginsBy io

defIn "../outputs/${top_design}.floorplan.innovus.macros.def" 
generateTracks -honorPitch

#loadFPlan
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *

checkDesign -powerGround -noHtml -outfile pg.rpt

#######
# Make sure you place the macros before starting the power mesh.  Or maybe remove the -onlyAIO option of the placeAIO -onlyAIO
######

# Power Grid here.  This is ICC2 version:
# M7/8 Mesh
#create_pg_mesh_pattern mesh_pat -layers {  {{vertical_layer: M8} {width: 4} {spacing: interleaving} {pitch: 16}}   \
#    {{horizontal_layer: M7} {width: 2}        {spacing: interleaving} {pitch: 8}}  }
#M2 Lower Mesh
# Orca does 0.350 width VSS two stripes, then 0.7u VDD stripe.  Repeating 16u. for now, do something simpler 
#create_pg_mesh_pattern lmesh_pat -layers {  {{vertical_layer: M2} {width: 0.7} {spacing: interleaving} {pitch: 16}}  } 
#M1 Std Cell grid
#create_pg_std_cell_conn_pattern rail_pat -layers {M1} -rail_width {0.06 0.06}
#   -via_rule {       {{layers: M6} {layers: M7} {via_master: default}}        {{layers: M8} {layers: M7} {via_master: VIA78_3x3}}}
#set_pg_strategy mesh_strat -core -extension {{stop:outermost_ring}} -pattern {{pattern:mesh_pat } { nets:{VDD VSS} } } 
#set_pg_strategy rail_strat -core -pattern {{pattern:rail_pat } { nets:{VDD VSS} } } 
#set_pg_strategy lmesh_strat -core -pattern {{pattern:lmesh_pat } { nets:{VDD VSS} } } 
#compile_pg -strategies {mesh_strat rail_strat lmesh_strat}

# Core power ring
#addRing -type core_rings -nets {VDD VSS} -layer {top M8 bottom M8 left M7 right M7} -offset 1 -width 4 -spacing 1.0
# Add Meshes
#You want the different metal stripes to be on top of the M1 stripe of the same VDD/VSS polarity
if {1==0} { 
set row_height 1.6720
set pwidth 0.060
set pset_to_set [expr 6 * $row_height]
set pspacing [expr 3 * $row_height - $pwidth ]
set pstart [ expr (3 * $row_height) - ($pwidth * 1 / 2.0) ] 
addStripe -nets {VSS VDD} -direction vertical   -layer M2 -width $pwidth -start $pstart -set_to_set_distance $pset_to_set -spacing $pspacing 
addStripe -nets {VSS VDD} -direction horizontal -layer M3 -width $pwidth -start $pstart -set_to_set_distance $pset_to_set -spacing $pspacing 
addStripe -nets {VSS VDD} -direction vertical   -layer M4 -width $pwidth -start $pstart -set_to_set_distance $pset_to_set -spacing $pspacing 
set pwidth 0.120
set pset_to_set [expr 6 * $row_height]
set pspacing [expr 3 * $row_height - $pwidth ]
set pstart [ expr (3 * $row_height) - ($pwidth * 1 / 2.0) ] 
addStripe -nets {VSS VDD} -direction horizontal -layer M5 -width $pwidth -start $pstart -set_to_set_distance $pset_to_set -spacing $pspacing 
addStripe -nets {VSS VDD} -direction vertical   -layer M6 -width $pwidth -start $pstart -set_to_set_distance $pset_to_set -spacing $pspacing 
set pwidth 1.20
set pset_to_set [expr 18 * $row_height]
set pspacing [expr 9 * $row_height - $pwidth ]
set pstart [ expr (9 * $row_height) - ($pwidth * 1 / 2.0) ] 
addStripe -nets {VSS VDD} -direction horizontal -layer M7 -width $pwidth -start $pstart -set_to_set_distance $pset_to_set -spacing $pspacing 
set pwidth 2.40
set pset_to_set [expr 54 * $row_height]
set pspacing [expr 27 * $row_height - $pwidth ]
set pstart [ expr (27 * $row_height) - ($pwidth * 1 / 2.0) ] 
addStripe -nets {VSS VDD} -direction vertical   -layer M8 -width $pwidth -start $pstart -set_to_set_distance $pset_to_set -spacing $pspacing 
sroute -connect {corePin padPin} -crossoverViaLayerRange {1 2}
}

#connect_global_net VDD -type pg_pin -pin VDD -inst_base_name *
#connect_global_net VSS -type pg_pin -pin VSS -inst_base_name *

#add_rings -center 1 -layer {bottom M7 top M7 left M8 right M8} -width 5 -spacing 2 -nets {VDD VSS}
addStripe -spacing 20 -layer M8 -width 3 -nets {VDD VSS} -set_to_set_distance 200
addStripe -spacing 20 -layer M7 -width 1 -nets {VDD VSS} -set_to_set_distance 200 -direction horizontal
sroute -connect corePin -layerChangeRange { M1(1) M8(8) } -blockPinTarget nearestTarget -corePinTarget firstAfterRowEnd -allowJogging 1 -crossoverViaLayerRange { M1(1) M8(8) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { M1(1) M8(8) }

#addStripe -nets {VDD VSS} -direction vertical   -layer M2 -width 0.060 -set_to_set_distance 20 -spacing 10
#addStripe -nets {VDD VSS} -direction horizontal   -layer M3 -width 0.060 -set_to_set_distance 20 -spacing 10
#addStripe -nets {VDD VSS} -direction vertical   -layer M4 -width 0.060 -set_to_set_distance 20 -spacing 10
#addStripe -nets {VDD VSS} -direction horizontal   -layer M5 -width 0.120 -set_to_set_distance 20 -spacing 10
#addStripe -nets {VDD VSS} -direction vertical   -layer M6 -width 0.120 -set_to_set_distance 20 -spacing 10
#addStripe -nets {VDD VSS} -direction horizontal   -layer M7 -width 2 -set_to_set_distance 40 -spacing 20
#addStripe -nets {VDD VSS} -direction vertical   -layer M8 -width 4 -set_to_set_distance 80 -spacing 40

# Connect full grid and add M1 VDD/VSS rails. 

# Placing pins and spreading pins out. 
#editPin -edge 3 -pin [get_attribute [get_ports *] full_name] -layer 4 -spreadDirection clockwise -spreadType RANGE -offsetStart 100 -fixedPin 1 -fixOverlap 1 

#source -echo -verbose ../../${top_design}.macro_placement_innovus.tcl
defOut -noStdCells "../outputs/${top_design}.floorplan.innovus.def"


#defOut -noStdCells -noTracks -noSpecialNet -noTracks  "../outputs/${top_design}.floorplan.innovus.macros.def"

deselectAll
select_obj [ get_ports * ]
select_obj [ get_db insts -if ".is_black_box==true" ]
select_obj [ get_db insts -if ".is_pad==true" ]
#defOut -selected "../outputs/${top_design}.floorplan.innovus.macros.def"



puts "Logfile message: writing def file completed ..."


