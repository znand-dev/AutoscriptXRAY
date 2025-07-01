#!/usr/bin/env python3
import os
import sys
import time
import logging
from websocket_server import WebsocketServer

# Configuration dengan environment variables
PORT = int(os.getenv('SSHWS_PORT', 80))
HOST = os.getenv('SSHWS_HOST', '127.0.0.1')  # Bind to localhost by default
MAX_MESSAGE_SIZE = int(os.getenv('SSHWS_MAX_MSG_SIZE', 1024))
MAX_CLIENTS = int(os.getenv('SSHWS_MAX_CLIENTS', 100))

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/sshws.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Connection tracking
client_connections = {}
connection_count = 0

def new_client(client, server):
    global connection_count
    
    # Rate limiting - max connections check
    if connection_count >= MAX_CLIENTS:
        logger.warning(f"Max connections reached ({MAX_CLIENTS}). Denying new connection.")
        server.deny_new_connections()
        return
    
    connection_count += 1
    client_connections[client['id']] = {
        'connected_at': time.time(),
        'message_count': 0
    }
    
    logger.info(f"Client connected: {client['id']} (Total: {connection_count})")

def client_left(client, server):
    global connection_count
    
    if client['id'] in client_connections:
        del client_connections[client['id']]
        connection_count -= 1
    
    logger.info(f"Client disconnected: {client['id']} (Total: {connection_count})")

def message_received(client, server, message):
    client_id = client['id']
    
    # Security checks
    if client_id not in client_connections:
        logger.warning(f"Message from unknown client {client_id}")
        return
    
    # Message size limit
    if len(message) > MAX_MESSAGE_SIZE:
        logger.warning(f"Message too large from {client_id}: {len(message)} bytes")
        # Disconnect client for security
        server.deny_new_connections()
        return
    
    # Rate limiting - message count per client
    client_connections[client_id]['message_count'] += 1
    if client_connections[client_id]['message_count'] > 1000:  # 1000 messages per connection
        logger.warning(f"Client {client_id} exceeded message limit")
        return
    
    # Log message (truncated for security)
    message_preview = message[:100] + "..." if len(message) > 100 else message
    logger.info(f"Message from {client_id}: {message_preview}")

def main():
    try:
        logger.info(f"Starting SSH WebSocket server on {HOST}:{PORT}")
        logger.info(f"Max clients: {MAX_CLIENTS}, Max message size: {MAX_MESSAGE_SIZE}")
        
        server = WebsocketServer(port=PORT, host=HOST)
        server.set_fn_new_client(new_client)
        server.set_fn_client_left(client_left)
        server.set_fn_message_received(message_received)
        
        logger.info("SSH WebSocket server started successfully")
        server.run_forever()
        
    except PermissionError:
        logger.error(f"Permission denied to bind to port {PORT}. Try running as root or use port > 1024")
        sys.exit(1)
    except OSError as e:
        logger.error(f"Failed to start server: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
