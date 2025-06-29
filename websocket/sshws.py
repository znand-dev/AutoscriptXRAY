#!/usr/bin/env python3
from websocket_server import WebsocketServer

PORT = 80
HOST = '0.0.0.0'

def new_client(client, server):
    print(f"[WS] Client connected: {client['id']}")

def client_left(client, server):
    print(f"[WS] Client disconnected: {client['id']}")

def message_received(client, server, message):
    print(f"[WS] Message from {client['id']}: {message}")

server = WebsocketServer(port=PORT, host=HOST)
server.set_fn_new_client(new_client)
server.set_fn_client_left(client_left)
server.set_fn_message_received(message_received)
server.run_forever()
