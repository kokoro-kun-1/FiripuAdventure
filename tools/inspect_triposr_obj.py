import bpy, os
from mathutils import Vector

# Cargar el .obj original de TripoSR (que tenía vertex colors)
obj_path = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\triposr_v03\0\mesh.obj'

# Limpiar
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Importar OBJ
bpy.ops.wm.obj_import(filepath=obj_path)
obj = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
print(f"Objeto: {obj.name}")
print(f"Verts: {len(obj.data.vertices)}")
print(f"Faces: {len(obj.data.polygons)}")
print(f"Materiales: {len(obj.data.materials)}")
print(f"UV Maps: {len(obj.data.uv_layers)}")
print(f"Color Attrs: {len(obj.data.color_attributes)}")
for ca in obj.data.color_attributes:
    print(f"  {ca.name} domain={ca.domain} type={ca.data_type}")

# Verificar si hay colores por vértice en el mesh
if obj.data.color_attributes:
    ca = obj.data.color_attributes[0]
    print(f"\nPrimeros 10 colores:")
    for i in range(min(10, len(ca.data))):
        print(f"  {i}: {ca.data[i].color}")

# Guardar info
out_txt = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\triposr_v03\0\mesh_info.txt'
with open(out_txt, 'w', encoding='utf-8') as f:
    f.write(f"Mesh: {obj.name}\n")
    f.write(f"Verts: {len(obj.data.vertices)}\n")
    f.write(f"Faces: {len(obj.data.polygons)}\n")
    f.write(f"Materials: {len(obj.data.materials)}\n")
    f.write(f"UV Maps: {len(obj.data.uv_layers)}\n")
    f.write(f"Color Attrs: {len(obj.data.color_attributes)}\n")
    for ca in obj.data.color_attributes:
        f.write(f"  {ca.name} domain={ca.domain} type={ca.data_type}\n")
print(f"\nInfo guardada en: {out_txt}")