"""Remove background from Fanta limon image."""
from pathlib import Path
from rembg import remove
from PIL import Image

SRC = Path(r"C:\Users\pouso\.cursor\projects\c-Users-pouso-Desktop-BOCADILLERIA\assets\c__Users_pouso_AppData_Roaming_Cursor_User_workspaceStorage_b7c833907b3a0f726a52f664a8160712_images_image-9a8fd8fc-0ab3-47b3-9203-9849ac7f38f3.png")
DST = Path(r"C:\Users\pouso\Desktop\BOCADILLERIA\assets\fanta_limon_sin_fondo.png")

DST.parent.mkdir(parents=True, exist_ok=True)
print(f"Source: {SRC} (exists={SRC.exists()})")

with SRC.open("rb") as f:
    data = f.read()

print(f"Read {len(data)} bytes. Removing background...")
out = remove(data)

with DST.open("wb") as f:
    f.write(out)

img = Image.open(DST)
print(f"Saved: {DST} ({img.size}, mode={img.mode}, {DST.stat().st_size} bytes)")
