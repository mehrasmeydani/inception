FROM alpine:3.22

RUN apk add --no-cache\
     nginx\
     openssl

RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=AT/ST=Vienna/L=Vienna/O=42Vienna/CN=megardes.42.fr"

COPY conf/nginx.conf /etc/nginx/http.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
