# Stage 1: Build Environment
FROM ubuntu:noble AS build-stage
WORKDIR /app
RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && ./install-opentofu.sh --install-method deb

# Stage 2: Runtime environment
FROM ubuntu:noble AS final-stage
WORKDIR /app
COPY --from=build-stage /usr/bin/tofu /usr/bin/tofu
COPY . .
RUN cd modules

USER root 
ENTRYPOINT ["tofu"]
# CMD ["plan"]
# //terraform -chdir=workspaces/stg plan
