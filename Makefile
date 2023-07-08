build:
	docker build -t fruity .

run:
	docker run --rm -it fruity

br:
	docker build -t fruity . && docker run --rm -it fruity