PROJECT = `basename "$(PWD)"`
DEV_IMAGE = $(PROJECT).dev
PACK_IMAGE = $(PROJECT).pack
DOCKERFILE = _.Dockerfile
DOCKERFILE_PACK = pack.Dockerfile
DOCKERFILE_DEV = dev.Dockerfile
DOCKER_RUN = docker run \
	  -v `pwd`/..:/mnt/parent \
	  -v `pwd`/home:$$HOME \
	  -v /etc/group:/etc/group:ro \
	  -v /etc/passwd:/etc/passwd:ro \
	  -u $$( id -u $$USER ):$$( id -g $$USER ) \
	  -w $$HOME \
	  -it $(DEV_IMAGE)
all: test-app pack
%.Dockerfile: base/%.Dockerfile
	cp $< $@
home/%.ros: base/%.ros
	cp $< $@ ||true
pack: packer $(DOCKERFILE)
	printf "%s\n%s\n" "FROM $(PACK_IMAGE)" "`tail -n +2 base/$(DOCKERFILE)`" > $(DOCKERFILE).tmp
	cmp -s $(DOCKERFILE).tmp $(DOCKERFILE)||cp $(DOCKERFILE).tmp $(DOCKERFILE)
	rm -f $(DOCKERFILE).tmp
	docker rmi -f $(PROJECT) || true
	docker build -f $(DOCKERFILE) -t $(PROJECT) .

packer: $(DOCKERFILE_PACK)
	docker images | grep $(PACK_IMAGE)[^\.] || docker build -f $(DOCKERFILE_PACK) -t $(PACK_IMAGE) .
clean-packer:
	docker rmi -f $(PACK_IMAGE) || true
rebuild-packer:
	make PROJECT=$(PROJECT) clean-base || true
	make PROJECT=$(PROJECT) packer
app: base home/app.ros
	$(DOCKER_RUN) /bin/sh -c "make build"
test-app: app
	$(DOCKER_RUN) /bin/sh -c "make test"
run:
	docker images | grep $(PROJECT)[^\.] || make PROJECT=$(PROJECT) pack
	docker run -it $(PROJECT)

shell: base
	$(DOCKER_RUN) /bin/sh
clean:
	make PROJECT=$(PROJECT) clean-base
	rm -rf ./home/
	docker rmi -f $(PROJECT) || true
	rm -f dev.Dockerfile pack.Dockerfile
base: $(DOCKERFILE_DEV)
	docker images | grep $(DEV_IMAGE)[^\.] || docker build -f $(DOCKERFILE_DEV) -t $(DEV_IMAGE) .
	cp Makefile home
clean-base:
	docker rmi -f $(DEV_IMAGE) || true
rebuild-base:
	make PROJECT=$(PROJECT) clean-base || true
	make PROJECT=$(PROJECT) base
install-emacs: home/.emacs.d/init.el
install: base
	mkdir -p home/mount
	echo "(ignore-errors (eval (read-from-string \"(pushnew (merge-pathnames \\\"mount/\\\" (user-homedir-pathname)) ql:*local-project-directories*)\")))" > home/.roswell/init.lisp
home/.emacs.d/init.el:
	make PROJECT=$(PROJECT) base
	$(DOCKER_RUN) /bin/sh -c "ros setup"
	$(DOCKER_RUN) /bin/sh -c "ros install slime"
	$(DOCKER_RUN) /bin/sh -c "ros install clhs"
	$(DOCKER_RUN) /bin/sh -c "ros -s clhs -e '(clhs:install-clhs-use-local)'"
	mkdir -p ./home/.emacs.d/site-lisp
	wget -nc -O ./home/.emacs.d/site-lisp/slime-repl-ansi-color.el https://raw.githubusercontent.com/deadtrickster/slime-repl-ansi-color/master/slime-repl-ansi-color.el|true
	wget -nc -O ./home/.emacs.d/site-lisp/0.8.tar.gz https://github.com/purcell/ac-slime/archive/0.8.tar.gz|true
	tar xf ./home/.emacs.d/site-lisp/0.8.tar.gz -C ./home/.emacs.d/site-lisp
	mkdir -p ./home/.emacs.d/
	cp -n init.el ./home/.emacs.d/
	$(DOCKER_RUN) /bin/sh -c "emacs --batch --load ~/.emacs.d/init.el"

# below are used inside container.
build:
	if [ -f build ]; then \
		./build; \
	else \
		ros build app.ros; \
	fi
test:
	if [ -f test ] ;then \
		./test; \
	else \
		ros app.ros test; \
	fi

.PHONY: pack app test-app shell clean base clean-base rebuild-base build test install-emacs
