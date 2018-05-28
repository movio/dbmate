# runtime image
FROM debian:stretch-slim
RUN apt-get update && apt-get install -y mysql-client
COPY dbmate-linux-amd64 /usr/local/bin/dbmate
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/dbmate"]
