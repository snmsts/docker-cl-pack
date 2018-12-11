help:
	
cache:
	docker build --target $(PACKAGE)-cl-base -t $(PACKAGE)-cl-base .
	docker build --target $(PACKAGE)-runner -t $(PACKAGE)-runner .
	docker build --target $(PACKAGE)-deps -t $(PACKAGE)-deps .

all:
	test -z "$$(docker images -q $(PACKAGE)-deps)" && make cache || true
	docker build -t $(PACKAGE) .
	docker run -t $(PACKAGE):latest
	docker ps -af ancestor=$(PACKAGE):latest -q
	$(MKDIR_P) release/$(PACKAGE_VERSION)/
	docker cp "$$(docker ps -af ancestor=$(PACKAGE):latest -q):/usr/bin/$(PACKAGE)" release/$(PACKAGE_VERSION)/$(PACKAGE)

update:
	test -z "$$(docker images -q $(PACKAGE)-deps)" && make cache || true
	docker run -w /app -i -P $(PACKAGE)-deps:latest bash -c "\$$HOME/.roswell/bin/qlot update"
	docker cp "$$(docker ps -al -af ancestor=$(PACKAGE)-deps:latest -q):/app/qlfile.lock" qlfile.lock
build: runtime.ros
	ros build runtime.ros

runtime.ros:
	ros init runtime.ros

clean:
	docker rmi -f $(PACKAGE)-cl-base
	docker rmi -f $(PACKAGE)-runner
	docker rmi -f $(PACKAGE)-deps

dev:
	$(MKDIR_P) devenv
	docker run \
	  -v $(PWD)/devenv:$$HOME \
	  -v $(PWD):$$HOME/app \
	  -v /etc/group:/etc/group:ro \
	  -v /etc/passwd:/etc/passwd:ro \
	  -u $$( id -u $$USER ):$$( id -g $$USER ) \
	  -w $$HOME \
	  -it $(PACKAGE)-deps:latest env PATH=$$HOME/.roswell/bin:$$PATH bash -i || true
