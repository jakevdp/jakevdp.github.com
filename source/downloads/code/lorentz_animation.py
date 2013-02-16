import numpy as np
from scipy import integrate

from matplotlib import pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.colors import cnames
from matplotlib import animation

N_trajectories = 20

def lorentz_deriv(x, t0, sigma=10., beta=8./3, rho=28.0):
    """Compute the derivative of a Lorentz process.
    x is a vector [x0, x1, x2]
    t0 is a dummy argument
    sigma, beta, rho are the Lorentz parameters
    """
    return [sigma * (x[1] - x[0]),
            x[0] * (rho - x[2]) - x[1],
            x[0] * x[1] - beta * x[2]]

# Choose random starting points, uniformly distributed from -15 to 15
np.random.seed(1)
x0 = -15 + 30 * np.random.random((N_trajectories, 3))

# Solve for the trajectories
t = np.linspace(0, 4, 1000)
x = np.asarray([integrate.odeint(lorentz_deriv, x0i, t)
                for x0i in x0])

# Set up figure & 3D axis for animation
fig = plt.figure()
ax = fig.add_axes([0, 0, 1, 1], projection='3d')
ax.axis('off')

# set up lines and points
colors = plt.cm.jet(np.linspace(0, 1, N_trajectories))
lines = sum([ax.plot([], [], [], '-', c=c)
             for c in colors], [])
pts = sum([ax.plot([], [], [], 'o', c=c)
           for c in colors], [])

# prepare the axes limits and point-of-view
ax.set_xlim((-25, 25))
ax.set_ylim((-35, 35))
ax.set_zlim((5, 55))
ax.view_init(30, 0)

# initialization function: plot the background of each frame
def init():
    for line, pt in zip(lines, pts):
        line.set_data([], [])
        line.set_3d_properties([])

        pt.set_data([], [])
        pt.set_3d_properties([])
    return lines + pts

# animation function.  This will be called sequentially with the frame number
def animate(i):
    i = (2 * i) % x[0].shape[0]

    for line, pt, xi in zip(lines, pts, x):
        line.set_data(xi[:i, 0], xi[:i, 1])
        line.set_3d_properties(xi[:i, 2])

        pt.set_data(xi[i - 1:i, 0], xi[i - 1:i, 1])
        pt.set_3d_properties(xi[i - 1:i, 2])

    ax.view_init(30, 0.3 * i)
    fig.canvas.draw()
    return lines + pts

# instantiate the animator.
anim = animation.FuncAnimation(fig, animate, init_func=init,
                               frames=500, interval=30, blit=True)

# Save as mp4. This requires mplayer or ffmpeg to be installed
anim.save('lorentz_attractor.mp4', fps=15, extra_args=['-vcodec', 'libx264'])

plt.show()
