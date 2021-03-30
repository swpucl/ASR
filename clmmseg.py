import os
import mmseg
import jieba
from tqdm import tqdm

root = './data/primewords/train'
#for i in mmseg.seg_txt("我爱天安门".encode()):
#    print(i.decode())

#seg_list = jieba.cut("我爱天安门", cut_all=False)
#print("Full Mode: " + " ".join(seg_list))

old_txt = os.path.join(root,'transcripts.txt')
new_txt = os.path.join(root,'text.txt')
with open(old_txt) as r:
    all_lines = r.readlines()
r.close()
with open(new_txt,'w') as w:
    for i in tqdm(all_lines):
        seg_list = jieba.cut(i.split(' ')[-1], cut_all=False)
        #print(" ".join(seg_list).strip())
        w.writelines(i.split(' ')[0]+' '+" ".join(seg_list).strip()+'\n')
w.close()