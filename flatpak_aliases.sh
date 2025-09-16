flatpak list --app --columns=application | while read -r app_id; do
    short_name="${app_id##*.}"
    short_name=$(echo "$short_name" | tr '[:upper:]' '[:lower:]')
    echo "alias $short_name=\"flatpak run $app_id\""
done > ~/.config/flatpak_aliases.txt

