# External material and attribution

The project implementation and documentation are distributed under BSD-2-Clause. The references below identify mathematical conventions and external numerical reference values used by the tools. No external software implementation or reference-tool collection is bundled.

## RGB anchor examples

The named RGB anchor tables are provided in `data/anchors/`. Original palette-routine credits: A. E. Welchman and H. Yamamoto.

## VTK formulas

VTK formula and quantization reference: [vtkLookupTable v9.5.2](https://github.com/Kitware/VTK/blob/v9.5.2/Common/Core/vtkLookupTable.cxx), copyright Ken Martin, Will Schroeder and Bill Lorensen, BSD-3-Clause. The mathematical operation is independently implemented; no VTK source is vendored. The `vtk-hsv` and `vtk-rygb` names designate this package's formula presets.

## Color-vision-deficiency reference values

Color-vision-deficiency matrices: Machado, Oliveira & Fernandes (2009), [10.1109/TVCG.2009.113](https://doi.org/10.1109/TVCG.2009.113), supplementary reference values, also documented in [Colorspacious 1.1.2 cvd.py](https://github.com/njsmith/colorspacious/blob/v1.1.2/colorspacious/cvd.py), which credits the paper. Colorspacious code is not included here. It is MIT, copyright 2014–2015 Colorspacious developers; cvd.py additionally credits Nathaniel Smith (2015).
