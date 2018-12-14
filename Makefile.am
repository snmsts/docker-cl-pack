help:
	
cache:
	docker build --target $(PACKAGE)-cl-base -t $(PACKAGE)-cl-base .
	docker build --target $(PACKAGE)-runner -t $(PACKAGE)-runner .
	docker build --target $(PACKAGE)-deps -t $(PACKAGE)-deps .

no-cache:
	docker build --no-cache --target $(PACKAGE)-cl-base -t $(PACKAGE)-cl-base .
	docker build --no-cache --target $(PACKAGE)-runner -t $(PACKAGE)-runner .
	docker build --target $(PACKAGE)-deps -t $(PACKAGE)-deps .

all:
	test -z "$$(docker images -q $(PACKAGE)-deps)" && make cache || true
	docker build -t $(PACKAGE) .
	docker run -t $(PACKAGE):latest
	docker ps -af ancestor=$(PACKAGE):latest -q
	$(MKDIR_P) release/$(PACKAGE_VERSION)/
	docker cp "$$(docker ps -af ancestor=$(PACKAGE):latest -q):/app" release/$(PACKAGE_VERSION)/

update:
	test -z "$$(docker images -q $(PACKAGE)-deps)" && make cache || true
	docker run -w /app -i -P $(PACKAGE)-deps:latest bash -c "\$$HOME/.roswell/bin/qlot update"
	docker cp "$$(docker ps -al -af ancestor=$(PACKAGE)-deps:latest -q):/app/qlfile.lock" qlfile.lock

clean:
	docker rmi -f $(PACKAGE)-cl-base
	docker rmi -f $(PACKAGE)-runner
	docker rmi -f $(PACKAGE)-deps

serve:
	docker run \
	  -p $(PORT_FORWARD_PORT):5000 \
	  -w /app \
	  -it $(PACKAGE):latest \
	  bash -c "./runtime" || true

shell:
	$(MKDIR_P) devenv
	docker run \
	  -v $(PWD)/devenv:$$HOME \
	  -v $(PWD):$$HOME/app \
	  -v /etc/group:/etc/group:ro \
	  -v /etc/passwd:/etc/passwd:ro \
	  -u $$( id -u $$USER ):$$( id -g $$USER ) \
	  -w $$HOME \
	  -it $(PACKAGE)-deps:latest \
	  bash -c "echo \"export PS1='[$(PACKAGE):shell] \w$$ '\" >> ~/.bashrc \
	  && echo \"export PATH=$$HOME/.roswell/bin:$$PATH\" >> ~/.bashrc \
	  &&bash" || true
debug:
	docker run \
	  -u lisp:lisp \
	  -w /home/lisp \
	  -it $(PACKAGE)-deps:latest \
	  bash -c "echo \"export PS1='[$(PACKAGE):debug] \w$$ '\" >> ~/.bashrc \
	  && bash" || true

runtime.ros:
	ros init runtime.ros

build: runtime.ros
	rm -rf _
	$(MKDIR_P) _
	ros build runtime.ros
	cp runtime _
	cp app.lisp _
