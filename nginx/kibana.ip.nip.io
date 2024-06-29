server {
    listen 80;

    server_name kibana.IP.nip.io;

    auth_basic "Acesso Restrito";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://IP:5601/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
