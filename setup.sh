#!/bin/bash

# Skrypt do automatyzacji konfiguracji serwera Linux

echo "Aktualizuję system..."
sudo apt update && sudo apt upgrade -y

echo "Sprawdzam, czy Apache jest zainstalowany..."
if dpkg -l | grep -q apache2; then
    echo "Apache już jest zainstalowany."
else
    echo "Instaluję Apache..."
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
fi

echo "Sprawdzam firewalld..."
if dpkg -l | grep -q firewalld; then
    echo "firewalld jest już zainstalowane."
else
    echo "Instaluję firewalld..."
    sudo apt install firewalld -y
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
fi

echo "Sprawdzam reguły firewalla..."
if sudo firewall-cmd --list-all | grep -q "services:.*http"; then
    echo "Reguła HTTP już istnieje."
else
    sudo firewall-cmd --permanent --add-service=http
fi

if sudo firewall-cmd --list-all | grep -q "services:.*https"; then
    echo "Reguła HTTPS już istnieje."
else
    sudo firewall-cmd --permanent --add-service=https
fi

sudo firewall-cmd --reload

echo "Dodaję nowego użytkownika..."
read -p "Podaj nazwę użytkownika (używaj małych liter): " username
username=$(echo "$username" | tr '[:upper:]' '[:lower:]')  # Zamiana dużych liter na małe

# Sprawdzenie, czy użytkownik już istnieje
if id "$username" &>/dev/null; then
    echo "Użytkownik $username już istnieje."
else
    sudo adduser $username
    sudo usermod -aG sudo $username
    echo "Dodano użytkownika $username z uprawnieniami sudo."
fi

echo "Konfiguracja zakończona!"
