#!/bin/zsh

echo "-------------- Gestor de Docker --------------"
echo "1) Iniciar contenedores dettach"
echo "2) Detener contenedores"
echo "3) Iniciar y build de contenedores"
echo "4) Ver los contenedores corriendo actualmente"
echo "5) Salir"
echo "----------------------------------------------"
echo " "
read opcion

case $opcion in
1)
  docker compose up -d
  ;;
2)
  docker compose down
  ;;
3)
  docker compose up -d --build
  ;;
4)
  docker ps
  ;;
5)
  exit 0
  ;;
*)
  echo "Opción no valida"
  ;;
esac
