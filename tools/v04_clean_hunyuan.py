import bpy, math
from mathutils import Vector

SRC = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03.glb'
OUT = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v04_clean.blend'
RENDER_DIR = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03'

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=SRC)
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
if not meshes:
    raise RuntimeError('El GLB no contiene mallas')

# Unificar sólo si el import produjo varias mallas.
bpy.ops.object.select_all(action='DESELECT')
for obj in meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
if len(meshes) > 1:
    bpy.ops.object.join()
char = bpy.context.active_object
char.name = 'Firipu_V04_Clean'

# Escala canónica: 1.08 m, pies en Z=0.
def bounds(obj):
    pts = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    return Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts))), Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))

lo, hi = bounds(char)
height = hi.z - lo.z
char.scale *= 1.08 / height
bpy.context.view_layer.objects.active = char
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
lo, hi = bounds(char)
char.location.z -= lo.z
bpy.ops.object.transform_apply(location=True, rotation=False, scale=False)

# Limpieza conservadora: elimina ondulación de alta frecuencia sin cambiar volumen global.
# Corrective Smooth mantiene bordes/silueta mejor que voxel remesh.
mod = char.modifiers.new('MicroBump_Cleanup', 'CORRECTIVE_SMOOTH')
mod.factor = 0.18
mod.iterations = 4
mod.scale = 1.0
mod.smooth_type = 'LENGTH_WEIGHTED'
mod.use_only_smooth = True
bpy.ops.object.modifier_apply(modifier=mod.name)

# Segundo pase mínimo Laplacian para picos aislados.
mod = char.modifiers.new('Spike_Cleanup', 'LAPLACIANSMOOTH')
mod.lambda_factor = 0.04
mod.iterations = 2
mod.use_volume_preserve = True
bpy.ops.object.modifier_apply(modifier=mod.name)

# Normales coherentes y sombreado suave.
bpy.context.view_layer.objects.active = char
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.object.mode_set(mode='OBJECT')
for poly in char.data.polygons:
    poly.use_smooth = True

# Material neutro de inspección; la geometría se valida antes de texturizar.
mat = bpy.data.materials.new('MAT_Clay_Inspection')
mat.diffuse_color = (0.32, 0.46, 0.65, 1.0)
mat.use_nodes = True
bsdf = mat.node_tree.nodes.get('Principled BSDF')
bsdf.inputs['Base Color'].default_value = (0.19, 0.34, 0.58, 1.0)
bsdf.inputs['Roughness'].default_value = 0.72
char.data.materials.clear()
char.data.materials.append(mat)

# Suelo y estudio claro.
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 900
scene.render.resolution_y = 1100
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.render.film_transparent = False
scene.world.color = (0.055, 0.055, 0.055)

bpy.ops.mesh.primitive_plane_add(size=6, location=(0, 0, -0.002))
floor = bpy.context.active_object
floor.name = 'Inspection_Ground'
fmat = bpy.data.materials.new('MAT_Ground')
fmat.diffuse_color = (0.055, 0.06, 0.07, 1)
floor.data.materials.append(fmat)

# Área principal, relleno y contraluz.
def area(name, loc, energy, size):
    data = bpy.data.lights.new(name, 'AREA')
    data.energy = energy
    data.shape = 'DISK'
    data.size = size
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.location = loc
    direction = Vector((0, 0, 0.58)) - obj.location
    obj.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return obj

area('Key', (2.3, -2.8, 2.5), 850, 2.4)
area('Fill', (-2.0, -1.6, 1.6), 500, 2.8)
area('Rim', (0.4, 2.5, 2.2), 700, 1.8)

# Cámara ortográfica mirando al centro. Frente canónico = -Y.
cam_data = bpy.data.cameras.new('Turnaround_Camera')
cam_data.type = 'ORTHO'
cam_data.ortho_scale = 1.28
cam = bpy.data.objects.new('Turnaround_Camera', cam_data)
bpy.context.collection.objects.link(cam)
scene.camera = cam
center = Vector((0, 0, 0.54))

angles = [0, 45, 90, 135, 180, 225, 270, 315]
for angle in angles:
    rad = math.radians(angle)
    # 0° frontal: cámara en Y negativo; 90°: lateral derecho.
    cam.location = Vector((2.2 * math.sin(rad), -2.2 * math.cos(rad), 0.58))
    cam.rotation_euler = (center - cam.location).to_track_quat('-Z', 'Y').to_euler()
    scene.render.filepath = f'{RENDER_DIR}\\clean_v04_{angle:03d}.png'
    bpy.ops.render.render(write_still=True)

# Métricas finales.
lo, hi = bounds(char)
char['target_height_m'] = 1.08
char['cleanup'] = 'corrective_smooth_0.18x4 + laplacian_0.04x2_volume_preserve'
bpy.ops.wm.save_as_mainfile(filepath=OUT)
print(f'OK blend={OUT}')
print(f'verts={len(char.data.vertices)} faces={len(char.data.polygons)}')
print(f'bounds_min={tuple(round(v, 5) for v in lo)} bounds_max={tuple(round(v, 5) for v in hi)} height={hi.z-lo.z:.5f}')
