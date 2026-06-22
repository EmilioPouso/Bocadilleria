"""Remove background from bocadillo lomo y queso image."""
from pathlib import Path
from rembg import remove
from PIL import Image

SRC = Path(r"C:\Users\pouso\.cursor\projects\c-Users-pouso-Desktop-BOCADILLERIA\assets\c__Users_pouso_AppData_Roaming_Cursor_User_workspaceStorage_b7c833907b3a0f726a52f664a8160712_images_image-50e43087-ee54-4d2a-891d-61b13c016008.png")
DST = Path(r"C:\Users\pouso\Desktop\BOCADILLERIA\assets\bocadillo_lomo_queso_sin_fondo.png")

DST.parent.mkdir(parents=True, exist_ok=True)
with SRC.open("rb") as f:
    data = f.read()

out = remove(data)
with DST.open("wb") as f:
    f.write(out)

img = Image.open(DST)
print(f"Saved: {DST} ({img.size}, mode={img.mode}, {DST.stat().st_size} bytes)")
