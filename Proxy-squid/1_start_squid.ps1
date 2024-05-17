#docker pull sameersbn/squid:3.5.27-2

docker run --name squid -d --publish 127.0.0.1:3128:3128 --volume ${PWD}/squid_password_ADD_YOUR_CREDS.conf:/etc/squid/squid.conf --restart always  sameersbn/squid:3.5.27-2

#docker exec -it squid tail -f /var/log/squid/access.log
