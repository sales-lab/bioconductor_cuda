#!/bin/bash
#
# Adapted from: https://raw.githubusercontent.com/Bioconductor/bioconductor_docker/refs/heads/devel/bioc_scripts/install_bioc_sysdeps.sh
# 
set -e

apt-get install -y --no-install-recommends apt-utils

## Basic Deps
apt-get install -y --no-install-recommends \
	gdb \
	libxml2-dev \
	python3-pip \
	libz-dev \
	liblzma-dev \
	libbz2-dev \
	libpng-dev \
	libgit2-dev

## sys deps from bioc_full
apt-get install -y --no-install-recommends \
	pkg-config \
	fortran77-compiler \
	byacc \
	automake \
	curl \
	cmake

## This section installs libraries
apt-get install -y --no-install-recommends \
	libpcre2-dev \
	libnetcdf-dev \
	libhdf5-serial-dev \
	libfftw3-dev \
	libopenbabel-dev \
	libopenmpi-dev \
	libxt-dev \
	libudunits2-dev \
	libgeos-dev \
	libproj-dev \
	libcairo2-dev \
	libtiff5-dev \
	libreadline-dev \
	libgsl0-dev \
	libgslcblas0 \
	libgtk2.0-dev \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	libgmp3-dev \
	libhdf5-dev \
	libncurses-dev \
	libxpm-dev \
	liblapack-dev \
	libv8-dev \
	libgtkmm-2.4-dev \
	libmpfr-dev \
	libmodule-build-perl \
	libapparmor-dev \
	libprotoc-dev \
	librdf0-dev \
	libmagick++-dev \
	libsasl2-dev \
	libpoppler-cpp-dev \
	libprotobuf-dev \
	libpq-dev \
	libarchive-dev \
	coinor-libcgl-dev \
	coinor-libsymphony-dev \
	coinor-libsymphony-doc \
	libpoppler-glib-dev

## software - perl extentions and modules
apt-get install -y --no-install-recommends \
	libperl-dev \
	libarchive-extract-perl \
	libfile-copy-recursive-perl \
	libcgi-pm-perl \
	libdbi-perl \
	libdbd-mysql-perl \
	libxml-simple-perl

## new libs
apt-get install -y --no-install-recommends \
	libglpk-dev \
	libeigen3-dev \
 	liblz4-dev

## Databases and other software
apt-get install -y --no-install-recommends \
	sqlite3 \
	openmpi-bin \
	mpi-default-bin \
	openmpi-common \
	openmpi-doc \
	tcl8.6-dev \
	tk-dev \
	default-jdk \
	imagemagick \
	tabix \
	ggobi \
	graphviz \
	protobuf-compiler \
	jags \
	libhiredis-dev

## Additional resources
apt-get install -y --no-install-recommends \
	xfonts-100dpi \
	xfonts-75dpi \
	biber \
	libsbml5-dev \
	libzmq3-dev \
	python3-dev \
	python3-venv

## More additional resources
## libavfilter-dev - <infinityFlow, host of other packages>
## mono-runtime - <rawrr, MsBackendRawFileReader>
## libfuse-dev - <Travel>
## ocl-icd-opencl-dev - <gpuMagic> - but machine needs to be a GPU--otherwise it's useless
apt-get -y --no-install-recommends install \
	libmariadb-dev-compat \
	libjpeg-dev \
	libjpeg-turbo8-dev \
	libjpeg8-dev \
	libavfilter-dev \
	libfuse-dev \
	mono-runtime \
	ocl-icd-opencl-dev

## Python installations
# pip3 install scikit-learn pandas pyyaml --break-system-packages || pip3 install scikit-learn pandas pyyaml
# Replacing old pip installation above with apt install for system-wide installations of packages given the
# new restrictions breaking system-wide pip install
apt-get -y --no-install-recommends install \
        python3-pandas \
	python3-yaml \
        python3-sklearn

## libgdal is needed for sf
apt-get install -y --no-install-recommends \
	libgdal-dev \
	default-libmysqlclient-dev \
	libmysqlclient-dev
