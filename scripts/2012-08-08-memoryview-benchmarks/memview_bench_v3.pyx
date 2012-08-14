# memview_bench_v3.pyx

import numpy as np

cimport numpy as np
from libc.math cimport sqrt
cimport cython

# define a function pointer to a metric
ctypedef double (*metric_ptr)(double[::1], double[::1])

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double euclidean_distance(double[::1] x1,
                               double[::1] x2):
    cdef double tmp, d
    cdef np.intp_t i, N

    d = 0
    N = x1.shape[0]
    # assume x2 has the same shape as x1.  This could be dangerous!

    for i in range(N):
        tmp = x1[i] - x2[i]
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

    cdef np.intp_t i, j, n_samples
    n_samples = X.shape[0]

    cdef double[:, ::1] D = np.empty((n_samples, n_samples))

    for i in range(n_samples):
        for j in range(n_samples):
            D[i, j] = dist_func(X[i], X[j])

    return D


@cython.boundscheck(False)
@cython.wraparound(False)
def pairwise_inline(double[:, ::1] X not None):
    cdef np.intp_t i, j, n_samples
    n_samples = X.shape[0]

    cdef double[:, ::1] D = np.empty((n_samples, n_samples))

    for i in range(n_samples):
        for j in range(n_samples):
            D[i, j] = euclidean_distance(X[i], X[j])

    return D
