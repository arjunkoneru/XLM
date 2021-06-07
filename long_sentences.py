src_file = "data/processed/kn-te/char/test.kn-te.kn"
tgt_file = "data/rawdata/test.kn-te.te"
save_src='./src.kn'
save_tgt='./src.te'
f1 = open(src_file,'r')
line=1
long_lines=[]
index_lines=[]
for x in f1:
    words = x.split(" ")
    wc = len(words)
    if( wc < 250):
        long_lines.append(x)
        index_lines.append(line)
    line+=1
f1.close()
r1=open(save_src,'w+')
r1.writelines(long_lines)
r1.close()
f2=open(tgt_file,'r')
line=1
long_lines = []
for x in f2:
    if line in index_lines:
        long_lines.append(x)
    line+=1
r2=open(save_tgt,'w+')
r2.writelines(long_lines)
r2.close()
