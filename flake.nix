{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils?rev=b1d9ab70662946ef0850d488da1c9019f3a9752a" ;
            nixpkgs.url = "github:NixOs/nixpkgs?rev=9afce28a1719e35c295fe8b379a491659acd9cd6" ;
        } ;
    outputs =
        { flake-utils , nixpkgs , self } :
            let
                fun =
                    system :
                        let
                            environment-variable = name : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString name ) "}" ] ;
                            lib =
                                {
                                    at ? "/run/wrappers/bin/at" ,
                                    cache ? { } ,
                                    cache-default-epoch ? 1 ,
                                    cache-directory ? "/tmp" ,
                                    cache-epoch-hash ? "cc3be3d5e123a64b31bd74e9d3e3a4e13337ad02c5d3b622af5094688f9255b773448e911a4bf1fb156e2a05ea599108f96ac0e056cbb27d489d6f9cc4c2324a" ,
                                    cache-instantiation-exit ? 64 ,
                                    cache-instantiation-message ? "We were unable to instantiate." ,
                                    cache-lock-exit ? 64 ,
                                    cache-lock-message ? "We were unable to lock the cache." ,
                                    cache-timestamp ? "bc4815fbc3b8c18f56ba1fa1cc22105f1ce4dfc8e29acd3140b0483976ab4980a559a487c3de5d23c24fd48b60f1a6531572af4a4da5349131a75ec49217d661" ,
                                    invalid-script-throw ?  value : "b01a14bb7131a8e7bd216e451e4203a123c0b8df5e15dbf52ab6aea134f9eebc33572e663103bf60fcdb71ea6761d8bcb2cc6f8a9170165b5023138f05d1b172:  ${ builtins.typeOf value }" ,
                                    invalid-temporary-throw ? value : "5a675ed32421e1ca7f99ad18413cc5ae2b4bde11700e6f0cf77e326c1af9767cc27a87ecb806979701239425790efeb06bc3e3e65d501fdc799a0a685ecf4ad2:  ${ builtins.typeOf value }" ,
                                    lock ? "/tmp/tmp.JnWlkWVHzR.lock" ,
                                    out ? "e07240d0b9209443a0219b9486f9c4e1fbbc3a3f58875105789ea8210f114bbf2c4d420efff457da21738b8cd00c5ae2c0935fc17ca575260d51d0903797f82d" ,
                                    secondary ? { } ,
                                    scripts ? secondary : { } ,
                                    target ? "e4608844be8ee356014f54c180b70cce7b8f1c34d9b73a8f3d9f516135ef5b889f9bd2ca55f4d1d66d3b81ed58f2c90a5e7ff082fa3c704339c0772ead4c644a" ,
                                    temporary ? { } ,
                                    temporary-init-error-code ? 64 ,
                                    temporary-init-error-message ? "We were unable to complete initiation:  ${ environment-variable "BROKEN" }." ,
                                    temporary-resource-directory ? "${ pkgs.coreutils }/bin/mktemp --directory -t XXXXXXXX.resource" ,
                                    temporary-broken-directory ? "${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.broken"
                                } :
                                    pkgs.stdenv.mkDerivation
                                        {
                                            name = "implementation" ;
                                            src = ./. ;
                                            nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                            installPhase =
                                                let
                                                    has-standard-input =
                                                        strip
                                                            ''
                                                                [ -t 0 ] || [[ "$( ${ pkgs.coreutils }/bin/readlink /proc/self/fd/0 )" == pipe:* ]]
                                                            '' ;
                                                    mappers =
                                                        let
                                                            cache =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then
                                                                        let
                                                                            cache =
                                                                                ''
                                                                                    export ${ cache-timestamp }=${ environment-variable "${ cache-timestamp }:=$( ${ pkgs.coreutils }/bin/date +%s )" } &&
                                                                                        EPOCH_TIMESTAMP=$( ${ pkgs.coreutils }/bin/date --date @$(( ( ${ environment-variable cache-timestamp } / ${ temporary.epoch } ) * ${ temporary.epoch } )) +%s ) &&
                                                                                        PARENT_HASH=${ environment-variable cache-epoch-hash } &&
                                                                                        if ${ has-standard-input }
                                                                                        then
                                                                                            HAS_STANDARD_INPUT=true &&
                                                                                                STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee )
                                                                                        else
                                                                                            HAS_STANDARD_INPUT=false &&
                                                                                                STANDARD_INPUT=""
                                                                                        fi &&
                                                                                        ENCODED_ARGUMENTS=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } | ${ pkgs.coreutils }/bin/base64 ) &&
                                                                                        ENCODED_STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ pkgs.coreutils }/bin/base64 ) &&
                                                                                        export ${ cache-epoch-hash }=$( ${ pkgs.coreutils }/bin/echo "${ constant-hash } ${ environment-variable "EPOCH_TIMESTAMP" } ${ environment-variable "@" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } $( ${ pkgs.coreutils }/bin/whoami )" | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                        exec 3> ${ cache-directory }/${ environment-variable cache-epoch-hash }.lock &&
                                                                                        if ${ pkgs.flock }/bin/flock 3
                                                                                        then
                                                                                           if [ -d ${ cache-directory }/${ environment-variable cache-epoch-hash } ]
                                                                                            then
                                                                                                if [ ! -z ${ environment-variable "PARENT_HASH" } ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/ln --symbolic ${ cache-directory }/${ environment-variable "PARENT_HASH" } ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PARENT_HASH" }.hash
                                                                                                fi &&
                                                                                                GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PPID" } ) &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "PPID" } > ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PPID" }.pid &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "GRANDPARENT_PID" } > ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "GRANDPARENT_PID" }.pid &&
                                                                                                    ${ pkgs.coreutils }/bin/cat ${ cache-directory }/${ environment-variable cache-epoch-hash }/link
                                                                                            else
                                                                                                WORK_DIR=$( ${ pkgs.coreutils }/bin/mktemp --directory ) &&
                                                                                                    ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "WORK_DIR" }/flag &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ pkgs.writeShellScript "init" init } ${ environment-variable "ENCODED_ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "ENCODED_STANDARD_INPUT" } ${ environment-variable cache-epoch-hash } ${ environment-variable "WORK_DIR" } | ${ at } now > /dev/null 2>&1 &&
                                                                                                    while [ ! -f ${ environment-variable "WORK_DIR" }/flag/flag ]
                                                                                                    do
                                                                                                        ${ pkgs.coreutils }/bin/sleep 0
                                                                                                    done &&
                                                                                                    # ${ pkgs.inotify-tools }/bin/inotifywait --event create ${ environment-variable "WORK_DIR" }/flag/ &&
                                                                                                    if [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIR" }/status )" == 0 ]
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/mv ${ environment-variable "WORK_DIR" } ${ cache-directory }/${ environment-variable cache-epoch-hash } &&
                                                                                                        if [ ! -z "${ environment-variable "PARENT_HASH" }" ]
                                                                                                        then
                                                                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ cache-directory }/${ environment-variable "PARENT_HASH" } ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PARENT_HASH" }.hash
                                                                                                        fi &&
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "PPID" } > ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PPID" }.pid &&
                                                                                                        GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PPID" } ) &&
                                                                                                        ${ pkgs.coreutils }/bin/cat ${ cache-directory }/${ environment-variable cache-epoch-hash }/link
                                                                                                    else
                                                                                                        ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIR" }/link &&
                                                                                                            ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable "WORK_DIR" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo "${ cache-instantiation-message }" >&2 &&
                                                                                                            exit ${ builtins.toString cache-instantiation-exit }
                                                                                                    fi
                                                                                            fi
                                                                                        else
                                                                                            ${ pkgs.coreutils }/bin/echo ${ cache-directory }/${ environment-variable cache-epoch-hash }/link &&
                                                                                                ${ pkgs.coreutils }/bin/echo "${ cache-lock-message }" >&2 &&
                                                                                                exit ${ builtins.toString cache-lock-exit }
                                                                                        fi &&
                                                                                        ${ pkgs.flock }/bin/flock -u 3
                                                                                        ${ pkgs.coreutils }/bin/rm ${ cache-directory }/${ environment-variable cache-epoch-hash }.lock
                                                                                '' ;
                                                                            constant-hash = builtins.hashString "sha512" ( builtins.concatStringsSep ";" ( builtins.concatLists [ path [ name ( builtins.toString temporary.temporary ) ( builtins.toString temporary.epoch ) ] ] ) ) ;
                                                                            init =
                                                                                ''
                                                                                    ENCODED_ARGUMENTS=${ environment-variable 1 } &&
                                                                                        HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                        ENCODED_STANDARD_INPUT=${ environment-variable 3 } &&
                                                                                        export ${ cache-epoch-hash }=${ environment-variable 4 } &&
                                                                                        WORK_DIR=${ environment-variable 5 } &&
                                                                                        ARGUMENTS=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable "ENCODED_ARGUMENTS" } | ${ pkgs.coreutils }/bin/base64 --decode ) &&
                                                                                        STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable "ENCODED_STANDARD_INPUT" } | ${ pkgs.coreutils }/bin/base64 --decode ) &&
                                                                                        ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "invalidate" invalidate } ${ environment-variable "WORK_DIR" }/invalidate &&
                                                                                        if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                        then
                                                                                            if ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ temporary.temporary } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "WORK_DIR" }/link
                                                                                            then
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "WORK_DIR" }/status
                                                                                            else
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "WORK_DIR" }/status
                                                                                            fi
                                                                                        else
                                                                                            if ${ temporary.temporary } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "WORK_DIR" }/link
                                                                                            then
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "WORK_DIR" }/status
                                                                                            else
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "WORK_DIR" }/status
                                                                                            fi
                                                                                        fi &&
                                                                                        ${ pkgs.coreutils }/bin/touch ${ environment-variable "WORK_DIR" }/flag/flag &&
                                                                                        while [ -f ${ environment-variable "WORK_DIR" }/flag/flag ]
                                                                                        do
                                                                                            ${ pkgs.coreutils }/bin/sleep 0s
                                                                                        done &&
                                                                                        while [ ! -e ${ cache-directory }/${ environment-variable cache-epoch-hash }/invalidate ]
                                                                                        do
                                                                                            ${ pkgs.coreutils }/bin/sleep 0s
                                                                                        done &&
                                                                                        # ${ pkgs.inotify-tools }/bin/inotifywait --event delete ${ cache-directory }/${ environment-variable cache-epoch-hash }/flag/flag --timeout $(( temporary.epoch - $( ${ pkgs.coreutils }/bin/date +%s ) % temporary.epoch )) &&
                                                                                        if [ -x ${ cache-directory }/${ environment-variable cache-epoch-hash }/invalidate ]
                                                                                        then
                                                                                            ${ cache-directory }/${ environment-variable cache-epoch-hash }/invalidate
                                                                                        fi
                                                                                '' ;
                                                                            invalidate =
                                                                                ''
                                                                                    export ${ cache-epoch-hash }=$( ${ pkgs.coreutils }/bin/basename $( ${ pkgs.coreutils }/bin/dirname ${ environment-variable 0 } ) ) &&
                                                                                        exec 3> ${ cache-directory }/${ environment-variable cache-epoch-hash }.lock &&
                                                                                        ${ pkgs.flock }/bin/flock 3 &&
                                                                                        ${ pkgs.coreutils }/bin/rm ${ cache-directory }/${ environment-variable cache-epoch-hash }/flag/flag &&
                                                                                        INVALIDATION_DIR=$( ${ pkgs.coreutils }/bin/mktemp --dry-run ) &&
                                                                                        ${ pkgs.coreutils }/bin/mv ${ cache-directory }/${ environment-variable cache-epoch-hash } ${ environment-variable "INVALIDATION_DIR" } &&
                                                                                        # WHY THE FUCK DOES NOT THE BELOW WORK?
                                                                                        # ${ pkgs.coreutils }/bin/rm ${ cache-directory }/${ environment-variable cache-epoch-hash }.lock &&
                                                                                        ${ pkgs.flock }/bin/flock -u 3 &&
                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "INVALIDATION_DIR" } -mindepth 1 -type f -name "*.pid" | while read PID_FILE
                                                                                        do
                                                                                            PID=$( ${ pkgs.coreutils }/bin/basename ${ environment-variable "PID_FILE%.*" } ) &&
                                                                                                ${ pkgs.coreutils }/bin/tail --follow /dev/null --pid ${ environment-variable "PID" } &&
                                                                                                ${ pkgs.coreutils }/bin/rm ${ environment-variable "PID_FILE" }
                                                                                        done &&
                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "INVALIDATION_DIR" } -mindepth 1 -type l -name "*.hash" -exec ${ pkgs.coreutils }/bin/readlink {} \; | while read HASH_LINK
                                                                                        do
                                                                                            if [ -d ${ environment-variable "HASH_LINK" } ] && [ -x ${ environment-variable "HASH_LINK" }/invalidate ]
                                                                                            then
                                                                                                ${ environment-variable "HASH_LINK" }/invalidate
                                                                                            fi &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/rm ${ environment-variable "HASH_LINK" }
                                                                                        done &&
                                                                                        ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable "INVALIDATION_DIR" }
                                                                                '' ;
                                                                            temporary =
                                                                                let
                                                                                    identity =
                                                                                        {
                                                                                            epoch ? builtins.null ,
                                                                                            temporary ,
                                                                                        } :
                                                                                            {
                                                                                                epoch = builtins.toString ( if builtins.typeOf epoch == "null" then cache-default-epoch else epoch ) ;
                                                                                                temporary = temporary ;
                                                                                            } ;
                                                                                    in identity ( value tertiary.temporary ) ;
                                                                            in pkgs.writeShellScript name cache
                                                                    else builtins.mapAttrs ( cache ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                            script =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then
                                                                        strip
                                                                            ''
                                                                                write_it ${ pkgs.writeShellScript name ( value secondary tertiary ) } ${ builtins.concatStringsSep "/" path } "${ name }"
                                                                            ''
                                                                    else if builtins.typeOf value == "set" then  builtins.mapAttrs ( script ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                    else builtins.throw ( invalid-script-throw value ) ;
                                                            temporary =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then
                                                                        let
                                                                            init =
                                                                                let
                                                                                    init =
                                                                                        if builtins.typeOf temporary.init == "null" then
                                                                                            {
                                                                                                does-not-have-standard-input = "STATUS=0" ;
                                                                                                has-standard-input = "STATUS=0" ;
                                                                                            }
                                                                                        else
                                                                                            {
                                                                                                does-not-have-standard-input =
                                                                                                    ''
                                                                                                        if ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                                        then
                                                                                                            STATUS=${ environment-variable "?" } &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                        else
                                                                                                            STATUS=${ environment-variable "?" } &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                        fi
                                                                                                    '' ;
                                                                                                has-standard-input =
                                                                                                    ''
                                                                                                        if ${ pkgs.coreutils }/bin/tee | ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                                        then
                                                                                                            STATUS=${ environment-variable "?" } &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                        else
                                                                                                            STATUS=${ environment-variable "?" } &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                        fi
                                                                                                    '' ;
                                                                                            } ;
                                                                                    invalidate =
                                                                                        {
                                                                                            does-not-have-standard-input = "${ environment-variable "RESOURCE" } ${ environment-variable "PPID" }" ;
                                                                                            has-standard-input = "${ environment-variable "RESOURCE" } $( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PPID" } )" ;
                                                                                        } ;
                                                                                    in
                                                                                        ''
                                                                                            RESOURCE=$( ${ temporary-resource-directory } ) &&
                                                                                                export ${ target }=${ environment-variable "RESOURCE" }/target &&
                                                                                                if ${ has-standard-input }
                                                                                                then
                                                                                                    ${ strip init.has-standard-input } &&
                                                                                                        INVALIDATE="${ invalidate.has-standard-input }"
                                                                                                else
                                                                                                    ${ strip init.does-not-have-standard-input } &&
                                                                                                        INVALIDATE="${ invalidate.does-not-have-standard-input }"
                                                                                                fi &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "INVALIDATE" } > ${ environment-variable "RESOURCE" }/invalidate.sh &&
                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/invalidate.sh &&
                                                                                                if [ ${ environment-variable "STATUS" } == 0 ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ pkgs.bash }/bin/bash -c ${ environment-variable "RESOURCE" }/invalidate.sh | ${ at } now > /dev/null 2>&1 &&
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                else
                                                                                                    BROKEN=$( ${ temporary-broken-directory } ) &&
                                                                                                        ${ pkgs.coreutils }/bin/mv ${ environment-variable "RESOURCE" } ${ environment-variable "BROKEN" } &&
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "BROKEN" }/target &&
                                                                                                        ${ pkgs.coreutils }/bin/echo "${ builtins.toString temporary-init-error-message }" >&2 &&
                                                                                                        exit ${ builtins.toString temporary-init-error-code }
                                                                                                fi
                                                                                        '' ;
                                                                            release =
                                                                                let
                                                                                    release =
                                                                                        {
                                                                                            null =
                                                                                                ''
                                                                                                    ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable "RESOURCE" }
                                                                                                '' ;
                                                                                            set =
                                                                                                ''
                                                                                                    if ${ pkgs.writeShellScript "release" temporary.release } > ${ environment-variable "RESOURCE" }/release.out.log 2> ${ environment-variable "RESOURCE" }/release.err.log
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable "RESOURCE" }
                                                                                                    else
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/release.status.asc &&
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/release.out.log ${ environment-variable "RESOURCE" }/release.err.log ${ environment-variable "RESOURCE" }/release.status.asc &&
                                                                                                            ${ pkgs.coreutils }/bin/mv ${ environment-variable "RESOURCE" } $( ${ temporary-broken-directory } )
                                                                                                    fi
                                                                                                '' ;
                                                                                        } ;
                                                                                    in
                                                                                        ''
                                                                                            RESOURCE=${ environment-variable 1 } &&
                                                                                                PID=${ environment-variable 2 } &&
                                                                                                if [ -f ${ environment-variable "RESOURCE" }/init.out.log ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log
                                                                                                fi &&
                                                                                                if [ -f ${ environment-variable "RESOURCE" }/init.err.log ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.err.log
                                                                                                fi &&
                                                                                                if [ -f ${ environment-variable "RESOURCE" }/init.status.asc ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                fi &&
                                                                                                ${ pkgs.coreutils }/bin/tail --follow /dev/null --pid ${ environment-variable "PID" } &&
                                                                                                export ${ target }=${ environment-variable "RESOURCE" }/target &&
                                                                                                ${ if builtins.typeOf temporary.release == "null" then release.null else release.set }
                                                                                        '' ;
                                                                            temporary =
                                                                                let
                                                                                    identity =
                                                                                        {
                                                                                            init ? builtins.null ,
                                                                                            release ? builtins.null
                                                                                        } :
                                                                                            {
                                                                                                init = init ;
                                                                                                release = release ;
                                                                                            } ;
                                                                                    in identity ( value tertiary.scripts ) ;
                                                                            in
                                                                                strip
                                                                                    ''
                                                                                        write_it ${ pkgs.writeShellScript name init } ${ builtins.concatStringsSep "/" path } "${ name }"
                                                                                    ''
                                                                else if builtins.typeOf value == "set" then builtins.mapAttrs ( temporary ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                else builtins.throw ( invalid-temporary-throw value ) ;
                                                            in
                                                                {
                                                                    cache = cache [ ( environment-variable out ) "cache" ] ;
                                                                    script = script [ ( environment-variable out ) "scripts" ] ;
                                                                    temporary = temporary [ ( environment-variable out ) "temporary" ] ;
                                                                } ;
                                                    strip =
                                                        string :
                                                            let
                                                                first = builtins.substring 0 1 string ;
                                                                head = builtins.substring 0 ( length - 1 ) string ;
                                                                last = builtins.substring ( length - 1 ) 1 string ;
                                                                length = builtins.stringLength string ;
                                                                tail = builtins.substring 1 ( length - 1 ) string ;
                                                                whitespace = [ " " "\t" "\n" "\r" "\f" ] ;
                                                                in
                                                                    if length == 0 then string
                                                                    else if builtins.any ( w : w == first ) whitespace then strip tail
                                                                    else if builtins.any ( w : w == last ) whitespace then strip head
                                                                    else string ;
                                                    tertiary =
                                                        let
                                                            mapper =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then builtins.concatStringsSep "/" ( builtins.concatLists [ path [ name ] ])
                                                                    else builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                            in
                                                                {
                                                                    cache = builtins.mapAttrs ( mapper [ ( environment-variable out ) "cache" ] ) cache ;
                                                                    environment-variable = environment-variable ;
                                                                    has-standard-input = has-standard-input ;
                                                                    scripts = builtins.mapAttrs ( mapper [ ( environment-variable out ) "scripts" ] ) scripts ;
                                                                    target = target ;
                                                                    temporary = builtins.mapAttrs ( mapper [ ( environment-variable out ) "temporary" ] ) temporary ;
                                                                    strip = strip ;
                                                                } ;
                                                    write =
                                                        let
                                                            input =
                                                                {
                                                                    "${ environment-variable out }" =
                                                                        {
                                                                            scripts = builtins.mapAttrs mappers.script scripts ;
                                                                            temporary = builtins.mapAttrs mappers.temporary temporary ;
                                                                        } ;
                                                                } ;
                                                            list = builtins.concatLists ( builtins.attrValues output ) ;
                                                            mapper = name : value : if builtins.typeOf value == "set" then builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs mapper value ) ) else [ ( builtins.toString value ) ] ;
                                                            output = builtins.mapAttrs mapper input ;
                                                            in builtins.concatStringsSep "&&\n" list ;
                                                    in
                                                        ''
                                                            ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                export ${ out }=$out &&
                                                                write_it ( )
                                                                    {
                                                                        ${ pkgs.coreutils }/bin/mkdir --parents ${ environment-variable 2 } &&
                                                                             ${ pkgs.coreutils }/bin/ln --symbolic ${ environment-variable 1 } ${ environment-variable 2 }/${ environment-variable 3 }.sh &&
                                                                             makeWrapper ${ environment-variable 2 }/${ environment-variable 3 }.sh ${ environment-variable 2 }/${ environment-variable 3 } --set ${ out } $out
                                                                    } &&
                                                                ${ write }
                                                        '' ;
                                        } ;
                            pkgs = import nixpkgs { system = system ; } ;
                            in
                                {
                                    checks =
                                        {
                                            simple =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        name = "checks" ;
                                                        src = ./. ;
                                                        buildCommand =
                                                            let
                                                                log-file = "/build/cp9FGgb4.confirm" ;
                                                                resources =
                                                                    lib
                                                                        {
                                                                            at =
                                                                                pkgs.writeShellScript
                                                                                    "at"
                                                                                    ''
                                                                                        ${ pkgs.coreutils }/bin/tee &
                                                                                    '' ;
                                                                            cache =
                                                                                {
                                                                                    evictor = temporary : { temporary = temporary.evictor ; cache = 2 ; } ;
                                                                                } ;
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            scripts =
                                                                                {
                                                                                    test=
                                                                                        { pkgs , ... } : { environment-variable , scripts , temporary , ... } :
                                                                                            let
                                                                                                null-file = "/build/BEuZydrN.confirm" ;
                                                                                                in
                                                                                                ''
                                                                                                    util_mktemp ( )
                                                                                                        {
                                                                                                            ${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.verification
                                                                                                        }
                                                                                                        para_script ( )
                                                                                                            {
                                                                                                                SCRIPT=${ environment-variable 1 } &&
                                                                                                                    HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                    STATUS_CODE=${ environment-variable 3 } &&
                                                                                                                    EXPECTED=${ environment-variable 4 } &&
                                                                                                                    ARGUMENTS=${ environment-variable 5 } &&
                                                                                                                    STANDARD_INPUT=${ environment-variable 6 } &&
                                                                                                                    EXPECTED_STANDARD_OUTPUT=${ environment-variable 7 } &&
                                                                                                                    EXPECTED_STANDARD_ERROR=${ environment-variable 8 } &&
                                                                                                                    LOG_FILE=${ log-file } &&
                                                                                                                    STANDARD_OUTPUT_FILE=$( util_mktemp ) &&
                                                                                                                    STANDARD_ERROR_FILE=$( util_mktemp ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo > ${ environment-variable "LOG_FILE" } &&
                                                                                                                    if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                    then
                                                                                                                        assert_status_code ${ environment-variable "STATUS_CODE" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "STANDARD_OUTPUT_FILE" } 2> ${ environment-variable "STANDARD_ERROR_FILE" }"
                                                                                                                    elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                    then
                                                                                                                        assert_status_code ${ environment-variable "STATUS_CODE" } "${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "STANDARD_OUTPUT_FILE" } 2> ${ environment-variable "STANDARD_ERROR_FILE" }"
                                                                                                                    else
                                                                                                                        fail "We did not expect HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" }"
                                                                                                                    fi &&
                                                                                                                    assert_equals ${ environment-variable "EXPECTED" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "LOG_FILE" } ) "We expect the log file to match exactly." &&
                                                                                                                    assert_equals ${ environment-variable "EXPECTED_STANDARD_OUTPUT" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_OUTPUT_FILE" } ) "We expect the standard output to match exactly." &&
                                                                                                                    assert_equals ${ environment-variable "EXPECTED_STANDARD_ERROR" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_ERROR_FILE" } ) "We expect the standard error to match exactly."
                                                                                                            } &&
                                                                                                        para_temporary_mult ( )
                                                                                                            {
                                                                                                                TEMPORARY=${ environment-variable 1 } &&
                                                                                                                    HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                    ARGUMENTS=${ environment-variable 3 } &&
                                                                                                                    STANDARD_INPUT=${ environment-variable 4 } &&
                                                                                                                    EXPECTED_STATUS=${ environment-variable 5 } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo > ${ environment-variable "LOG_FILE" } &&
                                                                                                                    if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                    then
                                                                                                                        OBSERVED_1=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_2=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" )
                                                                                                                    elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                    then
                                                                                                                        OBSERVED_1=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_2=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" )
                                                                                                                    else
                                                                                                                        fail "We did not expect HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" }"
                                                                                                                    fi &&
                                                                                                                    assert_not_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_2" } "We should be generating new unique values each time."
                                                                                                            } &&
                                                                                                        para_temporary_order ( )
                                                                                                            {
                                                                                                                TEMPORARY=${ environment-variable 1 } &&
                                                                                                                    HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                    ARGUMENTS=${ environment-variable 3 } &&
                                                                                                                    STANDARD_INPUT=${ environment-variable 4 } &&
                                                                                                                    EXPECTED_STATUS=${ environment-variable 5 } &&
                                                                                                                    EXPECTED=${ environment-variable 6 } &&
                                                                                                                    LOG_FILE=${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo > ${ environment-variable "LOG_FILE" } &&
                                                                                                                    if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                    then
                                                                                                                        assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1"
                                                                                                                    elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                    then
                                                                                                                        assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1"
                                                                                                                    else
                                                                                                                        fail "We did not expect HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" }"
                                                                                                                    fi &&
                                                                                                                    if [ -z "${ environment-variable "EXPECTED" }" ]
                                                                                                                    then
                                                                                                                        assert_equals "${ environment-variable "EXPECTED" }" "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "LOG_FILE" } )" "We expect the log file."
                                                                                                                    else
                                                                                                                        assert_equals ${ environment-variable "EXPECTED" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "LOG_FILE" } ) "We expect the log file."
                                                                                                                    fi
                                                                                                            }  &&
                                                                                                        para_cache_mult ( )
                                                                                                            {
                                                                                                                CACHE=${ environment-variable 1 } &&
                                                                                                                    HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                    ARGUMENTS=${ environment-variable 3 } &&
                                                                                                                    STANDARD_INPUT=${ environment-variable 4 } &&
                                                                                                                    EXPECTED_STATUS=${ environment-variable 5 } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo > ${ environment-variable "LOG_FILE" } &&
                                                                                                                    if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                    then
                                                                                                                        OBSERVED_1=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_2=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_3=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" }_PRIME > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_4=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" }_PRIME | ${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_5=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" }_PRIME > /dev/null 2>&1" ) &&
                                                                                                                            assert_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_2" } "If we repeatedly call the cache with the same then we should get the same." &&
                                                                                                                            assert_not_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_3" } "If we change the arguments then repeated calls to the cache should return different." &&
                                                                                                                            assert_not_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_4" } "If we change the input then repeated calls to the cache should return differnt." &&
                                                                                                                            assert_not_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_5" } "If we change both the arguments and inputs then repeated calls to the cache should return different."
                                                                                                                    elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                    then
                                                                                                                        OBSERVED_1=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_2=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1" ) &&
                                                                                                                            OBSERVED_3=$( assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" }_PRIME > /dev/null 2>&1" ) &&
                                                                                                                            assert_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_2" } "If we repeatedly call the cache with the same then we should get the same." &&
                                                                                                                            assert_not_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_3" } "If we change the arguments then repeated calls to the cache should return different."
                                                                                                                    else
                                                                                                                        fail "We did not expect HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" }"
                                                                                                                    fi &&
                                                                                                                    assert_not_equals ${ environment-variable "OBSERVED_1" } ${ environment-variable "OBSERVED_2" } "We should be generating new unique values each time."
                                                                                                            } &&
                                                                                                        para_cache_order ( )
                                                                                                            {
                                                                                                                CACHE=${ environment-variable 1 } &&
                                                                                                                    HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                    ARGUMENTS=${ environment-variable 3 } &&
                                                                                                                    STANDARD_INPUT=${ environment-variable 4 } &&
                                                                                                                    EXPECTED_STATUS=${ environment-variable 5 } &&
                                                                                                                    LOG_FILE=${ environment-variable 6 } &&
                                                                                                                    EXPECTED=${ environment-variable 7 } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo > ${ environment-variable "LOG_FILE" } &&
                                                                                                                    if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                    then
                                                                                                                        assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/bash -c \"${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1\""
                                                                                                                    elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                    then
                                                                                                                        assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.coreutils }/bin/bash -c \"${ environment-variable "CACHE" } ${ environment-variable "ARGUMENTS" } > /dev/null 2>&1\""
                                                                                                                    else
                                                                                                                        fail "We did not expect HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" }"
                                                                                                                    fi &&
                                                                                                                    if [ -z "${ environment-variable "EXPECTED" }" ]
                                                                                                                    then
                                                                                                                        assert_equals "${ environment-variable "EXPECTED" }" "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "LOG_FILE" } )" "We expect the log file."
                                                                                                                    else
                                                                                                                        assert_equals ${ environment-variable "EXPECTED" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "LOG_FILE" } ) "We expect the log file."
                                                                                                                    fi
                                                                                                            }  &&
                                                                                                        X_test_script ( )
                                                                                                            {
                                                                                                                 para_script ${ scripts.verification.script.script.bad } true 71 bvq_qyr_izw_yfp_lmc_vft_tsp_fsk_ izw vft nqt yun &&
                                                                                                                    para_script ${ scripts.verification.script.script.bad } false 71 bvq_qyr_jue_yfp_yzr_fsk_ jue djz nqt yun &&
                                                                                                                    para_script ${ scripts.verification.script.script.good } true 0 miv_nma_aff_zgm_ytw_knj_eod_kjo_ aff knj itp nbg &&
                                                                                                                    para_script ${ scripts.verification.script.script.good } false 0 miv_nma_gkw_zgm_jmu_kjo_ gkw hdd itp nbg
                                                                                                             } &&
                                                                                                        x_test_temporary ( )
                                                                                                            {
                                                                                                                para_script ${ scripts.verification.temporary.init.bad } true 72 rtw_rlc_txc_hgb_wmp_smf_bww_zpp_ txc smf epz vdl &&
                                                                                                                    para_script ${ scripts.verification.temporary.init.bad } false 72 rtw_rlc_txc_hgb_xtn_zpp_ txc smf epz vdl &&
                                                                                                                    para_script ${ scripts.verification.temporary.init.good } true 0 zvu_nvv_txc_eyg_doe_smf_baj_xne_ txc smf zus qki &&
                                                                                                                    para_script ${ scripts.verification.temporary.init.good } false 0 zvu_nvv_txc_eyg_nrq_xne_ txc smf zus qki &&
                                                                                                                    para_script ${ scripts.verification.temporary.release.bad } true 73 aue_mmx_txc_vpr_gei_smf_orm_mck_ txc smf uoz jtg &&
                                                                                                                    para_script ${ scripts.verification.temporary.release.bad } false 73 aue_mmx_txc_vpr_toa_mck_ txc smf uoz jtg &&
                                                                                                                    para_script ${ scripts.verification.temporary.release.good } true 0 eiz_nos_txc_sae_keb_smf_yho_hex_ txc smf eec jxv &&
                                                                                                                    para_script ${ scripts.verification.temporary.release.good } false 0 eiz_nos_txc_sae_lql_hex_ txc smf eec jxv &&
                                                                                                                    para_temporary_mult ${ temporary.bad.bad } true txc smf 90 &&
                                                                                                                    para_temporary_order ${ temporary.bad.bad } true txc smf 90 rtw_rlc_txc_hgb_wmp_smf_bww_zpp_
                                                                                                                    para_temporary_order ${ temporary.bad.bad } true txc smf 90 "" &&
                                                                                                                    para_temporary_mult ${ temporary.bad.bad } false txc smf 90 &&
                                                                                                                    para_temporary_order ${ temporary.bad.bad } false txc smf  90 rtw_rlc_txc_hgb_xtn_zpp_ &&
                                                                                                                    para_temporary_order ${ temporary.bad.bad } false txc smf 90 "" &&
                                                                                                                    para_temporary_mult ${ temporary.bad.good } true txc smf 90 &&
                                                                                                                    para_temporary_order ${ temporary.bad.good } true txc smf 90 rtw_rlc_txc_hgb_wmp_smf_bww_zpp_ &&
                                                                                                                    para_temporary_order ${ temporary.bad.good } true txc smf 90 "" &&
                                                                                                                    para_temporary_mult ${ temporary.bad.good } false txc smf 90 &&
                                                                                                                    para_temporary_order ${ temporary.bad.good } false txc smf  90 rtw_rlc_txc_hgb_xtn_zpp_ &&
                                                                                                                    para_temporary_order ${ temporary.bad.good } false txc smf 90 "" &&
                                                                                                                    para_temporary_mult ${ temporary.bad.null } true txc smf 90 &&
                                                                                                                    para_temporary_order ${ temporary.bad.null } true txc smf 90 rtw_rlc_txc_hgb_wmp_smf_bww_zpp_ &&
                                                                                                                    para_temporary_order ${ temporary.bad.null } true txc smf 90 ${ null-file } "" &&
                                                                                                                    para_temporary_mult ${ temporary.bad.null } false txc smf 90 &&
                                                                                                                    para_temporary_order ${ temporary.bad.null } false txc smf  90 rtw_rlc_txc_hgb_xtn_zpp_ &&
                                                                                                                    para_temporary_order ${ temporary.bad.null } false txc smf 90 ${ null-file } "" &&
                                                                                                                    para_temporary_mult ${ temporary.good.bad } true txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.good.bad } true txc smf 0 zvu_nvv_txc_eyg_doe_smf_baj_xne_
                                                                                                                    para_temporary_order ${ temporary.good.bad } true txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.good.bad } false txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.good.bad } false txc smf  0 zvu_nvv_txc_eyg_nrq_xne_ &&
                                                                                                                    para_temporary_order ${ temporary.good.bad } false txc smf 0 /build/Jh4pICL7.confirm "" &&
                                                                                                                    para_temporary_mult ${ temporary.good.good } true txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.good.good } true txc smf 0 zvu_nvv_txc_eyg_doe_smf_baj_xne_ &&
                                                                                                                    para_temporary_order ${ temporary.good.good } true txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.good.good } false txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.good.good } false txc smf  0 zvu_nvv_txc_eyg_nrq_xne_ &&
                                                                                                                    para_temporary_order ${ temporary.good.good } false txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.good.null } true txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.good.null } true txc smf 0 zvu_nvv_txc_eyg_doe_smf_baj_xne_ &&
                                                                                                                    para_temporary_order ${ temporary.good.null } true txc smf 0 ${ null-file } "" &&
                                                                                                                    para_temporary_mult ${ temporary.good.null } false txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.good.null } false txc smf  0 zvu_nvv_txc_eyg_nrq_xne_ &&
                                                                                                                    para_temporary_order ${ temporary.good.null } false txc smf 0 ${ null-file } "" &&
                                                                                                                    para_temporary_mult ${ temporary.null.bad } true txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.null.bad } true txc smf 0 "" &&
                                                                                                                    para_temporary_order ${ temporary.null.bad } true txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.null.bad } false txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.null.bad } false txc smf  0 ""  &&
                                                                                                                    para_temporary_order ${ temporary.null.bad } false txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.null.good } true txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.null.good } true txc smf 0 ""  &&
                                                                                                                    para_temporary_order ${ temporary.null.good } true txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.null.good } false txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.null.good } false txc smf  0 ""  &&
                                                                                                                    para_temporary_order ${ temporary.null.good } false txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.null.null } true txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.null.null } true txc smf 0 ""  &&
                                                                                                                    para_temporary_order ${ temporary.null.null } true txc smf 0 "" &&
                                                                                                                    para_temporary_mult ${ temporary.null.null } false txc smf 0 &&
                                                                                                                    para_temporary_order ${ temporary.null.null } false txc smf  0 ""  &&
                                                                                                                    para_temporary_order ${ temporary.null.null } false txc smf 0 ""
                                                                                                            } &&
                                                                                                        x_test_cache ( )
                                                                                                            {
                                                                                                                para_script ${ scripts.verification.temporary.init.evictor } true 0 cqt_dqu_txc_cyn_zop_smf_aec_uni_ txc smf dcs bae &&
                                                                                                                    para_script ${ scripts.verification.temporary.release.evictor } true 0 kcc_lkp_txc_wfj_grl_smf_qsc_zso_ txc smf frd iqw &&
                                                                                                                    para_temporary_mult ${ temporary.evictor } true dcs bae 0 &&
                                                                                                                    para_temporary_order ${ temporary.evictor } true dcs bae 0 cqt_dqu_dcs_cyn_zop_bae_aec_uni_ &&
                                                                                                                    para_temporary_order ${ temporary.evictor } true dcs bae 0 "" &&
                                                                                                                    para_script ${ scripts.verification.temporary.init.evictor } false 0 cqt_dqu_txc_cyn_otb_uni_ txc smf dcs bae &&
                                                                                                                    para_script ${ scripts.verification.temporary.release.evictor } false 0 kcc_lkp_txc_wfj_vpy_zso_ txc smf frd iqw &&
                                                                                                                    para_temporary_mult ${ temporary.evictor } false dcs bae 0 &&
                                                                                                                    para_temporary_order ${ temporary.evictor } false dcs bae 0 cqt_dqu_dcs_cyn_otb_uni_  &&
                                                                                                                    para_temporary_order ${ temporary.evictor } false dcs bae 0 ""
                                                                                                            }
                                                                                                '' ;
                                                                                    verification =
                                                                                        let
                                                                                            evictor =
                                                                                                 {
                                                                                                    status-code ,
                                                                                                    log-begin ,
                                                                                                    log-end ,
                                                                                                    log-no ,
                                                                                                    arguments-begin ,
                                                                                                    arguments-end ,
                                                                                                    arguments-no ,
                                                                                                    standard-input-begin ,
                                                                                                    standard-input-end ,
                                                                                                    standard-input-no ,
                                                                                                    standard-output ,
                                                                                                    standard-error
                                                                                                } : { pkgs , ... } : { cache , environment-variable , has-standard-input , scripts , strip , target , temporary } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo -n ${ log-begin }_ >> ${ log-file } &&
                                                                                                            if [ -z "${ environment-variable "@" }" ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ arguments-no }_ >> ${ log-file }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ arguments-begin }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "@" }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ arguments-end }_ >> ${ log-file }
                                                                                                            fi &&
                                                                                                            if ${ has-standard-input }
                                                                                                            then
                                                                                                                STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ standard-input-begin }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "STANDARD_INPUT" }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ standard-input-end }_ >> ${ log-file }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ standard-input-no }_ >> ${ log-file }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ standard-output } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ standard-error } >&2 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo -n ${ log-end }_ >> ${ log-file } &&
                                                                                                            exit ${ builtins.toString status-code }
                                                                                                    '' ;
                                                                                            script =
                                                                                                 {
                                                                                                    status-code ,
                                                                                                    log-begin ,
                                                                                                    log-end ,
                                                                                                    log-no ,
                                                                                                    arguments-begin ,
                                                                                                    arguments-end ,
                                                                                                    arguments-no ,
                                                                                                    standard-input-begin ,
                                                                                                    standard-input-end ,
                                                                                                    standard-input-no ,
                                                                                                    standard-output ,
                                                                                                    standard-error ,
                                                                                                    target-file
                                                                                                } : { pkgs , ... } : { cache , environment-variable , has-standard-input , scripts , strip , target , temporary } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo -n ${ log-begin }_ >> ${ log-file } &&
                                                                                                            if [ -z "${ environment-variable "@" }" ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ arguments-no }_ >> ${ log-file }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ arguments-begin }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "@" }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ arguments-end }_ >> ${ log-file }
                                                                                                            fi &&
                                                                                                            if ${ has-standard-input }
                                                                                                            then
                                                                                                                STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ standard-input-begin }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "STANDARD_INPUT" }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ standard-input-end }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ cache.evictor } ${ environment-variable "ARGUMENTS" }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ standard-input-no }_ >> ${ log-file } &&
                                                                                                                    ${ cache.evictor } ${ environment-variable "ARGUMENTS" }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ target-file } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ standard-output } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ standard-error } >&2 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo -n ${ log-end }_ >> ${ log-file } &&
                                                                                                            exit ${ builtins.toString status-code }
                                                                                                    '' ;
                                                                                            in
                                                                                                {
                                                                                                    script =
                                                                                                        {
                                                                                                            script =
                                                                                                                {
                                                                                                                    bad =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                status-code = 71 ;
                                                                                                                                log-begin = "bvq" ;
                                                                                                                                log-end = "fsk" ;
                                                                                                                                log-no = "ses" ;
                                                                                                                                arguments-begin = "qyr" ;
                                                                                                                                arguments-end = "yfp" ;
                                                                                                                                arguments-no = "neb" ;
                                                                                                                                standard-input-begin = "lmc" ;
                                                                                                                                standard-input-end = "tsp" ;
                                                                                                                                standard-input-no = "yzr" ;
                                                                                                                                standard-output = "nqt" ;
                                                                                                                                standard-error = "yun" ;
                                                                                                                                target-file = "/build/Iw7j4sOr.confirm" ;
                                                                                                                            } ;
                                                                                                                    good =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "miv" ;
                                                                                                                                log-end = "kjo" ;
                                                                                                                                log-no = "uer" ;
                                                                                                                                arguments-begin = "nma" ;
                                                                                                                                arguments-end = "zgm" ;
                                                                                                                                arguments-no = "pjc" ;
                                                                                                                                standard-input-begin = "ytw" ;
                                                                                                                                standard-input-end = "eod" ;
                                                                                                                                standard-input-no = "jmu" ;
                                                                                                                                standard-output = "itp" ;
                                                                                                                                standard-error = "nbg" ;
                                                                                                                                target-file = "/build/Z8iexL0r.confirm" ;
                                                                                                                            } ;
                                                                                                                } ;
                                                                                                         } ;
                                                                                                    temporary =
                                                                                                        {
                                                                                                            init =
                                                                                                                {
                                                                                                                    bad =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                status-code = 72 ;
                                                                                                                                log-begin = "rtw" ;
                                                                                                                                log-end = "zpp" ;
                                                                                                                                log-no = "lce" ;
                                                                                                                                arguments-begin = "rlc" ;
                                                                                                                                arguments-end = "hgb" ;
                                                                                                                                arguments-no = "qnj" ;
                                                                                                                                standard-input-begin = "wmp" ;
                                                                                                                                standard-input-end = "bww" ;
                                                                                                                                standard-input-no = "xtn" ;
                                                                                                                                standard-output = "epz" ;
                                                                                                                                standard-error = "vdl" ;
                                                                                                                                target-file = "/build/m9WX7Bnd.confirm" ;
                                                                                                                            } ;
                                                                                                                    evictor =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "cqt" ;
                                                                                                                                log-end = "uni" ;
                                                                                                                                log-no = "ahh" ;
                                                                                                                                arguments-begin = "dqu" ;
                                                                                                                                arguments-end = "cyn" ;
                                                                                                                                arguments-no = "oaz" ;
                                                                                                                                standard-input-begin = "zop" ;
                                                                                                                                standard-input-end = "aec" ;
                                                                                                                                standard-input-no = "otb" ;
                                                                                                                                standard-output = "dcs" ;
                                                                                                                                standard-error = "bae" ;
                                                                                                                                target-file = "/build/lzgR2nlV.confirm" ;
                                                                                                                            } ;
                                                                                                                    good =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "zvu" ;
                                                                                                                                log-end = "xne" ;
                                                                                                                                log-no = "hkh" ;
                                                                                                                                arguments-begin = "nvv" ;
                                                                                                                                arguments-end = "eyg" ;
                                                                                                                                arguments-no = "srv" ;
                                                                                                                                standard-input-begin = "doe" ;
                                                                                                                                standard-input-end = "baj" ;
                                                                                                                                standard-input-no = "nrq" ;
                                                                                                                                standard-output = "zus" ;
                                                                                                                                standard-error = "qki" ;
                                                                                                                                target-file = "/build/ccNePxLX.confirm" ;
                                                                                                                            } ;
                                                                                                                } ;
                                                                                                            release =
                                                                                                                {
                                                                                                                    bad =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                status-code = 73 ;
                                                                                                                                log-begin = "aue" ;
                                                                                                                                log-end = "mck" ;
                                                                                                                                log-no = "uya" ;
                                                                                                                                arguments-begin = "mmx" ;
                                                                                                                                arguments-end = "vpr" ;
                                                                                                                                arguments-no = "xdj" ;
                                                                                                                                standard-input-begin = "gei" ;
                                                                                                                                standard-input-end = "orm" ;
                                                                                                                                standard-input-no = "toa" ;
                                                                                                                                standard-output = "uoz" ;
                                                                                                                                standard-error = "jtg" ;
                                                                                                                                target-file = "/build/iwl3MCIj.confirm" ;
                                                                                                                            } ;
                                                                                                                    evictor =
                                                                                                                        evictor
                                                                                                                            {
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "kcc" ;
                                                                                                                                log-end = "zso" ;
                                                                                                                                log-no = "iaa" ;
                                                                                                                                arguments-begin = "lkp" ;
                                                                                                                                arguments-end = "wfj" ;
                                                                                                                                arguments-no = "dux" ;
                                                                                                                                standard-input-begin = "grl" ;
                                                                                                                                standard-input-end = "qsc" ;
                                                                                                                                standard-input-no = "vpy" ;
                                                                                                                                standard-output = "frd" ;
                                                                                                                                standard-error = "iqw" ;
                                                                                                                            } ;
                                                                                                                    good =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "eiz" ;
                                                                                                                                log-end = "hex" ;
                                                                                                                                log-no = "zgc" ;
                                                                                                                                arguments-begin = "nos" ;
                                                                                                                                arguments-end = "sae" ;
                                                                                                                                arguments-no = "gku" ;
                                                                                                                                standard-input-begin = "keb" ;
                                                                                                                                standard-input-end = "yho" ;
                                                                                                                                standard-input-no = "lql" ;
                                                                                                                                standard-output = "eec" ;
                                                                                                                                standard-error = "jxv" ;
                                                                                                                                target-file = "/build/SLLPZSO5.confirm" ;
                                                                                                                            } ;
                                                                                                                } ;
                                                                                                        } ;
                                                                                                } ;
                                                                                } ;
                                                                            temporary =
                                                                                {
                                                                                    bad =
                                                                                        {
                                                                                            bad = scripts : { init = scripts.verification.temporary.init.bad ; release = scripts.verification.temporary.release.bad ; } ;
                                                                                            good = scripts : { init = scripts.verification.temporary.init.bad ; release = scripts.verification.temporary.release.good ; } ;
                                                                                            null = scripts : { init = scripts.verification.temporary.init.bad ; } ;
                                                                                        } ;
                                                                                    good =
                                                                                        {
                                                                                            bad = scripts : { init = scripts.verification.temporary.init.good ; release = scripts.verification.temporary.release.bad ; } ;
                                                                                            good = scripts : { init = scripts.verification.temporary.init.good ; release = scripts.verification.temporary.release.good ; } ;
                                                                                            null = scripts : { init = scripts.verification.temporary.init.good ; } ;
                                                                                        } ;
                                                                                    evictor = scripts : { init = scripts.verification.temporary.init.evictor ; release = scripts.verification.temporary.release.evictor ; } ;
                                                                                    null =
                                                                                        {
                                                                                            bad = scripts : { release = scripts.verification.temporary.release.bad ; } ;
                                                                                            good = scripts : { release = scripts.verification.temporary.release.good ; } ;
                                                                                            null = scripts : { } ;
                                                                                        } ;
                                                                                } ;
                                                                            temporary-init-error-code = 90 ;
                                                                            temporary-init-error-message = "jsq" ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            export e07240d0b9209443a0219b9486f9c4e1fbbc3a3f58875105789ea8210f114bbf2c4d420efff457da21738b8cd00c5ae2c0935fc17ca575260d51d0903797f82d=${ resources } &&
                                                                            ${ pkgs.bash_unit }/bin/bash_unit ${ resources }/scripts/test.sh
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
