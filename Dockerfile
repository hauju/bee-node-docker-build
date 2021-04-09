FROM rust:slim-bullseye as builder
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install git npm build-essential cmake pkg-config librocksdb-dev llvm clang libclang-dev libssl-dev   
WORKDIR /src
RUN git clone https://github.com/iotaledger/bee.git --branch chrysalis-pt-2 
WORKDIR /src/bee/bee-node
RUN git submodule update --init
RUN cd src/plugins/dashboard/frontend && npm install
RUN cd src/plugins/dashboard/frontend && npm run build-bee
RUN cargo build --release --features dashboard

FROM debian:bullseye-slim
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y --no-install-recommends install ca-certificates libssl1.1 \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
WORKDIR /app
COPY --from=builder /src/bee/target/release/bee bee
ENTRYPOINT ["./bee"]  