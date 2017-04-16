#!/bin/bash

source ./compilator.conf

URL='https://hub.spigotmc.org/versions/'
BUILDTOOLSURL='https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar'
BUILDTOOLEXEC='BuildTools.jar'
CNORMAL='\033[0m'
CGREEN='\033[0;32m'
CRED='\033[0;31m'
CYELLOW='\033[0;33m'

spinner()
{
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

bye() {

	echo ""
	echo ""
	echo "    Bye :)"
	echo ""
	exit -1
}

start_compilation()
{
    # NEW COMPILATION
		echo ""
		echo -e "${CNORMAL}    -- New compilation starting --${CNORMAL}"
		echo ""

		# CREATING DIRECTORY $NDATE
		mkdir $NDATE
		cd $NDATE

		# DOWNLOADING BuildTools
		echo -e -n "${CNORMAL}    Downloading compilator, please wait ${spin[0]}"

		curl -sS -o BuildTools.jar $BUILDTOOLSURL &
		spinner

	  echo -e "${CGREEN}Done${CNORMAL}"

		# START COMPILATION
		echo -e -n "${CNORMAL}    Starting compilation, please wait "

		java -jar $BUILDTOOLEXEC --rev $VERSION > /dev/null 2>&1 &
		spinner

	  echo -e "${CGREEN}Done${CNORMAL}"

		# CLEANING
		echo -e -n "${CNORMAL}    Cleaning compilation, please wait "

		curl -sL $URL$VERSION.json -O $VERSION.json > /dev/null 2>&1 &
		spinner

		if [ -d apache-maven-3.2.5 ]; then
		  rm -Rf apache-maven-3.2.5
		fi

		if [ -d BuildData ]; then
		  rm -Rf BuildData
		fi

		if [ -d Bukkit ]; then
		  rm -Rf Bukkit
		fi

		if [ -d CraftBukkit ]; then
		  rm -Rf CraftBukkit
		fi

		if [ -d Spigot ]; then
		  rm -Rf Spigot
		fi

		if [ -d work ]; then
		  rm -Rf work
		fi

		if [ -f BuildTools.jar ]; then
		  rm BuildTools.jar
		fi

	  echo -e "${CGREEN}Done${CNORMAL}"

    echo ""
    echo -e "${CNORMAL}    ${CGREEN}Compilation completed ! ${CNORMAL}"
    echo ""
    echo ""
		bye
}

clear

echo -e "${CNORMAL}-------------------------------------------${CNORMAL}"
echo -e "--          ${CGREEN}Spigot compilator ${CYELLOW} v1.0      ${CNORMAL}--"
echo -e "--                ${NORMAL}By ${CRED}Hasturcraft         ${CNORMAL}--"
echo -e "${CNORMAL}-------------------------------------------"
echo ""
echo ""
echo -e "    I start to find the latest release for spigot version ${CYELLOW}$VERSION${CNORMAL}"
sleep 1

# GET DISTANT RELEASE PAGE && FIND VERSION LINE IN $CONTENT
while read LINE
do
    if echo "$LINE" | grep -q "$VERSION.json"; then
        CONTENT=$LINE
        break
    fi
done < <(curl -sL $URL)

echo ""

# CHECK IF $CONTENT IS NOT EMPTY
if [ -z "$CONTENT" ]
then

  echo -e "${CRED}    I haven't find the latest release for spigot version ${CYELLOW}$VERSION${CNORMAL}"

else

  # PARSE CONTENT TO $array && GET RELEASE DATE IN $RDATE

  IFS=' ' read -r -a array <<< "$CONTENT"

  for index in "${!array[@]}"
  do

    RDATE="${array[2]}"

  done

	# CONVERT $NDATE TO GOOD FORMAT IN $NDATE
  NDATE=$(date -d $RDATE +%F)

  echo -e "${CNORMAL}    Latest release is ${CGREEN}$NDATE${CNORMAL}"
  echo ""

	# CHECK IF $NDATE DIRECTORY EXIST
  if [ -d $NDATE ]
  then
	  echo -e "${CNORMAL}    A directory ${CRED}$NDATE exist${CNORMAL}"
    echo ""

	  # CHECK IF SPIGOT CORE EXIST
		echo -e -n "${CNORMAL}    I check if ${CGREEN}spigot-$VERSION.jar${CNORMAL} exist in ${CYELLOW}$NDATE${CNORMAL} directory : "

		if [ -f $NDATE/spigot-$VERSION.jar ];
		then

			echo -e "${CGREEN}Find${CNORMAL}"
			C1=1;

		else

			echo -e "${CRED}Not find${CNORMAL}"
			C1=0
        fi

		#CHECK IF BuildTools.log.txt EXIST
        echo -e -n "${CNORMAL}    I check if ${CGREEN}BuildTools.log.txt${CNORMAL} exist in ${CYELLOW}$NDATE${CNORMAL} directory : "

		if [ -f $NDATE/BuildTools.log.txt ];
		then

			echo -e "${CGREEN}Find${CNORMAL}"
			C2=1;

		else

			echo -e "${CRED}Not find${CNORMAL}"
			C2=0
        fi

		#CHECK IF $VERSION.json EXIST
        echo -e -n "${CNORMAL}    I check if ${CGREEN}$VERSION.json${CNORMAL} exist in ${CYELLOW}$NDATE${CNORMAL} directory : "

		if [ -f $NDATE/$VERSION.json ];
		then

			echo -e "${CGREEN}Find${CNORMAL}"
			C3=1;

		else

			echo -e "${CRED}Not find${CNORMAL}"
			C3=0
        fi

		echo ""
		echo -e "${CNORMAL}    What can i do ?"
		echo -e "${CNORMAL}    1 - Erase existant and recompile spigot ${CGREEN}$NDATE${CNORMAL} release${CNORMAL}"
		echo -e "${CNORMAL}    2 - Quit${CNORMAL}"
		echo ""
		echo -e -n "${CNORMAL}    Your choice : "

		read answer

		if [ "$answer" == "1" ]; then

			# DELETING OLD DIRECTORY $NDATE
			rm -Rf $NDATE

		    start_compilation

		elif [ "$answer" == "2" ]; then

			bye

		fi
	else

		echo -e "${CNORMAL}    No directory ${CRED}$NDATE ${CNORMAL}found${CNORMAL}"
		echo ""

		echo ""
		echo -e "${CNORMAL}    What can i do ?"
		echo -e "${CNORMAL}    1 - Start the compilation of spigot ${CGREEN}$NDATE${CNORMAL} release${CNORMAL}"
		echo -e "${CNORMAL}    2 - Quit${CNORMAL}"
		echo ""
		echo -e -n "${CNORMAL}    Your choice : "

		read answer

		if [ "$answer" == "1" ]; then

		    start_compilation

		elif [ "$answer" == "2" ]; then

			bye

		fi


    fi

fi
