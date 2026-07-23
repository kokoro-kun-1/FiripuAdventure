import os, time, torch
from PIL import Image
from hy3dgen.rembg import BackgroundRemover
from hy3dgen.shapegen import Hunyuan3DDiTFlowMatchingPipeline

OUT = r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03'
os.makedirs(OUT, exist_ok=True)
paths = {
    'front': r'C:\Users\manue\Desktop\firipu\firipu_apose_frente_sin_accesorios_2048.png',
    'right': r'C:\Users\manue\Desktop\firipu\firipu_apose_lateral_derecho_sin_accesorios_2048.png',
    'back':  r'C:\Users\manue\Desktop\firipu\firipu_apose_espalda_sin_accesorios_2048.png',
}
rembg = BackgroundRemover()
images = {}
for key, path in paths.items():
    img = Image.open(path).convert('RGB')
    images[key] = rembg(img).convert('RGBA')
    images[key].save(os.path.join(OUT, f'input_{key}_removed.png'))

# FP16 + modelo multivista cabe en 6 GB; sin offload para evitar mezcla de dispositivos
pipeline = Hunyuan3DDiTFlowMatchingPipeline.from_pretrained(
    'tencent/Hunyuan3D-2mv',
    subfolder='hunyuan3d-dit-v2-mv',
    variant='fp16'
)

start = time.time()
mesh = pipeline(
    image=images,
    num_inference_steps=30,
    octree_resolution=256,
    num_chunks=8000,
    generator=torch.manual_seed(12345),
    output_type='trimesh'
)[0]
out = os.path.join(OUT, 'firipu_hunyuan_mv_v03.glb')
mesh.export(out)
print('CREATED', out, 'SECONDS', round(time.time()-start,2), 'VERTS', len(mesh.vertices), 'FACES', len(mesh.faces))