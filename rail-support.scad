/* ==========================================================================
   MAKITA GUIDE RAIL DROP-IN DOVETAIL SUPPORT & FULL SHIM KIT
   Calibrated to Makita 183mm Extrusion Technical Drawing
   - Blind sliding dovetail with 3mm rear end-stop for automatic flush alignment
   - Complete stackable shim kit (1mm, 2mm, 3mm, 6mm) included on print plate
   - Pre-oriented on sides for zero-support printing & maximum layer strength
   ========================================================================== */

// --- RENDER SELECTION ---
// Options: "print_plate", "assembly_preview", "bottom_base", "top_bridge", "shim"
part_to_render = "print_plate"; 

// --- HEIGHT SETTINGS (mm) ---
// base_support_height = exact thickness of your base workpiece (e.g., 12.0 for 1/2" ply)
base_support_height = 12.0; 
single_shim_h       = 6.0;   // Used only if part_to_render is set to single "shim"
shim_set_heights    = [1.0, 2.0, 3.0, 6.0]; // Full kit rendered on "print_plate"
support_depth       = 35.0;  // Front-to-back depth of the support block

// --- MAKITA RAIL DIMENSIONS FROM DRAWING (mm) ---
// Datum X = 0 is the outer left (non-cutting) aluminum edge
// Datum Z = base_support_height is the bottom face of the rail's glide strips
rail_width              = 183.0; // Aluminum extrusion width (186mm includes splinter strip)
splinter_clearance      = 4.0;   // Stops short of right edge to clear blade & splinter guard
left_total_height       = 10.8;  // Total height at left edge (2.1 glide + 6.6 wall + 2.1 lip)

// Top T-Slot (16mm outer housing, 12mm inner slot, 8.5mm top opening)
dist_edge_to_top_open   = 3.75;  // (16 - 8.5) / 2 from outer left edge (X = 0)
top_slot_opening        = 8.5;   // Top T-slot opening width

// Underside Guide Channel (Starts at 16 + 32 = 48mm; 16mm rib, 12mm inner, 8.5mm opening)
dist_edge_to_bot_open   = 51.75; // 48 + (16 - 8.5) / 2 from outer left edge (X = 0)
bot_slot_opening        = 8.5;   // Bottom T-slot opening width
bot_key_height          = 4.0;   // Height of guide key (clears the 12mm interior cavity)

// --- WIDE SIDE WING & BLIND DOVETAIL SETTINGS ---
side_wing_w             = 16.0;  // Wider 16mm side wing for high rigidity
dt_neck_w               = 6.5;   // Narrow top neck of the dovetail
dt_base_w               = 9.5;   // Wide bottom base of the dovetail
dt_height               = 5.5;   // Vertical engagement depth of the dovetail
dt_end_stop_wall        = 3.0;   // Solid rear wall thickness at back of dovetail slot
tolerance               = 0.25;  // Sliding fit tolerance (adjust 0.20-0.30 for your printer)

// --- HARDWARE & SHIM PIN SETTINGS ---
bolt_hole_dia           = 6.4;   // Clearance hole for an M6 drop-in T-bolt
pin_dia                 = 6.0;   // Alignment peg diameter between base and shims
pin_height              = 3.0;   // Height of alignment pegs

$fn = 40;

// Derived Dimensions
top_slot_center_x = dist_edge_to_top_open + (top_slot_opening / 2); // 8.0mm from left edge
bot_slot_center_x = dist_edge_to_bot_open + (bot_slot_opening / 2); // 56.0mm from left edge
bot_key_width     = bot_slot_opening - (tolerance * 2);             // 8.0mm for smooth sliding

block_width  = rail_width - splinter_clearance; // 179.0mm
top_arm_h    = 5.0;  // Low-profile top arm height (clears saw motor/baseplate)
top_arm_len  = 16.0; // Covers the full 16mm width of the top T-slot housing
dt_center_x  = -side_wing_w / 2; // Centered at X = -8.0mm inside the 16mm side wing
dt_slot_len  = support_depth - dt_end_stop_wall; // 32.0mm blind slot depth

// Helper module to generate a 3D dovetail prism along the Y-axis
module dovetail_prism(neck_w, base_w, h, len) {
    rotate([-90, 0, 0])
        linear_extrude(height = len)
            polygon(points = [
                [-neck_w / 2, 0],
                [ neck_w / 2, 0],
                [ base_w / 2, h],
                [-base_w / 2, h]
            ]);
}

module alignment_pins(is_hole = false) {
    d = is_hole ? pin_dia + tolerance : pin_dia - tolerance;
    h = is_hole ? pin_height + 0.4 : pin_height;
    
    for (x_pos = [15, block_width / 2, block_width - 20]) {
        translate([x_pos, support_depth / 2, 0])
            cylinder(d = d, h = h);
    }
}

module bottom_base() {
    chamfer_len = block_width + side_wing_w + 2;
    chamfer_x   = (block_width - side_wing_w) / 2;

    difference() {
        union() {
            // 1. Main Full-Width Support Base + Wide 16mm Left Side Wing
            translate([-side_wing_w, 0, 0])
                cube([block_width + side_wing_w, support_depth, base_support_height]);
            
            // 2. Underside Channel Guide Register (centered at X = 56.0mm)
            translate([bot_slot_center_x - (bot_key_width / 2), 0, base_support_height])
                cube([bot_key_width, support_depth, bot_key_height]);
        }
        
        // Subtract Blind Female Dovetail Slot (stops 3mm short of rear face)
        translate([dt_center_x, -0.01, base_support_height + 0.01])
            dovetail_prism(
                neck_w = dt_neck_w + (tolerance * 2),
                base_w = dt_base_w + (tolerance * 2),
                h      = dt_height + tolerance,
                len    = dt_slot_len + 0.01
            );
            
        // Bottom alignment pin holes for attaching stackable shims
        translate([0, 0, -0.01])
            alignment_pins(is_hole = true);
            
        // Chamfer front and back bottom edges so the rail slides smoothly over bench seams
        translate([chamfer_x, 0, 0])
            rotate([45, 0, 0])
            cube([chamfer_len, 3, 3], center=true);
        translate([chamfer_x, support_depth, 0])
            rotate([45, 0, 0])
            cube([chamfer_len, 3, 3], center=true);
    }
}

module top_bridge() {
    top_z       = base_support_height + left_total_height + tolerance;
    neck_span   = side_wing_w - 4.0; // Sturdy 12mm vertical neck connecting top arm to dovetail
    male_dt_len = dt_slot_len - tolerance; // Stops flush against the 3mm rear end-stop

    difference() {
        union() {
            // 1. Top Plate spanning from the wide side wing over the 16mm T-slot housing
            translate([-side_wing_w, 0, top_z])
                cube([top_arm_len + side_wing_w, support_depth, top_arm_h]);
                
            // 2. Registration Nub that drops into the 8.5mm top T-slot opening
            translate([dist_edge_to_top_open + tolerance, 0, top_z - 1.5])
                cube([top_slot_opening - (tolerance * 2), support_depth, 1.5]);
                
            // 3. Sturdy Vertical Neck dropping down alongside the outer rail edge
            translate([-side_wing_w + 2.0, 0, base_support_height + tolerance])
                cube([neck_span, support_depth, left_total_height + 0.01]);
                
            // 4. Male Dovetail Tail (shortened to seat against the 3mm rear end-stop)
            translate([dt_center_x, 0, base_support_height + tolerance + 0.01])
                dovetail_prism(
                    neck_w = dt_neck_w,
                    base_w = dt_base_w,
                    h      = dt_height,
                    len    = male_dt_len
                );
        }
        
        // M6 Bolt Hole centered on the Top T-Slot (X = 8.0mm)
        translate([top_slot_center_x, support_depth / 2, top_z - 3.0])
            cylinder(d = bolt_hole_dia, h = top_arm_h + 6.0);
    }
}

module stackable_shim(h_val = 6.0) {
    chamfer_len = block_width + side_wing_w + 2;
    chamfer_x   = (block_width - side_wing_w) / 2;

    difference() {
        union() {
            // Shim body matching the full footprint of the Bottom Base + 16mm side wing
            translate([-side_wing_w, 0, 0])
                cube([block_width + side_wing_w, support_depth, h_val]);
            
            // Top male alignment pins that plug into the Bottom Base or upper shim
            translate([0, 0, h_val])
                alignment_pins(is_hole = false);
        }
        
        // Bottom female pin holes (only on thicker shims so pins don't poke through)
        if (h_val >= pin_height + 1.2) {
            translate([0, 0, -0.01])
                alignment_pins(is_hole = true);
        }

        // Chamfer front and back bottom edges on shims >= 3mm
        if (h_val >= 3.0) {
            translate([chamfer_x, 0, 0])
                rotate([45, 0, 0])
                cube([chamfer_len, 3, 3], center=true);
            translate([chamfer_x, support_depth, 0])
                rotate([45, 0, 0])
                cube([chamfer_len, 3, 3], center=true);
        }
    }
}

// Render chosen mode
if (part_to_render == "print_plate") {
    spacing = 14.0;
    
    // 1. Bottom Base (lying on its front face; blind dovetail opens upward for zero supports)
    translate([side_wing_w, 0, 0])
        rotate([-90, 0, 0])
        bottom_base();
        
    // 2. Top Bridge (lying on its side right behind the Bottom Base)
    y_bridge = base_support_height + bot_key_height + spacing;
    translate([side_wing_w, y_bridge, 0])
        rotate([-90, 0, 0])
        top_bridge();
        
    // 3. Full Set of Stackable Shims (1mm, 2mm, 3mm, 6mm) laid out behind Top Bridge
    y_shims_start = y_bridge + base_support_height + left_total_height + top_arm_h + spacing;
    for (i = [0 : len(shim_set_heights) - 1]) {
        h_curr = shim_set_heights[i];
        y_offset = y_shims_start + i * (6.0 + pin_height + spacing);
        translate([side_wing_w, y_offset, 0])
            rotate([-90, 0, 0])
            stackable_shim(h_val = h_curr);
    }
        
} else if (part_to_render == "bottom_base") {
    bottom_base();
} else if (part_to_render == "top_bridge") {
    top_bridge();
} else if (part_to_render == "shim") {
    stackable_shim(h_val = single_shim_h);
} else if (part_to_render == "assembly_preview") {
    color("SteelBlue") bottom_base();
    color("Orange")    top_bridge();
color("LightGrey") translate([0, 0, -6.0 - 2]) stackable_shim(h_val = 6.0);
color("Silver")    translate([0, 0, -6.0 - 3.0 - 4]) stackable_shim(h_val = 3.0);
}