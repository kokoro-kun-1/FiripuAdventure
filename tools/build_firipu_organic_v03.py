import bpy, math, os
from mathutils import Vector

ROOT=r"C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\organic_v03"
os.makedirs(ROOT,exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)

EXPORT=bpy.data.collections.new('FIRIPU_V03_EXPORT'); bpy.context.scene.collection.children.link(EXPORT)
RENDER=bpy.data.collections.new('FIRIPU_V03_RENDER'); bpy.context.scene.collection.children.link(RENDER)

def mat(name,c,rough=.7):
 m=bpy.data.materials.new(name); m.diffuse_color=(*c,1); m.use_nodes=True
 b=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED'); b.inputs['Base Color'].default_value=(*c,1); b.inputs['Roughness'].default_value=rough; return m
SKIN=mat('Piel',(0.86,.50,.30),.58); HAIR=mat('Cabello',(.035,.012,.006),.78); BLUE=mat('Poleron',(0.025,.18,.48),.82)
CREAM=mat('Camiseta_Crema',(.82,.72,.56),.9); BROWN=mat('Pantalon',(.27,.105,.025),.82); KNEE=mat('Rodillera',(.13,.045,.012),.88)
BOOT=mat('Cuero_Botas',(.16,.05,.012),.62); SOLE=mat('Goma_Suela',(.08,.022,.006),.86); WHITE=mat('Esclerotica',(.92,.91,.86),.4)
IRIS=mat('Iris_Cafe',(.18,.045,.006),.3); BLACK=mat('Pupila',(.002,.001,.001),.25); RED=mat('Franja_Roja',(.55,.018,.008),.8)

def put(o,col=EXPORT):
 for c in list(o.users_collection): c.objects.unlink(o)
 col.objects.link(o); return o

def smooth(o):
 if o.type=='MESH':
  for p in o.data.polygons:p.use_smooth=True
 return o

def ell(name,loc,scale,ma,seg=32,rings=20):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=seg,ring_count=rings,location=loc); o=bpy.context.object; o.name=name; o.scale=scale
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); o.data.materials.append(ma); return put(smooth(o))

def capsule(name,a,b,r,ma):
 a,b=Vector(a),Vector(b); d=b-a; mid=(a+b)/2
 bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,location=mid); o=bpy.context.object; o.name=name
 o.scale=(r,r,d.length/2+r); o.rotation_mode='QUATERNION'; o.rotation_quaternion=Vector((0,0,1)).rotation_difference(d.normalized())
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); o.data.materials.append(ma); return put(smooth(o))

def union(objs,name,voxel=.006,smooth_iter=3):
 bpy.ops.object.select_all(action='DESELECT')
 for o in objs:o.select_set(True)
 bpy.context.view_layer.objects.active=objs[0]; bpy.ops.object.join(); o=bpy.context.object; o.name=name
 o.data.remesh_voxel_size=voxel; o.data.remesh_voxel_adaptivity=.05; bpy.ops.object.voxel_remesh()
 sm=o.modifiers.new('Relax','SMOOTH'); sm.factor=.28; sm.iterations=smooth_iter; bpy.ops.object.modifier_apply(modifier=sm.name)
 return smooth(o)

def loft(name,rings,ma,steps=24):
 vs=[]; fs=[]
 for z,rx,front,back in rings:
  for i in range(steps):
   a=2*math.pi*i/steps; y=(-front if math.sin(a)<0 else back)*abs(math.sin(a)); x=rx*math.cos(a); vs.append((x,y,z))
 for j in range(len(rings)-1):
  for i in range(steps): a=j*steps+i; b=j*steps+(i+1)%steps; c=(j+1)*steps+(i+1)%steps; d=(j+1)*steps+i; fs.append((a,b,c,d))
 fs.append(tuple(range(steps-1,-1,-1))); top=(len(rings)-1)*steps; fs.append(tuple(top+i for i in range(steps)))
 me=bpy.data.meshes.new(name+'Mesh'); me.from_pydata(vs,[],fs); me.materials.append(ma); o=bpy.data.objects.new(name,me); EXPORT.objects.link(o)
 sub=o.modifiers.new('Organic','SUBSURF'); sub.levels=2; sub.render_levels=2; return smooth(o)

def curved_clump(name,points,radii,ma):
 cu=bpy.data.curves.new(name+'Curve','CURVE'); cu.dimensions='3D'; cu.resolution_u=3; cu.bevel_depth=.038; cu.bevel_resolution=3; cu.resolution_u=4
 sp=cu.splines.new('BEZIER'); sp.bezier_points.add(len(points)-1)
 for bp,p,r in zip(sp.bezier_points,points,radii): bp.co=p; bp.radius=r; bp.handle_left_type='AUTO'; bp.handle_right_type='AUTO'
 o=bpy.data.objects.new(name,cu); cu.materials.append(ma); EXPORT.objects.link(o); return o

def torus(name,loc,major,minor,ma):
 bpy.ops.mesh.primitive_torus_add(major_radius=major,minor_radius=minor,major_segments=32,minor_segments=10,location=loc); o=bpy.context.object;o.name=name;o.data.materials.append(ma);return put(smooth(o))

# CUERPO/ROPA: perfiles controlados, no esferas visibles.
hoodie=loft('Poleron_Organico',[(.51,.17,.105,.095),(.60,.195,.12,.105),(.71,.205,.125,.11),(.79,.18,.11,.115),(.82,.105,.075,.08)],BLUE)
pants=loft('Pantalon_Cintura',[(.43,.155,.09,.085),(.50,.17,.105,.095),(.55,.175,.105,.10)],BROWN)
# Piernas y brazos con transiciones suaves.
for side,s in [('L',-1),('R',1)]:
 leg=union([capsule('tmp',(s*.095,0,.20),(s*.105,0,.49),.068,BROWN),ell('tmp',(s*.105,0,.47),(.085,.075,.09),BROWN)],f'Pierna_{side}',.007,2)
 ell(f'Rodillera_{side}',(s*.105,-.068,.365),(.067,.026,.065),KNEE,24,14)
 capsule(f'Calcetin_{side}',(s*.105,0,.115),(s*.105,0,.235),.061,CREAM); torus(f'Franja_{side}',(s*.105,0,.205),.061,.007,RED)
 # Brazo azul + antebrazo crema, más fino y largo que v02.
 capsule(f'Manga_{side}',(s*.17,0,.765),(s*.278,0,.615),.058,BLUE)
 capsule(f'Antebrazo_{side}',(s*.278,0,.615),(s*.325,-.003,.515),.043,CREAM)
 torus(f'MangaRemangada_{side}',(s*.282,0,.61),.057,.014,CREAM)
 # Mano orgánica fusionada: palma, masa tenar y cinco dedos relajados.
 bits=[ell('tmp',(s*.345,-.004,.485),(.041,.031,.052),SKIN,20,12),ell('tmp',(s*.326,-.012,.478),(.026,.025,.032),SKIN,18,10)]
 lens=[.041,.052,.057,.052,.041]; ys=[-.026,-.013,0,.013,.026]
 for i,(ln,yy) in enumerate(zip(lens,ys)):
  x=s*(.349+(i-2)*.005); bits.append(capsule('tmp',(x,yy,.465),(x+s*.002,yy-.002,.465-ln),.0085 if i!=2 else .0095,SKIN))
 bits.append(capsule('tmp',(s*.325,-.015,.48),(s*.302,-.023,.445),.011,SKIN))
 union(bits,f'Mano_{side}',.0038,2)

# BOTAS POR MASAS FUSIONADAS, puntera ancha/empeine/caña/talón.
for side,s in [('L',-1),('R',1)]:
 x=s*.105
 body=[ell('tmp',(x,-.085,.085),(.078,.125,.065),BOOT),ell('tmp',(x,-.015,.12),(.069,.075,.095),BOOT),ell('tmp',(x,.035,.13),(.071,.06,.105),BOOT)]
 union(body,f'Bota_{side}',.005,3)
 sole=ell(f'Suela_{side}',(x,-.045,.025),(.087,.145,.028),SOLE,28,14)
 ell(f'Lengueta_{side}',(x,-.105,.132),(.045,.020,.068),BOOT,20,12)
 for j in range(4): capsule(f'CordonBota_{side}_{j}',(x-.043,-.146,.092+j*.025),(x+.043,-.146,.102+j*.025),.0038,CREAM)

# CABEZA CONTINUA POR UNIÓN VOXEL.
head_bits=[ell('tmp',(0,.018,.955),(.158,.142,.172),SKIN,36,24),ell('tmp',(0,-.105,.925),(.135,.075,.116),SKIN,32,20),
 ell('tmp',(-.083,-.116,.91),(.067,.047,.067),SKIN,26,16),ell('tmp',(.083,-.116,.91),(.067,.047,.067),SKIN,26,16),
 ell('tmp',(0,-.078,.865),(.102,.072,.070),SKIN,28,18),ell('tmp',(0,-.145,.93),(.029,.025,.027),SKIN,22,12),
 ell('tmp',(-.153,.0,.947),(.032,.022,.047),SKIN,22,14),ell('tmp',(.153,.0,.947),(.032,.022,.047),SKIN,22,14),capsule('tmp',(0,.018,.805),(0,.018,.865),.057,SKIN)]
head=union(head_bits,'Cabeza_Organica',.0045,4)
# Ojos embebidos, iris con menos blanco visible.
for side,s in [('L',-1),('R',1)]:
 ell(f'Ojo_{side}',(s*.057,-.137,.972),(.039,.026,.047),WHITE,28,18); ell(f'Iris_{side}',(s*.057,-.161,.972),(.020,.009,.025),IRIS,22,14); ell(f'Pupila_{side}',(s*.057,-.169,.972),(.009,.005,.013),BLACK,18,10)
 # cejas curvas cortas
 curved_clump(f'Ceja_{side}',[(s*.095,-.166,1.028),(s*.062,-.172,1.037),(s*.028,-.168,1.03)],[.45,.5,.18],HAIR).data.bevel_depth=.012
# Boca neutral sutil.
curved_clump('Boca', [(-.034,-.160,.875),(0,-.165,.871),(.034,-.160,.875)],[.25,.35,.12],BOOT).data.bevel_depth=.007

# Cabello: casquete discreto + 22 trayectorias asimétricas con taper.
ell('Casquete_Cabello',(0,.035,1.055),(.164,.142,.125),HAIR,36,24)
clumps=[
[(-.12,-.08,1.10),(-.08,-.145,1.105),(-.03,-.155,1.075)],[(-.06,-.10,1.14),(-.02,-.16,1.13),(.02,-.15,1.09)],[(.02,-.11,1.15),(.07,-.15,1.13),(.09,-.13,1.08)],[(.09,-.08,1.13),(.14,-.10,1.10),(.14,-.06,1.04)],
[(-.13,0,1.13),(-.17,-.025,1.10),(-.16,-.02,1.04)],[(-.10,.07,1.16),(-.16,.06,1.12),(-.17,.04,1.06)],[(0,.10,1.18),(-.05,.15,1.16),(-.09,.14,1.10)],[(.08,.09,1.17),(.13,.14,1.14),(.15,.10,1.08)],
[(.13,.02,1.13),(.18,.025,1.09),(.17,.01,1.03)],[(-.05,.13,1.12),(-.08,.16,1.07),(-.09,.14,1.01)],[(.03,.14,1.13),(.04,.17,1.07),(.04,.15,1.00)],[(.10,.11,1.12),(.12,.15,1.07),(.11,.13,1.00)],
[(-.15,.02,1.07),(-.17,.04,1.01),(-.15,.02,.96)],[(.15,.03,1.07),(.17,.05,1.01),(.15,.03,.96)],[(-.12,.10,1.06),(-.14,.13,1.00),(-.12,.10,.95)],[(.12,.10,1.06),(.14,.13,1.00),(.12,.10,.95)],
[(-.05,.15,1.07),(-.06,.17,1.01),(-.05,.14,.95)],[(.05,.15,1.07),(.06,.17,1.01),(.05,.14,.95)],[(-.08,-.12,1.08),(-.12,-.15,1.05),(-.13,-.12,1.00)],[(.075,-.12,1.08),(.115,-.15,1.05),(.13,-.12,1.00)],
[(-.02,-.13,1.12),(-.055,-.16,1.10),(-.075,-.15,1.065)],[(.045,-.13,1.12),(.02,-.17,1.10),(-.005,-.16,1.065)]]
for i,p in enumerate(clumps): curved_clump(f'Mechon_{i:02d}',p,[1.0,.72,.08],HAIR)

# Capucha aplanada, pretina y bolsillo curvo.
hood=loft('Capucha',[(.77,.11,.02,.065),(.83,.15,.025,.115),(.88,.13,.02,.135),(.91,.075,.015,.09)],BLUE,28)
# Escalar todo a 1,08 m exactos.
bpy.context.view_layer.update(); pts=[o.matrix_world@Vector(c) for o in EXPORT.objects for c in o.bound_box]; lo=min(p.z for p in pts); hi=max(p.z for p in pts); k=1.08/(hi-lo)
for o in EXPORT.objects: o.location.z=(o.location.z-lo)*k; o.location.x*=k;o.location.y*=k;o.scale*=k;o['version']='v03'
bpy.context.view_layer.update()

# Render clay/color turnaround.
plane=ell('Piso',(0,0,-.06),(2.5,2.5,.05),mat('PisoMat',(.18,.18,.2),.95),32,12); [c.objects.unlink(plane) for c in list(plane.users_collection)]; RENDER.objects.link(plane)
world=bpy.context.scene.world; world.use_nodes=True; world.node_tree.nodes['Background'].inputs['Color'].default_value=(.025,.03,.045,1);world.node_tree.nodes['Background'].inputs['Strength'].default_value=.35
for name,loc,en,size,col in [('Key',(-2,-3,3),1200,3,(1,.82,.68)),('Fill',(2,-2,2),750,2.5,(.65,.78,1)),('Rim',(0,2,2.5),900,2,(.72,.82,1))]:
 bpy.ops.object.light_add(type='AREA',location=loc); l=bpy.context.object;l.name=name;l.data.energy=en;l.data.size=size;l.data.color=col;l.rotation_euler=(Vector((0,0,.58))-l.location).to_track_quat('-Z','Y').to_euler(); [c.objects.unlink(l) for c in list(l.users_collection)];RENDER.objects.link(l)
bpy.ops.object.camera_add();cam=bpy.context.object;[c.objects.unlink(cam) for c in list(cam.users_collection)];RENDER.objects.link(cam);cam.data.lens=62;bpy.context.scene.camera=cam
sc=bpy.context.scene;sc.render.engine='BLENDER_EEVEE';sc.render.resolution_x=700;sc.render.resolution_y=900;sc.render.resolution_percentage=100;sc.render.image_settings.file_format='PNG'
for label,deg in [('front',0),('three_quarter',45),('side',90),('back',180)]:
 a=math.radians(deg);cam.location=(2.4*math.sin(a),-2.4*math.cos(a),1.18);cam.rotation_euler=(Vector((0,0,.55))-cam.location).to_track_quat('-Z','Y').to_euler();sc.render.filepath=os.path.join(ROOT,f'firipu_organic_v03_{label}.png');bpy.ops.render.render(write_still=True)
blend=os.path.join(ROOT,'firipu_organic_v03.blend');bpy.ops.wm.save_as_mainfile(filepath=blend)
bpy.ops.object.select_all(action='DESELECT');[o.select_set(True) for o in EXPORT.objects];bpy.context.view_layer.objects.active=next(iter(EXPORT.objects));glb=os.path.join(ROOT,'firipu_organic_v03.glb');bpy.ops.export_scene.gltf(filepath=glb,export_format='GLB',use_selection=True,export_apply=True)
print('CREATED',blend);print('CREATED',glb);print('EXPORT_OBJECTS',len(EXPORT.objects))
