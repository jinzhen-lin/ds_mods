
import os
import re
import sys

import numpy as np
from PIL import Image


def pad_image(image, target_size):
    iw, ih = image.size
    img_data = np.array(image)

    bg_size = max(image.size)
    bg_img_data = np.zeros((bg_size, bg_size, 4))

    start_pos = ((bg_size - iw) // 2, (bg_size - ih) // 2)
    end_pos = (start_pos[0] + iw, start_pos[1] + ih)
    bg_img_data[start_pos[1]:end_pos[1], start_pos[0]:end_pos[0], :] = img_data
    new_image = Image.fromarray(np.uint8(bg_img_data), "RGBA")
    return new_image.resize(target_size, Image.ANTIALIAS)


if __name__ == '__main__':
    origin_path = os.path.abspath(sys.argv[1])
    if len(sys.argv) > 2:
        modpath = sys.argv[2]
    else:
        modpath = "../"
    modpath = os.path.abspath(modpath)

    for typename in ["living", "building"]:
        prefabname_list = []
        typename_new = typename + "_square"
        typepath = os.path.join(origin_path, typename)
        typepath_new = os.path.join(origin_path, typename_new)

        for img_filename in os.listdir(typepath):
            origin_img_fullname = os.path.join(typepath, img_filename)
            basename = re.sub("\\.webp|\\.png", "", img_filename)
            target_img_fullname = os.path.join(typepath_new, basename + ".png")
            if basename.find("|") == -1:
                prefabname_list.append(basename)
            origin_img = Image.open(origin_img_fullname)
            target_img = pad_image(origin_img.convert("RGBA"), (56, 56))
            target_img.save(target_img_fullname)
        with open(os.path.join(modpath, "scripts/TMI/list/itemlist_%s.txt" % typename), "w") as f:
            f.write("\n".join(prefabname_list))
        altas_path = os.path.join(modpath, "images/tmi/")
        atlas_file = os.path.join(altas_path, "%s.xml" % typename)
        img_files = os.path.join(typepath_new, "*.png")
        os.system("ktech %s %s --atlas %s" % (img_files, altas_path, atlas_file))
        
