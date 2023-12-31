FROM golang:1.18 AS build-env

# Install dependencies
RUN apt-get update
RUN apt-get install git

# Set up env vars
ENV COSMOS_BUILD_OPTIONS nostrip

# Set working directory for the build
WORKDIR /src 

COPY . .
RUN go mod download

# Make the binary
RUN make build 

# Final image
FROM debian

# Install ca-certificates
RUN apt-get update
RUN apt-get install jq -y

WORKDIR /root

COPY docker/entrypoint.sh .
COPY init.sh .

# Copy over binaries from the build-env
COPY --from=build-env /src/build/nautid /usr/bin/nautid

EXPOSE 26656 26657

ENTRYPOINT ["./entrypoint-debug.sh"]
CMD ["nautid"]