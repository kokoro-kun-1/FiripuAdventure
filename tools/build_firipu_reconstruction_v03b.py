import bpy, math, os
from mathutils import Vector
SRC=r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\triposr_v03\0\mesh.obj'
ROOT=r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\reconstruction_v03b';os.makedirs(ROOT,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False);bpy.ops.wm.obj_import(filepath=SRC)
body=[o for o in bpy.context.scene.objects if o.type=='MESH'][0];body.name='Firipu_Reconstruccion_Base'
# Orientación, centrado y escala exacta.
pts=[body.matrix_world@Vector(c) for c in body.bound_box];lo=Vector((min(p.x for p in pts),min(p.y for p in pts),min(p.z for p in pts)));hi=Vector((max(p.x for p in pts),max(p.y for p in pts),max(p.z for p in pts)));body.location-=(lo+hi)/2;body.rotation_euler[1]=math.radians(-90);bpy.ops.object.transform_apply(location=False,rotation=True,scale=False)
bpy.context.view_layer.update();pts=[body.matrix_world@Vector(c) for c in body.bound_box];h=max(p.z for p in pts)-min(p.z for p in pts);body.scale*=1.08/h;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);pts=[body.matrix_world@Vector(c) for c in body.bound_box];body.location.z-=min(p.z for p in pts);bpy.ops.object.transform_apply(location=True,rotation=False,scale=False)
# Limpieza conservadora del ruido de reconstrucción.
sm=body.modifiers.new('Limpieza_Superficie','LAPLACIANSMOOTH');sm.iterations=3;sm.lambda_factor=.12;sm.use_volume_preserve=True;bpy.context.view_layer.objects.active=body;bpy.ops.object.modifier_apply(modifier=sm.name)
# Material desde los colores de vértice recuperados de la imagen.
m=bpy.data.materials.new('Colores_Reconstruidos');m.use_nodes=True;n=m.node_tree.nodes;n.clear();out=n.new('ShaderNodeOutputMaterial');bs=n.new('ShaderNodeBsdfPrincipled');vc=n.new('ShaderNodeVertexColor');vc.layer_name='Color';bs.inputs['Roughness'].default_value=.72;m.node_tree.links.new(vc.outputs['Color'],bs.inputs['Base Color']);m.node_tree.links.new(bs.outputs['BSDF'],out.inputs['Surface']);body.data.materials.clear();body.data.materials.append(m)
for p in body.data.polygons:p.use_smooth=True
# Luces y suelo.
bpy.ops.mesh.primitive_plane_add(size=8,location=(0,0,-.004));floor=bpy.context.object;fm=bpy.data.materials.new('Suelo');fm.diffuse_color=(.18,.18,.2,1);floor.data.materials.append(fm)
world=bpy.context.scene.world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs['Color'].default_value=(.02,.025,.04,1);world.node_tree.nodes['Background'].inputs['Strength'].default_value=.38
for loc,en,size,col in [((-2,-3,3),1250,3,(1,.82,.68)),((2,-2,2),700,2.5,(.62,.76,1)),((0,2,2.5),900,2,(.75,.82,1))]:
 bpy.ops.object.light_add(type='AREA',location=loc);l=bpy.context.object;l.data.energy=en;l.data.size=size;l.data.color=col;l.rotation_euler=(Vector((0,0,.55))-l.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add();cam=bpy.context.object;cam.data.lens=62;bpy.context.scene.camera=cam
sc=bpy.context.scene;sc.render.engine='BLENDER_EEVEE';sc.render.resolution_x=700;sc.render.resolution_y=900;sc.render.resolution_percentage=100;sc.render.image_settings.file_format='PNG'
for label,deg in [('front',0),('three_quarter',45),('side',90),('back',180)]:
 a=math.radians(deg);cam.location=(2.2*math.sin(a),-2.2*math.cos(a),1.08);cam.rotation_euler=(Vector((0,0,.54))-cam.location).to_track_quat('-Z','Y').to_euler();sc.render.filepath=os.path.join(ROOT,f'firipu_reconstruction_v03b_{label}.png');bpy.ops.render.render(write_still=True)
# Guardar editable y GLB solo de la malla.
blend=os.path.join(ROOT,'firipu_reconstruction_v03b.blend');bpy.ops.wm.save_as_mainfile(filepath=blend);bpy.ops.object.select_all(action='DESELECT');body.select_set(True);bpy.context.view_layer.objects.active=body;glb=os.path.join(ROOT,'firipu_reconstruction_v03b.glb');bpy.ops.export_scene.gltf(filepath=glb,export_format='GLB',use_selection=True,export_apply=True)
print('CREATED',blend);print('CREATED',glb);print('VERTICES',len(body.data.vertices),'FACES',len(body.data.polygons),'HEIGHT',1.08)
