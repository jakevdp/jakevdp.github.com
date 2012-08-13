import numpy as np

def euclidean_distance(x1, x2):
    x1 = np.asarray(x1)
    x2 = np.asarray(x2)
    return np.sqrt(np.sum((x1 - x2) ** 2))

def pairwise(X, metric=euclidean_distance):
    X = np.asarray(X)
    
    n_samples, n_dim = X.shape

    D = np.empty((n_samples, n_samples))

    for i in range(n_samples):
        for j in range(n_samples):
 	    D[i, j] = metric(X[i], X[j])

    return D
