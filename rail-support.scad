// ==========================================================================
// MAKITA GUIDE RAIL DROP-IN DOVETAIL SUPPORT & GRAVITY-LOCKING SHIM KIT
// Calibrated to Makita 183mm Extrusion Technical Drawing
// - Shims use horizontal sliding dovetails so they stay attached when lifted
// - Shims print FLAT on the build plate for maximum adhesion (no wobbling)
// - Bottom Base & Top Bridge print on their sides with zero supports needed
// ==========================================================================

// --- RENDER SELECTION ---
// Options: "print_plate", "assembly_preview", "bottom_base", "top_bridge", "shim"
part_to_render = "print_plate"; 

// --- HEIGHT SETTINGS (mm) ---
base_support_height = 12.0; // Base height (12.0mm = 1/2" ply)
single_shim_h       = 26.0; // Used when part_to_render is set to single "shim"
shim_set_heights    = [1.0, 2.0, 3.0, 6.0, 26.0]; // 12mm base + 26mm = 38mm (2x4 stud)
support_depth       = 35.0; // Front-to-back depth of the support block

// --- MAKITA RAIL DIMENSIONS FROM DRAWING (mm) ---
rail_width              = 183.0; // Aluminum extrusion width (186mm includes splinter strip)
splinter_clearance      = 4.0;   // Stops short of right edge to clear blade & splinter guard
left_total_height       = 10.8;  // Total height at left edge (2.1 glide + 6.6 wall + 2.1 lip)

// Top T-Slot (16mm outer housing, 12mm inner slot, 8.5mm top opening)
dist_edge_to_top_open   = 3.75;  // From outer left edge (X = 0) to near lip
top_slot_opening        = 8.5;   // Top T-slot opening width

// Underside Guide Channel (Starts at 48mm; 16mm rib, 12mm inner, 8.5mm opening)
dist_edge_to_bot_open   = 51.75; // From outer left edge (X = 0) to near wall
bot_slot_opening        = 8.5;   // Bottom T-slot opening width
bot_key_height          = 4.0;   // Height of guide key

// --- SIDE WING & TOP BRIDGE DOVETAIL SETTINGS ---
side_wing_w             = 16.0;  // Wider 16mm side wing for high rigidity
dt_neck_w               = 6.5;   // Narrow top neck of the side dovetail
dt_base_w               = 9.5;   // Wide bottom base of the side dovetail
dt_height               = 5.5;   // Vertical engagement depth of the side dovetail
dt_end_stop_wall        = 3.0;   // Solid rear wall thickness at back of dovetail slot
tolerance               = 0.25;  // Sliding fit tolerance

// --- SHIM GRAVITY-LOCK DOVETAIL SETTINGS ---
shim_dt_neck_w          = 6.0;   // Narrow neck width of shim dovetail
shim_dt_base_w          = 8.4;   // Wide flared top width of shim dovetail
shim_dt_height          = 2.2;   // Height of shim dovetail lock
shim_dt_stop_wall       = 2.5;   // Rear stop wall so shims don't slide out the back

// --- HARDWARE SETTINGS ---
bolt_hole_dia           = 6.4;   // Clearance hole for an M6 drop-in T-bolt

$fn = 40;

// Derived Dimensions
top_slot_center_x = dist_edge_to_top_open + (top_slot_opening / 2); // 8.0mm
bot_slot_center_x = dist_edge_to_bot_open + (bot_slot_opening / 2); // 56.0mm
bot_key_width     = bot_slot_opening - (tolerance * 2);             // 8.0mm

block_width     = rail_width - splinter_clearance; // 179.0mm
top_arm_h       = 5.0;  // Low-profile top arm height
top_arm_len     = 16.0; // Covers the full 16mm width of the top T-slot housing
dt_center_x     = -side_wing_w / 2; // Centered at X = -8.0mm
dt_slot_len     = support_depth - dt_end_stop_wall; // 32.0mm blind slot depth
shim_dt_len     = support_depth - shim_dt_stop_wall; // 32.5mm blind shim slot depth

// Rotation angle variables
ang_neg90 = -90;
ang_pos90 = 90;
ang_45    = 45;
ang_zero  = 0;

// Helper module: 45-degree chamfer bar along the X-axis
module chamfer_bar(len) {
    rotate([ang_zero, ang_pos90, ang_zero])
        linear_extrude(height = len, center = true)
            rotate(ang_45)
                square([2.2, 2.2], center = true);
}

// Helper module: 3D dovetail prism along the Y-axis
module dovetail_prism(neck_w, base_w, h, len, inverted = false) {
    z_top = inverted ? -h : h;
    rotate([ang_neg90, ang_zero, ang_zero])
        linear_extrude(height = len)
            polygon(points = [
                [-neck_w / 2, ang_zero],
                [ neck_w / 2, ang_zero],
                [ base_w / 2, z_top],
                [-base_w / 2, z_top]
            ]);
}

// Helper module: Teardrop cylinder along Z-axis (prints horizontally with zero sag)
module teardrop_hole(d, h) {
    r = d / 2;
    linear_extrude(height = h)
        union() {
            circle(r = r);
            polygon(points = [
                [-r * 0.707, -r * 0.707],
                [ r * 0.707, -r * 0.707],
                [ ang_zero, -r * 1.414]
            ]);
        }
}

// Helper module: Three gravity-locking sliding dovetails for the shims
module shim_dovetails(is_slot = false) {
    nw  = is_slot ? shim_dt_neck_w + (tolerance * 2) : shim_dt_neck_w;
    bw  = is_slot ? shim_dt_base_w + (tolerance * 2) : shim_dt_base_w;
    h   = is_slot ? shim_dt_height + tolerance : shim_dt_height;
    len = is_slot ? shim_dt_len + 0.02 : shim_dt_len - tolerance;
    y_pos = is_slot ? -0.02 : ang_zero;
    z_pos = is_slot ? -0.01 : ang_zero;

    for (x_pos = [15, block_width / 2, block_width - 20]) {
        translate([x_pos, y_pos, z_pos])
            dovetail_prism(neck_w = nw, base_w = bw, h = h, len = len, inverted = true);
    }
}

module bottom_base() {
    chamfer_len = block_width + side_wing_w + 2;
    chamfer_x   = (block_width - side_wing_w) / 2;

    difference() {
        union() {
            // 1. Main Full-Width Support Base + Wide 16mm Left Side Wing
            translate([-side_wing_w, ang_zero, ang_zero])
                cube([block_width + side_wing_w, support_depth, base_support_height]);
            
            // 2. Underside Channel Guide Register (centered at X = 56.0mm)
            translate([bot_slot_center_x - (bot_key_width / 2), ang_zero, base_support_height])
                cube([bot_key_width, support_depth, bot_key_height]);
        }
        
        // Subtract Blind Female Dovetail Slot on left wing (stops 3mm short of rear face)
        translate([dt_center_x, -0.01, base_support_height + 0.01])
            dovetail_prism(
                neck_w = dt_neck_w + (tolerance * 2),
                base_w = dt_base_w + (tolerance * 2),
                h      = dt_height + tolerance,
                len    = dt_slot_len + 0.01,
                inverted = false
            );
            
        // Subtract bottom blind dovetail slots so shims lock on against gravity
        shim_dovetails(is_slot = true);
            
        // Engraved "12mm" label on the front face
        translate([block_width * 0.65, 0.6, base_support_height / 2])
            rotate([ang_pos90, ang_zero, ang_zero])
                linear_extrude(height = 0.8)
                    text("12mm", size = 5.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
            
        // Chamfer front and back bottom edges
        translate([chamfer_x, ang_zero, ang_zero])
            chamfer_bar(chamfer_len);
        translate([chamfer_x, support_depth, ang_zero])
            chamfer_bar(chamfer_len);
    }
}

module top_bridge() {
    top_z       = base_support_height + left_total_height + tolerance;
    neck_span   = side_wing_w - 4.0;
    male_dt_len = dt_slot_len - tolerance;

    difference() {
        union() {
            // 1. Top Plate spanning from the wide side wing over the 16mm T-slot housing
            translate([-side_wing_w, ang_zero, top_z])
                cube([top_arm_len + side_wing_w, support_depth, top_arm_h]);
                
            // 2. Registration Nub that drops into the 8.5mm top T-slot opening
            translate([dist_edge_to_top_open + tolerance, ang_zero, top_z - 1.5])
                cube([top_slot_opening - (tolerance * 2), support_depth, 1.5]);
                
            // 3. Sturdy Vertical Neck dropping down alongside the outer rail edge
            translate([-side_wing_w + 2.0, ang_zero, base_support_height + tolerance])
                cube([neck_span, support_depth, left_total_height + 0.01]);
                
            // 4. Male Dovetail Tail (shortened to seat against the 3mm rear end-stop)
            translate([dt_center_x, ang_zero, base_support_height + tolerance + 0.01])
                dovetail_prism(
                    neck_w = dt_neck_w,
                    base_w = dt_base_w,
                    h      = dt_height,
                    len    = male_dt_len,
                    inverted = false
                );
        }
        
        // Zero-sag Teardrop M6 Bolt Hole centered on the Top T-Slot (X = 8.0mm)
        translate([top_slot_center_x, support_depth / 2, top_z - 3.0])
            teardrop_hole(d = bolt_hole_dia, h = top_arm_h + 6.0);
    }
}

module stackable_shim(h_val = 6.0) {
    chamfer_len = block_width + side_wing_w + 2;
    chamfer_x   = (block_width - side_wing_w) / 2;
    label_txt   = (h_val == 26.0) ? "26mm (2x4)" : str(h_val, "mm");
    txt_size    = (h_val < 3.0) ? 3.5 : 5.0;

    difference() {
        union() {
            // Shim body matching the full footprint of the Bottom Base + 16mm side wing
            translate([-side_wing_w, ang_zero, ang_zero])
                cube([block_width + side_wing_w, support_depth, h_val]);
            
            // Top male gravity-locking dovetails
            translate([ang_zero, ang_zero, h_val - 0.01])
                shim_dovetails(is_slot = false);
        }
        
        // Bottom female dovetail slots (on shims >= 4mm so upper slot roof stays strong)
        if (h_val >= shim_dt_height + 1.8) {
            shim_dovetails(is_slot = true);
        }

        // Recessed height label
        if (h_val >= 3.0) {
            translate([block_width * 0.65, 0.6, h_val / 2])
                rotate([ang_pos90, ang_zero, ang_zero])
                    linear_extrude(height = 0.8)
                        text(label_txt, size = txt_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        } else {
            // On 1mm & 2mm shims, label sits cleanly on the top face between dovetails
            translate([block_width * 0.68, support_depth / 2, h_val - 0.45])
                linear_extrude(height = 0.6)
                    text(label_txt, size = 5.0, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
        }

        // Chamfer front and back bottom edges on shims >= 3mm
        if (h_val >= 3.0) {
            translate([chamfer_x, ang_zero, ang_zero])
                chamfer_bar(chamfer_len);
            translate([chamfer_x, support_depth, ang_zero])
                chamfer_bar(chamfer_len);
        }
    }
}

// Render chosen mode (using standalone if blocks for full OpenSCAD compatibility)
if (part_to_render == "print_plate") {
    spacing = 12.0;

    // 1. Bottom Base (rotated on its rear face; blind dovetails open upward)
    translate([side_wing_w, ang_zero, ang_zero])
        rotate([ang_neg90, ang_zero, ang_zero])
            bottom_base();

    // 2. Top Bridge (rotated on its rear face; teardrop hole prints with zero sag)
    y_bridge = base_support_height + bot_key_height + spacing;
    translate([side_wing_w, y_bridge, ang_zero])
        rotate([ang_neg90, ang_zero, ang_zero])
            top_bridge();

    // 3. Full Set of Stackable Shims laid out FLAT on the build plate (1mm, 2mm, 3mm, 6mm, 26mm)
    y_shims_start = y_bridge + base_support_height + left_total_height + top_arm_h + spacing;
    for (i = [0 : len(shim_set_heights) - 1]) {
        h_curr   = shim_set_heights[i];
        y_offset = y_shims_start + i * (support_depth + spacing);
        translate([side_wing_w, y_offset, ang_zero])
            stackable_shim(h_val = h_curr);
    }
}
if (part_to_render == "bottom_base") {
    bottom_base();
}
if (part_to_render == "top_bridge") {
    top_bridge();
}
if (part_to_render == "shim") {
    stackable_shim(h_val = single_shim_h);
}
if (part_to_render == "assembly_preview") {
    color("SteelBlue") bottom_base();
    color("Orange")    top_bridge();
    color("LightGrey") translate([ang_zero, ang_zero, -26.0 - 2]) stackable_shim(h_val = 26.0);
}
