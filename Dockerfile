# Please, try to use images located in public.ecr.aws/docker/library
FROM public.ecr.aws/docker/library/r-base:4.3.1 AS builder

# Install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev libcurl4-openssl-dev libxml2-dev libnetcdf-dev pandoc wget \
    && rm -rf /var/lib/apt/lists/*

# Download and install Python 3.11
RUN wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz \
    && tar -xf Python-3.11.0.tar.xz \
    && cd Python-3.11.0 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.11.0*

# Install pip for Python 3.11
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3.11 get-pip.py \
    && rm get-pip.py

# Install R packages from CRAN
RUN install2.r --error \
    rmarkdown \
    BiocManager \
    pak \
    readr \
    magrittr \
    dplyr \
    data.table \
    xtable \
    aws.s3 \
    aws.ec2metadata

# Install Python packages
RUN python3.11 -m pip install \
    --break-system-packages \
    rpy2 \
    boto3 \
    requests-toolbelt \
    requests-aws4auth \
    gql \
    requests \
    pyyaml \
    s3fs \
    aiohttp \
    aiofile 


FROM public.ecr.aws/docker/library/r-base:4.3.1

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev libcurl4-openssl-dev pandoc libxml2 libnetcdf19 wget procps \
    build-essential zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install Python 3.11
RUN wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz \
    && tar -xf Python-3.11.0.tar.xz \
    && cd Python-3.11.0 \
    && ./configure --enable-optimizations --with-ensurepip=install \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.11.0*

# Install pip for Python 3.11
RUN wget https://bootstrap.pypa.io/get-pip.py \
&& python3.11 get-pip.py \
&& rm get-pip.py
# Copy R packages from the builder image
COPY --from=builder /usr/local/lib/R/site-library/ /usr/local/lib/R/site-library/

# Copy Python packages from the builder image
COPY --from=builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/

# Copy your script to run the tool
COPY script.Rmd /app/

# Necessary files for running your tool on the Datoma infrastructure
COPY install_jobrunner.py /app/install_jobrunner.py
RUN chmod +x /app/install_jobrunner.py
COPY install_jobrunner_and_run.sh /app/install_jobrunner_and_run.sh
RUN chmod +x /app/install_jobrunner_and_run.sh
COPY datomaconfig.yml /app/
RUN mkdir /app/results

# Necessary lines to run the tool
WORKDIR /app
ENTRYPOINT ["/bin/bash" ,"/app/install_jobrunner_and_run.sh" ]
