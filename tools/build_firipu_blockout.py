import bpy
import math
import os
from mathutils import Vector

ROOT = r"C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\blockout"
os.makedirs(ROOT, exist_ok=True)

# Limpiar escena
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials, bpy.data.cameras, bpy.data.lights):
    pass

# Materiales simples de blockout, basados en las referencias aprobadas
def mat(name, color, roughness=0.7, metallic=0.0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1)
    bsdf.inputs['Roughness'].default_value = roughness
    bsdf.inputs['Metallic'].default_value = metallic
    return m

SKIN = mat('MAT_Piel', (0.82, 0.48, 0.28), 0.62)
HAIR = mat('MAT_Cabello', (0.055, 0.022, 0.012), 0.82)
BLUE = mat('MAT_Poleron_Azul', (0.035, 0.22, 0.52), 0.82)
CREAM = mat('MAT_Interior_Crema', (0.82, 0.70, 0.52), 0.9)
BROWN = mat('MAT_Pantalon_Cafe', (0.30, 0.13, 0.045), 0.84)
KNEE = mat('MAT_Rodilleras', (0.18, 0.075, 0.025), 0.9)
BOOT = mat('MAT_Botas_Cuero', (0.20, 0.075, 0.022), 0.63)
SOLE = mat('MAT_Suelas', (0.12, 0.045, 0.015), 0.88)
WHITE = mat('MAT_Ojos_Blanco', (0.95, 0.95, 0.91), 0.38)
IRIS = mat('MAT_Iris_Cafe', (0.18, 0.055, 0.012), 0.3)
BLACK = mat('MAT_Pupila', (0.004, 0.003, 0.002), 0.25)

COL = bpy.data.collections.new('FIRIPU_BLOCKOUT_V01')
bpy.context.scene.collection.children.link(COL)

def move_to_collection(obj):
    for c in list(obj.users_collection): c.objects.unlink(obj)
    COL.objects.link(obj)

def smooth(obj):
    if obj.type == 'MESH':
        for p in obj.data.polygons: p.use_smooth = True

def uv(name, loc, scale, material, seg=32, rings=20):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=rings, location=loc)
    o=bpy.context.object; o.name=name; o.scale=scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(material); smooth(o); move_to_collection(o); return o

def cube(name, loc, scale, material, bevel=0.03):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o=bpy.context.object; o.name=name; o.scale=scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    b=o.modifiers.new('Bevel','BEVEL'); b.width=bevel; b.segments=3
    o.data.materials.append(material); smooth(o); move_to_collection(o); return o

def cylinder_between(name, a, b, radius, material, vertices=20):
    a,b=Vector(a),Vector(b); d=b-a; length=d.length; mid=(a+b)/2
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=length, location=mid)
    o=bpy.context.object; o.name=name
    o.rotation_mode='QUATERNION'; o.rotation_quaternion=Vector((0,0,1)).rotation_difference(d.normalized())
    o.data.materials.append(material); smooth(o); move_to_collection(o); return o

def torus(name, loc, major, minor, material, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=32, minor_segments=10, location=loc, rotation=rot)
    o=bpy.context.object; o.name=name; o.data.materials.append(material); smooth(o); move_to_collection(o); return o

# Escala final: 1.08 m. Piso Z=0.
# Piernas y calcetines
for side,x in [('L',-0.105),('R',0.105)]:
    cylinder_between(f'Pierna_{side}', (x,0,0.24), (x,0,0.50), 0.078, BROWN)
    cylinder_between(f'Calcetin_{side}', (x,0,0.145), (x,0,0.255), 0.069, CREAM)
    torus(f'FranjaCalcetin_{side}', (x,0,0.222), 0.069, 0.008, mat(f'MAT_Franja_{side}',(0.55,0.025,0.012),0.8), rot=(0,0,0))
    # Botas: pie hacia -Y (frente del personaje)
    cube(f'Bota_{side}', (x,-0.035,0.085), (0.082,0.135,0.072), BOOT, 0.035)
    cube(f'Suela_{side}', (x,-0.042,0.025), (0.09,0.145,0.025), SOLE, 0.018)
    cube(f'Rodillera_{side}', (x,-0.073,0.405), (0.070,0.022,0.070), KNEE, 0.025)

# Caderas, torso y polerón
uv('Caderas', (0,0,0.50), (0.20,0.13,0.15), BROWN)
uv('Torso_Poleron', (0,0,0.69), (0.235,0.145,0.235), BLUE)
cube('Pretina_Poleron', (0,0,0.535), (0.205,0.135,0.028), BLUE, 0.018)
# Bolsillo canguro
cube('Bolsillo_Canguro', (0,-0.133,0.63), (0.125,0.022,0.065), BLUE, 0.025)
# Capucha como volumen posterior y borde
uv('Capucha', (0,0.105,0.825), (0.205,0.105,0.145), BLUE)
torus('Borde_Capucha', (0,-0.015,0.82), 0.145, 0.022, BLUE, rot=(math.radians(90),0,0))

# Brazos en A-pose ~27 grados
for side,s in [('L',-1),('R',1)]:
    shoulder=(s*0.19,0,0.79); elbow=(s*0.285,0,0.63); wrist=(s*0.335,-0.005,0.51)
    cylinder_between(f'BrazoSuperior_{side}', shoulder, elbow, 0.068, BLUE)
    cylinder_between(f'AntebrazoCrema_{side}', elbow, wrist, 0.054, CREAM)
    # puño remangado
    cylinder_between(f'PunioRemangado_{side}', (s*0.274,0,0.648), (s*0.297,0,0.605), 0.073, CREAM)
    uv(f'Mano_{side}', (s*0.347,-0.005,0.475), (0.050,0.036,0.075), SKIN)

# Cuello, cabeza y orejas
cylinder_between('Cuello', (0,0,0.80), (0,0,0.88), 0.066, SKIN)
uv('Cabeza', (0,-0.012,0.945), (0.165,0.145,0.175), SKIN, 40, 28)
uv('Mejilla_L', (-0.098,-0.133,0.922), (0.052,0.025,0.052), SKIN)
uv('Mejilla_R', (0.098,-0.133,0.922), (0.052,0.025,0.052), SKIN)
uv('Nariz', (0,-0.158,0.947), (0.030,0.026,0.024), SKIN)
for side,x in [('L',-0.168),('R',0.168)]:
    uv(f'Oreja_{side}', (x,-0.005,0.954), (0.034,0.024,0.050), SKIN)
# ojos al frente -Y
for side,x in [('L',-0.061),('R',0.061)]:
    uv(f'Ojo_{side}', (x,-0.145,0.990), (0.043,0.020,0.050), WHITE, 28, 18)
    uv(f'Iris_{side}', (x,-0.165,0.990), (0.022,0.009,0.028), IRIS, 24, 14)
    uv(f'Pupila_{side}', (x,-0.173,0.990), (0.010,0.005,0.014), BLACK, 20, 12)
# cejas
for side,x in [('L',-0.063),('R',0.063)]:
    cube(f'Ceja_{side}', (x,-0.163,1.055), (0.042,0.008,0.009), HAIR, 0.008)
# boca neutral
cube('Boca_Neutral', (0,-0.163,0.885), (0.035,0.006,0.006), BOOT, 0.006)

# Pelo: casquete + 22 mechones sólidos simplificados
uv('Casquete_Cabello', (0,0.018,1.075), (0.172,0.148,0.125), HAIR, 36, 24)
hair_specs=[]
for ring,z,rad,count in [(0,1.125,0.105,7),(1,1.075,0.145,9),(2,1.015,0.158,8)]:
    for i in range(count):
        a=2*math.pi*i/count + ring*0.18
        x=math.cos(a)*rad; y=math.sin(a)*rad*0.74+0.015
        hair_specs.append((x,y,z,count,i))
for idx,(x,y,z,count,i) in enumerate(hair_specs):
    o=uv(f'Mechon_{idx:02d}', (x,y,z), (0.052,0.038,0.080), HAIR, 20, 12)
    o.rotation_euler=(0.25*math.sin(i), 0.35*math.cos(i), math.atan2(y,x)+0.4)

# Normalizar el blockout a 1,08 m exactos desde el suelo hasta el pelo.
bpy.context.view_layer.update()
points = [o.matrix_world @ Vector(corner) for o in COL.objects if o.type == 'MESH' for corner in o.bound_box]
current_height = max(p.z for p in points) - min(p.z for p in points)
height_scale = 1.08 / current_height
for o in COL.objects:
    o.location *= height_scale
    o.scale *= height_scale
    o['firipu_blockout_version'] = 'v01'
    o['scale_meters'] = 1.0
bpy.context.view_layer.update()

# Piso, luces y cámara fuera de colección exportable
bpy.ops.mesh.primitive_plane_add(size=20, location=(0,0,-0.002))
plane=bpy.context.object; plane.name='Piso_Render'; plane.data.materials.append(mat('MAT_Piso',(0.75,0.75,0.75),0.9))
# Mantener el piso exclusivamente en la escena de render, nunca en el GLB.
for collection in list(plane.users_collection):
    collection.objects.unlink(plane)
bpy.context.scene.collection.objects.link(plane)

world=bpy.context.scene.world
world.color=(0.04,0.04,0.04)
world.use_nodes=True
world.node_tree.nodes['Background'].inputs['Color'].default_value=(0.035,0.04,0.05,1)
world.node_tree.nodes['Background'].inputs['Strength'].default_value=0.35

def area(name,loc,energy,size,color):
    bpy.ops.object.light_add(type='AREA', location=loc)
    l=bpy.context.object; l.name=name; l.data.energy=energy; l.data.shape='DISK'; l.data.size=size; l.data.color=color
    q=Vector((0,0,0.65))-l.location; l.rotation_euler=q.to_track_quat('-Z','Y').to_euler()
area('Key',(-2,-3,3),1100,3.0,(1.0,0.82,0.68))
area('Fill',(2,-2,2),700,2.5,(0.62,0.78,1.0))
area('Rim',(0,2,2.5),900,2.0,(0.75,0.86,1.0))

bpy.ops.object.camera_add(location=(1.8,-3.4,1.35))
cam=bpy.context.object; cam.name='Camera_Render'
target=Vector((0,0,0.58)); cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler(); cam.data.lens=58
bpy.context.scene.camera=cam

scene=bpy.context.scene
scene.render.engine='BLENDER_EEVEE'
scene.render.resolution_x=900; scene.render.resolution_y=1100; scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
scene.render.film_transparent=False
scene.render.filepath=os.path.join(ROOT,'firipu_blockout_v01_preview.png')
scene.render.image_settings.color_mode='RGBA'

# Guardar y exportar exclusivamente la colección Firipu.
blend_path=os.path.join(ROOT,'firipu_blockout_v01.blend')
bpy.ops.wm.save_as_mainfile(filepath=blend_path)
bpy.ops.object.select_all(action='DESELECT')
for o in COL.objects: o.select_set(True)
bpy.context.view_layer.objects.active=next(iter(COL.objects))
glb_path=os.path.join(ROOT,'firipu_blockout_v01.glb')
bpy.ops.export_scene.gltf(filepath=glb_path, export_format='GLB', use_selection=True, export_apply=True)
bpy.ops.render.render(write_still=True)
print('CREATED', blend_path)
print('CREATED', glb_path)
print('CREATED', scene.render.filepath)
print('HEIGHT_TARGET_M',1.08)
print('EXPORTED_OBJECTS',len(COL.objects))
