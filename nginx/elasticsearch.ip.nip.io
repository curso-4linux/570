server {
    listen 80;

    server_name elasticsearch.IP.nip.io;

    location / {
        proxy_pass http://localhost:9200/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-34.42.35.155 $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
