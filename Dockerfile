FROM nvcr.io/nvidia/cuda:13.0.2-devel-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive

COPY ./install_bioc_sysdeps.sh /

RUN { \
    echo "path-exclude /usr/share/doc/*"; \
    echo "path-exclude /usr/share/man/*"; \
    echo "force-unsafe-io"; \
    } > /etc/dpkg/dpkg.cfg.d/01-docker-optimizations

RUN apt-get update \
 && apt-get upgrade --assume-yes \
 && apt-get install --assume-yes curl ca-certificates \
 && curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x5E25F516B04C661B" \
    -o /usr/share/keyrings/marutter.asc \
 && echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/marutter.asc] http://ppa.launchpad.net/marutter/rrutter4.0/ubuntu noble main' \
    > /etc/apt/sources.list.d/marutter.list \
 && apt-get update \
 && apt-get install --assume-yes --no-install-recommends r-base-dev \
 && bash /install_bioc_sysdeps.sh \
 && rm /install_bioc_sysdeps.sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Fix the dynamic linker run-time bindings
RUN echo /usr/local/cuda/targets/x86_64-linux/lib/stubs >>/etc/ld.so.conf.d/000_cuda.conf \
 && ldconfig

RUN Rscript -e "install.packages('pak', repos = 'https://r-lib.github.io/p/pak/dev/')" \
 && Rscript -e 'pak::pkg_install(c("BiocManager", "devtools")); pak::cache_clean()' \
 && Rscript -e "BiocManager::install(ask = FALSE)" \
 && Rscript -e 'BiocManager::install("preprocessCore", configure.args = c(preprocessCore = "--disable-threading"), force=TRUE, ask=FALSE, type="source")'

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
