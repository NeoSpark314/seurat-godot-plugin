# Seurat Godot Plugin
A Godot editor plugin to capture data for the Google Seurat scene simplification technology.

**Version 0.7.0**: this version needs Godot 3.2 to function

It allows to take a complex scene with millions of triangles from Godot and convert it to a limited view volume scene that can be rendered smoothly for example on an Oculus Quest.

As an example the Amazon Lumberyard Bistro scene (https://developer.nvidia.com/orca/amazon-lumberyard-bistro) where the exterior consists of 2,965,809 triangles

![Bistro Scene in Godot](doc/images/intro_bistroScene_godot.jpg?raw=true)

can be approximated for a small viewing volume (in this example 1m^3):

![Bistro Scene Approximated](doc/images/intro_bistroScene_approximated.jpg?raw=true)

And rendered on the Oculus Quest using the [Quest Godot Plugin](https://github.com/GodotVR/godot_oculus_mobile) at 72 Hz:

![Bistro Scene Oculus Quest](doc/images/oculusquest_bistro_screenshot.jpg?raw=true)

A Oculus Quest .apk generated from version 0.7 captures can be downloaded here: [SeuratGodotDemoQuest_v0.7.apk](https://github.com/NeoSpark314/seurat-godot-plugin/releases/download/v0.7/SeuratGodotDemoQuest_v0.7.apk) and
you can see demo on the Oculus Quest in action here:
[![v0.7 demo video link](doc/images/intro_youtube_preview.jpg?raw=true)](https://www.youtube.com/watch?v=ikYTkyIMV8k)



## What is Google Seurat
Google Seurat (https://github.com/googlevr/seurat) is a scene simplification technology. It was build to port complex scenes to mobile 6DOF hardware and keep as much visual fidelity as possible. It takes a fixed viewing volume and produces a single mesh and texture with hard constraints on resolution and polygon count.

This short post here https://developers.google.com/vr/discover/seurat explains the basics.

It was originally announced at Google IO 2017 with an impressive demo in cooperation with ILM (You can watch the announcement [here on YouTube](https://www.youtube.com/watch?time_continue=1714&v=tto90e-DfeM))

In May 2018 the technology was open sourced (https://developers.googleblog.com/2018/05/open-sourcing-seurat.html) and also a paper published on HPG 2018 ([Seurat Paper](https://pharr.org/matt/papers/seurat_hpg_2018.pdf)) that contains the algorithmic details of Seurat.

## Using the plugin to capture data
To use the plugin you need to clone the repository and copy the `addon` folder into the Godot project where you want to capture. Or you can use the included `capture_sample` scene for testing.

In the rest of the documentation I will be using the Sponza demo scene from Calinou (https://github.com/Calinou/godot-sponza).

### Enable the plugin
Go to your Project Settings in the Plugins tab and set the Seurat Godot Plugin to active.

![Enable the Plugin](doc/images/pluginsetup_activate.jpg?raw=true)

### Creating the capture box

When the plugin is active there is a new node type called **SeuratCaputreBox**. Add this node to your scene root. The capture box boundaries are represented by a red wireframe box.

Position this box in the area where you want to capture and make sure that **no geometry overlaps!**

![Add capture box](doc/images/pluginsetup_createCaptureBox.jpg?raw=true)


### Configuring the capture box

There are several settings inside the inspector to configure the capture of the scene. The most important settings are:

![Configure capture box](doc/images/pluginsetup_configureCaptureBox.jpg?raw=true)

* **Cube Face Resolution**: The size of a single face of the captured cube maps
* **Camera Near**: near plane used for the cube map capture. Make sure it is not to big as it might result in overlapping geometry.
* **Camera Far**: far plane distance. When processing the data later make sure that the Seurat sky cutoff distance is closer then your far plane.
* **Center Resolution Scale** The Seurat documentation reccomends to render the center of the capture box in higher resolution then the rest to get better quality. This is the scale factor for the center cube map (default is 4x resolution of the rest). Be carefull to not set it too large (especially when increasing the cube face resolution).
* **Export Path** The directory where the exported images will be stored. If it does not exist the plugin will try to create it.
* **Num Captures** The number of cube maps that will be captured. The first capture will always be in the center of the capture box. Additional captures will be distributed inside the capture volume. 16 captures for testing and 32 for the final capture are usually good starting points.
* **Append Settings to Path** Enabling this will append the capture settings like cube face resolution to the output path. This is usefull when testing different export settings for quality comparisons.



### Run the Capture
Make sure to open the output window to see potential errors when executing the capture. Then click the **Start Capture** checkbox in the inspector.

The screen will start flashing white during the capture. This is the screen space quad rendered to capture the depth buffer.

In the output directory will then be all images stored. The .png images contain the color buffer cube map faces. The .exr images contain the depth buffer. In addition there will be a manifest.json created that contains all the capture settings like camera position and projection matrices.

A single cube face color/depth pair will look like this (note taht the depth image is scaled to be visible)

![Single captured face](doc/images/capture_sponza_cubeface_coloranddepth.jpg?raw=true)

The image below shows a part of how the cube map captures will look like.

![Capture Overview](doc/images/capture_sponza_cubemaps_overview.jpg?raw-true)


## Processing the captured data with Seurat

To process the captured data into a renderable mesh+texture you need to execute the seurat pipeline tool https://github.com/googlevr/seurat. Compiling these is quite time and disk space consuming. If you are on windows you can also use the pre-build binaries created by ddiakopoulos at https://github.com/ddiakopoulos/seurat/releases/download/0.1/seurat-compiled-msvc2017-x64.zip

Seurat will read the manifest.json and create internally first a point cloud representation of the data and then will further process it to create the mesh and the texture atlas. 

There are many settings that are documented in the Seurat github that allow to control the output quality triangle count and output texture resolution. The command and settings I used to create the sample is (triangle count and texture resolution was left on the default)

```
> seurat-pipeline-msvc2017-x64.exe -input_path seurat_capture_images\manifest.json -output_path seurat_output\result
```

The output is a result.obj containg the approximated geometry and a result.png containg the texture atlas. There is also a result.exr created contating a float version of the texture atlas as well as a result.ice. The result.ice can be opened with the viewer application `seurat-butterfly-msvc2017-x64.exe` to preview the result.

## Rendering the processed data in Godot
The generated .obj and .png can then be imported in Godot. You have to carefully tweak the import settings as result will only look good if there are no approximations made.

Make sure to **turn off Optimize Mesh** in the .obj import settings:

![Mesh Import Settings](doc/images/render_mesh_import_settings.jpg?raw-true)

The imported mesh will then look like this:
![Imported Mesh](doc/images/render_imported_mesh.jpg?raw-true)

For the texture import make sure to **disable Mip Maps** and that the texture does not get resized.
![Texture Import Settings](doc/images/render_texture_import_settings.jpg?raw-true)

Next is to create a shader material for the mesh and assign the provided `seurat_blend.shader`. This shader exposes a single parameter that is the texture slot:

![Shader Settings](doc/images/render_shader_settings.jpg?raw-true)

The final result should then look like this:
![Final Result](doc/images/render_sponza_result.jpg?raw-true)
