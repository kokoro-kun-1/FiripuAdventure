import os, time, torch
from PIL import Image
from hy3dgen.rembg import BackgroundRemover
from hy3dgen.shapegen import Hunyuan3DDiTFlowMatchingPipeline

OUT=r'C:\Users\manue\projects\FiripuAdventure\art\characters\firipu\hunyuan_mv_v03'
os.makedirs(OUT,exist_ok=True)
paths={
 'front':r'C:\Users\manue\Desktop\firipu\firipu_apose_frente_sin_accesorios_2048.png',
 'right':r'C:\Users\manue\Desktop\firipu\firipu_apose_lateral_derecho_sin_accesorios_2048.png',
 'back':r'C:\Users\manue\Desktop\firipu\firipu_apose_espalda_sin_accesorios_2048.png',
}
rembg=BackgroundRemover()
images={}
for key,path in paths.items():
 image=Image.open(path).convert('RGB')
 images[key]=rembg(image).convert('RGBA')
 images[key].save(os.path.join(OUT,f'input_{key}_removed.png'))

pipeline=Hunyuan3DDiTFlowMatchingPipeline.from_pretrained(
 'tencent/Hunyuan3D-2mv',subfolder='hunyuan3d-dit-v2-mv',variant='fp16'
)
# El modelo multivista cabe en 6 GB para generación de geometría.
# No usar cpu_offload: esta versión deja el scheduler en CPU y mezcla dispositivos.
start=time.time()
mesh=pipeline(image=images,num_inference_steps=40,octree_resolution=320,num_chunks=12000,generator=torch.manual_seed(12345),output_type='trimesh')[0]
out=os.path.join(OUT,'firipu_hunyuan_mv_v03.glb');mesh.export(out)
print('CREATED',out,'SECONDS',round(time.time()-start,2),'VERTICES',len(mesh.vertices),'FACES',len(mesh.faces))
