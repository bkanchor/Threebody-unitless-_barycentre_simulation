import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt('threebody_output.dat', skiprows=1)
x1, y1, z1 = data[:,0], data[:,1], data[:,2]
x2, y2, z2 = data[:,3], data[:,4], data[:,5]
x3, y3, z3 = data[:,6], data[:,7], data[:,8]

plt.figure(figsize=(16, 7))

# ----------------------- XY plane -----------------------
plt.subplot(1,2,1)
plt.plot(x1, y1, color='r', label='Body 1')
plt.plot(x2, y2, color='b', label='Body 2')
plt.plot(x3, y3, '--', linewidth=0.5, color='k', label='Test body')

# Mark start points (large circles)
plt.scatter([x1[0], x2[0], x3[0]],
            [y1[0], y2[0], y3[0]],
            color=['r','b','k'], s=50, marker='o', label='Start')

# Mark end points (large X markers)
plt.scatter([x1[-1], x2[-1], x3[-1]],
            [y1[-1], y2[-1], y3[-1]],
            color=['r','b','k'], s=70, marker='x', label='End')

plt.legend()
plt.xlim(-1.5, 1.5)
plt.ylim(-1.5, 1.5)
plt.xlabel("x")
plt.ylabel("y")
plt.title('XY plane')


# ----------------------- XZ plane -----------------------
plt.subplot(1,2,2)
plt.plot(x1, z1, color='r')
plt.plot(x2, z2, color='b')
plt.plot(x3, z3, '--', linewidth=0.5, color='k')

# Start points
plt.scatter([x1[0], x2[0], x3[0]],
            [z1[0], z2[0], z3[0]],
            color=['r','b','k'], s=50, marker='o')

# End points
plt.scatter([x1[-1], x2[-1], x3[-1]],
            [z1[-1], z2[-1], z3[-1]],
            color=['r','b','k'], s=70, marker='x')

plt.xlim(-1.5, 1.5)
plt.ylim(-1.5, 1.5)
plt.xlabel("x")
plt.ylabel("z")
plt.title('XZ plane')

plt.savefig('binary_3body_marked.png', dpi=800)
plt.show()
