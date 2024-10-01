#!/bin/bash

PROMETHEUS_VERSION="2.50.0"
NODE_EXPORTER_VERSION="1.6.0"
INSTALL_DIR="/opt/prometheus"
USER="prometheus"

# Create prometheus user
echo "Creating prometheus user..."
useradd --no-create-home --shell /bin/false $USER

# Create directories
echo "Creating directories for Prometheus..."
mkdir -p $INSTALL_DIR
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

# Download Prometheus
echo "Downloading Prometheus..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz

# Extracting
echo "Extracting Prometheus..."
tar -xvf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
cd prometheus-$PROMETHEUS_VERSION.linux-amd64

# Moving files
echo "Moving Prometheus files..."
mv prometheus /usr/local/bin/
mv promtool /usr/local/bin/
mv consoles /etc/prometheus/
mv console_libraries /etc/prometheus/
mv prometheus.yml /etc/prometheus/

# Setting permissions
echo "Setting permissions..."
chown -R $USER:$USER /etc/prometheus
chown -R $USER:$USER /var/lib/prometheus

# Creating a system service
echo "Creating system service for Prometheus..."
cat <<EOF >/etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=/var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Prometheus
echo "Reloading systemd and starting Prometheus..."
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus

echo "Prometheus has been successfully installed and started!"

# (Optional) Install Node Exporter
read -p "Do you want to install Node Exporter for server monitoring? (y/n): " install_node_exporter

if [[ $install_node_exporter == "y" ]]; then
    echo "Downloading and installing Node Exporter..."
    
    # Downloading Node Exporter
    cd /tmp
    wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
    tar -xvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
    mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/

    # Creating a system service for Node Exporter
    echo "Creating system service for Node Exporter..."
    cat <<EOF >/etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
User=$USER
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

    # Starting Node Exporter
    systemctl daemon-reload
    systemctl start node_exporter
    systemctl enable node_exporter

    echo "Node Exporter has been successfully installed and started!"
fi

echo "Installation is complete! Prometheus is available on port 9090."
