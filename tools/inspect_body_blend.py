import bpy

blend_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_v03_body.blend'
bpy.ops.wm.open_mainfile(filepath=blend_path)

print("=== OBJETOS EN firipu_v03_body.blend ===")
for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        mats = [m.name for m in obj.data.materials] if obj.data.materials else '[]'
        print(f"  MESH: {obj.name:20s}  verts={len(obj.data.vertices):5d}  faces={len(obj.data.polygons):5d}  mats={mats}")

# Ver colección
coll = bpy.data.collections.get('CHR_Firipu_Body')
if coll:
    print(f"\nColección CHR_Firipu_Body: {len(coll.objects)} objetos")
    for o in coll.objects:
        print(f"  {o.name} ({o.type})")