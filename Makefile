PROJECT=`basename "$(PWD)"`
BASE_IMAGE = $(PROJECT)-build
DOCKER_RUN = docker run \
	  -v `pwd`/home:$$HOME \
	  -v /etc/group:/etc/group:ro \
	  -v /etc/passwd:/etc/passwd:ro \
	  -u $$( id -u $$USER ):$$( id -g $$USER ) \
	  -w $$HOME \
	  -it $(BASE_IMAGE)

pack: app test-app
	docker rmi -f $(PROJECT) || true
	docker build -f Dockerfile.pack -t $(PROJECT) .
app: base
	$(DOCKER_RUN) /bin/sh -c "make build"
test-app: base
	$(DOCKER_RUN) /bin/sh -c "make test"
run:
	docker images | grep $(PROJECT) || make pack
	docker run -it $(PROJECT)

shell: base
	$(DOCKER_RUN) /bin/sh
clean:
	make clean-base
	rm -rf home
	docker rmi -f $(PROJECT) || true
base:
	docker images | grep $(BASE_IMAGE) || docker build -f Dockerfile.build -t $(BASE_IMAGE) .
	mkdir -p home
	cp Makefile app.ros home
clean-base:
	docker rmi -f $(BASE_IMAGE)
rebuild-base:
	make clean-base || true
	make base
install-emacs: home/.emacs.d/init.el

home/.emacs.d/init.el:
	make base
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
	ros build app.ros
test:
	ros app.ros test

.PHONY: pack app test-app shell clean base clean-base rebuild-base build test install-emacs
