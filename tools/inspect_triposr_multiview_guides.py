import bpy, math, os, sys
from mathutils import Vector
BASE=r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\triposr_multiview_guides'
for idx in (0,1):
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 root=os.path.join(BASE,str(idx));bpy.ops.wm.obj_import(filepath=os.path.join(root,'mesh.obj'));o=[x for x in bpy.context.scene.objects if x.type=='MESH'][0]
 pts=[o.matrix_world@Vector(c) for c in o.bound_box];lo=Vector((min(p.x for p in pts),min(p.y for p in pts),min(p.z for p in pts)));hi=Vector((max(p.x for p in pts),max(p.y for p in pts),max(p.z for p in pts)));o.location-=(lo+hi)/2;o.rotation_euler[1]=math.radians(-90);bpy.ops.object.transform_apply(location=False,rotation=True,scale=False)
 pts=[o.matrix_world@Vector(c) for c in o.bound_box];k=1.08/(max(p.z for p in pts)-min(p.z for p in pts));o.scale*=k;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);pts=[o.matrix_world@Vector(c) for c in o.bound_box];o.location.z-=min(p.z for p in pts)
 m=bpy.data.materials.new(f'Color{idx}');m.use_nodes=True;n=m.node_tree.nodes;bs=next(q for q in n if q.type=='BSDF_PRINCIPLED');vc=n.new('ShaderNodeVertexColor');vc.layer_name='Color';m.node_tree.links.new(vc.outputs['Color'],bs.inputs['Base Color']);bs.inputs['Roughness'].default_value=.75;o.data.materials.clear();o.data.materials.append(m)
 for p in o.data.polygons:p.use_smooth=True
 bpy.ops.mesh.primitive_plane_add(size=8,location=(0,0,-.004));
 world=bpy.context.scene.world;world.color=(.02,.02,.03)
 for loc,en in [((-2,-3,3),1200),((2,-2,2),650),((0,2,2.5),800)]:
  bpy.ops.object.light_add(type='AREA',location=loc);l=bpy.context.object;l.data.energy=en;l.data.size=3;l.rotation_euler=(Vector((0,0,.54))-l.location).to_track_quat('-Z','Y').to_euler()
 bpy.ops.object.camera_add(location=(0,-2.2,1.08));cam=bpy.context.object;cam.data.lens=62;cam.rotation_euler=(Vector((0,0,.54))-cam.location).to_track_quat('-Z','Y').to_euler();bpy.context.scene.camera=cam
 sc=bpy.context.scene;sc.render.engine='BLENDER_EEVEE';sc.render.resolution_x=700;sc.render.resolution_y=900;sc.render.resolution_percentage=100;sc.render.filepath=os.path.join(root,'guide_render.png');bpy.ops.render.render(write_still=True)
 print('GUIDE',idx,'DONE')
