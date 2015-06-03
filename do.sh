#! /bin/sh

# brew install jq # https://robots.thoughtbot.com/jq-is-sed-for-json


REPO_NAME=${1}
UUID=${2}
ROOT='.'
TEMP_DIR=${ROOT}/zips

ZIP_FILE=${TEMP_DIR}/${UUID}.zip
JSON_FILE=${TEMP_DIR}/${UUID}.json
UUID_DIR=${TEMP_DIR}/${UUID}
REPO_PATH=../${REPO_NAME}

mkdir -p ${TEMP_DIR}

# Find the latest version
curl --location http://archive.cnx.org/extras/${UUID} > ${JSON_FILE}

# Find the URL for the latest version of the ZIP
ZIP_URL=$(cat ${JSON_FILE} | jq --raw-output '.downloads | map(select(.format == "Offline ZIP")) | .[0].path')
ZIP_URL="http://cnx.org${ZIP_URL}"


# Follow redirects and download the zip file
curl --location ${ZIP_URL} > ${ZIP_FILE}

# Clear the dir before unzipping (so it does not prompt)
rm -rf ${UUID_DIR}

# Unzip the file
unzip ${ZIP_FILE} -d ${UUID_DIR}

# The unzipped files are all in a dir named `col_*_complete`
COMPLETE_DIR=$(find ${UUID_DIR}/* | head -1)

# sh ${ROOT}/convert-collection.sh ${COMPLETE_DIR} ${REPO_PATH}
FOO=$(cd ${REPO_PATH} & git commit -m 'update book') # I wish I could specify the version here
# git push ${REPO_PATH}
