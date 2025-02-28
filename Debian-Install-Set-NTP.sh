sudo apt install ntp -y &&
sudo bash -c "echo server fw01.domain.com prefer iburst >> /etc/ntp.conf" &&
sudo systemctl restart ntp
