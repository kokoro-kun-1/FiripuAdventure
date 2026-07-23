import bpy, math, bmesh
from mathutils import Vector

# Limpiar escena
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Cargar el work.blend ya escalado
work_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_mv_v03_work.blend'
bpy.ops.wm.open_mainfile(filepath=work_blend)

obj = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
print(f"Objeto base: {obj.name}, verts={len(obj.data.vertices)}, faces={len(obj.data.polygons)}")

# === PALETA CANÓNICA (sRGB 0-1) ===
PALETTE = {
    'skin':        (0.96, 0.78, 0.68),  # piel clara cálida
    'hair':        (0.18, 0.12, 0.08),  # castaño oscuro
    'eyes':        (0.25, 0.18, 0.12),  # café
    'freckles':    (0.65, 0.35, 0.20),  # pecas
    'hoodie':      (0.12, 0.35, 0.65),  # azul polerón
    'tshirt':      (0.95, 0.92, 0.85),  # crema camiseta
    'pants':       (0.35, 0.28, 0.22),  # café cargo
    'knee_patch':  (0.15, 0.12, 0.10),  # rodilleras oscuras
    'socks':       (0.95, 0.92, 0.85),  # crema calcetines
    'sock_stripe': (0.70, 0.15, 0.15),  # franja roja
    'boots':       (0.28, 0.18, 0.12),  # café botas
    'boot_sole':   (0.12, 0.10, 0.08),  # suela oscura
    'backpack':    (0.35, 0.40, 0.25),  # oliva mochila
    'bandana':     (0.65, 0.25, 0.15),  # rojiza pañoleta
}

def make_mat(name, base_color, rough=0.8, spec=0.04):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get('Principled BSDF')
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*base_color, 1.0)
        bsdf.inputs['Roughness'].default_value = rough
        if 'Specular' in bsdf.inputs:
            bsdf.inputs['Specular'].default_value = spec
        elif 'Specular IOR Level' in bsdf.inputs:
            bsdf.inputs['Specular IOR Level'].default_value = spec
    return mat

# Crear materiales
mats = {k: make_mat(k, v) for k, v in PALETTE.items()}

# === SEPARAR POR PARTES (heurística por posición Z y normales) ===
bpy.context.view_layer.objects.active = obj
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')

# Separar por componentes sueltos primero
bpy.ops.mesh.separate(type='LOOSE')
bpy.ops.object.mode_set(mode='OBJECT')

parts = [o for o in bpy.context.scene.objects if o.type == 'MESH']
print(f"\nPartes tras LOOSE: {len(parts)}")
for i, p in enumerate(parts):
    bbox = [p.matrix_world @ Vector(c) for c in p.bound_box]
    cz = sum(v.z for v in bbox) / 8
    print(f"  {i}: {p.name} verts={len(p.data.vertices)} centro_Z={cz:.3f}")

# Si solo una parte, intentar separar por umbrales Z manual
if len(parts) == 1:
    print("\nUna sola malla - separando por umbrales Z...")
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='DESELECT')
    
    bm = bmesh.from_edit_mesh(parts[0].data)
    # Seleccionar cara superior (cabeza + cabello aprox Z > 0.85)
    for face in bm.faces:
        cz = sum((parts[0].matrix_world @ v.co).z for v in face.verts) / len(face.verts)
        if cz > 0.85:  # cabeza
            face.select = True
    bmesh.update_edit_mesh(parts[0].data)
    bpy.ops.mesh.separate(type='SELECTED')
    bpy.ops.object.mode_set(mode='OBJECT')
    
    parts = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    print(f"Partes tras separar cabeza: {len(parts)}")

# Renombrar y asignar materiales por heurística de posición
for p in parts:
    bbox = [p.matrix_world @ Vector(c) for c in p.bound_box]
    cz = sum(v.z for v in bbox) / 8
    cz_max = max(v.z for v in bbox)
    cz_min = min(v.z for v in bbox)
    
    if cz > 0.85:  # cabeza
        p.name = 'head_hair'
        p.data.materials.append(mats['hair'])
    elif cz > 0.65:  # cuello/cabeza inferior
        p.name = 'head_face'
        p.data.materials.append(mats['skin'])
    elif cz > 0.45:  # torso superior (polerón)
        p.name = 'torso_hoodie'
        p.data.materials.append(mats['hoodie'])
    elif cz > 0.30:  # torso medio (camiseta)
        p.name = 'torso_tshirt'
        p.data.materials.append(mats['tshirt'])
    elif cz > 0.15:  # muslos/pantalón
        p.name = 'legs_pants'
        p.data.materials.append(mats['pants'])
    elif cz > 0.07:  # rodillas/pantorrillas
        p.name = 'legs_lower'
        p.data.materials.append(mats['pants'])
    else:  # pies/botas
        p.name = 'feet_boots'
        p.data.materials.append(mats['boots'])
    
    print(f"  {p.name}: Z={cz:.3f} [{cz_min:.3f}-{cz_max:.3f}] mat={p.data.materials[0].name if p.data.materials else 'none'}")

# Sombreado suave en todas
for p in parts:
    for poly in p.data.polygons:
        poly.use_smooth = True

# Configurar render
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.film_transparent = True

# Luz
light_data = bpy.data.lights.new('KeyLight', 'SUN')
light_data.energy = 3.0
light_obj = bpy.data.objects.new('KeyLight', light_data)
bpy.context.collection.objects.link(light_obj)
light_obj.rotation_euler = (math.radians(-45), math.radians(30), 0)

light_data2 = bpy.data.lights.new('FillLight', 'SUN')
light_data2.energy = 1.0
light_obj2 = bpy.data.objects.new('FillLight', light_data2)
bpy.context.collection.objects.link(light_obj2)
light_obj2.rotation_euler = (math.radians(-30), math.radians(-60), 0)

# Cámara orbital 8 vistas
for angle in [0, 45, 90, 135, 180, 225, 270, 315]:
    rad = math.radians(angle)
    cam = bpy.data.cameras.new(f"Cam_{angle}")
    cam_obj = bpy.data.objects.new(f"Cam_{angle}", cam)
    bpy.context.collection.objects.link(cam_obj)
    cam_obj.location = (2.0 * math.cos(rad), 2.0 * math.sin(rad), 0.55)
    cam_obj.rotation_euler = (math.radians(90), 0, rad + math.radians(90))
    scene.camera = cam_obj
    
    out_path = fr'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\v03_colored_{angle:03d}.png'
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Render {angle}° -> {out_path}")

# Guardar blend v03 colored
out_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_colored.blend'
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print(f"\n✅ Blend v03 colored guardado: {out_blend}")