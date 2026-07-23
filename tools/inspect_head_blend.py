import bpy, os

blend_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_head.blend'
bpy.ops.wm.open_mainfile(filepath=blend_path)

print("=== OBJETOS EN firipu_v03_head.blend ===")
for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        print(f"  MESH: {obj.name}  verts={len(obj.data.vertices)}  faces={len(obj.data.polygons)}  mats={[m.name for m in obj.data.materials]}")
    elif obj.type == 'CURVE':
        print(f"  CURVE: {obj.name}  splines={len(obj.data.splines)}")
    else:
        print(f"  {obj.type}: {obj.name}")

# Ver colección
coll = bpy.data.collections.get('CHR_Firipu_Head')
if coll:
    print(f"\nColección CHR_Firipu_Head: {len(coll.objects)} objetos")
    for o in coll.objects:
        print(f"  {o.name} ({o.type})")