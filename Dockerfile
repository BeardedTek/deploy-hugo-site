ARG HUGO_VERSION
#####################  BUILDER  ####################
FROM hugomods/hugo:go-git-$HUGO_VERSION AS builder
ARG HUGO_REPO
ARG HUGO_OPTS
ARG DOMAIN
ARG PROTOCOL
ARG HUGO_BASEURL=${PROTOCOL}://${DOMAIN}
ARG PLAUSIBLE_HOST

ENV HUGO_BASEURL=$HUGO_BASEURL
# Clone the Repository
RUN git clone $HUGO_REPO /src
# Build the site
RUN hugo $HUGO_OPTS

###################  FINAL STAGE  ##################
# Use hugo:nginx as the base of the final image
FROM hugomods/hugo:nginx
# Copy only the static files from build stage
COPY --from=builder /src/public /site

# Copy plausible proxy script and replace with defined PLAUSIBLE HOST if it exists
COPY plausible-proxy.conf /etc/nginx/conf.d/
RUN if [ -n $PLAUSIBLE_HOST ]; sed -i "s/PLAUSIBLE_HOST/${PLAUSIBLE_HOST}/g" .etc/nginx/conf.d/plausible-proxy.conf; else rm -f /etc/nginx/conf.d/plausible-proxy.conf; fi;
