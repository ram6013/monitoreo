ruta=$(pwd)
user=$(who -a)
user_filtered=$(echo  "$user" | awk '{print $7}' | grep -E '^[0-9]+$')
if [ -f "$ruta/monitoreo.txt" ]; then
    zenity --width=400 --height=200 --question --title="Alerta: Inicio" --text="¿Quieres empezar de cero el monitoreo?"
    if [ $? = 0 ]; then
        echo "$user_filtered" > "$ruta/monitoreo.txt"
        echo "Archivo creado para monitoreo."
    else
        echo "Se mantiene el archivo actual."
    fi
else
    echo "$user_filtered" > "$ruta/monitoreo.txt"
    echo "Archivo creado para monitoreo. Aviso se hace con la información actual. Si quiere la mayor seguridad, se recomienda reiniciar y luego ejecutarlo."
fi

while true; do
    new_user=$(who -a)
    new_user_filtered=$(echo  "$new_user" | awk '{print $7}' | grep -E '^[0-9]+$')
       echo "$new_user_filtered" > "$ruta/check_monitoreo.txt"
    diferencias=$(diff --suppress-common-lines "$ruta/monitoreo.txt" "$ruta/check_monitoreo.txt"| grep '^>')
    if [ -n "$diferencias" ]; then
        zenity --width=400 --height=200 --question --title="Alerta: Usuarios nuevos" --text="¿Quieres eliminarlo(s):\n $diferencias ?"
        if [ $? = 0 ]; then
            for id in $diferencias; do
                sudo kill $id
            done
            echo "Se ha eliminado con exito."
            user=$(who -a)
            user_filtered=$(echo  "$user" | awk '{print $7}' | grep -E '^[0-9]+$')
            echo "$user_filtered" > "$ruta/monitoreo.txt"
        else
            echo "No se ha eliminado."
            echo "$new_user_filtered" > "$ruta/monitoreo.txt"
        fi
    fi
    sleep 10
done