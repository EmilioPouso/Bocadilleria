"""Remove background from bocadillo mixto image."""
from pathlib import Path
from rembg import remove
from PIL import Image

SRC = Path(r"C:\Users\pouso\.cursor\projects\c-Users-pouso-Desktop-BOCADILLERIA\assets\c__Users_pouso_AppData_Roaming_Cursor_User_workspaceStorage_b7c833907b3a0f726a52f664a8160712_images_image-a083fa58-ae0f-4292-a622-693d9d783bb0.png")
DST = Path(r"C:\Users\pouso\Desktop\BOCADILLERIA\assets\bocadillo_mixto_sin_fondo.png")

DST.parent.mkdir(parents=True, exist_ok=True)
with SRC.open("rb") as f:
    data = f.read()

out = remove(data)
with DST.open("wb") as f:
    f.write(out)

img = Image.open(DST)
print(f"Saved: {DST} ({img.size}, mode={img.mode}, {DST.stat().st_size} bytes)")
