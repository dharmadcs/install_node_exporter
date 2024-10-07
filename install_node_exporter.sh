#!/bin/bash

# Set version for Node Exporter
VERSION="1.8.2"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz"
SERVICE_PATH="/etc/systemd/system/node_exporter.service"

# Step 1: Download Node Exporter
echo "Downloading Node Exporter version $VERSION..."
wget $DOWNLOAD_URL

# Step 2: Extract tar file
echo "Extracting Node Exporter..."
tar xvfz node_exporter-${VERSION}.linux-amd64.tar.gz

# Step 3: Move Node Exporter binary to /usr/local/bin
echo "Moving Node Exporter binary to /usr/local/bin..."
sudo mv node_exporter-${VERSION}.linux-amd64/node_exporter /usr/local/bin/

# Step 4: Create a dedicated user for Node Exporter
echo "Creating user for Node Exporter..."
sudo useradd -rs /bin/false node_exporter

# Step 5: Create systemd service file
echo "Creating systemd service file..."
sudo bash -c "cat > $SERVICE_PATH" <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Step 6: Reload systemd and start Node Exporter
echo "Reloading systemd and starting Node Exporter..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Step 7: Check Node Exporter status
echo "Checking Node Exporter status..."
sudo systemctl status node_exporter

# Step 8: Verify metrics endpoint
echo "Verifying Node Exporter metrics..."
curl http://localhost:9100/metrics

echo "Node Exporter installation and setup complete!"