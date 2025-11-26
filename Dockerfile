ARG CUDA_VERSION=13.0.2

FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-devel-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CACHE_BUSTER=default

COPY ./install_bioc_sysdeps.sh /

RUN { \
    echo "path-exclude /usr/share/doc/*"; \
    echo "path-exclude /usr/share/man/*"; \
    echo "force-unsafe-io"; \
    } > /etc/dpkg/dpkg.cfg.d/01-docker-optimizations

RUN echo "Weekly cache bust: $CACHE_BUSTER" \
 && apt-get update \
 && apt-get upgrade --assume-yes \
 && apt-get install --assume-yes curl ca-certificates \
 && curl -sL 'https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc' \
    -o /usr/share/keyrings/marutter.asc \
 && echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/marutter.asc] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/' \
    > /etc/apt/sources.list.d/marutter.list \
 && curl -sL "https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc" \
    -o /usr/share/keyrings/eddelbuettel.asc \
 && echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/eddelbuettel.asc] https://r2u.stat.illinois.edu/ubuntu noble main' \
    > /etc/apt/sources.list.d/r2u.list \
 && { echo "Package: *" \
 &&   echo "Pin: release o=CRAN-Apt Project" \
 &&   echo "Pin: release l=CRAN-Apt Packages" \
 &&   echo "Pin-Priority: 700"; \
    } > /etc/apt/preferences.d/99r2u \
 && apt-get update \
 && apt-get install --assume-yes --no-install-recommends r-base-dev python3-dbus python3-gi python3-apt \
 && bash /install_bioc_sysdeps.sh \
 && rm /install_bioc_sysdeps.sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Fix the dynamic linker run-time bindings
RUN echo /usr/local/cuda/targets/x86_64-linux/lib/stubs >>/etc/ld.so.conf.d/000_cuda.conf \
 && ldconfig

RUN echo "NVBLAS_CPU_BLAS_LIB /usr/lib/x86_64-linux-gnu/blas/libblas.so.3" >> /etc/nvblas.conf \
 && echo "NVBLAS_GPU_LIST ALL" >> /etc/nvblas.conf \
 && echo "NVBLAS_TILE_DIM 2048" >> /etc/nvblas.conf \
 && echo "NVBLAS_AUTOPIN_MEM_ENABLED" >> /etc/nvblas.conf

RUN mv /usr/bin/R /usr/bin/R.orig \
 && echo '#!/bin/bash' > /usr/bin/R \
 && echo 'export NVBLAS_CONFIG_FILE=/etc/nvblas.conf' >> /usr/bin/R \
 && echo 'export LD_PRELOAD=/usr/local/cuda/lib64/libnvblas.so' >> /usr/bin/R \
 && echo 'exec /usr/bin/R.orig "$@"' >> /usr/bin/R \
 && chmod +x /usr/bin/R

RUN mv /usr/bin/Rscript /usr/bin/Rscript.orig \
 && echo '#!/bin/bash' > /usr/bin/Rscript \
 && echo 'export NVBLAS_CONFIG_FILE=/etc/nvblas.conf' >> /usr/bin/Rscript \
 && echo 'export LD_PRELOAD=/usr/local/cuda/lib64/libnvblas.so'>> /usr/bin/Rscript \
 && echo 'exec /usr/bin/Rscript.orig "$@"' >> /usr/bin/Rscript \
 && chmod +x /usr/bin/Rscript

RUN Rscript -e 'install.packages("bspm")' \
 && RHOME=$(R RHOME) \
 && echo "suppressMessages(bspm::enable())" >> ${RHOME}/etc/Rprofile.site \
 && echo "options(bspm.version.check=FALSE)" >> ${RHOME}/etc/Rprofile.site \
 && apt-get update \
 && Rscript -e 'install.packages(c("BiocManager", "devtools"))' \
 && Rscript -e 'BiocManager::install("preprocessCore", configure.args = c(preprocessCore = "--disable-threading"), force=TRUE, ask=FALSE, type="source")' \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "R_LIBS=/usr/lib/R/host-site-library:\${R_LIBS}" > /usr/lib/R/etc/Renviron.site \
 && curl -OL http://bioconductor.org/checkResults/devel/bioc-LATEST/Renviron.bioc \
 && sed -i '/^IS_BIOC_BUILD_MACHINE/d' Renviron.bioc \
 && cat Renviron.bioc | grep -o '^[^#]*' | sed 's/export //g' >>/etc/environment \
 && cat Renviron.bioc >> /usr/lib/R/etc/Renviron.site \
 && echo BIOCONDUCTOR_VERSION=${BIOCONDUCTOR_VERSION} >> /usr/lib/R/etc/Renviron.site \
 && echo BIOCONDUCTOR_DOCKER_VERSION=${BIOCONDUCTOR_DOCKER_VERSION} >> /usr/lib/R/etc/Renviron.site \
 && echo 'LIBSBML_CFLAGS="-I/usr/include"' >> /usr/lib/R/etc/Renviron.site \
 && echo 'LIBSBML_LIBS="-lsbml"' >> /usr/lib/R/etc/Renviron.site \
 && rm -rf Renviron.bioc
