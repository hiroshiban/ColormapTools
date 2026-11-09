# API and conventions

## Connecting two to four RGB anchors

`[rgb,info] = generate_colormap_from_rgb(colors,n,Name,Value,...)`

`colors` is a finite 2-by-3, 3-by-3 or 4-by-3 normalized display-encoded sRGB array. Each row is one anchor. Byte RGB must be explicitly divided by 255; ranges are not inferred. For larger LUTs or cyclic paths, use `generate_colormap` directly.

`n` is the exact nonnegative integer row count (default 256). The open path includes both endpoints for n>=2; n=0 returns 0-by-3 and n=1 samples the first anchor. An interior knot is represented exactly only when the output grid contains its position.

| Option | Default | Meaning |
| --- | --- | --- |
| Method | linear | linear or sinusoidal; cosine is an alias for sinusoidal |
| Positions | equally spaced | One strictly increasing value per anchor, beginning at 0 and ending at 1 |
| Reverse | false | Reverse the generated output rows |
| Quantize | false | Round output to 8-bit levels and return normalized RGB |

Sinusoidal interpolation uses `w=(1-cos(pi*u))/2` and mixes adjacent RGB anchors as `(1-w)*a+w*b`. First derivatives vanish at each anchor before quantization; second derivatives need not agree. This is RGB regularity, not a perceptual-uniformity constraint.

`info` retains the core method, requested method, source anchor RGB, positions, reverse flag, quantization and sampling conventions. Example:

```matlab
anchors = [1 0 0;1 1 1;0 0 1];
[rgb,info] = generate_colormap_from_rgb(anchors,257,'Method','sinusoidal');
```

## Generating maps

`[rgb,info] = generate_colormap(source,n,Name,Value,...)`

`source` is a normalized N×3 sRGB array (one grayscale column is accepted), CSV path, anchor filename stem, or analytic preset. Finite RGB values must be in [0,1]; integer 0–255 tables must be normalized explicitly. `n` is a nonnegative integer, default 256. Zero returns 0×3; one returns the first color.

| Option | Default | Meaning |
| --- | --- | --- |
| `Method` | `linear` | LUT interpolation: `linear`, `cosine`, `smoothstep`, `smootherstep`, `pchip`, `nearest` |
| `Cyclic` | automatic for `hsv` and `hsv-scurve`, otherwise false | Closed paths sample [0,1]; cycles sample [0,1) |
| `Reverse` | false | Reverse output row order |
| `Quantize` | false | Normalize rounded 8-bit colors; VTK S-curve presets use truncation as in the source |
| `HueRange` | preset-specific | Two HSV endpoints in [0,1], analytic presets only |
| `Positions` | equally spaced | Strictly increasing anchor positions; cyclic positions start at 0 and end below 1 |

In cyclic mode an exactly duplicated last anchor is removed automatically when no custom `Positions` are supplied. The last anchor connects to the first. This is a data convention, not an inference that an arbitrary palette is suitable for circular data. PCHIP is shape preserving per channel but is not guaranteed to match derivatives at a cyclic seam. Cosine and smoothstep have zero first derivatives at every anchor; smootherstep also has zero second derivatives there. These endpoint derivatives do not make the map perceptually uniform.

`vtk-hsv` defaults to hue [0,.9], while `vtk-rygb` uses VTK's literal default [0,.66667]. Both use fixed saturation/value 1, inclusive sampling, and the component mapping `(1+cos((1-c)*pi))/2`. `Quantize=true` uses `floor(255*c)/255` for that S-curve. Linear quantization uses `floor(255*c+.5)/255`. Floating point arithmetic near exact byte boundaries can differ between MATLAB and a C++ runtime. Exported LUTs provide a concrete comparison target.

## Phase coordinates

`[rgb,info] = generate_phase_colormap(source,n,...)` uses half-open samples. At output row j:

```text
t = (j-1)/n
source_phase = sign * Cycles * t + PhaseDegrees/360
```

`Reverse=true` sets sign to −1; otherwise +1. `Cycles` must be a positive integer. `Alternating=true` uses a triangular traversal of an open LUT with period two traversals. If the number of traversals is odd, its seam need not close. A named analytic source is densely sampled at 4096 points then interpolated; a supplied LUT is used directly. Supply a numeric LUT directly to avoid this additional dense sampling step.

## Rendering legends

`[rgb,alpha,meta] = colormap_legend(lut,format,...)` has no display or file-write side effects. Formats are `horizontal`, `vertical`, `swatches`, `wheel`, `ring`, `wedge`, `semicircle`, `eccentricity`, `phase-amplitude`.

| Option | Default | Meaning |
| --- | --- | --- |
| `Size` | 401 | square raster width/height, or length of bar |
| `Thickness` | 40 | bar thickness |
| `OriginDegrees` | 90 | Cartesian direction of zero: 0 right, 90 up |
| `Direction` | `clockwise` | progression in the displayed image |
| `PhaseDegrees` | 0 | source LUT phase offset |
| `InnerRadius` | .65 | normalized hole radius for a ring |
| `AngleRange` | [0 90] | wedge mask, measured in progression coordinates; a semicircle uses [0 180] |
| `Cyclic` | true for angle formats | whether the LUT wraps |
| `Method` | `bins` | default floor(N*u)+1 lookup matching `apply_colormap`; other interpolation methods optional |
| `Reverse` | false | reverse LUT order |
| `RadialScale` | `linear` | `linear` or `log` color indexing for an eccentricity disk |
| `RadialLimits` | [0 1] | physical radius values, positive minimum required for log |
| `NeutralColor` | [1 1 1] | center color for phase–amplitude mixing |

For an eccentricity disk, physical radius varies linearly with position: r_phys=r_min+radius*(r_max−r_min). `RadialScale='log'` maps log(r_phys) to color. This does not warp the geometric visual field. Center alpha is zero for angle-based formats; it remains valid for eccentricity. Returned metadata includes the normalized scalar field, radius and angle coordinate arrays.

`show_colormap` accepts those options plus `Parent` (axes), `Title`, `Limits`, `Label`, `TickValues`, and `TickLabels`. Circular tick positions use `Limits`; radial ticks use `RadialLimits`. Masks are not automatically used to filter tick labels for wedge/semicircle views; supply only ticks relevant to that view. The default bar is open; use `Cyclic=true` if displaying the full phase cycle as a strip. Labels at both cyclic endpoints denote the same phase.

## Mapping real data

`[rgb,alpha,index] = apply_colormap(values,lut,...)` accepts a 2D real numeric array. It never modifies data or changes the LUT. `Limits=[lo hi]`, `Scale='linear'|'log'`, `Cyclic=false|true`, and `OutOfRange='clamp'|'transparent'` define normalization. Nonfinite values are transparent and have index 0. A clamped u=1 uses the final row; cyclic u=1 wraps to row 1. Out-of-range handling is applied before wrapping when transparency is requested.

Use one agreed table and scalar mapping in MATLAB, Python and VTK. Color management, lighting, alpha compositing, texture filtering, gamma, tone mapping and framebuffer quantization still require agreement in rendered 3D/VR scenes.

## Diagnostics and export

`analyze_colormap(lut,'Cyclic',true|false)` reports CIELAB D65 L*, ΔE76 steps and their population CV, a 5%-of-mean near-stationary fraction, raw RGB second differences, endpoint/seam distances, 8-bit unique colors, and full-severity Machado CVD diagnostics. A seam ratio is meaningful only for cyclic tables. Lightness turn counts use a 1e−6 step threshold and may count tiny numerical irregularities; diverging/cyclic maps legitimately reverse lightness. No overall pass/fail score is calculated. [Color-difference definitions and interpretation](COLOR_DIFFERENCE.md#english) describe the adjacent ΔE76 values, CV, D65 assumptions and limits used in the README figure.

`simulate_color_vision(lut,'protan'|'deutan'|'tritan')` applies the severity-100 matrices in linear-light sRGB, clips to gamut and returns the clipping fraction. This covers three simulations, not every observer or CVD severity.

`export_colormap('name.csv',lut,'Source',...,'Cyclic',...)` writes a CSV and JSON metadata with SHA-256 of the exact CSV bytes. This is a scalar lookup-table interchange format, not a VTK .vti/.vtk file.
