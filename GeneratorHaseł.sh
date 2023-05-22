#!/bin/bash

generate_password() {
    length=$1
    characters='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-='

    password=""
    for ((i=0; i<$length; i++)); do
        random_index=$((RANDOM % ${#characters}))
        password+=${characters:$random_index:1}
    done

    echo "$password"
}

read -p "Podaj ilość znaków w haśle: " password_length

if [[ ! $password_length =~ ^[0-9]+$ ]]; then
    echo "Podano nieprawidłową liczbę znaków."
    exit 1
fi

generated_password=$(generate_password $password_length)
echo "Wygenerowane hasło: $generated_password"

