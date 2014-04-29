"""
Reconstruction of what we need to do
"""

from numpy import linspace

class Image:
	

def load(inf, spacing = None, optics = None):
    """
    Load data or results

    Parameters
    ----------
    inf : string filename
    optics : :class:`holopy.optics.Optics` object or string (optional)
        Optical train parameters.  If string, specifies the filename
        of an optics yaml
    Returns
    -------
    obj : The object loaded, :class:`holopy.core.marray.Image`, or as loaded from yaml

    """
    if isinstance(optics, (basestring, file)):
        optics = serialize.load(optics)
        # In the past We allowed optics yamls to be written without an !Optics
        # tag, so for that backwards compatability, we attempt to turn an
        # anonymous dict into an Optics
        if isinstance(optics, dict):
            optics = Optics(**optics)


    loaded = Image(load_image(inf), spacing = spacing, optics = optics)

    return loaded

def propagate(data, d, gradient_filter=False):
    """
    Propagates a hologram along the optical axis

    Parameters
    ----------
    data : :class:`.Image` or :class:`.VectorGrid`
       Hologram to propagate
    d : float or list of floats
       Distance to propagate, in meters, or desired schema.  A list tells to
       propagate to several distances and return the volume
    gradient_filter : float
       For each distance, compute a second propagation a distance
       gradient_filter away and subtract.  This enhances contrast of
       rapidly varying features

    Returns
    -------
    data : :class:`.Image` or :class:`.Volume`
       The hologram progagated to a distance d from its current location.

    """
    if np.isscalar(d) and d == 0:
        # Propagationg no distance has no effect
        return data

    # Computing the transfer function will fail for d = 0. So, if we
    # are asked to compute a reconstruction for a set of distances
    # containing 0, we pull that distance out and then add in a copy
    # of the input at the end.
    contains_zero = False
    if not np.isscalar(d):
        d = np.array(d)
        if (d == 0).any():
            contains_zero = True
            d_old = d
            d = np.delete(d, np.nonzero(d == 0))

    G = trans_func(data, d, squeeze=False, gradient_filter=gradient_filter)

    ft = fft(data)

    ft = np.repeat(ft[:, :, np.newaxis,...], G.shape[2], axis=2)

    ft = apply_trans_func(ft, G)

    res = ifft(ft, overwrite=True)

    # This will not work correctly if you have 0 in the distances more
    # than once. But why would you do that?
    if contains_zero:
        d = d_old
        res = np.insert(res, np.nonzero(d==0)[0][0], data, axis=2)

    res = np.squeeze(res)

    origin = np.array(data.origin)
    origin[2] += _ensure_array(d)[0]

    if not np.isscalar(d) and not isinstance(data, VectorGrid):
        # check if supplied distances are in a regular grid
        dd = np.diff(d)
        if np.allclose(dd[0], dd):
            # shape of none will have the shape inferred from arr
            spacing = np.append(data.spacing, dd[0])
            res = Volume(res, spacing = spacing, origin = origin,
                         **dict_without(data._dict,
                                        ['spacing', 'origin', 'dtype']))
        else:
            res = Marray(res, positions=positions, origin = origin,
                         **dict_without(data._dict, ['spacing', 'position', 'dtype']))

    return res


