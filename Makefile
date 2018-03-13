PROJECT=`basename "$(PWD)"`
BASE_IMAGE = $(PROJECT)-build
DOCKER_RUN = docker run \
	  -v `pwd`/local-projects:/media/local-projects \
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
	mkdir -p home/.roswell/local-projects
	mkdir -p local-projects
	ln -s /media/local-projects home/.roswell/local-projects/externals || true
	docker images | grep $(BASE_IMAGE) || docker build -f Dockerfile.build -t $(BASE_IMAGE) .
	cp Makefile app.ros home
clean-base:
	docker rmi -f $(BASE_IMAGE)
rebuild-base:
	make clean-base || true
	make base
# below are used inside container.
build:
	ros build app.ros
test:
	ros app.ros test

.PHONY: pack app test-app shell clean base clean-base rebuild-base build test
