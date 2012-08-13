# memview_bench_v4.pyx

import numpy as np

cimport numpy as np
from libc.math cimport sqrt
cimport cython

# define a function pointer to a metric
ctypedef double (*metric_ptr)(double*, double*, int)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double euclidean_distance(double* x1,
                               double* x2,
                               int N):
    cdef double tmp, d
    cdef np.intp_t i

    d = 0

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

    cdef np.intp_t i, j, n_samples, n_dim
    n_samples = X.shape[0]
    n_dim = X.shape[1]

    cdef double[:, ::1] D = np.empty((n_samples, n_samples))

    cdef double* Dptr = &D[0, 0]
    cdef double* Xptr = &X[0, 0]

    for i in range(n_samples):
        for j in range(n_samples):
            Dptr[i * n_samples + j] = dist_func(Xptr + i * n_dim,
                                                Xptr + j * n_dim,
                                                n_dim)

    return D
