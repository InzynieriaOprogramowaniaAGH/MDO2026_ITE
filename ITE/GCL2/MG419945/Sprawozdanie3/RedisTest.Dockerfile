FROM build-image

WORKDIR /repo/redis-8.0.0

CMD ["make", "test"]
