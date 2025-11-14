import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# Load data
data = np.loadtxt('threebody_output.dat', skiprows=1)
x1, y1, z1 = data[:,0], data[:,1], data[:,2]
x2, y2, z2 = data[:,3], data[:,4], data[:,5]
x3, y3, z3 = data[:,6], data[:,7], data[:,8]

# Downsample for speed (optional)
step = 50
frames = range(0, len(x1), step)

# --- Figure ---
fig, axes = plt.subplots(1, 2, figsize=(12, 6))

ax_xy = axes[0]
ax_xz = axes[1]

# Square limits
for ax in axes:
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')

ax_xy.set_xlabel("x")
ax_xy.set_ylabel("y")
ax_xy.set_title("XY-plane")

ax_xz.set_xlabel("x")
ax_xz.set_ylabel("z")
ax_xz.set_title("XZ-plane")

# --- Moving points ---
p1_xy, = ax_xy.plot([], [], 'o', markersize=4, color='r')
p2_xy, = ax_xy.plot([], [], 'o', markersize=4, color='b')
p3_xy, = ax_xy.plot([], [], 'o', markersize=3, color='k')

p1_xz, = ax_xz.plot([], [], 'o', markersize=4, color='r')
p2_xz, = ax_xz.plot([], [], 'o', markersize=4, color='b')
p3_xz, = ax_xz.plot([], [], 'o', markersize=3, color='k')

# --- Trails ---
trail_len = 100

t1_xy, = ax_xy.plot([], [], linewidth=1, color='r')
t2_xy, = ax_xy.plot([], [], linewidth=1, color='b')
t3_xy, = ax_xy.plot([], [], linewidth=0.5, color='k')

t1_xz, = ax_xz.plot([], [], linewidth=1, color='r')
t2_xz, = ax_xz.plot([], [], linewidth=1, color='b')
t3_xz, = ax_xz.plot([], [], linewidth=0.5, color='k')

def init():
    for obj in (p1_xy, p2_xy, p3_xy,
                p1_xz, p2_xz, p3_xz,
                t1_xy, t2_xy, t3_xy,
                t1_xz, t2_xz, t3_xz):
        obj.set_data([], [])
    return (p1_xy, p2_xy, p3_xy,
            p1_xz, p2_xz, p3_xz,
            t1_xy, t2_xy, t3_xy,
            t1_xz, t2_xz, t3_xz)

def update(i):
    idx = frames[i]

    start = max(0, idx - trail_len * step)
    sl = slice(start, idx + 1, step)

    # --- XY moving points ---
    p1_xy.set_data([x1[idx]], [y1[idx]])
    p2_xy.set_data([x2[idx]], [y2[idx]])
    p3_xy.set_data([x3[idx]], [y3[idx]])

    # --- XZ moving points ---
    p1_xz.set_data([x1[idx]], [z1[idx]])
    p2_xz.set_data([x2[idx]], [z2[idx]])
    p3_xz.set_data([x3[idx]], [z3[idx]])

    # --- XY trails ---
    t1_xy.set_data(x1[sl], y1[sl])
    t2_xy.set_data(x2[sl], y2[sl])
    t3_xy.set_data(x3[sl], y3[sl])

    # --- XZ trails ---
    t1_xz.set_data(x1[sl], z1[sl])
    t2_xz.set_data(x2[sl], z2[sl])
    t3_xz.set_data(x3[sl], z3[sl])

    return (p1_xy, p2_xy, p3_xy,
            p1_xz, p2_xz, p3_xz,
            t1_xy, t2_xy, t3_xy,
            t1_xz, t2_xz, t3_xz)

anim = FuncAnimation(fig, update, init_func=init,
                     frames=len(frames), interval=10, blit=False)

# Save as MP4 or GIF with Pillow writer
output = "threebody_xy_xz_animation.mp4"
anim.save(output, fps=60)

plt.show()
print("Saved:", output)
