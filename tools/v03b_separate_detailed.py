import bpy, math, bmesh
from mathutils import Vector

# Cargar el blend coloreado
blend_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_colored.blend'
bpy.ops.wm.open_mainfile(filepath=blend_path)

# Obtener todas las mallas
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
print(f"Mallas actuales: {len(meshes)}")
for m in meshes:
    print(f"  {m.name}: verts={len(m.data.vertices)}")

# Unir todo en una sola malla para re-separar mejor
if len(meshes) > 1:
    bpy.context.view_layer.objects.active = meshes[0]
    for m in meshes[1:]:
        m.select_set(True)
    bpy.ops.object.join()
    main_obj = bpy.context.active_object
else:
    main_obj = meshes[0]

print(f"\nMalla unificada: {main_obj.name}, verts={len(main_obj.data.vertices)}")

# === PALETA CANÓNICA ===
PALETTE = {
    'skin':        (0.96, 0.78, 0.68),
    'hair':        (0.18, 0.12, 0.08),
    'eyes':        (0.25, 0.18, 0.12),
    'freckles':    (0.65, 0.35, 0.20),
    'hoodie':      (0.12, 0.35, 0.65),
    'tshirt':      (0.95, 0.92, 0.85),
    'pants':       (0.35, 0.28, 0.22),
    'knee_patch':  (0.15, 0.12, 0.10),
    'socks':       (0.95, 0.92, 0.85),
    'sock_stripe': (0.70, 0.15, 0.15),
    'boots':       (0.28, 0.18, 0.12),
    'boot_sole':   (0.12, 0.10, 0.08),
    'backpack':    (0.35, 0.40, 0.25),
    'bandana':     (0.65, 0.25, 0.15),
}

def make_mat(name, base_color, rough=0.8, spec=0.04):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*base_color, 1.0)
        bsdf.inputs['Roughness'].default_value = rough
        if 'Specular' in bsdf.inputs:
            bsdf.inputs['Specular'].default_value = spec
        elif 'Specular IOR Level' in bsdf.inputs:
            bsdf.inputs['Specular IOR Level'].default_value = spec
    return mat

mats = {k: make_mat(k, v) for k, v in PALETTE.items()}

# === SEPARACIÓN MULTI-PASO POR Z + NORMALES ===
bpy.context.view_layer.objects.active = main_obj
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')

# Paso 1: Separar por componentes sueltos (por si acaso)
bpy.ops.mesh.separate(type='LOOSE')
bpy.ops.object.mode_set(mode='OBJECT')

parts = [o for o in bpy.context.scene.objects if o.type == 'MESH']
print(f"\nTras LOOSE: {len(parts)} partes")

# Función auxiliar: separar selección actual
def separate_selected(obj_name):
    bpy.context.view_layer.objects.active = bpy.data.objects[obj_name]
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.separate(type='SELECTED')
    bpy.ops.object.mode_set(mode='OBJECT')

# Función: seleccionar caras por umbral Z en un objeto
def select_by_z(obj, z_min, z_max, normal_filter=None):
    """Selecciona caras cuyo centroide Z esté en rango. normal_filter: 'up' (Z>0.7), 'down' (Z<-0.7), 'side' (|Z|<0.3)"""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.faces.ensure_lookup_table()
    
    mw = obj.matrix_world
    for face in bm.faces:
        face.select = False
        cz = sum((mw @ v.co).z for v in face.verts) / len(face.verts)
        if z_min <= cz <= z_max:
            if normal_filter:
                nz = (mw.to_3x3() @ face.normal.normalized()).z
                if normal_filter == 'up' and nz > 0.7:
                    face.select = True
                elif normal_filter == 'down' and nz < -0.7:
                    face.select = True
                elif normal_filter == 'side' and abs(nz) < 0.3:
                    face.select = True
                elif normal_filter is None:
                    face.select = True
            else:
                face.select = True
    bm.to_mesh(obj.data)
    bm.free()

# Procesar cada parte existente y sub-dividirla
all_parts = list(parts)
for part in all_parts:
    bbox = [part.matrix_world @ Vector(c) for c in part.bound_box]
    z_min = min(v.z for v in bbox)
    z_max = max(v.z for v in bbox)
    z_cent = sum(v.z for v in bbox) / 8
    height = z_max - z_min
    
    print(f"\nProcesando {part.name}: Z=[{z_min:.3f}-{z_max:.3f}] centro={z_cent:.3f} h={height:.3f}")
    
    # CABEZA (z > 0.85) - ya separado, pero refinemos: cara vs cabello
    if z_cent > 0.85:
        # Separar cara (frente, Z > 0.95, normales hacia adelante) vs cabello (resto)
        select_by_z(part, 0.95, 1.08, normal_filter='up')  # caras frontales superiores = cara
        bpy.context.view_layer.objects.active = part
        bpy.ops.object.mode_set(mode='EDIT')
        if any(f.select for f in bmesh.from_edit_mesh(part.data).faces):
            bpy.ops.mesh.separate(type='SELECTED')
            bpy.ops.object.mode_set(mode='OBJECT')
            print("  -> Separado: cara (frontales)")
        else:
            bpy.ops.object.mode_set(mode='OBJECT')
            print("  -> No hay caras frontales separables")
    
    # TORSO SUPERIOR (0.65-0.85) - polerón
    elif z_cent > 0.65:
        # Separar mangas (lados, normales X/Y) vs cuerpo frontal/trasero
        pass  # mantener como polerón por ahora
    
    # TORSO MEDIO (0.45-0.65) - camiseta (mangas remangadas)
    elif z_cent > 0.45:
        pass
    
    # MUSLOS / PANTALÓN SUPERIOR (0.30-0.45)
    elif z_cent > 0.30:
        pass
    
    # RODILLAS / PANTORRILLAS (0.15-0.30) - rodilleras + pantalón
    elif z_cent > 0.15:
        pass
    
    # PIES / BOTAS (0-0.15)
    elif z_cent > 0:
        # Separar suela (normales hacia abajo, Z < 0.03) vs bota
        select_by_z(part, 0.0, 0.03, normal_filter='down')
        bpy.context.view_layer.objects.active = part
        bpy.ops.object.mode_set(mode='EDIT')
        if any(f.select for f in bmesh.from_edit_mesh(part.data).faces):
            bpy.ops.mesh.separate(type='SELECTED')
            bpy.ops.object.mode_set(mode='OBJECT')
            print("  -> Separado: suela")
        else:
            bpy.ops.object.mode_set(mode='OBJECT')

# Recolectar todas las partes finales
parts = [o for o in bpy.context.scene.objects if o.type == 'MESH']
print(f"\n=== PARTES FINALES: {len(parts)} ===")

# Asignar materiales por heurística de posición y nombre
for p in parts:
    bbox = [p.matrix_world @ Vector(c) for c in p.bound_box]
    cz = sum(v.z for v in bbox) / 8
    cz_max = max(v.z for v in bbox)
    cz_min = min(v.z for v in bbox)
    
    # Determinar tipo por posición Z y geometría
    if cz > 0.95:  # cara/piel
        p.name = 'head_face'
        p.data.materials.clear()
        p.data.materials.append(mats['skin'])
    elif cz > 0.85:  # cabello
        p.name = 'head_hair'
        p.data.materials.clear()
        p.data.materials.append(mats['hair'])
    elif cz > 0.65:  # polerón
        p.name = 'torso_hoodie'
        p.data.materials.clear()
        p.data.materials.append(mats['hoodie'])
    elif cz > 0.45:  # camiseta
        p.name = 'torso_tshirt'
        p.data.materials.clear()
        p.data.materials.append(mats['tshirt'])
    elif cz > 0.30:  # pantalón muslos
        p.name = 'legs_pants_upper'
        p.data.materials.clear()
        p.data.materials.append(mats['pants'])
    elif cz > 0.15:  # rodilleras / pantorrillas
        # Heurística: si es delgado y frontal -> rodillera
        if height < 0.1:
            p.name = 'knee_patch_L' if 'left' in p.name.lower() or sum(v.x for v in bbox)/8 < 0 else 'knee_patch_R'
            p.data.materials.clear()
            p.data.materials.append(mats['knee_patch'])
        else:
            p.name = 'legs_pants_lower'
            p.data.materials.clear()
            p.data.materials.append(mats['pants'])
    elif cz > 0.03:  # calcetines / botas superiores
        # Separar franja calcetín (Z ~0.07-0.10) vs bota
        if cz > 0.07:
            p.name = 'socks'
            p.data.materials.clear()
            p.data.materials.append(mats['socks'])
        else:
            p.name = 'boots_upper'
            p.data.materials.clear()
            p.data.materials.append(mats['boots'])
    else:  # suela
        if 'sole' not in p.name.lower():
            p.name = 'boots_sole'
        p.data.materials.clear()
        p.data.materials.append(mats['boot_sole'])
    
    print(f"  {p.name}: Z={cz:.3f} [{cz_min:.3f}-{cz_max:.3f}] mat={p.data.materials[0].name if p.data.materials else 'none'}")

# Sombreado suave
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
for ld in bpy.data.lights:
    bpy.data.lights.remove(ld)
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
    
    out_path = fr'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\v03b_colored_{angle:03d}.png'
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Render {angle}° -> {out_path}")

# Guardar blend final v03b
out_blend = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03b_colored.blend'
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
print(f"\n✅ Blend v03b colored guardado: {out_blend}")