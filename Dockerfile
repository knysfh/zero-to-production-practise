####    编译阶段    ####
FROM rust:1.80 AS builder
WORKDIR /app

## 更换编译阶段源
RUN cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bk
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources

## 调整编译阶段时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update

RUN apt update && apt install lld clang -y
COPY . .
ENV SQLX_OFFLINE=true
ENV APP_ENVIRONMENT=production
RUN cargo build --release


####    运行阶段    ####
FROM debian:trixie-slim AS runtime

## 更换运行阶段源
RUN cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bk
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources

WORKDIR /app
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/zero-test zero-test
COPY configuration configuration
ENV APP_ENVIRONMENT=production
ENV APP_APPLICATION_PORT=5023
ENTRYPOINT ["./zero-test"]