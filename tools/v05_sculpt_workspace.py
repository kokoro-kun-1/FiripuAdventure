import bpy
from mathutils import Vector

SRC = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v04_clean.blend'
OUT = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v05_sculpt_workspace.blend'
FRONT = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\input_front_removed.png'
RIGHT = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\input_right_removed.png'
BACK = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\input_back_removed.png'

bpy.ops.wm.open_mainfile(filepath=SRC)
char = bpy.data.objects.get('Firipu_V04_Clean')
if not char:
    raise RuntimeError('No se encontró Firipu_V04_Clean')

# Colecciones de producción.
root = bpy.data.collections.new('FIRIPU_V05_PRODUCTION')
refs = bpy.data.collections.new('00_REFERENCIAS')
guide_coll = bpy.data.collections.new('01_GUIA_HUNYUAN')
sculpt_coll = bpy.data.collections.new('02_SCULPT_WORK')
retopo_coll = bpy.data.collections.new('03_RETOPO')
root.children.link(refs)
root.children.link(guide_coll)
root.children.link(sculpt_coll)
root.children.link(retopo_coll)
bpy.context.scene.collection.children.link(root)

# Guía original bloqueada e intocable.
char.name = 'GUIDE_Hunyuan_Clean'
for c in list(char.users_collection):
    c.objects.unlink(char)
guide_coll.objects.link(char)
char.hide_render = True
char.hide_set(True)
char.hide_select = True
char.display_type = 'WIRE'

# Copia de escultura editable.
work = char.copy()
work.data = char.data.copy()
work.name = 'SCULPT_Firipu_V05'
sculpt_coll.objects.link(work)
work.hide_render = False
work.hide_set(False)
work.hide_select = False
work.display_type = 'SOLID'
work['workflow'] = 'sculpt source; preserve GUIDE_Hunyuan_Clean'
work['canonical_height_m'] = 1.08

# Reemplazar material de inspección por piel/arcilla neutra cálida.
mat = bpy.data.materials.new('MAT_Sculpt_Clay')
mat.use_nodes = True
bsdf = mat.node_tree.nodes.get('Principled BSDF')
bsdf.inputs['Base Color'].default_value = (0.48, 0.25, 0.14, 1)
bsdf.inputs['Roughness'].default_value = 0.78
work.data.materials.clear()
work.data.materials.append(mat)

# Planos de referencia mediante empties de imagen: no se exportan ni renderizan.
def add_reference(name, path, location, rotation, size=1.08):
    img = bpy.data.images.load(path, check_existing=True)
    data = bpy.data.objects.new(name, None)
    data.empty_display_type = 'IMAGE'
    data.data = img
    data.empty_display_size = size
    data.color[3] = 0.55
    data.empty_image_depth = 'BACK'
    data.show_in_front = False
    data.location = location
    data.rotation_euler = rotation
    data.hide_render = True
    refs.objects.link(data)
    return data

# Imágenes 1:1 cuadradas, personaje centrado con márgenes; escala calibrada visualmente
# para que la figura ocupe 1.08 m. Se deja offset suficiente para evitar z-fighting.
front = add_reference('REF_FRONT', FRONT, (0, 0.19, 0.54), (1.5707963268, 0, 0), 1.23)
right = add_reference('REF_RIGHT', RIGHT, (-0.29, 0, 0.54), (1.5707963268, 0, 1.5707963268), 1.23)
back = add_reference('REF_BACK', BACK, (0, -0.19, 0.54), (1.5707963268, 0, 3.1415926536), 1.23)

# Marcadores métricos de dimensiones canónicas.
def marker(name, loc, scale):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for c in list(obj.users_collection):
        c.objects.unlink(obj)
    refs.objects.link(obj)
    obj.display_type = 'WIRE'
    obj.hide_render = True
    obj.hide_select = True
    return obj

marker('METRIC_Height_1m08', (0.33, 0, 0.54), (0.006, 0.006, 1.08))
marker('METRIC_Head_23cm', (0.30, 0, 0.965), (0.006, 0.006, 0.23))
marker('METRIC_Boot_18cm', (0, -0.25, 0.025), (0.18, 0.006, 0.006))

# Grupos de vértices semánticos para correcciones no destructivas posteriores.
semantic = {
    'REGION_HEAD': (0.84, 1.081),
    'REGION_FACE': (0.86, 1.03),
    'REGION_TORSO': (0.43, 0.85),
    'REGION_LEGS': (0.12, 0.48),
    'REGION_BOOTS': (-0.01, 0.16),
}
for name, (z0, z1) in semantic.items():
    group = work.vertex_groups.new(name=name)
    ids = []
    for v in work.data.vertices:
        z = (work.matrix_world @ v.co).z
        if z0 <= z <= z1:
            ids.append(v.index)
    if ids:
        group.add(ids, 1.0, 'REPLACE')

# Simetría como herramienta visual, sin aplicar: la referencia conserva asimetría del cabello.
mirror = work.modifiers.new('RetopoSymmetry_Preview', 'MIRROR')
mirror.use_axis[0] = True
mirror.use_clip = True
mirror.use_mirror_merge = True
mirror.show_render = False
mirror.show_viewport = False

# Configuración de escena para modelado.
scene = bpy.context.scene
scene.unit_settings.system = 'METRIC'
scene.unit_settings.scale_length = 1.0
scene.tool_settings.transform_pivot_point = 'MEDIAN_POINT'
scene.render.engine = 'BLENDER_EEVEE'

# Seleccionar malla editable y dejar workspace listo.
bpy.context.view_layer.objects.active = work
work.select_set(True)
for obj in bpy.context.selected_objects:
    if obj != work:
        obj.select_set(False)

bpy.ops.wm.save_as_mainfile(filepath=OUT)
print(f'OK workspace={OUT}')
print(f'work verts={len(work.data.vertices)} faces={len(work.data.polygons)}')
print('refs=FRONT,RIGHT,BACK; groups=' + ','.join(semantic.keys()))
