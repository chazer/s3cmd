FROM python:3.6-alpine as build

RUN apk add --no-cache git

WORKDIR /src

RUN git clone --single-branch --branch ssl-auth  https://github.com/chazer/s3cmd.git .

RUN python setup.py install

RUN touch /root/.s3cfg

RUN ( \
    echo "[default]"; \
    echo "access_key = "; \
    echo "access_token = "; \
    echo "bucket_location = US"; \
    echo "host_base = s3.amazonaws.com"; \
    echo "host_bucket = %(bucket)s.s3.amazonaws.com"; \
    echo "encrypt = False"; \
    echo "gpg_command = None"; \
    echo "use_https = True"; \
    echo "proxy_host = "; \
    echo "proxy_port = 0"; \
    ) | tee /root/.s3cfg


FROM python:3.6-alpine

COPY --from=build /usr/local/lib/python3.6/site-packages /usr/local/lib/python3.6/site-packages
COPY --from=build /usr/local/bin/s3cmd /usr/local/bin/s3cmd
COPY --from=build /root/.s3cfg /root/.s3cfg

ENTRYPOINT [ "/usr/local/bin/s3cmd" ]
