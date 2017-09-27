#!/bin/bash
set -e

build() {
    local var="$1"
    local stmt="$2"
    export $var+="$(printf "\n${stmt}")"
}

run() {
    echo "${!1}" | ${PREFIX}/bin/isql
}

createNewPassword() {
    # openssl generates random data.
        openssl </dev/null >/dev/null 2>/dev/null
    if [ $? -eq 0 ]
    then
        # We generate 40 random chars, strip any '/''s and get the first 20
        NewPasswd=`openssl rand -base64 40 | tr -d '/' | cut -c1-20`
    fi

        # If openssl is missing...
        if [ -z "$NewPasswd" ]
        then
                NewPasswd=`dd if=/dev/urandom bs=10 count=1 2>/dev/null | od -x | head -n 1 | tr -d ' ' | cut -c8-27`
        fi

        # On some systems even this routines may be missing. So if
        # the specific one isn't available then keep the original password.
    if [ -z "$NewPasswd" ]
    then
        NewPasswd="masterkey"
    fi

        echo "$NewPasswd"
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

file_env 'FIREBIRD_USER'
file_env 'FIREBIRD_PASSWORD'
file_env 'FIREBIRD_DATABASE'

build isql "set sql dialect 3;"
if [ ! -z "${FIREBIRD_DATABASE}" -a ! -f "${DBPATH}/${FIREBIRD_DATABASE}" ]; then
    if [ "${FIREBIRD_USER}" ];  then
        build isql "CONNECT employee USER '${ISC_USER}' PASSWORD '${ISC_PASSWORD}';"
        if [ -z "${FIREBIRD_PASSWORD}" ]; then
            FIREBIRD_PASSWORD=$(createNewPassword)
            echo "setting '${FIREBIRD_USER}' password to '${FIREBIRD_PASSWORD}'"
        fi
        build isql "CREATE USER ${FIREBIRD_USER} PASSWORD '${FIREBIRD_PASSWORD}';"
        build isql "COMMIT;"
    fi

    stmt="CREATE DATABASE '${DBPATH}/${FIREBIRD_DATABASE}'"
    if [ "${FIREBIRD_USER}" ];  then
        stmt+=" USER '${FIREBIRD_USER}' PASSWORD '${FIREBIRD_PASSWORD}'"
    fi
    stmt+=" DEFAULT CHARACTER SET UTF8;";
    build isql "${stmt}";
    build isql "COMMIT;"
    if [ "${isql}" ]; then
        build isql "QUIT;"
        run isql
    fi
fi

$@
