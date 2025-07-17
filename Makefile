test: build up clean

test-no-cache: build-no-cache up run-tests clean

build:
	docker compose -f docker-compose.test.yml -p ci build

build-no-cache:
	docker compose -f docker-compose.test.yml -p ci build --no-cache

up:
	docker compose -f docker-compose.test.yml -p ci up -d

clean:
	docker compose -f docker-compose.test.yml -p ci down
