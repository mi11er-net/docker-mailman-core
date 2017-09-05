FROM python:3.6-alpine

LABEL maintainer="Matthew Miller"

# Set Environemnt Vars
ENV WORKDIR /opt/mailman
ENV MAILMAN_CONFIG_FILE ${WORKDIR}/var/etc/mailman.cfg
ENV HYPERKITTY_CONFIG_FILE ${WORKDIR}/var/etc/mailman-hyperkitty.cfg

# Change the working directory.
WORKDIR ${WORKDIR}

# Set Versions
ARG MAILMAN_VERSION=3.1.0
ARG HYPERKITTY_VERSION=1.1.0

# Install all required packages
# Add user for executing mailman
# Set ownership of Mailman's WORKDIR
RUN apk add --no-cache --virtual .mailman-build-deps gcc python3-dev musl-dev \
    && apk add --no-cache postgresql-dev bash postgresql-client \
    && pip install psycopg2 mailman==${MAILMAN_VERSION} mailman-hyperkitty==${HYPERKITTY_VERSION} pymysql \
    && apk del --no-cache .mailman-build-deps \
    && adduser -S mailman \
    && chown -R mailman /opt/mailman

VOLUME ${WORKDIR}

#Add startup script to container
COPY docker-entrypoint.sh /usr/local/bin/

# Expose the ports for the api (8001) and lmtp (8024)
EXPOSE 8001 8024

# Set the user
USER mailman

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["master"]
