#!/usr/bin/env bash

# Author: Ayush Goyal <perfectayush@gmail.com>

function usage() {
  cat <<END
Script to start revealjs presentation in docker
Usage:
$0 <options>

-f REVEALJS_HTML_FILE - file you want to use for presentation
-l                    - Setup live reload for debugging
END
}

while getopts "f:l" flag; do
    case "$flag" in
        f)
            FILE=$OPTARG;;
        l)
            LIVE_RELOAD=1;;
        h)
            usage; exit 0;;
        *)
            usage; exit 1;;
    esac
done

if [[ -z "$FILE" ]]; then
    echo "ERROR: File to start for presentation is not defined."
    usage; exit 1
fi
if [[ $LIVE_RELOAD -eq 1 ]]; then
   RELOAD_OPTS=" -p 35729:35729 "
fi

RESOURCES_DIR="$(dirname $(realpath $FILE))/resources"
if [ -d "${RESOURCES_DIR}" ]; then
    RES_VOL_OPT=" -v ${RESOURCES_DIR}:/srv/resources/ "
fi

CONTAINER_ID=`docker run -d --name revealjs-${FILE} -v "$(pwd)/${FILE}:/srv/index.html" ${RES_VOL_OPT} -p 8000 ${RELOAD_OPTS} --rm -i -t revealjs-revealjs:latest`
[ $? -ne 0 ] && exit 1
PUBLISHED_PORT=`docker port ${CONTAINER_ID} 8000 | cut -d: -f2`
{ sleep 5 ; open -a "Google Chrome" http://localhost:${PUBLISHED_PORT} ; } &

echo "Service will be available on http://localhost:${PUBLISHED_PORT} shortly"

docker attach ${CONTAINER_ID}
