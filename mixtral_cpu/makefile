dockerfile = ./dockerfile
name = mixtral_cpu
tag = dev
registry = 058264342822.dkr.ecr.eu-central-1.amazonaws.com/rvrecht

clean: # Remove cached and compiled files in repo
	@find . -type f -name "*.py[co]" -delete
	@find . -type d -name "__pycache__" -delete

build: clean # Build image => (name, tag, [base_image])
	docker build -f $(dockerfile) -t $(name):$(tag) .

run: build
	docker rm -f mixtral_cpu || true
	docker run -d -t -p 8000:8000 --name mixtral_cpu $(name):$(tag)

push: # AWS CLI musst be installed and configured to work with this
	@echo "Running clean..."
	@find . -type f -name "*.py[co]" -delete
	@find . -type d -name "__pycache__" -delete
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $(registry)
	docker build --platform linux/amd64 -f $(dockerfile) -t $(registry):$(name) .
	docker push $(registry):$(name)
	