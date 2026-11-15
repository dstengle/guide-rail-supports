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
- **Top bridge**: clamps through the rail's top T-slot with a drop-in M6 T-bolt. It joins
  the base with a blind sliding dovetail on a 16 mm side wing. A 3 mm rear stop sets it flush,
  so the support can go on anywhere along the rail without sliding on from the end.
- **Stackable shim kit** (1, 2, 3, 6 and 26 mm): shims attach under the base with three
  horizontal sliding dovetails, so they stay on when you lift the rail. The 12 mm base plus
  the 26 mm shim gives 38 mm, the thickness of a 2x4. Each shim has its thickness engraved on it.
- **Support-free printing**: the base and bridge print on their rear faces, with a teardrop
  M6 hole. The shims print flat.

## Usage

Open `rail-support.scad` in [OpenSCAD](https://openscad.org/) and set `part_to_render`:

| Value              | Output                                          |
|--------------------|-------------------------------------------------|
| `print_plate`      | Every part laid out for printing (the default)  |
| `assembly_preview` | Parts shown assembled, in colour                 |
| `bottom_base`      | Base only                                       |
| `top_bridge`       | Bridge only                                     |
| `shim`             | One shim, `single_shim_h` thick                 |

From the command line:

```bash
openscad -o print_plate.3mf -D 'part_to_render="print_plate"' rail-support.scad
```

Key parameters:

- `base_support_height`: workpiece thickness
- `tolerance`: sliding fit, 0.20–0.30 depending on your printer
- `support_depth`: front-to-back depth of the support
