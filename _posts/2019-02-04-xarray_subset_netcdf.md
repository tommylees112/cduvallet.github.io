---
layout: single
title:  "Welcome to my blog!"
date:   2019-02-04 17:59:25 +0100
categories: python
excerpt:

header:
  overlay_image: /images/unsplash_mountains2.jpg
  overlay_filter: 0.6 # same as adding an opacity of 0.5 to a black background
  actions:
   #- label: " "
   #- label: " "

---

As my second blog post I will be writing a little note-to-self on how to use xarray to change the dimensions of multiple netcdf objects so that they all match. This makes selecting multiple variables for the same grid-point on the earth's surface so much simpler.

**NOTE**: this code is probably awfully written so if anyone has a better way of doing it, or else has any other comments then they would be very much appreciated!

NetCDF is a data format which contains n-dimensional arrays and associated metadata (geolocations, previous transformations, source). It is widely used in climate science and tends to be the data format that I have to work with for my PhD. There are a number of very useful tools for working with NetCDF data formats including `ncview`, `ncdump -h` and the `cdo` and `nco` commands. Here we will be focusing on using the brilliant `xarray` package for working with NetCDF. For more information checkout the xarray [documentation](http://xarray.pydata.org/en/stable/).

***

# The Problem

I want to use a drought index ([SPI](https://climatedataguide.ucar.edu/climate-data/standardized-precipitation-index-spi) & [explanation](https://wrcc.dri.edu/spi/explanation.html) // [SPEI](http://spei.csic.es/home.html)) to define periods of 'drought'. I then want to know what **other land surface variables** (temperature, soil moisture, evapotranspiration) were doing **before** and **after** the drought.

The longer term thinking is about whether there is any predictability of drought in other variables, but I'm *skeptical* that a) this is original b) that we'll be able to find anything interesting.

However, all of my variables are from different sources (model-output or earth observation data) and so have *different time periods* and *different grids/pixel sizes*.

The drought indices will serve as my `reference_dataset` which defines the *time range*, the *temporal* and *spatial resolution*, and the *longitude latitude bounding box*.

***

# The Aim

To create **one** NetCDF file with **one** set of *dimensions* (time, lat, lon) and multiple *variables*.

The **variables** are the values that we are interested in, such as precipitation for a given grid box, or soil moisture. The **dimensions** are the numbers that allow us to orientate ourselves, so we can select a grid box at a *particular location* on the earth's surface at a *particular time*.

***

# How I did it

I created a set of python functions which use functionality from [**`xarray`**](http://xarray.pydata.org/en/stable/) and another package I recently found called [**`xESMF`**](https://xesmf.readthedocs.io/en/latest/).

## Pseudo code

```
1. Open the reference dataset (the drought indices - SPI & SPEI) & the variables to be merged
2. create a drought mask (is that pixel/grid box at that time in drought?)
3. FOR EACH OTHER VARIABLE TO BE MERGED
        a. convert to the same time frequency (e.g. from daily to monthly)
        b. select the same time slice (e.g. 1st January 2010 to 31st December 2016)
        c. convert to the same grid / resolution (e.g. 600*480 to 404*316)
        d. select the same lat lon bounding box
4. Merge these into one output dataset
5. save as a new NetCDF file
```

## 0. Imports

We need the following packages for this code

```python
import xarray as xr
import xesmf as xe # for regridding
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import tqdm
import click
```

## 1. Open reference dataset & the variables to be merged

`xarray` makes opening and working with netcdf data easy.

```python
reference_ds = xr.open_dataset('spei_spi.nc')

temp = xr.open_dataset("LST_EastAfrica.nc")
temp_day = temp.lst_day
temp_night = temp.lst_night
temp_mean = (temp.lst_day + temp.lst_night) / 2
temp_mean.name = 'lst_mean'
```

## 2. create a drought mask (is that pixel/grid box at that time in drought?)


## 3. For each variable to be merged loop through and put onto the same grid

This is the real meat of the scripts, where I was doing things that I haven't done before.

```python
ds_to_merge = []

for ds_ in other_netcdfs:
    # rename 'latitude' to 'lat' etc.
    ds_ = normalise_coordinate_names(ds_)
    # select the same SLICE of time (reference_ds.min() - reference_ds.min())
    ds_ = convert_to_same_time_freq(ds, ds_)
    ds_ = select_same_time_slice(ds, ds_)
    # REGRID to same dimensions
    ds_ = convert_to_same_grid(ds, ds_)
    # select the same lat lon slice
    ds_ = select_same_lat_lon_slice(ds, ds_)

    ds_to_merge.append(ds_)
```

### a) convert to the same time frequency

The `if` statement was required in order to capture behaviour for both `xr.Dataarray` and `xr.Dataset` objects.

```python
def convert_to_same_time_freq(reference_ds,ds):
    """ Upscale or downscale data so on the same time frequencies
    e.g. convert daily data to monthly ('MS' = month start)
    """
    freq = pd.infer_freq(reference_ds.time.values)
    ds = ds.resample(time='MS').median(dim='time')

    try:
        vars = [i for i in ds.var().variables]
    except:
        vars = ds.name
    print(f"Resampled ds ({vars}) to {freq}")
    return ds
```

### b) select the same time slice

I had some problems here because of the hard upper limit in python. Whereby, when selecting from a list the values are taken **UP TO BUT NOT INCLUDING** this value. At least I think that is what is going on here.

e.g.
```
In [1]: [0,1,2,3,4,5][:5]
Out[1]: [0, 1, 2, 3, 4]
In [2]: [0,1,2,3,4,5][:6]
Out[2]: [0, 1, 2, 3, 4, 5]
```

The function uses some cool `pandas` timeseries functionality such as
* checking the frequency in a date range (`pd.infer_freq()`)
* creating a list of datetime objects (`pd.date_range()`)

```python
def select_same_time_slice(reference_ds, ds):
    """ Select the values for the same timestep as the """
    # CHECK THEY ARE THE SAME FREQUENCY
    # get the frequency of the time series from reference_ds
    freq = pd.infer_freq(reference_ds.time.values)
    old_freq = pd.infer_freq(ds.time.values)
    assert freq == old_freq, f"The frequencies should be the same! currenlty ref: {freq} vs. old: {old_freq}"

    # get the STARTING time point from the reference_ds
    min_time = reference_ds.time.min().values
    max_time = reference_ds.time.max().values
    orig_time_range = pd.date_range(min_time, max_time, freq=freq)
    # EXTEND the original time_range by 1 (so selecting the whole slice)
    # because python doesn't select the final time in a range
    periods = len(orig_time_range) + 1
    # create new time series going ONE EXTRA PERIOD
    new_time_range = pd.date_range(min_time, freq=freq, periods=periods)
    new_max = new_time_range.max()

    # select using the NEW MAX as upper limit
    ds = ds.sel(time=slice(min_time, new_max))

    print_time_min = pd.to_datetime(ds.time.min().values)
    print_time_max = pd.to_datetime(ds.time.max().values)
    try:
        vars = [i for i in ds.var().variables]
    except:
        vars = ds.name
    ref_vars = [i for i in reference_ds.var().variables]
    print(f"Select same timeslice for ds with vars: {vars}. Min {print_time_min} Max {print_time_max}")

    return ds
```

### c) convert to the same grid / resolution

This is where we get to use **`xESMF`** (imported as `xe`) for regridding!

Unfortunately, my initial one-liner was made a multi-liner by the difficulties of working with `xr.Dataset`'s rather than `xr.Dataarray`'s. In order to work with `xr.Dataset` you have to first **turn them into `xr.Dataarray`**, do the regridding *then* recombine them after the fact.

```python
def convert_to_same_grid(reference_ds, ds):
    """ Use xEMSF package to regrid ds to the same grid as reference_ds """
    # create the grid you want to convert TO (from reference_ds)
    ds_out = xr.Dataset({
        'lat': (['lat'], reference_ds.lat),
        'lon': (['lon'], reference_ds.lon),
    })

    # create the regridder object
    regridder = xe.Regridder(ds, ds_out, 'bilinear', reuse_weights=True)

    # IF it's a dataarray just do the original transformations
    if isinstance(ds, xr.core.dataarray.DataArray):
        ds = regridder(ds)
    # OTHERWISE loop through each of the variables, regrid the datarray then recombine into dataset
    elif isinstance(ds, xr.core.dataset.Dataset):
        vars = [i for i in ds.var().variables]
        if len(vars) ==1 :
            ds = regridder(ds)
        else:
            output_dict = {}
            # LOOP over each variable and append to dict
            for var in vars:
                print(f"- regridding var {var} -")
                da = ds[var]
                da = regridder(da)
                output_dict[var] = da
            # REBUILD
            ds = xr.Dataset(output_dict)
    else:
        assert False, "This function only works with xarray dataset / dataarray objects"

    return ds
```

### d) select the same lat lon bounding box

We again experienced some pretty strange behaviour here.

```python
def select_same_lat_lon_slice(reference_ds, ds):
    """
    Take a slice of data from the `ds` according to the bounding box from
     the reference_ds.
    NOTE: - latitude has to be from max() to min() for some reason?
          - becuase it's crossing the equator? e.g. -14.:8.
    Therefore, have to run an if statement to decide which way round to put the data
    """
    if len(ds.sel(lat=slice(reference_ds.lat.min(), reference_ds.lat.max())).lat) == 0:
        ds = ds.sel(lat=slice(reference_ds.lat.max(), reference_ds.lat.min()))
    else:
        ds = ds.sel(lat=slice(reference_ds.lat.min(), reference_ds.lat.max()))
    ds = ds.sel(lon=slice(reference_ds.lon.min(), reference_ds.lon.max()))

    try:
        vars = [i for i in ds.var().variables]
    except:
        vars = ds.name
    ref_vars = [i for i in reference_ds.var().variables]
    print(f"Select the same bounding box for ds {vars} from reference_ds {ref_vars}")
    return ds
```

## 4. Merge these into one output dataset

```python
def append_reference_ds_vars(reference_ds, ds_to_merge):
    # merge in the reference_ds variables
    for var in reference_ds.var().variables:
        ds_to_merge.append(reference_ds[var])

    return ds_to_merge


ds_to_merge = append_reference_ds_vars(reference_ds, ds_to_merge)
ds_to_merge.append(spei_mask)
ds_to_merge.append(spi_mask)

# merge the variables into one xarray dataset object
output_ds = xr.merge(ds_to_merge)
```

## 5. save as a new NetCDF file

```python
def save_netcdf(output_ds, filename):
    """ save the dataset"""
    output_ds.to_netcdf(filename)
    print(f"{filename} saved!")
    return

save_netcdf(output_ds, "output.nc")
```

***

This has been turned into a little [command line script](assets/scripts/.py) which should (might?) work with different datasets. Hopefully this serves as a piece of documentation. Worst case scenario it has helped me out to clean up and check my code.

Any one who wants to use it please feel free! Let me know if it does/doesn't work.
