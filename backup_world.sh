############### CONFIGURATION DU JEU #############
game='valheim'
# Chemin complet du dossier a compresser (peut être récupéré avec un pwd)
save_folder_parent='/home/steam/.config/unity3d/IronGate/Valheim/'
save_folder='worlds/'
# Chemin où le dossier compressé doit être copié
destination_folder='/home/steam/servers/valheim/'
# Dossier qui contient le script du start server et script a lancer
server_folder='/home/steam/servers/valheim/'
server_script='./start_server.sh'
#Le nombre de sauvegardes qu'on veut garder
keep_saves=14
auto_update=1
app_id=896660

############### SCRIPT DE COPIE #################
# On stoppe ici le server via son screen (jeu_server)en checkant toutes les secondes que le serveur est stoppé proprement et complètement
while pkill --signal SIGINT "${game}_server"; do
    sleep 1
done
# On supprime le screen
screen -X -S ${game}_server quit

echo 'Le serveur valheim a été stoppé.'
# On récupère la date atuelle au format YYYYMMDD_HHMMSS
actual_date=$(date '+%Y%m%d_%H%M%S')
# On defini le nom du fichier au format /chemin/ou/copier/les/save/jeu_server_YYYYMMDD_HHMMSS.rar
copy_name="${destination_folder}${game}_server_${actual_date}.rar"

# On se place dans le dossier qui contient les saves (pour ne pas avoir tout le chemin depuis home dans le rar)
cd $save_folder_parent
# On rar le dossier des saves (rar a chemin/ou/le/dossier/va/etre.rar dossier/a/compresser/)
rar a $copy_name $save_folder
# On se place dans le dossier des saves
cd $destination_folder
# On liste tous les fichiers du dossier de sauvegarde par ordre de timestamp, on supprime les X premières lignes (soit autant de saves qu'on veut garder)
# puis on supprime toutes les lignes restantes en prenant en compte les caractères spéciaux (-d)
ls -t | sed -e "1,${keep_saves}d" | xargs -0 -d '\n' rm
echo 'La copie du fichier de sauvegarde a été faite.'
# On démarre un nouveau screen format jeu_server
screen -dmS ${game}_server
if [ $auto_update = "1" ] 
then 
    # On s'attache au screen, et on lance la commande pour update (via steamcmd) et démarrer le serveur
    screen -r ${game}_server -X stuff "cd && ./steamcmd +login anonymous +force_install_dir ${server_folder} +app_update ${app_id} validate +quit && cd ${server_folder}\n${server_script}\n"
    echo "Le serveur a été mis a jour (si disponible) et lancé."
else
    # On s'attache au screen, et on démarre simplement le serveur
    screen -r ${game}_server -X stuff "cd ${server_folder}\n${server_script}\n"
    echo "Le serveur a été lancé."
fi
