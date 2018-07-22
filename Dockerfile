# runtime image
FROM alpine:latest
RUN apk add --no-cache postgresql-client
COPY dbmate-linux-amd64 /usr/local/bin/dbmate
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/dbmate"]
