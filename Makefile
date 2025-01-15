.PHONY: server client

default: all

all: server client

server:
	@zip ./server/server.zip -j ./server/server.py
	@cd server && terraform init
	@cd server && terraform apply

client:
	@aws s3 sync ./client s3://elapsed-time-host-bucket
