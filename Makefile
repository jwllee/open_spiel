VENV_DIR?="venv"
USER_UID=$(shell id -u)
DIR=$(shell pwd)


new-venv:
	echo "Creating new virtual environment at $(VENV_DIR)"
	mkdir $(VENV_DIR)
	cd $(VENV_DIR)
	virtualenv -p python3 venv


build-docker:
	docker build -t open-spiel .


# create a new user 
UID:=$(shell id -u)
GID:=$(shell id -g)
USERNAME:=$(shell id -n -u)
GROUPNAME:=$(shell id -n -g)
USERNAME:=jwllee
GROUPNAME:=jwllee
CMDLINE='groupadd -f $(GROUPNAME) && groupmod -o -g $(GID) $(GROUPNAME); \
		id -u $(USERNAME) &>/dev/null || \
		useradd -m -N $(USERNAME) && \
		usermod -o -u $(UID) -g $(GID) $(USERNAME); \
		chroot --userspec=$(USERNAME) / && cd code'

CMD='export PYTHONPATH=$$PYTHONPATH:/$$HOME/code/open_spiel; export PYTHONPATH=$$PYTHONPATH:/$$HOME/code/open_spiel/build/python; /bin/bash'
run-container: build-docker
	docker run -it \
		-e DISPLAY=unix$(DISPLAY) \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $(DIR):/home/jwllee/code \
		--network="host" \
		open-spiel:latest \
		/bin/bash -c ${CMD}

