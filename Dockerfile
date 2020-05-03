FROM alpine

# Install required packages
RUN apk add --no-cache \
    git \
    bash \
    curl \
    protobuf \
    nodejs \
    nodejs-npm

RUN npm install -g quicktype

# Copy scripts
COPY src/ /

# Start executor. Params are passed from github actions
ENTRYPOINT ["./executor.sh"]