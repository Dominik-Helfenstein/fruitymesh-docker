FROM i386/alpine

RUN apk add --no-cache build-base wget bash zsh libstdc++6 zlib gcompat cmake python3 musl-locales tzdata

# Set up compiler
ENV bin /fruitymesh/bin
RUN mkdir -p ${bin}
ENV gcc_4_9 gcc-arm-none-eabi-4_9-2015q3

# COPY downloads $bin
RUN wget -O ${bin}/${gcc_4_9}.tar.bz2 https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q3-update/+download/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2
RUN cd ${bin} && \
    tar -xjf ${gcc_4_9}.tar.bz2 && \
    rm ${gcc_4_9}.tar.bz2
RUN echo "export ARM_GCC_BIN=${bin}/${gcc_4_9}/bin" >> ~/.bashrc
RUN echo "export PATH=\$PATH:\$ARM_GCC_BIN" >> ~/.bashrc

# Install nrf command line tools
ENV nrf_cmdline_tools nrf-command-line-tools
RUN wget -O ${bin}/${nrf_cmdline_tools}.tar.gz https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-22-0/nrf-command-line-tools-10.22.0_linux-arm64.tar.gz
RUN cd ${bin} && \
    tar -xzf ${nrf_cmdline_tools}.tar.gz && \
    rm ${nrf_cmdline_tools}.tar.gz
RUN echo "export NRF_CMDLINE_TOOLS=${bin}/${nrf_cmdline_tools}/bin" >> ~/.bashrc
RUN echo "export PATH=\$PATH:\$NRF_CMDLINE_TOOLS" >> ~/.bashrc

RUN mkdir -p /fruitymesh/_build/commandline
RUN echo "cmake ../../ -DBUILD_TYPE=FIRMWARE -DGCC_PATH=${bin}/${gcc_4_9} -G \"Unix Makefiles\"" >> /fruitymesh/_build/commandline/01_setup.sh
RUN chmod +x /fruitymesh/_build/commandline/01_setup.sh
RUN echo "cmake --build . --target github_dev_nrf52" >> /fruitymesh/_build/commandline/02_build.sh
RUN chmod +x /fruitymesh/_build/commandline/02_build.sh

ENV TZ=Europe/Berlin
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime

WORKDIR /fruitymesh
COPY . .

ENTRYPOINT [ "/bin/bash" ]