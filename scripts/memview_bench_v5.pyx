# memview_bench_v5.pyx

import numpy as np

cimport numpy as np
from libc.math cimport sqrt
cimport cython

# define a function pointer to a metric
ctypedef double (*metric_ptr)(double[:, ::1], np.intp_t, np.intp_t)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double euclidean_distance(double[:, ::1] X,
                               np.intp_t i1, np.intp_t i2):
    cdef double tmp, d
    cdef np.intp_t j

    d = 0

    for j in range(X.shape[1]):
        tmp = X[i1, j] - X[i2, j]
        d += tmp * tmp

    return sqrt(d)


@cython.boundscheck(False)
@cython.wraparound(False)
def pairwise(double[:, ::1] X not None,
             metric = 'euclidean'):
    cdef metric_ptr dist_func
    if metric == 'euclidean':
        dist_func = &euclidean_distance
    else:
        raise ValueError("unrecognized metric")

    cdef np.intp_t i, j, n_samples, n_dim
    n_samples = X.shape[0]
    n_dim = X.shape[1]

    cdef double[:, ::1] D = np.empty((n_samples, n_samples))

    for i in range(n_samples):
        for j in range(n_samples):
            D[i, j] = dist_func(X, i, j)

    return D
