import bpy, os
from mathutils import Vector

# Cargar .blend escalado
blend_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\firipu_hunyuan_v03_scaled.blend'
bpy.ops.wm.open_mainfile(filepath=blend_path)

obj = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
print(f"Objeto: {obj.name}")
print(f"Materiales: {len(obj.data.materials)}")
for i, mat in enumerate(obj.data.materials):
    print(f"  [{i}] {mat.name if mat else 'None'}")

# Ver grupos de vértices
print(f"\nGrupos de vértices: {len(obj.vertex_groups)}")
for vg in obj.vertex_groups:
    print(f"  {vg.name}: {vg.index}")

# Ver UV maps
print(f"\nUV Maps: {len(obj.data.uv_layers)}")
for uv in obj.data.uv_layers:
    print(f"  {uv.name}")

# Ver color attributes
print(f"\nColor Attributes: {len(obj.data.color_attributes)}")
for ca in obj.data.color_attributes:
    print(f"  {ca.name} domain={ca.domain} type={ca.data_type}")

# Guardar info
out_txt = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03\mesh_info.txt'
with open(out_txt, 'w', encoding='utf-8') as f:
    f.write(f"Mesh: {obj.name}\n")
    f.write(f"Verts: {len(obj.data.vertices)}\n")
    f.write(f"Faces: {len(obj.data.polygons)}\n")
    f.write(f"Materials: {len(obj.data.materials)}\n")
    for i, mat in enumerate(obj.data.materials):
        f.write(f"  [{i}] {mat.name if mat else 'None'}\n")
    f.write(f"Vertex Groups: {len(obj.vertex_groups)}\n")
    for vg in obj.vertex_groups:
        f.write(f"  {vg.name}\n")
    f.write(f"UV Maps: {len(obj.data.uv_layers)}\n")
    for uv in obj.data.uv_layers:
        f.write(f"  {uv.name}\n")
    f.write(f"Color Attrs: {len(obj.data.color_attributes)}\n")
    for ca in obj.data.color_attributes:
        f.write(f"  {ca.name} domain={ca.domain} type={ca.data_type}\n")
print(f"\nInfo guardada en: {out_txt}")