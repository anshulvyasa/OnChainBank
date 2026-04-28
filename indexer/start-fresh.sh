#!/bin/bash
set -e

echo "Resetting indexer..."
docker compose down -v 2>/dev/null || true

echo "Starting containers..."
docker compose up -d

echo "Waiting for Graph node to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0
until curl -s -o /dev/null -w '' http://localhost:8020 2>/dev/null; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Graph node did not become ready after ${MAX_RETRIES} attempts. Check docker logs:"
    echo "docker compose logs graph-node"
    exit 1
  fi
  echo "   Attempt $RETRY_COUNT/$MAX_RETRIES - Graph node not ready yet, retrying in 2s..."
  sleep 2
done
echo "Graph node is ready!"

echo "Creating subgraph..."
npx graph create --node http://localhost:8020/ omegaindexer

echo "Deploying subgraph..."
npx graph deploy --node http://localhost:8020/ --ipfs http://localhost:5001 omegaindexer

echo ""
echo "Indexer is up and running!"
