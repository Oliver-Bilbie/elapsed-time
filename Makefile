.PHONY: server client

default: all

all: server client

server:
	@mkdir -p ./build ./build/server
	@echo "[INFO] Generating server zip file"
	@zip ./build/server/server.zip -j ./server/server.py
	@echo "[INFO] Deploying the server infrastructure"
	@cd server && terraform init
	@cd server && terraform apply
	@echo "[INFO] Server deployed 🚀"

client:
	@mkdir -p ./build ./build/client
	@echo "[INFO] Generating client files"
	@cp -r ./client/* ./build/client
	@sed -i "s|ELAPSED_TIME_ENDPOINT|$(shell cd server && terraform output -raw websocket_endpoint)|g" ./build/client/sync_timer.js
	@echo "[INFO] Uploading client files"
	@aws s3 sync ./build/client s3://elapsed-time-host-bucket
	@echo "[INFO] Resetting CDN cache"
	@aws cloudfront create-invalidation --distribution-id $(shell cd server && terraform output -raw cloudfront_distribution) --paths "/*"
	@echo "[INFO] Client deployed 🚀"
