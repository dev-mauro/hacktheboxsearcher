#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Text decoration
bold="\e[1m"
italic="\e[3m"
itaBold="\e[3m\e[1m"
underline="\e[4m"
underBold="\e[4m\e[1m"
strikeOut="\e[9m"
endDeco="\e[0m"

function ctrl_c () {
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  exit 1
}

trap ctrl_c INT 

function helpPanel () {
  echo -e "\n${yellowColour}HTB Machines is a solved machines searcher${endColour}\n"
  echo -e "${underBold}Usage:${endDeco} htbmachines.sh [OPTIONS] [ARGUMENTS]\n"
  echo -e "${underBold}Options:${endDeco}\n"
  echo -e "\t${bold}${blueColour}-h${endColour}${endDeco}\t\t\tHelp"
  echo -e "\t${bold}${blueColour}-u${endColour}${endDeco}\t\t\tUpdate machine info"
  echo -e "\t${bold}${blueColour}-m <MACHINE NAME>${endColour}${endDeco}\tDisplay machine info with given name"
  echo -e "\t${bold}${blueColour}-q <QUERY>${endColour}${endDeco}\t\tDisplay machine info with given query (name, skill, ip, etc...)"
  echo -e "\t${bold}${blueColour}-i <MACHINE IP>${endColour}${endDeco}\t\tDisplay machine info with given ip"
  echo -e "\t${bold}${blueColour}-y <MACHINE NAME>${endColour}${endDeco}\tDisplay Youtube video with machine solution of given name"
  echo -e "\t${bold}${blueColour}-o <OPERATIVE SYSTEM>${endColour}${endDeco}\tDisplay info of machines with given operative system"
  echo -e "\t${bold}${blueColour}-s <SKILL>${endColour}${endDeco}\t\tDisplay info of machines with given skill"
  echo -e "\t${bold}${blueColour}-d <DIFFICULTY>${endColour}${endDeco}\t\tDisplay info of machines with given difficulty"
}

# Descarga y actualiza la información de las maquinas las guarda en info_machines
function updateMachines () {
  if [ ! $(which js-beautify) ]; then
    echo -e "\n${redColour}[!] js-beautify is required. Install it and try again.\n"
    exit 1
  fi

  echo -e "\n${yellowColour}[i]${endColour} Updating machine info..."
  # Se quita el id y sku de las maquinas
  curl --silent -X GET https://htbmachines.github.io/bundle.js | js-beautify | grep -A 11 -E "lf.push|lf = " | grep -vE "lf.push|lf = |id:|resuelta:|sku:|});|--" | sed 's/name:/;name:/g' | tr -d '"' > info_machines 

  echo -e "${greenColour}[i]${endColour} Machine info has been updated"
}

# Lee el file info_machines que contiene la información de las máquinas
function getMachines () {
  if [ ! -f "info_machines" ]; then
    updateMachines
  fi

  machineInfo=$(cat ./info_machines)
  echo -e $machineInfo
}

# Muestra la info de la máquina con el nombre especificado
function getMachineByName () {
  machineName="$1"

  machines=$(getMachines)

  IFS=$';'

  machineFound=0

  for machine in $machines; do 
    if [ $(echo "$machine" | grep -i "name: $machineName") ]; then
      machine=$(echo $machine | sed 's/,/\n/g')
      echo -e "\n${yellowColour}[i] Machine found${endColour}\n"
      echo -e "$machine"
      machineFound=1
      break 
    fi

  done

  if [ $machineFound -eq 0 ]; then
    echo -e "\n${yellowColour}[i] Machine has not been found :(${endColour}"
  fi

  unset IFS
}

# Busca una máquina que contenga en alguno de sus campos la palabra buscada
function getMachine () {
  machineQuery="$1"

  machines=$(getMachines)
  resultsCounter=1

  IFS=$';'

  for machine in $machines; do 

    if [ $(echo "$machine" | grep -i "$machineQuery") ]; then
      # Reemplaza las comas por saltos de línea
      machine=$(echo $machine | sed 's/,/\n/g')
      # Obtiene el nombre de la maquina encontrada
      machineName=$(echo $machine | grep "name:" | awk '{print $2}' | tr -d ",")

      echo -e "\n${yellowColour}[i] $machineName - #$resultsCounter${endColour}"
      echo -e $machine | awk 'NR > 1'
      let resultsCounter+=1
    fi

  done

  if [ $resultsCounter -eq 1 ]; then
    echo -e "\n${yellowColour}[i] No machines has been found :(${endColour}"
  fi

  unset IFS
}

# Busca una maquina con la IP dada
function getMachineByIp () {
  machineIp="$1"

  machines=$(getMachines)

  IFS=$';'

  machineFound=0

  for machine in $machines; do 
    if [ $(echo "$machine" | grep -i "ip: $machineIp") ]; then
      machine=$(echo $machine | sed 's/,/\n/g')
      machineName=$(echo $machine | grep "name:" | awk '{print $2}' | tr -d ",")

      echo -e "\n${yellowColour}[i] ${machineName}${endColour} machine found\n"
      echo -e "$machine" | awk 'NR > 1'
      machineFound=1
      break 
    fi

  done

  if [ $machineFound -eq 0 ]; then
    echo -e "\n${yellowColour}[i] Machine has not been found :(${endColour}"
  fi

  unset IFS
}

# Muestra el link del video de Youtube de la máquina con el nombre dado
function getMachineVideo () {
  machineName="$1"
  machines=$(getMachines)
  IFS=$';'
  machineFound=0

  for machine in $machines; do
    machine=$(echo $machine | sed 's/,/\n/g')
    currentMachineName=$(echo $machine | grep "name:" | awk '{print $2}' | tr -d ",")
    machineVideo=$(echo $machine | grep "youtube:" | awk '{print $2}' FS=" " | tr -d ",") 

    if [ $(echo $machine | grep -i "name: $machineName") ]; then
      echo -e "\n${yellowColour}[i] $currentMachineName found${endColour}\n\nlink: ${blueColour}${machineVideo}${endColour}"
      machineFound=1
      break
    fi
     
  done

  if [ $machineFound -eq 0 ]; then
    echo -e "\n${yellowColour}[i] Machine has not been found :(${endColour}"
  fi

  unset IFS
}

function getMachineByOs () {
  machineOs="$1"

  machines=$(getMachines)
  resultsCounter=1

  IFS=$';'

  for machine in $machines; do 

    if [ $(echo "$machine" | grep -i "so: $machineOs") ]; then
      # Reemplaza las comas por saltos de línea
      machine=$(echo $machine | sed 's/,/\n/g')
      # Obtiene el nombre de la maquina encontrada
      machineName=$(echo $machine | grep "name:" | awk '{print $2}' | tr -d ",")

      echo -e "\n${yellowColour}[i] $machineName - #$resultsCounter${endColour}"
      echo -e $machine | awk 'NR > 1'
      let resultsCounter+=1
    fi

  done

  if [ $resultsCounter -eq 1 ]; then
    echo -e "\n${yellowColour}[i] No machines has been found :(${endColour}"
  fi

  unset IFS

}

function getMachineBySkill () {
  skill="$1"

  machines=$(getMachines)
  resultsCounter=1

  IFS=$';'

  for machine in $machines; do 
    # Reemplaza las comas por saltos de línea
    machine=$(echo $machine | sed 's/,/\n/g')
    machineSkills=$(echo $machine | grep "skills:" | awk '{print $2}' FS=": ")

    if [ $(echo $machineSkills | grep -i "$skill") ]; then
      # Obtiene el nombre de la maquina encontrada
      machineName=$(echo $machine | grep "name:" | awk '{print $2}' | tr -d ",")

      echo -e "\n${yellowColour}[i] $machineName - #$resultsCounter${endColour}"
      echo -e $machine | awk 'NR > 1'
      let resultsCounter+=1
    fi

  done

  if [ $resultsCounter -eq 1 ]; then
    echo -e "\n${yellowColour}[i] No machines has been found :(${endColour}"
  fi

  unset IFS

}

function getMachineByDifficulty () {
  difficulty=$1
  machines=$(cat ./info_machines)

  IFS=$';'

  searchedMachines=$(echo $machines | grep -B 5 "$difficulty" | grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' )
  resultsNumber=$(echo $searchedMachines | wc -l )

  if [ $searchedMachines ]; then
    echo -e "${yellowColour}\n[i] $resultsNumber Machines found${endColour}\n"
    echo -e "$searchedMachines" | column
  else
    echo -e "\n${yellowColour}[!] Given difficulty does not exist.${endColour} Available difficulties:\n"
    echo -e "${greenColour}Fácil${endColour} - ${yellowColour}Media${endColour} - ${redColour}Difícil${endColour} - ${purpleColour}Insane${endColour}"
  fi

  unset IFS
}

# Indicadores
declare -i parameter_counter=0

declare -i os_selected=0
declare -i difficulty_selected=0

while getopts "m:hs:i:y:i:o:q:d:u" arg; do
  case $arg in
    h) ;;
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    q) machineQuery=$OPTARG; let parameter_counter+=3;;
    i) searchedIp=$OPTARG; let parameter_counter+=4;;
    y) machineName=$OPTARG; let parameter_counter+=5;;
    o) operativeSystem=$OPTARG; let parameter_counter+=6;;
    s) skill=$OPTARG; let parameter_counter+=7;;
    d) difficulty=$OPTARG; let parameter_counter+=8;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  getMachineByName $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateMachines
elif [ $parameter_counter -eq 3 ]; then
  getMachine $machineQuery
elif [ $parameter_counter -eq 4 ]; then
  getMachineByIp $searchedIp
elif [ $parameter_counter -eq 5 ]; then
  getMachineVideo $machineName
elif [ $parameter_counter -eq 6 ]; then
  getMachineByOs $operativeSystem
elif [ $parameter_counter -eq 7 ]; then
  getMachineBySkill $skill
elif [ $parameter_counter -eq 8 ]; then
  getMachineByDifficulty $difficulty
elif [ $difficulty_selected && $os_selected ]; then
  # Funcion que busque por dificultad y so
  getMachineByDifficulty
else
  helpPanel
fi