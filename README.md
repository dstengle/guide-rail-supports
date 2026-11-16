# guide-rail-supports

3D-printed supports for your track saw guide rail. They hold the rail level when you
work with narrow stock, such as cross-cutting narrow boards or ripping thin strips.

The current design is a parametric OpenSCAD model built for the **Makita 183 mm guide rail**
(see [`docs/makita-rail-profile.jpg`](docs/makita-rail-profile.jpg) for the extrusion drawing).

![Assembly preview](docs/assembly_preview.png)

## Design overview

- **Bottom base**: a full-width block, as thick as your workpiece (`base_support_height`).
  It stops 4 mm short of the cutting edge to keep clear of the blade and splinter guard.
  A key on top registers in the rail's underside channel.
- **Top bridge**: clamps through the rail's top T-slot with a drop-in M6 T-bolt. Its post
  fills the side wing and stops 0.2 mm from the rail's outer edge. It joins the base with a
  blind sliding dovetail that **snaps into place**: the tail is split into two springy
  halves with small detent bumps that click into grooves just inside the slot mouth.
  The bumps stay slightly compressed when seated, which pushes the tail against the
  slot's sloped sides and takes out the play.
- **Stackable shim kit** (1, 2, 3, 6 and 26 mm): shims attach under the base with either
  magnets or sliding dovetails (see below). The 12 mm base plus the 26 mm shim gives
  38 mm, the thickness of a 2x4. Each shim has its thickness engraved on it.
- **Support-free printing**: the base and bridge print on their rear faces with teardrop
  holes, and the dovetail tail's rear end is cut back at 45°. The shims print flat.

## Shim connection

Set `shim_connection` to `"magnet"` (default) or `"dovetail"`.

### Magnets

Disc magnets sit at three points along each part (`connector_inset` from each end, plus
the middle). Every joint in the stack is the same:

- Each shim's **top magnet sticks up** `magnet_protrude` (1 mm).
- Every part has a **socket under its bottom magnet**, slightly deeper than that.
  The magnet sticking up from the part below nests into it.

So the magnets meet face to face, which gives the strongest hold, and they work as
locating pegs that stop the shims sliding.

| Parameter          | Meaning                                                           |
|--------------------|-------------------------------------------------------------------|
| `magnet_d`         | Magnet diameter                                                   |
| `magnet_h`         | Magnet thickness                                                  |
| `magnet_protrude`  | How far each shim's top magnet sticks up (less than `magnet_h`)   |
| `magnet_fit`       | Added to hole diameter: about 0.1 for a press fit, 0.3 to glue in |
| `magnet_recess`    | Sockets are this much deeper than `magnet_protrude`               |
| `magnet_min_floor` | Least plastic between a socket and a pocket                       |

With the defaults (10×2 mm magnets, 1 mm sticking up):

| Part        | Magnets                                                                   |
|-------------|---------------------------------------------------------------------------|
| Base        | Socket, with the magnet pushed to the end of the pocket                   |
| 26 mm, 6 mm | Top pocket (magnet 1 mm proud), plus socket and bottom pocket             |
| 3 mm        | Top pocket (magnet 1 mm proud), socket underneath, solid floor between    |
| 2 mm        | Through-hole, magnet glued 1 mm proud, which leaves the socket underneath |
| 1 mm        | Through-hole, magnet flush with the bottom and 1 mm proud. **No socket**  |

**Stacking rule:** any order works, except the **1 mm shim always goes at the very
bottom** of the stack. Its magnet fills its whole thickness, so there's no room for a
socket. The empty sockets under the bottom-most shim do no harm.

If your magnets' thickness doesn't let the thinnest shim's magnet stick up by exactly
`magnet_protrude`, OpenSCAD prints a warning.

**Polarity and assembly:** every magnet goes in with the **same pole facing down**.
The easiest way is to build the kit as a stack. Glue the magnets into one part, then set
the next part on top and drop its magnets in. Each one flips to attract the magnet below
and seats at the right depth. That matters for the 2 mm shim, whose through-hole doesn't
set the magnet's depth.

### Dovetails

Each shim has three sliding dovetails on top that slide into slots under the base or the
shim above, from the front. The dovetails are wider, shallower and looser than in the
first version, and the clearance is now measured square to each face. The tail root has
a fillet, and the slot mouth has a matching chamfer to allow for first-layer squish.
Shims too thin to fit a slot with a solid roof above it (1, 2 and 3 mm with the defaults)
can only go at the bottom of a stack.

## Usage

Open `rail-support.scad` in [OpenSCAD](https://openscad.org/) and set `part_to_render`:

| Value              | Output                                                      |
|--------------------|-------------------------------------------------------------|
| `print_plate`      | Every part laid out for printing (the default)              |
| `assembly_preview` | Parts shown assembled, with the `preview_shims` stack below |
| `bottom_base`      | Base only                                                   |
| `top_bridge`       | Bridge only                                                 |
| `shim`             | One shim, `single_shim_h` thick                             |

From the command line:

```bash
openscad -o print_plate.3mf -D 'part_to_render="print_plate"' -D 'shim_connection="magnet"' rail-support.scad
```

The full print plate is about 200 × 290 mm. Use **Split → To Objects** in your slicer and
rearrange the parts, or spread them over more than one plate.

### Tuning the bridge joint

| Parameter      | Effect                                                                 |
|----------------|------------------------------------------------------------------------|
| `dt_clearance` | Gap square to each dovetail face                                       |
| `dt_bump_h`    | Detent bump height: higher means a firmer click                        |
| `dt_preload`   | How much the bump stays compressed when seated: higher means less play |
| `dt_flex_wall` | Thickness of the springy halves: thinner means a softer snap           |
| `dt_flex_len`  | How far the split runs into the post: longer means a softer snap       |
| `dt_tail_split_w` | Split width inside the tail (1 mm). It limits how far the halves can squeeze together: too wide and the tail can pull out of the slot, too narrow and the bumps can't pass. OpenSCAD warns about either case. |
| `dt_spine`, `dt_spine_gap` | Solid spine between the springy walls in the post, with a 0.5 mm gap to each wall and to the tail. It fills the space the walls need to flex, keeps the post stiff and stops the walls folding inward. |
| `dt_snap`      | Set to `false` for a plain dovetail                                    |

Other key parameters:

- `base_support_height`: workpiece thickness
- `side_wing_w`: width of the wing that carries the dovetail and post (20 mm)
- `tolerance`: sliding fit of the underside key and top registration nub
