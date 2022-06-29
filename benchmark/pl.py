from asyncio.subprocess import PIPE
from cmath import log
import sys
import subprocess
import os
import numpy as np
import matplotlib.pyplot as plt
from contextlib import redirect_stdout
import io


amount = int(sys.argv[1])
res = []
for i in range(amount):
    pr = subprocess.run(['/home/pavel/assembly/5/5_dz.out'], capture_output=True)
    n = int(pr.stdout)
    res.append(n)


fig, ax = plt.subplots()
ax.hist(res, bins=100, color='orange', log=True)
fig.set_figwidth(24) 
fig.set_figheight(12)  
plt.show()


