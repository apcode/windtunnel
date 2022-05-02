FROM nvidia/cuda:10.2-base

# Install any extra things we might need
RUN apt-get update \
    && apt-get install -y \
    vim \
    ssh \
    sudo \
    wget \
    bc \
    htop \
    libscotch-dev \
    libcgal-dev \
    libopenmpi-dev \
    openmpi-bin \
    build-essential \
    software-properties-common ;\
    #rm -rf /var/lib/apt/lists/*

# Create a new user called foam
RUN useradd --user-group --create-home --shell /bin/bash foam ;\
    echo "foam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN apt-get update

# Install OpenFOAM v9 including configuring for use by user=foam
# plus an extra environment variable to make OpenMPI play nice
RUN bash -c "wget -O - http://dl.openfoam.org/gpg.key | apt-key add -" && \
    add-apt-repository http://dl.openfoam.org/ubuntu

RUN apt-get install -y openfoam9 && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --user-group --create-home --shell /bin/bash foam

RUN echo "source /opt/openfoam9/etc/bashrc" >> /home/foam/.bashrc ;\
    echo "export OMPI_MCA_btl_vader_single_copy_mechanism=none" >> ~foam/.bashrc

RUN chown -R foam:foam /opt/openfoam9/

RUN apt update && apt install -y \
    glmark2 \
    libcurl4-openssl-dev \
    libegl1 \
    libgl1 \
    libglfw3 \
    libglvnd0 \
    libglx0 \
    libx11-6 \
    libxext6 \
    qt5-default; \
    rm -rf /var/lib/apt/lists/*

RUN wget -q --show-progress --progress=bar:force --timeout=5 --tries=10 -O /opt/paraview-headless.tar.gz "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.0-osmesa-MPI-Linux-Python3.9-x86_64.tar.gz"

RUN tar -C /opt -xf /opt/paraview-headless.tar.gz && \
    mv /opt/ParaView-5.10.0-osmesa-MPI-Linux-Python3.9-x86_64/ /opt/paraview-headless && \
    sudo chown -R foam /opt/paraview-headless

#RUN wget -O /opt/paraview-headless.tar.gz "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.0-egl-MPI-Linux-Python3.9-x86_64.tar.gz"
#
#RUN tar -C /opt -xf /opt/paraview-headless.tar.gz && \
#    mv /opt/ParaView-5.10.0-egl-MPI-Linux-Python3.9-x86_64/ /opt/paraview-headless && \
#    sudo chown -R foam /opt/paraview-headless

RUN apt update && apt install -y \
    python3-pip \
    python3.8-dev

ENV PATH /opt/paraview-headless/bin:$PATH
ENV LD_LIBRARY_PATH /opt/paraview-headless/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH /home/foam/.local/lib/python3.6/site-packages
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
ENV QT_X11_NO_MITSHM=1

USER foam

# Run this as foam user
RUN pip3 install --user absl-py jinja2 numpy
RUN python3.8 -m pip install Cython
RUN python3.8 -m pip install absl-py jinja2 numpy
ENV PYTHONPATH /home/foam/.local/lib/python3.8/site-packages
