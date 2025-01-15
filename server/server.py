import os
import json
from datetime import datetime
import boto3


CONNECTION_TABLE_NAME = os.getenv("CONNECTION_TABLE_NAME")
dynamodb = boto3.resource("dynamodb")
conn_table = dynamodb.Table(CONNECTION_TABLE_NAME)

TIMESTAMP_PARAMETER = os.getenv("TIMESTAMP_PARAMETER")
ssm_client = boto3.client("ssm")

WEBSOCKET_ENDPOINT = os.getenv("WEBSOCKET_ENDPOINT").replace("wss", "https", 1)
api_client = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=WEBSOCKET_ENDPOINT,
)


def lambda_handler(event, context):
    connection_id = event["requestContext"]["connectionId"]
    route_key = event["requestContext"]["routeKey"]

    if route_key == "$connect":
        return connect_client(connection_id)

    if route_key == "$disconnect":
        return disconnect_client(connection_id)

    if route_key == "get_time":
        return get_time(connection_id)

    if route_key == "reset_time":
        return reset_time()

    return {"statusCode": 400, "body": "Unsupported route"}


def connect_client(connection_id):
    conn_table.put_item(Item={"connectionId": connection_id})
    return {"statusCode": 200}


def disconnect_client(connection_id):
    conn_table.delete_item(Item={"connectionId": connection_id})
    return {"statusCode": 200}


def get_time(connection_id):
    try:
        timestamp_str = ssm_client.get_parameter(
            Name=TIMESTAMP_PARAMETER, WithDecryption=False
        )["Parameter"]["Value"]
        timestamp = datetime.fromisoformat(timestamp_str)
        elapsed_time = datetime.now() - timestamp
        elapsed_seconds = elapsed_time.total_seconds()
        update_client(connection_id, timestamp_str, elapsed_seconds)

    except ValueError:
        reset_time()

    return {
        "statusCode": 200,
    }


def reset_time():
    timestamp_str = datetime.now().isoformat()

    ssm_client.put_parameter(
        Name=TIMESTAMP_PARAMETER, Value=timestamp_str, Type="String", Overwrite=True
    )

    connections = conn_table.scan()["Items"]

    for connection in connections:
        update_client(connection["connectionId"], timestamp_str, 0)

    return {"statusCode": 200}


def update_client(connection_id, timestamp_str, elapsed_seconds):
    try:
        api_client.post_to_connection(
            ConnectionId=connection_id,
            Data=json.dumps(
                {
                    "timestamp": timestamp_str,
                    "elapsed_seconds": elapsed_seconds,
                }
            ),
        )

    except Exception as e:
        conn_table.delete_item(Key={"connectionId": connection_id})
        print(f"Failed to send to connection {connection_id}: {e}")
