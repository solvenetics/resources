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
                                    secondary ? { } ,
                                    scripts ? secondary : { } ,
                                    target ? "e4608844be8ee356014f54c180b70cce7b8f1c34d9b73a8f3d9f516135ef5b889f9bd2ca55f4d1d66d3b81ed58f2c90a5e7ff082fa3c704339c0772ead4c644a" ,
                                    temporary ? { } ,
                                    temporary-init-error-code ? 64 ,
                                    temporary-init-error-message ? resource-directory : "We were unable to complete initiation:  ${ resource-directory }." ,
                                    temporary-resource-directory ? "${ pkgs.coreutils }/bin/mktemp --directory -t XXXXXXXX.resource" ,
                                    temporary-broken-directory ? "${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.broken"
                                } :
                                    let
                                        environment-variable = name : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString name ) "}" ] ;
                                        has-standard-input = ''[ -t 0 ] || [[ "$( ${ pkgs.coreutils }/bin/readlink /proc/self/fd/0 )" == pipe:* ]]'' ;
                                        outputs =
                                            {
                                                cache =
                                                    let
                                                        mapper =
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
                                                                                in identity ( value outputs.temporary ) ;
                                                                        in pkgs.writeShellScript name cache
                                                                else builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                        in builtins.mapAttrs ( mapper [ ] ) cache ;
                                                scripts =
                                                    let
                                                        mapper =
                                                            path : name : value :
                                                                if builtins.typeOf value == "lambda" then pkgs.writeShellScript name ( value ( secondary // { environment-variable = environment-variable ; has-standard-input = has-standard-input ; target = target ; } ) )
                                                                else if builtins.typeOf value == "set" then builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                else builtins.throw ( invalid-script-throw value ) ;
                                                        in builtins.mapAttrs ( mapper [ ] ) scripts ;
                                                temporary =
                                                    let
                                                        mapper =
                                                            path : name : value :
                                                                if builtins.typeOf value == "lambda" then
                                                                    let
                                                                        init =
                                                                            let
                                                                                init =
                                                                                    if builtins.typeOf temporary.init == "null" then
                                                                                        {
                                                                                            does-not-have-standard-input =
                                                                                                ''
${ pkgs.coreutils }/bin/echo AAAA 0003000 >> /build/AAAA.log &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PPID" } | ${ at } now > /dev/null 2>&1
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                '' ;
                                                                                            has-standard-input =
                                                                                                ''
${ pkgs.coreutils }/bin/echo AAAA 0004000 >> /build/AAAA.log &&
                                                                                                    GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PARENT_PID" } ) &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PPID" } | ${ at } now > /dev/null 2>&1 &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                '' ;
                                                                                        }
                                                                                    else
                                                                                        {
                                                                                            does-not-have-standard-input =
                                                                                                ''
                                                                                                    if [ "${ builtins.typeOf temporary.init }" == "null" ] || ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                                    then
                                                                                                        GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PPID" } ) &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
${ pkgs.coreutils }/bin/echo AAAA 0001000 >> /build/AAAA.log &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "$" } | ${ at } now > /dev/null 2>&1
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                    else
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
${ pkgs.coreutils }/bin/echo AAAA 0002000 >> /build/AAAA.log &&
                                                                                                            BROKEN=$( ${ temporary-broken-directory } ) &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ temporary-init-error-message "${ environment-variable "RESOURCE" }" } >&2 &&
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                            ${ pkgs.coreutils }/bin/mv ${ environment-variable "RESOURCE" } ${ environment-variable "BROKEN" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "BROKEN" }/target &&
                                                                                                            exit ${ builtins.toString temporary-init-error-code }
                                                                                                    fi
                                                                                                '' ;
                                                                                            has-standard-input =
                                                                                                ''
                                                                                                    if ${ pkgs.coreutils }/bin/tee | ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                            GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PARENT_PID" } ) &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PPID" } | ${ at } now > /dev/null 2>&1 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                    else
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                            BROKEN=$( ${ temporary-broken-directory } ) &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ temporary-init-error-message "${ environment-variable "RESOURCE" }" } >&2 &&
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                            ${ pkgs.coreutils }/bin/mv ${ environment-variable "RESOURCE" } ${ environment-variable "BROKEN" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "BROKEN" }/target &&
                                                                                                            exit ${ builtins.toString temporary-init-error-code }
                                                                                                    fi
                                                                                                '' ;
                                                                                        } ;
                                                                                in
                                                                                ''
                                                                                    RESOURCE=$( ${ temporary-resource-directory } ) &&
                                                                                        export ${ target }=${ environment-variable "RESOURCE" }/target &&
                                                                                        PARENT_PID=${ environment-variable "PPID" } &&
                                                                                        if ${ has-standard-input }
                                                                                        then
                                                                                            ${ init.has-standard-input }
                                                                                        else
                                                                                            ${ init.does-not-have-standard-input }
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
                                                                                in identity ( value outputs.scripts ) ;
                                                                        in pkgs.writeShellScript name init
                                                                else if builtins.typeOf value == "set" then builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                else builtins.throw ( invalid-temporary-throw value ) ;
                                                        in builtins.mapAttrs ( mapper [ ] ) temporary ;
                                            } ;
                                        in
                                            {
                                                cache = outputs.cache ;
                                                scripts = outputs.scripts ;
                                                temporary = outputs.temporary ;
                                            } ;
                            pkgs = import nixpkgs { system = system ; } ;
                            in
                                {
                                    checks =
                                        {
                                            simple =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        name = "simple" ;
                                                        src = ./. ;
                                                        buildCommand =
                                                            let
                                                                logging-file = "/build/ff842b2feb62d4758edff3eca36278968a16ad562f3a2ccaa0138aa6a5d24debb34d1e0d8abfa677dee6b6ab5044f6e1239dbefd8546c176231fcd3f82b5c15c.log" ;
                                                                resources =
                                                                    lib
                                                                        {
                                                                            at =
                                                                                pkgs.writeShellScript
                                                                                    "at"
                                                                                    ''
                                                                                        ${ pkgs.bash }/bin/bash -c "$( ${ pkgs.coreutils }/bin/tee )" > /dev/null 2>&1 &
                                                                                    '' ;
                                                                            cache =
                                                                                {
                                                                                    gamma-11 = temporary : { temporary = temporary.gamma-11 ; epoch = 4 ; } ;
                                                                                    gamma-12 = temporary : { temporary = temporary.gamma-12 ; epoch = 4 ; } ;
                                                                                    gamma-21 = temporary : { temporary = temporary.gamma-21 ; epoch = 4 ; } ;
                                                                                    gamma-22 = temporary : { temporary = temporary.gamma-22 ; epoch = 4 ; } ;
                                                                                    delta-1 = temporary : { temporary = temporary.delta ; epoch = 4 ; } ;
                                                                                    delta-2 = temporary : { temporary = temporary.delta ; epoch = 8 ; } ;
                                                                                } ;
                                                                            scripts =
                                                                                {
                                                                                    alpha =
                                                                                        { pkgs , environment-variable , has-standard-input , ... } :
                                                                                            ''
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } > ${ environment-variable "ARGUMENTS_TARGET" } &&
                                                                                                    if ${ has-standard-input }
                                                                                                    then
                                                                                                       ${ pkgs.coreutils }/bin/tee > ${ environment-variable "STANDARD_INPUT_TARGET" }
                                                                                                    fi &&
                                                                                                    exit ${ environment-variable "EXIT" }
                                                                                            '' ;
                                                                                    bash-unit =
                                                                                        { environment-variable , pkgs , ... } :
                                                                                            ''
                                                                                                util_log ( )
                                                                                                    {
                                                                                                        FILE=${ environment-variable 1 } &&
                                                                                                            if [ -f ${ environment-variable "FILE" } ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/cat ${ environment-variable "FILE" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/rm ${ environment-variable "FILE" }
                                                                                                        fi
                                                                                                    } &&
                                                                                                    util_wait_to ( )
                                                                                                        {
                                                                                                            OFFSET=${ environment-variable 1 } &&
                                                                                                                ${ pkgs.coreutils }/bin/sleep $(( 8 - ( $( ${ pkgs.coreutils }/bin/date +%s ) - ${ environment-variable "OFFSET" } ) % 8 ))s
                                                                                                        } &&
                                                                                                    fun_script ( )
                                                                                                        {
                                                                                                            SCRIPT=${ environment-variable 1 } &&
                                                                                                                ARGUMENTS=${ environment-variable 2 } &&
                                                                                                                HAS_STANDARD_INPUT=${ environment-variable 3 } &&
                                                                                                                STANDARD_INPUT=${ environment-variable 4 } &&
                                                                                                                EXPECTED_EXIT_STATUS_CODE=${ environment-variable 5 } &&
                                                                                                                LOG_FILE=${ environment-variable 6 } &&
                                                                                                                EXPECTED_LOG=${ environment-variable 7 } &&
                                                                                                                ARGUMENTS_FILE=${ environment-variable 8 } &&
                                                                                                                STANDARD_INPUT_FILE=${ environment-variable 9 } &&
                                                                                                                EXPECTED_STANDARD_OUTPUT=${ environment-variable 10 } &&
                                                                                                                STANDARD_OUTPUT_FILE=${ environment-variable 10 } &&
                                                                                                                EXPECTED_STANDARD_ERROR=${ environment-variable 11 } &&
                                                                                                                EXPECTED_ARGUMENTS=${ environment-variable "ARGUMENTS" } &&
                                                                                                                EXPECTED_STANDARD_INPUT="" &&
                                                                                                                if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                then
                                                                                                                    EXPECTED_STANDARD_INPUT=${ environment-variable "STANDARD_INPUT" } &&
                                                                                                                        assert_status_code ${ environment-variable "EXPECTED_EXIT_STATUS_CODE" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" }"
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                then
                                                                                                                    EXPECTED_STANDARD_INPUT="" &&
                                                                                                                        assert_status_code ${ environment-variable "EXPECTED_EXIT_STATUS_CODE" } "${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" }"
                                                                                                                else
                                                                                                                    fail "We were expecting HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" } to be either true or false."
                                                                                                                fi &&
                                                                                                                assert_equals ${ environment-variable "EXPECTED_LOG" } $( util_log ${ environment-variable "LOG_FILE" } ) "We expect the log to match exactly." &&
                                                                                                                assert_equals ${ environment-variable "EXPECTED_ARGUMENTS" } $( util_log ${ environment-variable "ARGUMENTS_FILE" } ) "We expected the arguments to match exactly." &&
                                                                                                                assert_equals "${ environment-variable "EXPECTED_STANDARD_INPUT" }" "$( util_log ${ environment-variable "STANDARD_INPUT_FILE" } )" "We expected the standard input to match exactly."
                                                                                                        } &&
                                                                                                    test_script ( )
                                                                                                        {
                                                                                                            fun_script ${ resources.scripts.verification.scripts.bad } tssleqyw true iumlndhx 74 /build/S4yZ0wvb.confirm pzwrrzvp_tumitvjy_tssleqyw_iuimpsqg_iuxydcak_iumlndhx_hlnrbtjm_wdplvhdq_ /build/UoD7FSCq.confirm /build/DHaDXwfZ.confirm mthtinsu /build/C4nWimZf.confirm
                                                                                                                fun_script ${ resources.scripts.verification.scripts.bad } czqvmwkc false kfgrzohq 74 /build/S4yZ0wvb.confirm  pzwrrzvp_tumitvjy_czqvmwkc_iuimpsqg_dsyfzfsc_wdplvhdq_ /build/UoD7FSCq.confirm /build/DHaDXwfZ.confirm mthtinsu /build/C4nWimZf.confirm
                                                                                                                # fun_script ${ resources.scripts.verification.scripts.bad } toxdnmgb true vurlynvs 74 /build/S4yZ0wvb.confirm pzwrrzvp_tumitvjy_tssleqyw_iuimpsqg_iuxydcak_iumlndhx_hlnrbtjm_wdplvhdq_ /build/UoD7FSCq.confirm /build/DHaDXwfZ.confirm mthtinsu /build/C4nWimZf.confirm
                                                                                                                # fun_script ${ resources.scripts.verification.scripts.bad } suuvnemy false gyzouqxh 74 /build/S4yZ0wvb.confirm  pzwrrzvp_tumitvjy_czqvmwkc_iuimpsqg_dsyfzfsc_wdplvhdq_ /build/UoD7FSCq.confirm /build/DHaDXwfZ.confirm mthtinsu /build/C4nWimZf.confirm &&
                                                                                                                ${ pkgs.coreutils }/bin/true
                                                                                                        }
                                                                                            '' ;
                                                                                    init =
                                                                                        {
                                                                                            beta =
                                                                                                let
                                                                                                    beta =
                                                                                                        { environment-variable , has-standard-input , pkgs , target , ... } : exit :
                                                                                                            ''
                                                                                                                ${ pkgs.coreutils }/bin/touch ${ environment-variable target } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } > ${ environment-variable "INIT_ARGUMENTS" } &&
                                                                                                                    if ${ has-standard-input }
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/tee > ${ environment-variable "INIT_STDIN" }
                                                                                                                    fi &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24 &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo 193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952 >&2 &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ environment-variable "INIT_TARGET" } &&
                                                                                                                    exit ${ builtins.toString exit }
                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = primary : beta primary 64 ;
                                                                                                            good = primary : beta primary 0 ;
                                                                                                        } ;
                                                                                            gamma =
                                                                                                let
                                                                                                    gamma =
                                                                                                        { environment-variable , has-standard-input , pkgs , target , ... } : exit :
                                                                                                            ''
                                                                                                                ${ pkgs.coreutils }/bin/echo -n jz_ >> ${ logging-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ environment-variable 1 }_ >> ${ logging-file } &&
                                                                                                                    if ${ has-standard-input }
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/echo -n yr_ >> ${ logging-file } &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo -n $( ${ pkgs.coreutils }/bin/tee )_ >> ${ logging-file }
                                                                                                                    else
                                                                                                                        ${ pkgs.coreutils }/bin/echo -n zg_ >> ${ logging-file }
                                                                                                                    fi &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ra_ >> ${ logging-file } &&
                                                                                                                    exit ${ builtins.toString exit }
                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = primary : gamma primary 64 ;
                                                                                                            good = primary : gamma primary 0 ;
                                                                                                        } ;
                                                                                            delta =
                                                                                                { environment-variable , has-standard-input , pkgs , target , ... } :
                                                                                                    ''
                                                                                                        GAMMA=${ environment-variable 1 } &&
                                                                                                            ARGUMENTS=${ environment-variable 2 } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo THIS IS THE GAMMA USED BY DELTA. &&
                                                                                                            ${ pkgs.coreutils }/bin/echo -n ki_ > ${ logging-file } &&
                                                                                                            if ${ has-standard-input }
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo -n pt_ >> ${ logging-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/tee | ${ environment-variable "GAMMA" } ${ environment-variable "ARGUMENTS" } &&
                                                                                                                     ${ pkgs.coreutils }/bin/echo -n wc_ >> ${ logging-file }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo -n fl_ >> ${ logging-file } &&
                                                                                                                    ${ environment-variable "GAMMA" } ${ environment-variable "ARGUMENTS" }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo -n mu_ >> ${ logging-file }
                                                                                                    '' ;
                                                                                        } ;
                                                                                    release =
                                                                                        {
                                                                                            beta =
                                                                                                let
                                                                                                    beta =
                                                                                                        { pkgs , environment-variable , has-standard-input , target , ... } : exit :
                                                                                                            ''
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ environment-variable "RELEASE_TARGET" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } > ${ environment-variable "RELEASE_ARGUMENTS" } &&
                                                                                                                    if ${ has-standard-input }
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/tee > ${ environment-variable "RELEASE_STDIN" }
                                                                                                                    fi &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo a92513f231769b19b4529ae89634bfb1593de9a55751805c1ed2a657ae45cde5773de852162d54c82559611d4ce49e58c17a93e2d5c042924832122b5e9985a4 &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo 52b1688f54a45391114a3ddcda15b6ac1845b0ec2abc4499aa45fb3b55d472441891a2b044c29df64531d4ca8260c2411deeb92bf2fc256fed055c214c5f99e3 >&2 &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ environment-variable "RELEASE_TARGET" } &&
                                                                                                                    exit ${ builtins.toString exit }
                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = primary : beta primary 64 ;
                                                                                                            good = primary : beta primary 0 ;
                                                                                                        } ;
                                                                                            gamma =
                                                                                                let
                                                                                                    gamma =
                                                                                                        { environment-variable , has-standard-input , pkgs , target , ... } : exit :
                                                                                                            ''
                                                                                                                ${ pkgs.coreutils }/bin/echo -n hc_ >> ${ logging-file } &&
                                                                                                                    exit ${ builtins.toString exit }
                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = primary : gamma primary 64 ;
                                                                                                            good = primary : gamma primary 0 ;
                                                                                                        } ;
                                                                                            delta =
                                                                                                { environment-variable , target , pkgs , ... } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo -n lt_ >> ${ logging-file }
                                                                                                    '' ;
                                                                                        } ;
                                                                                    verification =
                                                                                        let
                                                                                            script =
                                                                                                {
                                                                                                    begin-log-script ,
                                                                                                    log-file ,
                                                                                                    end-log-script ,
                                                                                                    begin-log-arguments ,
                                                                                                    end-log-arguments ,
                                                                                                    no-arguments ,
                                                                                                    arguments-file ,
                                                                                                    begin-log-standard-input ,
                                                                                                    end-log-standard-input ,
                                                                                                    no-standard-input ,
                                                                                                    standard-input-file ,
                                                                                                    standard-output ,
                                                                                                    standard-output-file ,
                                                                                                    standard-error ,
                                                                                                    standard-error-file ,
                                                                                                    target-file ,
                                                                                                    exit-status-code
                                                                                                } :
                                                                                                    { environment-variable , has-standard-input , pkgs , target , ... } :
                                                                                                        ''
                                                                                                            ARGUMENTS=${ environment-variable 1 } &&
                                                                                                                logit ( )
                                                                                                                    {
                                                                                                                        MESSAGE=${ environment-variable 1 } &&
                                                                                                                            FILE=${ environment-variable 2 } &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "MESSAGE" }_ >> ${ environment-variable "FILE" }
                                                                                                                    } &&
                                                                                                                logit ${ begin-log-script } ${ log-file } &&
                                                                                                                if [ -z "${ environment-variable "ARGUMENTS" }" ]
                                                                                                                then
                                                                                                                    logit ${ no-arguments } ${ log-file }
                                                                                                                else
                                                                                                                    logit ${ begin-log-arguments } ${ log-file } &&
                                                                                                                        logit ${ environment-variable "ARGUMENTS" } ${ log-file } &&
                                                                                                                        logit ${ end-log-arguments } ${ log-file } &&
                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "ARGUMENTS" } > ${ arguments-file }
                                                                                                                fi &&
                                                                                                                if ${ has-standard-input }
                                                                                                                then
                                                                                                                    STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                                                        logit ${ begin-log-standard-input } ${ log-file } &&
                                                                                                                        logit ${ environment-variable "STANDARD_INPUT" } ${ log-file } &&
                                                                                                                        logit ${ end-log-standard-input } ${ log-file } &&
                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } > ${ standard-input-file }
                                                                                                                else
                                                                                                                    logit ${ no-standard-input } ${ log-file }
                                                                                                                fi &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ target } > ${ target-file } &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ standard-output } &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ standard-error } >&2 &&
                                                                                                                logit ${ end-log-script } ${ log-file } &&
                                                                                                                exit ${ builtins.toString exit-status-code }
                                                                                                        '' ;
                                                                                            in
                                                                                                {
                                                                                                    scripts =
                                                                                                        {
                                                                                                            bad =
                                                                                                                script
                                                                                                                    {
                                                                                                                        begin-log-script = "pzwrrzvp" ;
                                                                                                                        log-file = "/build/S4yZ0wvb.confirm" ;
                                                                                                                        end-log-script = "wdplvhdq" ;
                                                                                                                        begin-log-arguments = "tumitvjy" ;
                                                                                                                        end-log-arguments = "iuimpsqg" ;
                                                                                                                        no-arguments = "wefgmhtg";
                                                                                                                        arguments-file = "/build/UoD7FSCq.confirm" ;
                                                                                                                        begin-log-standard-input = "iuxydcak" ;
                                                                                                                        end-log-standard-input = "hlnrbtjm" ;
                                                                                                                        no-standard-input = "dsyfzfsc" ;
                                                                                                                        standard-input-file = "/build/DHaDXwfZ.confirm" ;
                                                                                                                        standard-output = "mthtinsu" ;
                                                                                                                        standard-output-file = "/build/C4nWimZf.confirm" ;
                                                                                                                        standard-error = "ttcohcae" ;
                                                                                                                        standard-error-file = "/build/uTNOaaPb.confirm" ;
                                                                                                                        target-file = "/build/qSsy5Gng.confirm" ;
                                                                                                                        exit-status-code = 74 ;
                                                                                                                    } ;
                                                                                                            good =
                                                                                                                script
                                                                                                                    {
                                                                                                                        begin-log-script = "uyeerczx" ;
                                                                                                                        log-file = "/build/90yunhW8.confirm" ;
                                                                                                                        end-log-script = "iginbiht" ;
                                                                                                                        begin-log-arguments = "igxjfodr" ;
                                                                                                                        end-log-arguments = "ldpocylq" ;
                                                                                                                        no-arguments = "lxhzrnbg";
                                                                                                                        arguments-file = "/build/AZYAwIw8.confirm" ;
                                                                                                                        begin-log-standard-input = "qwzihijk" ;
                                                                                                                        end-log-standard-input = "ohoqaabj" ;
                                                                                                                        no-standard-input = "xeuvdlzy" ;
                                                                                                                        standard-input-file = "/build/RueRnD4g.confirm" ;
                                                                                                                        standard-output = "sftexuus" ;
                                                                                                                        standard-output-file = "/build/pbMvmgH2.confirm" ;
                                                                                                                        standard-error = "iacdzgje" ;
                                                                                                                        standard-error-file = "/build/oYCx7Boe.confirm" ;
                                                                                                                        target-file = "dhsjbbmd" ;
                                                                                                                        exit-status-code = 0 ;
                                                                                                                    } ;
                                                                                                        } ;
                                                                                                } ;
                                                                                } ;
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            temporary =
                                                                                {
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            ${ pkgs.bash_unit }/bin/bash_unit ${ resources.scripts.bash-unit }
                                                                     '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
