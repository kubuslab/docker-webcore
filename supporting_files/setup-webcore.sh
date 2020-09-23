#!/bin/bash
VERSION=0.0.1.1
ACTION=$1
PACKAGE_BASE=kubuslab/webcore-php:dev-master
PHP_BASE=https://gitlab.com/kubuslab/webcore-php.git
REPO_BASE=https://gitlab.com/kubuslab/webcore2-base.git
THEME_RES=https://gitlab.com/webcore/res-clipone.git
LOGDIR=/var/log/webcore
PRIVDIR=/webcore/private/files/
PUBDIR=/webcore/public/files/
shift

function read_input() {
    local teks=$1 scan=
    while [ -z "$scan" ]; do
        read -p "$teks" scan
    done
    echo $scan
}

function check_git() {
    if [ -z "$ACTION" -o "$ACTION" == "init" ]; then
        git config --global credential.helper store
        return
    fi

    local name=$(git config --global user.name)
    #local email=$(git config --global user.email)
    if [ -z "$name" ]; then
        echo "  -> Setup Git Account [GitLab].."
        name=$(read_input "Username GitLab: ")
        email=$(read_input "Email GitLab: ")

        git config --global user.name $name
        git config --global user.email $email
        git config --global credential.helper store
    fi
}

function webcore_init() {
    if [ "$ACTION" == "update-lib" ]; then
        rm -f /app/lib/.installed
    elif [ "$ACTION" == "reset" ]; then
        echo "Reset Semua Apps.."
        echo "  -> Hapus Library WebCore.."
        rm -rf /app/lib
        #for p in $(cat /app/lib/.projects 2>/dev/null); do
            ## PERINGATAN!:
            ## JANGAN LAKUKAN INI, BAHAYA!! MODULES YANG BELUM DISIMPAN BISA TERHAPUS 
            #echo "  -> Hapus project $p.."
            #rm -rf /app/$p
        #done
        echo "..OK"
        return
    elif [ -f /app/lib/.installed ]; then
        return
    fi

    if [ -d /app/lib/webcore-php ]; then
        cd /app/lib/webcore-php
        echo "Update Library WebCore..."
        git pull
        echo "..OK"
    else
        check_git

        echo "  -> Setup Environment.."
        # siapkan folder lib
        mkdir -p /app/lib/webcore-php
        cd /app/lib/webcore-php

        # download extension webcore.so
        git clone $PHP_BASE .

        # perbaiki file 92-webcore.ini
        sed -i 's/;;extension/extension/g' /etc/php/7.4/cli/conf.d/92-webcore.ini
        sed -i 's/;;extension/extension/g' /etc/php/7.4/apache2/conf.d/92-webcore.ini

        # buat directory logging
        mkdir -p $LOGDIR
        chown -R www-data:staff $LOGDIR

        # buat directory untuk file private
        mkdir -p $PRIVDIR
        chown -R www-data:staff $PRIVDIR

        # buat directory untuk file public
        mkdir -p $PUBDIR
        chown -R www-data:staff $PUBDIR

        # setup timezone
        cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    fi

    touch /app/lib/.installed
}

function webcore_project() {
    local nama=$1 aksi=$2 aksi2=$3 update=0 all=0
    local basedir=/app/$nama

    if [ -z "$nama" ]; then
        echo -e "Nama project harus disebutkan\n"
        echo -e "USAGE:\n    webcorecli project <nama-project>\n"
        exit
    fi

    if [ -d $basedir ]; then
        if [ "$aksi" == "update" ]; then
            update=1
            [ "$aksi2" == "all" ] && all=1
        elif [ -z "$aksi" ]; then
            echo "Periksa project $nama ... OK"
            return
        else
            update=2
        fi
    fi

    echo "Memuat project $nama di $basedir ..."
    if [ $update -eq 1 ]; then
        cd $basedir
        git pull

        echo "  -> Update paket library utama.."
        composer update $PACKAGE_BASE

        echo "  -> Update config 127.0.0.1 .."
        local confdir=$basedir/application/config/domains/127.0.0.1
        cd $confdir
        git pull

        echo "  -> Update theme default.."
        cd $basedir/resources
        git pull

        if [ $all -eq 1 ]; then
            for t in $(cat /app/lib/.themes 2>/dev/null); do
                echo "  -> Update theme $t .."
                webcore_theme $nama $t
            done
        fi
    elif [ $update -eq 0 ]; then
        mkdir -p $basedir
        cd $basedir
        git clone $REPO_BASE .

        echo "  -> Siapkan paket library utama.."
        composer require $PACKAGE_BASE

        echo "  -> Siapkan resource theme default.."
        mkdir -p $basedir/resources
        cd $basedir/resources
        git clone $THEME_RES .

        echo "  -> Siapkan directory log di $LOGDIR/$nama .."
        mkdir -p $LOGDIR/$nama
        chown -R www-data:staff $LOGDIR/$nama

        echo $project >> /app/lib/.projects
    fi

    #mkdir -p application/config/domains/localhost
    
    echo "..OK"
}

function webcore_module() {
    local project=$1 module=$2 url=$3
    
    if [ -z "$module" ]; then
        echo -e "Nama module harus disebutkan\n"
        echo -e "USAGE:\n    webcorecli module <nama-project> <nama-module> <git-url-module>\n"
        exit
    elif [ -z "$url" ]; then
        echo -e "Git URL untuk module harus disebutkan\n"
        echo -e "USAGE:\n    webcorecli module <nama-project> <nama-module> <git-url-module>\n"
        exit
    fi

    webcore_project $project

    local moddir=/app/$project/modules/$module
    if [ -d $moddir ]; then
        echo "Project $project module $module ... OK"
        echo "  -> Update module $module.."
        cd $moddir
        git pull
    else
        if [ -z "$url" ]; then
            echo "URL repository module harus ditentukan"
            exit
        fi

        echo "Memuat module $module di project $project ..."
        mkdir -p $moddir
        cd $moddir

        git clone $url .

        echo $module >> /app/lib/.modules

        echo "..OK"
    fi
}

function webcore_theme() {
    local project=$1 theme=$2

    if [ -z "$theme" ]; then
        echo -e "Nama theme harus ditentukan\n"
        echo -e "USAGE:\n    webcorecli theme <nama-project> <nama-theme>\n"
        exit
    fi

    webcore_project $project

    local themedir=/app/$project/application/themes/$theme
    local resdir=/app/$project/resources/$theme
    if [ -d $themedir ]; then
        echo "Project $project Theme::Engine $theme ... OK"
        echo "  -> Update Theme::Engine $theme.."
        cd $themedir
        git pull
    else
        echo "Memuat Theme::Engine $theme di project $project ..."
        mkdir -p $themedir
        cd $themedir
        git clone https://gitlab.com/webcore/theme-$theme.git .
        echo "..OK"

        echo "************************************************************************"
        echo "* Segera buat/edit file application/config/domains/localhost/theme.php *"
        echo "* kemudian tambahkan pada awal-awal baris:                             *"
        echo "*                                                                      *"
        echo "*   include_once APPPATH . 'themes/$theme/$theme-theme.php';            "
        echo "*                                                                      *"
        echo "************************************************************************"
    fi

    if [ -d $resdir ]; then
        echo "Project $project Theme::Resources $theme ... OK"
        echo "  -> Update Theme::Resource $theme.."
        cd $resdir
        git pull
    else
        echo "Memuat Theme::Resources $theme di project $project ..."
        mkdir -p $resdir
        cd $resdir
        git clone https://gitlab.com/webcore/res-$theme.git .

        echo $theme >> /app/lib/.themes

        echo "..OK"
    fi
}

function webcore_config() {
    local project=$1
    
    webcore_project $project

    local domaindir=/app/$project/application/config/domains
    local confdir=$domaindir/127.0.0.1
    if [ -d $confdir ]; then
        echo "Project $project config untuk domain 127.0.0.1 ... OK"
        echo "  -> Update config .."
        cd $confdir
        git pull
    else
        echo "Memuat config untuk domain 127.0.0.1 di project $project ..."
        mkdir -p $confdir
        cd $confdir
        git clone https://gitlab.com/docker-setup/config-$project.git .
        echo "..OK"

        # pastikan git berhasil
        if [ "$(ls -A $confdir)" ]; then
            echo "  -> Backup config localhost dan buat symlink ke 127.0.0.1"
            mv -f $domaindir/localhost $domaindir/localhost.backup
            ln -sf $confdir $domaindir/localhost
            echo "..OK"
        else
            echo "  WARNING: config-$project tidak tersedia di Repository!!!"
        fi
    fi
}

function webcore_db() {
    local project=$1 db=$2 user=$3 pass=$4 file=$5
    
    if [ -z "$db" ]; then
        echo -e "Nama database harus ditentukan\n"
        echo -e "USAGE:\n    webcorecli db <nama-project> <nama-db> <username-db> <password-db> <file-sql-data>\n"
        exit
    elif [ -z "$user" ]; then
        echo -e "Username database harus ditentukan\n"
        echo -e "USAGE:\n    webcorecli db <nama-project> <nama-db> <username-db> <password-db> <file-sql-data>\n"
        exit
    elif [ -z "$pass" ]; then
        echo -e "Password database harus ditentukan\n"
        echo -e "USAGE:\n    webcorecli db <nama-project> <nama-db> <username-db> <password-db> <file-sql-data>\n"
        exit
    elif [ -z "$file" ]; then
        echo -e "File data awal sql harus ditentukan\n"
        echo -e "USAGE:\n    webcorecli db <nama-project> <nama-db> <username-db> <password-db> <file-sql-data>\n"
        exit
    fi

    webcore_project $project

    echo "Membuat database MySQL '${db}' dengan user '${user}' password ${pass} dari file ${file}"
    mysql -uroot -e "CREATE USER '${user}'@'%' IDENTIFIED BY  '${pass}'"
    mysql -uroot -e "GRANT USAGE ON *.* TO  '${user}'@'%' IDENTIFIED BY '${pass}'"
    mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${db}"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'%'"

    # import database
    mysql -uroot $db < $file
}

function webcore_help() {
    echo -e "WebCore Project CLI versi $VERSION\nUSAGE:\n  webcorecli <command> [options1 option2 ...]\n"
    echo -e "Options:\n    webcorecli project <nama-project>\n\tBuat project baru\n"
    echo -e "    webcorecli project <nama-project> update\n\tUpdate project tertentu\n"
    echo -e "    webcorecli project <nama-project> update all\n\tUpdate project tertentu beserta config dan themenya\n"
    echo -e "    webcorecli reset\n\tReset / hapus folder /app/lib\n"
    echo -e "    webcorecli config <nama-project>\n\tBuat atau update config di project tertentu\n"
    echo -e "    webcorecli db <nama-project> <nama-db> <username-db> <password-db> <file-sql-data>\n\tBuat database, user dan password untuk project menggunakan file sql\n"
    echo -e "    webcorecli theme <nama-project> <nama-theme>\n\tBuat atau update theme di project tertentu\n"
    echo -e "    webcorecli module <nama-project> <nama-module> <git-url-module>\n\tBuat atau update module di project tertentu menggunakan git-url\n"
    exit
}

webcore_init

case "$ACTION" in
    project)
        webcore_project "$@"
        ;;
    module)
        webcore_module "$@"
        ;;
    theme)
        webcore_theme "$@"
        ;;
    config)
        webcore_config "$@"
        ;;
    db)
        webcore_db "$@"
        ;;
    help)
        webcore_help
esac