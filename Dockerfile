## Emacs, make this -*- mode: sh; -*-
#
# Based on GPL-2.0 image from Dirk Eddelbuettel <edd@debian.org> & Rocker Project

FROM ubuntu:focal

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/snjnz/rmd-docker" \
      maintainer="Sophie Jones <njon652@aucklanduni.ac.nz>"

ARG DEBIAN_FRONTEND=noninteractive

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		fonts-texgyre \
	&& rm -rf /var/lib/apt/lists/*

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

ENV R_BASE_VERSION 4.0.3

RUN apt-get update \
	&& apt-get install -y --no-install-recommends gnupg

RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" > /etc/apt/sources.list.d/cran.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

## Now install R and littler, and create a link for littler in /usr/local/bin
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                gcc-9-base \
                libopenblas0-pthread \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}-* \
		r-base-dev=${R_BASE_VERSION}-* \
		r-recommended=${R_BASE_VERSION}-* \
		pandoc \
		libjs-mathjax \
		fonts-mathjax-extras \
		openssh-client git \
	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installDeps.r /usr/local/bin/installDeps.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
      && wget https://github.com/jgm/pandoc/releases/download/2.11.3.1/pandoc-2.11.3.1-1-amd64.deb \
      && dpkg -i pandoc-2.11.3.1-1-amd64.deb \
      && rm -rf /var/lib/apt/lists/*

COPY Rprofile.site /etc/R/Rprofile.site

#RUN R -e "install.packages(c('knitr', 's20x', 'tinytex'))"

RUN R -e "install.packages(c('knitr', 's20x', 'tinytex')); library(tinytex); tinytex::install_tinytex()" \
      && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

CMD ["R"]
