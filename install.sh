#!/usr/bin/env bash

print_logo() {
	cat << "EOF"
   /$$$$$$                      /$$                          
 /$$__  $$                    | $$                          
| $$  \ $$  /$$$$$$   /$$$$$$$| $$$$$$$   /$$$$$$   /$$$$$$ 
| $$$$$$$$ /$$__  $$ /$$_____/| $$__  $$ /$$__  $$ /$$__  $$
| $$__  $$| $$  \__/| $$      | $$  \ $$| $$$$$$$$| $$  \__/
| $$  | $$| $$      | $$      | $$  | $$| $$_____/| $$      
| $$  | $$| $$      |  $$$$$$$| $$  | $$|  $$$$$$$| $$      
|__/  |__/|__/       \_______/|__/  |__/ \_______/|__/      
                                                            
EOF
}

clear
print_logo

# Exit On Error
set -e 

source utils.sh

# Source The Package list
if [ ! -f "packages.conf" ]; then
	echo -e "\e[31mError: packages.conf not found!\e[0m"
 	exit 1
fi

source packages.conf

echo "Updating System"
sudo pacman -Syyu --noconfirm

#install AUR 

if ! command yay &> /dev/null; then 
	echo "Installing yay AUR Helper...."
	sudo pacman -S --needed git base-devel --noconfirm
	if [[ ! -d "yay" ]];then
		echo "Cloning yay Repo..."
	else
		echo " Diroctory alrady Exist Removing yay "
		rm -rf yay
	fi

	git clone https://aur.archlinux.org/yay.git
	
	cd yay
	makepkg -si --noconfirm
	cd ..
	rm -rf yay
else
	echo "yay is alredy Installed..."

fi

  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"
  
  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"
  
  echo "Installing system maintenance tools..."
  install_packages "${MAINTENANCE[@]}"
  
  echo "Installing desktop environment..."
  install_packages "${DESKTOP[@]}"
  
  echo "Installing desktop environment..."
  install_packages "${OFFICE[@]}"
  
  echo "Installing media packages..."
  install_packages "${MEDIA[@]}"
  
  echo "Installing fonts..."
  install_packages "${FONTS[@]}"


echo "Enabling Services"
for service in "${SERVICES[@]}"; do
if ! systemctl is-enabled "$service" &> /dev/null;then
	sudo systemctl enable "$service"

else
	echo "$service is alrady Enabled"
fi
done

echo "Setup Complete! Reboot The System"
