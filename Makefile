.PHONY: install seal add-app refresh

install:
	@echo "Applying homelab..."
	@kubectl apply -f homelab.yaml

refresh:
	@echo "Refreshing homelab..."
	@kubectl -n argocd annotate applicationset homelab argocd.argoproj.io/application-set-refresh=0

seal:
	@./scripts/seal-secret.sh

add-app:
	@./scripts/add-app.sh

tf-plan:
	@cd ./terraform/proxmox && ./scripts/tf-with-keychain plan -out=talos-vms.tfplan

tf-apply:
	@cd ./terraform/proxmox && ./scripts/tf-with-keychain apply talos-vms.tfplan