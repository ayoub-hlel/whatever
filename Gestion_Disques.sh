#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory=$1
if [ ! -d "$directory" ]; then
    echo "Le répertoire spécifié n'existe pas."
    exit 1
fi

compress_files() {
    local file="$1"
    local size=$(stat -c %s "$file")
    if [ "$size" -ge 50000 ] && [ "$size" -le 100000 ]; then
        gzip -c "$file" > /tmp/$(basename "$file").gz
        echo "$file compressé avec succès."
        rm "$file"
        echo "$(date) : $file compressé et supprimé" >> journal.txt
    fi
}

delete_files() {
    local file="$1"
    local size=$(stat -c %s "$file")
    if [ "$size" -gt 100000 ]; then
        rm "$file"
        echo "$(date) : $file supprimé" >> journal.txt
    fi
}

find "$directory" -type f -printf "%s %p\n" | sort -n | cut -d' ' -f2- | while read -r file; do
    echo "Nom du fichier: $(basename "$file")"
    echo "Droits d'accès: $(stat -c %A "$file")"
    echo "Utilisateur propriétaire: $(stat -c %U "$file")"
    echo "Taille: $(stat -c %s "$file") octets"
    read -p "Voulez-vous supprimer (S) ou compresser (C) ce fichier? [S/C]: " choice
    case "$choice" in
        [sS])
            delete_files "$file"
            ;;
        [cC])
            compress_files "$file"
            ;;
        *)
            echo "Choix invalide. Le fichier ne sera ni supprimé ni compressé."
            ;;
    esac
done

exit 0
