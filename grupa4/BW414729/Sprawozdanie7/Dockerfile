FROM python:3.10-slim
WORKDIR /app
COPY yt-dlp-bin /usr/local/bin/yt-dlp
RUN chmod +x /usr/local/bin/yt-dlp
ENTRYPOINT ["yt-dlp"]