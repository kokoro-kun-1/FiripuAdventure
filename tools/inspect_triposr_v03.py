import bpy, math, os
from mathutils import Vector
ROOT=r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\triposr_v03\0'
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.ops.wm.obj_import(filepath=os.path.join(ROOT,'mesh.obj'))
objs=[o for o in bpy.context.scene.objects if o.type=='MESH']
pts=[o.matrix_world@Vector(c) for o in objs for c in o.bound_box]
lo=Vector((min(p.x for p in pts),min(p.y for p in pts),min(p.z for p in pts)))
hi=Vector((max(p.x for p in pts),max(p.y for p in pts),max(p.z for p in pts)))
center=(lo+hi)/2; size=hi-lo
# TripoSR suele usar Y vertical; elegir automáticamente el eje mayor y rotarlo a Z.
axis=max(range(3),key=lambda i:size[i])
for o in objs:
 o.location-=center
 if axis==1:o.rotation_euler[0]=math.radians(90)
 elif axis==0:o.rotation_euler[1]=math.radians(-90)
bpy.context.view_layer.update()
pts=[o.matrix_world@Vector(c) for o in objs for c in o.bound_box]; h=max(p.z for p in pts)-min(p.z for p in pts); k=1.08/h
for o in objs:o.scale*=k
bpy.context.view_layer.update();pts=[o.matrix_world@Vector(c) for o in objs for c in o.bound_box]; zmin=min(p.z for p in pts)
for o in objs:o.location.z-=zmin
# material gris si no existe
if not any(o.data.materials for o in objs):
 m=bpy.data.materials.new('Clay');m.diffuse_color=(.48,.32,.22,1)
 for o in objs:o.data.materials.append(m)
for o in objs:
 for p in o.data.polygons:p.use_smooth=True
# piso
bpy.ops.mesh.primitive_plane_add(size=8,location=(0,0,-.003)); plane=bpy.context.object
m=bpy.data.materials.new('Floor');m.diffuse_color=(.18,.18,.2,1);plane.data.materials.append(m)
world=bpy.context.scene.world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs['Color'].default_value=(.025,.03,.045,1);world.node_tree.nodes['Background'].inputs['Strength'].default_value=.4
for loc,en,size in [((-2,-3,3),1200,3),((2,-2,2),700,2.5),((0,2,2.5),900,2)]:
 bpy.ops.object.light_add(type='AREA',location=loc);l=bpy.context.object;l.data.energy=en;l.data.shape='DISK';l.data.size=size;l.rotation_euler=(Vector((0,0,.55))-l.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add();cam=bpy.context.object;cam.data.lens=60;bpy.context.scene.camera=cam
sc=bpy.context.scene;sc.render.engine='BLENDER_EEVEE';sc.render.resolution_x=700;sc.render.resolution_y=900;sc.render.resolution_percentage=100;sc.render.image_settings.file_format='PNG'
for label,deg in [('front',0),('three_quarter',45),('side',90),('back',180)]:
 a=math.radians(deg);cam.location=(2.2*math.sin(a),-2.2*math.cos(a),1.1);cam.rotation_euler=(Vector((0,0,.54))-cam.location).to_track_quat('-Z','Y').to_euler();sc.render.filepath=os.path.join(ROOT,f'triposr_{label}.png');bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ROOT,'triposr_inspection.blend'))
print('MESHES',len(objs),'HEIGHT',1.08,'SOURCE_SIZE',tuple(round(v,4) for v in size))
