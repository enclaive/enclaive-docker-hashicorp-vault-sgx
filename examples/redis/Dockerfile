FROM gramineproject/gramine:v1.4

RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb focal main" | tee /etc/apt/sources.list.d/redis.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends libsgx-dcap-default-qpl redis \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/

COPY ./sgx_default_qcnl.conf ./redis.conf /etc/
COPY ./premain ./redis.manifest.template ./entrypoint.sh ./

RUN gramine-sgx-gen-private-key \
    && gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu redis.manifest.template redis.manifest \
    && gramine-sgx-sign --manifest redis.manifest --output redis.manifest.sgx

VOLUME /data/ /logs/
EXPOSE 6379/tcp

ENTRYPOINT [ "./entrypoint.sh" ]