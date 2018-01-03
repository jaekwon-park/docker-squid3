# docker-squid3


squid3 docker container 

DNS Filtering to AWS NAT Instance with Squid



## INSTALL

**docker-squid3** need [docker-ce](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)(required) and [docker-compose](https://docs.docker.com/compose/install/)(optional)

with docker-compose:

```
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3129
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3130

# docker-compose up -d

```




