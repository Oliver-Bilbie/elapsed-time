.PHONY: server client

default: all

all: server client

server:
	@mkdir -p ./build ./build/server
	@zip ./build/server/server.zip -j ./server/server.py
	@cd server && terraform init
	@cd server && terraform apply

client:
	@mkdir -p ./build ./build/client
	@cp -r ./client/* ./build/client
	@sed -i "s|ELAPSED_TIME_ENDPOINT|$(shell cd server && terraform output -raw websocket_endpoint)|g" ./build/client/sync_timer.js
	@aws s3 sync ./build/client s3://elapsed-time-host-bucket
