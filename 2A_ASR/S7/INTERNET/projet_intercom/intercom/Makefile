.PHONY : shell

up_build :
	docker compose up --build -d

up :
	docker compose up -d

up_verbose :
	docker compose up

shell :	
	@if [ -z "$(container)" ]; then \
		echo "Usage: make shell container=<your-container-name>"; \
	else \
		docker exec -it $(container) bash; \
	fi

down :
	docker compose down
