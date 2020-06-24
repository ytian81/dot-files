echo "installing bat"

brew install bat

mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"

# Download a theme in '.tmTheme' format
git clone https://github.com/peaceant/gruvbox.git

# Update the binary cache
bat cache --build
