.PHONY: install seal add-app

install:
	@echo "Applying homelab..."
	@kubectl apply -f homelab.yaml

seal:
	@./scripts/seal-secret.sh

add-app:
	@./scripts/add-app.sh