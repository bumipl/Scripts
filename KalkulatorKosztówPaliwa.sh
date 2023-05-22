#!/bin/bash

echo "----WITAJ W KALKULATORZE PALIWA----"
echo "Pamiętaj, żeby liczyć zmiennoprzecinkowe podawać po kropce[.]"

echo "Podaj długość trasy [km]: "
read trasa

echo "Podaj spalanie w litrach na 100km: "
read spalanie

echo "Podaj cenę za litr paliwa: "
read cena_paliwa

koszt=$(echo "$trasa * $spalanie / 100 * $cena_paliwa" | bc)
echo "Koszt przejechania całej trasy to: $koszt zł"

echo "Czy chcesz podzielić kwotę na osoby?"
echo "1 - tak"
echo "2 - nie"

read dzialanie

case $dzialanie in
1)
echo "Podaj na ile osób dzielisz kwotę: "
read ilosc_osob
echo "Koszt przejechania całej trasy to: $koszt zł"
echo "Cena na osobę to: $(echo "$koszt / $ilosc_osob" | bc) zł"
;;
2)
echo "Koszt przejechania całej trasy to: $koszt zł"
;;
*)
echo "Wybrałeś opcję, której nie ma na liście"
;;
esac

echo ""
