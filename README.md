# Elapsed Time

A simple timer application which aims to minimize interactions between the client and the server whilst still remaining synchronized.

## [Hosted Here](https://timer.oliver-bilbie.co.uk)

### Architecture

The client is a simple static HTML webpage, which on load will open a websocket with the server.
The server will then evaluate the offset in seconds from the last reset time, and push this to the client.
From this point, the client uses its own system clock to advance the timer.

When any given client clicks the _reset_ button this will trigger the server to push the new zero time offset to all connected clients.

This architecture avoids the need for constant polling as would be the case with a typical HTTP API.

### Hosting your own

#### Prerequisites

- Your machine must be authenticated into an AWS account with sufficient permissions to deploy the infrastructure.
- You must have a Route53 hosted zone available on the AWS account.
- You must have an ACM certificate for the desired domain name available on the AWS account.
- Your machine must have terraform installed.

1. Configure a terraform backend in `./server/terraform.tfvars`. I recommend using an S3 backend as I have done; this will involve creating an S3 bucket and a DynamoDB table, then providing the names of these in the aforementioned file.
2. Update `./server/terraform.tfvars` to the values you would like.
3. From the root directory run `make`.
