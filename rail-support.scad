// ==========================================================================
// MAKITA GUIDE RAIL DROP-IN SUPPORT & STACKABLE SHIM KIT
// Calibrated to the Makita 183mm extrusion drawing (docs/makita-rail-profile.jpg)
// - Top bridge joins the base with a blind sliding dovetail that snaps into
//   place: a split, springy tail with detent bumps seats with no play
// - Shims attach with either magnets or sliding dovetails (shim_connection)
// - Base & bridge print on their rear faces, shims print flat, no supports
//
// Coordinates: X runs across the rail (X = 0 is the rail's outer, non-cutting
// edge), Y runs front (0) to back, Z is up (Z = 0 is the bench).
// ==========================================================================

/* [Render] */
part_to_render = "print_plate"; // [print_plate, assembly_preview, bottom_base, top_bridge, shim]

/* [Heights] */
base_support_height = 12.0; // Base height = workpiece thickness (12.0mm = 1/2" ply)
single_shim_h       = 26.0; // Used when part_to_render = "shim"
shim_set_heights    = [1.0, 2.0, 3.0, 6.0, 26.0]; // Kit laid out on "print_plate"
preview_shims       = [26.0]; // Stack shown under the base in "assembly_preview"
support_depth       = 35.0; // Front-to-back depth of the support

/* [Shim connection] */
shim_connection  = "magnet"; // [magnet, dovetail]
connector_inset  = 15.0;     // X distance of the outer magnets/dovetails from each end

// Magnets: all of them go in with the same pole facing down, so any stack attracts.
// Every shim's top magnet sticks up magnet_protrude above its top face, and every
// part has a socket under its bottom magnet that the magnet below nests into.
// Magnets meet face to face and double as locating pegs.
magnet_d         = 10.0;  // Magnet diameter
magnet_h         = 2.0;   // Magnet thickness
magnet_protrude  = 1.0;   // How far each shim's top magnet sticks up (< magnet_h)
magnet_fit       = 0.2;   // Added to hole diameter (~0.1 press fit, ~0.3 glue-in)
magnet_recess    = 0.15;  // Sockets are this much deeper than magnet_protrude
magnet_min_floor = 0.6;   // Least plastic between a socket and a pocket

// Dovetail shims
shim_dt_neck_w       = 8.0;  // Narrow neck of the shim dovetail (at the shim face)
shim_dt_base_w       = 11.0; // Wide flared end of the shim dovetail
shim_dt_height       = 2.4;  // Height of the shim dovetail
shim_dt_clearance    = 0.2;  // Gap measured square to each face of the dovetail
shim_dt_root_chamfer = 0.6;  // Fillet at the tail root; also chamfers the slot mouth
shim_dt_stop_wall    = 2.5;  // Rear stop wall so shims don't slide out the back
shim_min_roof        = 1.6;  // Least plastic above a shim's bottom slot

/* [Makita rail] */
rail_width            = 183.0; // Aluminum extrusion width (186mm includes splinter strip)
splinter_clearance    = 4.0;   // Stops short of right edge to clear blade & splinter guard
left_total_height     = 10.8;  // Total height at left edge (2.1 glide + 6.6 wall + 2.1 lip)
dist_edge_to_top_open = 3.75;  // From outer left edge (X = 0) to near lip of top T-slot
top_slot_opening      = 8.5;   // Top T-slot opening width
dist_edge_to_bot_open = 51.75; // From outer left edge (X = 0) to near wall of underside channel
bot_slot_opening      = 8.5;   // Underside channel opening width
bot_key_height        = 4.0;   // Height of guide key

/* [Bridge joint] */
side_wing_w      = 20.0; // Wing left of the rail that carries the dovetail and post
dt_neck_w        = 8.0;  // Narrow top neck of the dovetail
dt_base_w        = 13.0; // Wide bottom of the dovetail
dt_height        = 5.0;  // Vertical engagement depth of the dovetail
dt_clearance     = 0.15; // Gap measured square to each face of the dovetail
dt_end_stop_wall = 3.0;  // Solid rear wall at the back of the dovetail slot
dt_seat_gap      = 0.05; // Post-to-wing gap when the dovetail is seated
post_rail_gap    = 0.2;  // Gap between the bridge post and the rail's outer edge
rail_clamp_gap   = 0.25; // Gap between the top plate and rail top before tightening

// Snap fit: the tail is split into two springy halves with detent bumps near its
// front end. They click into grooves just inside the slot mouth when seated.
dt_snap        = true;
dt_flex_wall   = 1.6;  // Thickness of each springy half where it leaves the post
dt_flex_len    = 9.0;  // How far the split runs up into the post (longer = softer)
dt_relief_w    = 1.0;  // Slots that free the springy halves from the rest of the post
dt_spine       = true; // Solid spine between the springy walls in the post
dt_spine_gap   = 0.5;  // Gap from the spine to each wall and to the tail
dt_tail_split_w = 1.0; // Split width inside the tail. The halves can only squeeze
                       // together this far, so it must be enough for the detent
                       // bumps to pass but far less than the dovetail flare, or the
                       // tail can be pulled out of the slot.
dt_bump_h      = 0.4;  // Detent bump height on each flank
dt_preload     = 0.1;  // Bump stays this much compressed when seated (removes play)
dt_bump_y      = 1.0;  // Bump starts this far behind the tail's front end
dt_bump_ramp   = 1.5;  // Length of each bump ramp
dt_bump_flat   = 1.0;  // Length of the bump's flat top

/* [Hardware & fit] */
bolt_hole_dia = 6.4;  // Clearance hole for an M6 drop-in T-bolt
tolerance     = 0.25; // Sliding fit for the underside key and top registration nub

$fn = 48;

// ---- Rotation angle variables (kept as variables for OpenSCAD compatibility) ----
ang_neg90 = -90;
ang_pos90 = 90;
ang_45    = 45;
ang_zero  = 0;

// ---- Derived dimensions ----
block_width       = rail_width - splinter_clearance;                // 179.0mm
top_slot_center_x = dist_edge_to_top_open + (top_slot_opening / 2); // 8.0mm
bot_slot_center_x = dist_edge_to_bot_open + (bot_slot_opening / 2); // 56.0mm
bot_key_width     = bot_slot_opening - (tolerance * 2);             // 8.0mm
top_arm_h         = 5.0;  // Low-profile top arm height
top_arm_len       = 16.0; // Covers the full 16mm width of the top T-slot housing
top_z             = base_support_height + left_total_height + rail_clamp_gap;
connector_x       = [connector_inset, block_width / 2, block_width - connector_inset];

// Bridge dovetail. The tail is drawn in its seated position: lifted until its
// flanks touch the slot's overhanging flanks.
dt_center_x    = -side_wing_w / 2;
dt_theta       = atan(((dt_base_w - dt_neck_w) / 2) / dt_height);
dt_lift        = dt_clearance / sin(dt_theta);
dt_slot_len    = support_depth - dt_end_stop_wall;
dt_tail_len    = dt_slot_len - 0.3;
dt_tail_top_z  = base_support_height + dt_lift;
dt_tail_bot_z  = base_support_height - dt_height + dt_lift;
dt_tail_w_at_top_face = dt_neck_w + 2 * dt_lift * tan(dt_theta); // at Z = base top
dt_kerf_w      = dt_tail_w_at_top_face - 2 * dt_flex_wall; // split width in the post
dt_flare       = (dt_base_w - dt_neck_w) / 2;                // flare per side
post_z0        = base_support_height + dt_seat_gap;

// Shim dovetails
shim_slot_len   = support_depth - shim_dt_stop_wall;
shim_tail_len   = shim_slot_len - 0.3;
shim_slot_min_h = shim_dt_height + shim_dt_clearance + shim_min_roof;

// Magnets
magnet_pocket_d     = magnet_d + magnet_fit;
magnet_top_depth    = magnet_h - magnet_protrude;      // top pocket: magnet sticks up
magnet_socket       = magnet_protrude + magnet_recess; // empty space under a bottom magnet

// Shims thinner than a magnet only fit the stack if their magnet sticks up by
// exactly magnet_protrude
for (h = shim_set_heights)
    if (shim_connection == "magnet" && h < magnet_h && abs(magnet_h - h - magnet_protrude) > 0.01)
        echo(str("WARNING: the ", h, "mm shim's magnet sticks up ", magnet_h - h,
                 "mm, not magnet_protrude (", magnet_protrude, "mm), so it won't seat in the sockets"));

// Bridge snap sanity checks
if (dt_snap && dt_tail_split_w / 2 >= dt_flare - dt_clearance - 0.5)
    echo(str("WARNING: dt_tail_split_w (", dt_tail_split_w, "mm) lets the tail halves squeeze ",
             "together far enough to pull out of the slot; keep it well under ",
             2 * (dt_flare - dt_clearance - 0.5), "mm"));
if (dt_snap && dt_tail_split_w / 2 < dt_bump_h - dt_clearance)
    echo(str("WARNING: dt_tail_split_w (", dt_tail_split_w, "mm) is too narrow for the detent ",
             "bumps to pass; make it at least ", 2 * (dt_bump_h - dt_clearance), "mm"));

if (dt_snap && dt_spine && dt_spine_gap < dt_bump_h - dt_clearance + 0.1)
    echo(str("WARNING: dt_spine_gap (", dt_spine_gap, "mm) may not leave the springy walls ",
             "enough room to flex past the detent bumps; try at least ",
             dt_bump_h - dt_clearance + 0.1, "mm"));

function sum_to(v, i) = i < 0 ? 0 : v[i] + sum_to(v, i - 1);

// ==========================================================================
// Helpers
// ==========================================================================

// Extrude a 2D profile drawn in the XZ plane (2D y = Z) along +Y from y0.
module xz_prism(y0, len) {
    translate([ang_zero, y0 + len, ang_zero])
        rotate([ang_pos90, ang_zero, ang_zero])
            linear_extrude(height = len)
                children();
}

// Extrude a 2D profile drawn in the YZ plane (2D x = Y, 2D y = Z) along +X from x0.
module yz_prism(x0, len) {
    translate([x0, ang_zero, ang_zero])
        rotate([ang_pos90, ang_zero, ang_pos90])
            linear_extrude(height = len)
                children();
}

// 45-degree chamfer bar along the X-axis
module chamfer_bar(len) {
    rotate([ang_zero, ang_pos90, ang_zero])
        linear_extrude(height = len, center = true)
            rotate(ang_45)
                square([2.2, 2.2], center = true);
}

// Teardrop hole along Z with its point toward -Y. Parts that print on their
// rear face have -Y pointing up, so the hole prints without sagging.
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

module front_label(txt, size, zc) {
    translate([block_width * 0.65, 0.6, zc])
        rotate([ang_pos90, ang_zero, ang_zero])
            linear_extrude(height = 0.8)
                text(txt, size = size, halign = "center", valign = "center",
                     font = "Liberation Sans:style=Bold");
}

// ==========================================================================
// Bridge dovetail profiles (XZ plane, X relative to dt_center_x)
// ==========================================================================

// Tail in its seated position
module dt_tail_2d() {
    polygon(points = [
        [-dt_neck_w / 2, dt_tail_top_z],
        [ dt_neck_w / 2, dt_tail_top_z],
        [ dt_base_w / 2, dt_tail_bot_z],
        [-dt_base_w / 2, dt_tail_bot_z]
    ]);
}

// Slot: the nominal tail, offset by the clearance square to every face
module dt_slot_2d() {
    offset(delta = dt_clearance)
        polygon(points = [
            [-dt_neck_w / 2, base_support_height],
            [ dt_neck_w / 2, base_support_height],
            [ dt_base_w / 2, base_support_height - dt_height],
            [-dt_base_w / 2, base_support_height - dt_height]
        ]);
}

// The tail grown by d, kept to the flanks only
module dt_bump_2d(d) {
    intersection() {
        offset(delta = d) dt_tail_2d();
        translate([-50, dt_tail_bot_z + 0.6])
            square([100, base_support_height - 0.4 - (dt_tail_bot_z + 0.6)]);
    }
}

// Ramped bump along Y (grow = how far it stands proud of the tail flanks)
module dt_bump_solid(grow, y0, ramp, flat) {
    hull() {
        xz_prism(y0, 0.01) dt_bump_2d(0);
        xz_prism(y0 + ramp, flat) dt_bump_2d(grow);
        xz_prism(y0 + 2 * ramp + flat - 0.01, 0.01) dt_bump_2d(0);
    }
}

// ==========================================================================
// Shim connections
// ==========================================================================

// Shim dovetail profile: Z = 0 is the face it grows from, flaring toward +Z
module shim_tail_2d() {
    n  = shim_dt_neck_w;
    b  = shim_dt_base_w;
    hh = shim_dt_height;
    rc = shim_dt_root_chamfer;
    union() {
        polygon(points = [[-n / 2, 0], [n / 2, 0], [b / 2, hh], [-b / 2, hh]]);
        polygon(points = [[-n / 2 - rc, 0], [n / 2 + rc, 0], [n / 2, rc], [-n / 2, rc]]);
    }
}

module shim_dovetail_tails() {
    for (x_pos = connector_x)
        translate([x_pos, ang_zero, ang_zero])
            xz_prism(0, shim_tail_len) shim_tail_2d();
}

// Slots open at the bottom face (Z = 0) and at the front (Y = 0)
module shim_dovetail_slots() {
    for (x_pos = connector_x)
        translate([x_pos, ang_zero, ang_zero])
            xz_prism(-0.01, shim_slot_len + 0.01)
                offset(delta = shim_dt_clearance) shim_tail_2d();
}

// Magnet holes for a shim of height h_val (printed flat). m = magnet thickness,
// p = protrusion, tp = top pocket depth, sk = socket under the bottom magnet.
// A: room for two magnets  -> top pocket, plus socket + bottom pocket
// B: room for one magnet   -> top pocket; socket from below, floor between them
// C: at least m thick      -> through-hole; the magnet is glued so it sticks up p,
//                             leaving the socket underneath
// D: thinner than m        -> through-hole; magnet flush with the bottom, so
//                             there's no socket: this shim goes at the bottom
module shim_magnet_holes(h_val) {
    m  = magnet_h;
    tp = magnet_top_depth;
    sk = magnet_socket;
    for (x_pos = connector_x) {
        translate([x_pos, support_depth / 2, ang_zero]) {
            if (h_val >= sk + m + magnet_min_floor + tp) {
                translate([ang_zero, ang_zero, -0.01])
                    cylinder(d = magnet_pocket_d, h = sk + m + 0.01);
                translate([ang_zero, ang_zero, h_val - tp])
                    cylinder(d = magnet_pocket_d, h = tp + 0.01);
            }
            if (h_val < sk + m + magnet_min_floor + tp &&
                h_val >= sk + magnet_min_floor + tp) {
                translate([ang_zero, ang_zero, h_val - tp])
                    cylinder(d = magnet_pocket_d, h = tp + 0.01);
                translate([ang_zero, ang_zero, -0.01])
                    cylinder(d = magnet_pocket_d, h = sk + 0.01);
            }
            if (h_val < sk + magnet_min_floor + tp) {
                translate([ang_zero, ang_zero, -0.01])
                    cylinder(d = magnet_pocket_d, h = h_val + 0.02);
            }
        }
    }
}

// How far a shim's top magnet sticks up
function magnet_stickup(h_val) = (h_val < magnet_h) ? magnet_h - h_val : magnet_protrude;

// Protruding top magnets (shown in the preview only)
module shim_protruding_magnets(h_val) {
    if (shim_connection == "magnet") {
        for (x_pos = connector_x)
            translate([x_pos, support_depth / 2, h_val])
                cylinder(d = magnet_d, h = magnet_stickup(h_val));
    }
}

// ==========================================================================
// Parts
// ==========================================================================

module bottom_base() {
    chamfer_len = block_width + side_wing_w + 2;
    chamfer_x   = (block_width - side_wing_w) / 2;

    difference() {
        union() {
            // 1. Main full-width support base + side wing
            translate([-side_wing_w, ang_zero, ang_zero])
                cube([block_width + side_wing_w, support_depth, base_support_height]);

            // 2. Underside channel guide key (centered at X = 56.0mm)
            translate([bot_slot_center_x - (bot_key_width / 2), ang_zero, base_support_height])
                cube([bot_key_width, support_depth, bot_key_height]);
        }

        // Blind dovetail slot in the wing (stops short of the rear face)
        translate([dt_center_x, ang_zero, ang_zero])
            xz_prism(-0.01, dt_slot_len + 0.01) dt_slot_2d();

        // Detent grooves just inside the slot mouth
        if (dt_snap) {
            translate([dt_center_x, ang_zero, ang_zero])
                dt_bump_solid(dt_bump_h - dt_preload, dt_bump_y - 0.2, dt_bump_ramp + 0.2, dt_bump_flat);
        }

        // Shim connection on the underside
        if (shim_connection == "dovetail") {
            shim_dovetail_slots();
        }
        if (shim_connection == "magnet") {
            for (x_pos = connector_x)
                translate([x_pos, support_depth / 2, -0.01])
                    teardrop_hole(d = magnet_pocket_d, h = magnet_socket + magnet_h + 0.01);
        }

        // Engraved height label on the front face
        front_label(str(base_support_height, "mm"), min(5.0, base_support_height * 0.5),
                    base_support_height / 2);

        // Chamfer front and back bottom edges
        translate([chamfer_x, ang_zero, ang_zero])
            chamfer_bar(chamfer_len);
        translate([chamfer_x, support_depth, ang_zero])
            chamfer_bar(chamfer_len);
    }
}

module top_bridge() {
    post_x0 = -side_wing_w;
    post_x1 = -post_rail_gap;
    half_w  = dt_tail_w_at_top_face / 2;

    difference() {
        union() {
            // 1. Top plate spanning from the wing over the 16mm T-slot housing
            translate([-side_wing_w, ang_zero, top_z])
                cube([top_arm_len + side_wing_w, support_depth, top_arm_h]);

            // 2. Registration nub that drops into the 8.5mm top T-slot opening
            translate([dist_edge_to_top_open + tolerance, ang_zero, top_z - 1.5])
                cube([top_slot_opening - (tolerance * 2), support_depth, 1.5]);

            // 3. Full-width post, from the wing's outer edge to the rail's outer edge
            translate([post_x0, ang_zero, post_z0])
                cube([post_x1 - post_x0, support_depth, top_z - post_z0 + 0.01]);

            // 4. Dovetail tail. Its rear end is cut back at 45 degrees so it
            //    prints without supports when the bridge lies on its rear face.
            translate([dt_center_x, ang_zero, ang_zero])
                intersection() {
                    union() {
                        xz_prism(0, dt_tail_len) dt_tail_2d();
                        if (dt_snap)
                            dt_bump_solid(dt_bump_h, dt_bump_y, dt_bump_ramp, dt_bump_flat);
                    }
                    yz_prism(-50, 100)
                        polygon(points = [
                            [-1, dt_tail_bot_z - 1],
                            [dt_tail_len - (post_z0 - (dt_tail_bot_z - 1)), dt_tail_bot_z - 1],
                            [dt_tail_len, post_z0],
                            [dt_tail_len, top_z],
                            [-1, top_z]
                        ]);
                }
        }

        // Teardrop M6 bolt hole centered on the top T-slot (X = 8.0mm)
        translate([top_slot_center_x, support_depth / 2, top_z - 3.0])
            teardrop_hole(d = bolt_hole_dia, h = top_arm_h + 6.0);

        // Split the tail into two springy halves and free them from the post
        if (dt_snap) {
            // Narrow split inside the tail: the halves bottom out against each
            // other long before the tail could squeeze out through the slot neck
            translate([dt_center_x - dt_tail_split_w / 2, -1, dt_tail_bot_z - 1])
                cube([dt_tail_split_w, support_depth + 2, base_support_height - (dt_tail_bot_z - 1) + 0.01]);
            // Wide split in the post leaves thin walls that flex easily. A solid
            // spine fills the middle of it, leaving dt_spine_gap to each wall and
            // to the tail, so the walls can't fold far inward.
            difference() {
                translate([dt_center_x - dt_kerf_w / 2, -1, base_support_height])
                    cube([dt_kerf_w, support_depth + 2, dt_flex_len]);
                if (dt_spine)
                    translate([dt_center_x - dt_kerf_w / 2 + dt_spine_gap, -2,
                               base_support_height + dt_spine_gap])
                        cube([dt_kerf_w - 2 * dt_spine_gap, support_depth + 4, dt_flex_len]);
            }
            for (side = [-1, 1]) {
                translate([dt_center_x + side * (half_w + dt_relief_w / 2) - dt_relief_w / 2,
                           -1, base_support_height])
                    cube([dt_relief_w, support_depth + 2, dt_flex_len]);
            }
        }
    }
}

module stackable_shim(h_val = 6.0) {
    chamfer_len = block_width + side_wing_w + 2;
    chamfer_x   = (block_width - side_wing_w) / 2;
    label_txt   = str(h_val, "mm", (base_support_height + h_val == 38) ? " (2x4)" : "");
    txt_size    = (h_val < 3.0) ? 3.5 : min(5.0, h_val * 0.6);

    difference() {
        union() {
            // Shim body matching the full footprint of the base + side wing
            translate([-side_wing_w, ang_zero, ang_zero])
                cube([block_width + side_wing_w, support_depth, h_val]);

            // Dovetails on top that slide into the base or the shim above
            if (shim_connection == "dovetail") {
                translate([ang_zero, ang_zero, h_val - 0.01])
                    shim_dovetail_tails();
            }
        }

        // Dovetail slots underneath, only where there is room for a solid roof
        if (shim_connection == "dovetail" && h_val >= shim_slot_min_h) {
            shim_dovetail_slots();
        }

        if (shim_connection == "magnet") {
            shim_magnet_holes(h_val);
        }

        // Height label: on the front face when it fits, on the top face otherwise
        if (h_val >= 3.0) {
            front_label(label_txt, txt_size, h_val / 2);
        } else {
            translate([block_width * 0.68, support_depth / 2, h_val - 0.45])
                linear_extrude(height = 0.6)
                    text(label_txt, size = 5.0, halign = "center", valign = "center",
                         font = "Liberation Sans:style=Bold");
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

// ==========================================================================
// Render chosen mode (standalone if blocks for OpenSCAD compatibility)
// ==========================================================================

if (part_to_render == "print_plate") {
    spacing = 12.0;

    // 1. Bottom base, lying on its rear face
    translate([side_wing_w, ang_zero, support_depth])
        rotate([ang_neg90, ang_zero, ang_zero])
            bottom_base();

    // 2. Top bridge, lying on its rear face
    y_bridge = base_support_height + bot_key_height + spacing;
    translate([side_wing_w, y_bridge, support_depth])
        rotate([ang_neg90, ang_zero, ang_zero])
            top_bridge();

    // 3. Shim kit, flat on the build plate
    y_shims_start = y_bridge + top_z + top_arm_h + spacing;
    for (i = [0 : len(shim_set_heights) - 1]) {
        translate([side_wing_w, y_shims_start + i * (support_depth + spacing), ang_zero])
            stackable_shim(h_val = shim_set_heights[i]);
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
    preview_gap = 2.0 + magnet_h; // exploded gap, leaving room for protruding magnets
    color("SteelBlue") bottom_base();
    color("Orange")    top_bridge();
    for (i = [0 : len(preview_shims) - 1]) {
        color(i % 2 == 0 ? "LightGrey" : "Silver")
            translate([ang_zero, ang_zero, -(sum_to(preview_shims, i) + preview_gap * (i + 1))])
                stackable_shim(h_val = preview_shims[i]);
        color("DimGray")
            translate([ang_zero, ang_zero, -(sum_to(preview_shims, i) + preview_gap * (i + 1))])
                shim_protruding_magnets(preview_shims[i]);
    }
}
