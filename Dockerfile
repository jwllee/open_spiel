FROM ubuntu:18.04 as base_build

RUN apt-get update && apt-get install -y \
	sudo \
	git \
	vim \
	make \
	build-essential \
	gcc

ENV UNAME jwllee
ENV HOME=/home/${UNAME}
WORKDIR $HOME

RUN export UNAME=$UNAME UID=1000 GID=1000 && \
	mkdir -p "/home/${UNAME}" && \
	echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
	echo "${UNAME}:x:${UID}:" >> /etc/group && \
	mkdir -p /etc/sudoers.d && \
	echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
	chmod 0440 /etc/sudoers.d/${UNAME} && \
	chown ${UID}:${GID} -R /home/${UNAME} && \
	gpasswd -a ${UNAME} audio

RUN echo $HOME

# open_spiel dependencies
RUN apt-get update && apt-get install -y \
	virtualenv \
	python3.7 \
	python3.7-dev \
	python3-pip \
	python3-setuptools \
	python3-wheel \
	wget

# install cmake
WORKDIR /tmp/

RUN wget https://github.com/Kitware/CMake/releases/download/v3.15.4/cmake-3.15.4-Linux-x86_64.sh && \
	mkdir /opt/cmake && \
	sh cmake-3.15.4-Linux-x86_64.sh --skip-license  --prefix=/opt/cmake && \
	ln -s /opt/cmake/bin/cmake /usr/bin/cmake && \
	ln -s /opt/cmake/bin/ctest /usr/bin/ctest && \
	ln -s /opt/cmake/bin/ccmake /usr/bin/ccmake && \
	ln -s /opt/cmake/bin/cmake-gui /usr/bin/cmake-gui && \
	ln -s /opt/cmake/bin/cpack /usr/bin/cpack

RUN	echo $(cmake --version)

WORKDIR $HOME

USER jwllee

# make virtual environment and install independencies
COPY requirements.txt /tmp/requirements.txt
RUN virtualenv -p python3.7 venv  && \
	/bin/bash -c "source venv/bin/activate; pip install -r /tmp/requirements.txt;" 

# my own setup
# setup dotfiles
RUN git clone --recursive https://github.com/jwllee/dotfiles.git \
	&& cd dotfiles && make 

# setup vim
RUN git clone --recursive https://github.com/jwllee/.vim.git .vim \
	&& ln -sf /.vim/vimrc $HOME/.vimrc \
	&& cd $HOME/.vim \
	&& git submodule update --init

CMD [ "/bin/bash" ]
