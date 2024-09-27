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
                            has-standard-input =
                                 strip
                                     ''
                                         [ -t 0 ] || [[ "$( ${ pkgs.coreutils }/bin/readlink /proc/self/fd/0 )" == pipe:* ]]
                                     '' ;
                            lib =
                                {
                                    at ? "/run/wrappers/bin/at" ,
                                    cache ? { } ,
                                    cache-default-closure ? builtins.false ,
                                    cache-default-epoch ? 1 ,
                                    cache-directory ? environment-variable "TMPDIR" ,
                                    cache-epoch-hash ? "cc3be3d5e123a64b31bd74e9d3e3a4e13337ad02c5d3b622af5094688f9255b773448e911a4bf1fb156e2a05ea599108f96ac0e056cbb27d489d6f9cc4c2324a" ,
                                    cache-init-error-code ? 64 ,
                                    cache-init-error-message ? "We were unable to instantiate:  ${ environment-variable "WORK_DIR" }" ,
                                    cache-lock-exit ? 64 ,
                                    cache-lock-message ? "We were unable to lock the cache." ,
                                    cache-sleep ? 2 , # This is a kludge.  inotifywait is better but I can not get that to work.  Instead we are polling files and sleeping this amount of time between polls.  The smaller this is the faster this is but at the same time using more resources.
                                    cache-timestamp ? "bc4815fbc3b8c18f56ba1fa1cc22105f1ce4dfc8e29acd3140b0483976ab4980a559a487c3de5d23c24fd48b60f1a6531572af4a4da5349131a75ec49217d661" ,
                                    cache-work-directory ? "${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.work" ,
                                    invalid-cache-throw ? value : "02bc1acea7eb0055c96f9f39d90f2c348666ddc2a4f3c72c148ea61da4ddfc3d06fc851eefcf6821ec0708328f81d5eccb13c730447de562c2f19bddc5c83135: ${ builtins.typeOf value }" ,
                                    invalid-script-throw ? value : "b01a14bb7131a8e7bd216e451e4203a123c0b8df5e15dbf52ab6aea134f9eebc33572e663103bf60fcdb71ea6761d8bcb2cc6f8a9170165b5023138f05d1b172:  ${ builtins.typeOf value }" ,
                                    invalid-temporary-throw ? value : "5a675ed32421e1ca7f99ad18413cc5ae2b4bde11700e6f0cf77e326c1af9767cc27a87ecb806979701239425790efeb06bc3e3e65d501fdc799a0a685ecf4ad2:  ${ builtins.typeOf value }" ,
                                    lock ? "/tmp/tmp.JnWlkWVHzR.lock" ,
                                    out ? "e07240d0b9209443a0219b9486f9c4e1fbbc3a3f58875105789ea8210f114bbf2c4d420efff457da21738b8cd00c5ae2c0935fc17ca575260d51d0903797f82d" ,
                                    resource ? "bf01d7a5dfd1ad0c7bd4a8ecba39063384d09898d821698c82691d8f28d9aa1067e4abeff96cf3641ab311d22cb5937b9429b6ca0c151d6365fbe0025c575f01" ,
                                    secondary ? { } ,
                                    scripts ? secondary : { } ,
                                    target ? "e4608844be8ee356014f54c180b70cce7b8f1c34d9b73a8f3d9f516135ef5b889f9bd2ca55f4d1d66d3b81ed58f2c90a5e7ff082fa3c704339c0772ead4c644a" ,
                                    temporary ? { } ,
                                    temporary-init-error-code ? 64 ,
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
                                                    paths =
                                                        let
                                                            mapper =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then builtins.concatStringsSep "/" ( builtins.concatLists [ path [ name ] ] )
                                                                    else builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                            in
                                                                {
                                                                    scripts = builtins.mapAttrs ( mapper [ ( environment-variable out ) "scripts" ] ) ( scripts ) ;
                                                                    temporary = builtins.mapAttrs ( mapper [ ( environment-variable out ) "temporary" ] ) temporary ;
                                                                } ;
                                                    mappers =
                                                        let
                                                            cache =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then
                                                                        let
                                                                            clear =
                                                                                ''
                                                                                    ${ cache-epoch-hash }=$( ${ pkgs.coreutils }/bin/basename $( ${ pkgs.coreutils }/bin/dirname ${ environment-variable 0 } ) ) &&
                                                                                        WORK_DIRECTORY=$( ${ cache-work-directory } ) &&
                                                                                        exec 200> ${ cache-directory }/${ environment-variable cache-epoch-hash }.lock &&
                                                                                        ${ pkgs.flock }/bin/flock 10 &&
                                                                                        ${ pkgs.coreutils }/bin/mv ${ cache-directory }/${ environment-variable cache-epoch-hash } ${ environment-variable "WORK_DIRECTORY" } &&
                                                                                        ${ pkgs.flock }/bin/flock -u 10 &&
                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "WORK_DIRECTORY" } -mindepth 1 -maxdepth 1 -type f -name "*.pid" | while read PID_FILE
                                                                                        do
                                                                                            PID=$( ${ pkgs.coreutils }/bin/basename ${ environment-variable "PID_FILE%.*" } ) &&
                                                                                                ${ pkgs.coreutils }/bin/tail --follow /dev/null --pid ${ environment-variable "PID" } &&
                                                                                                ${ pkgs.coreutils }/bin/rm ${ environment-variable "PID_FILE" }
                                                                                        done &&
                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "WORK_DIRECTORY" } -mindepth 1 -maxdepth 1 -type f -name "*.sh" | while read CACHE_FILE
                                                                                        do
                                                                                            ${ environment-variable "CACHE_FILE" } &&
                                                                                                ${ pkgs.coreutils }/bin/rm ${ environment-variable "CACHE_FILE" }
                                                                                        done &&
                                                                                        ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable "WORK_DIRECTORY" }
                                                                                '' ;
                                                                            hook =
                                                                                let
                                                                                    populate =
                                                                                        let
                                                                                            identity =
                                                                                                {
                                                                                                    closure ? cache-default-closure ,
                                                                                                    epoch ? cache-default-epoch ,
                                                                                                    temporary
                                                                                                } :
                                                                                                    {
                                                                                                        closure = closure ;
                                                                                                        temporary = temporary ;
                                                                                                        epoch = builtins.toString epoch ;
                                                                                                    } ;
                                                                                            in identity ( value paths.temporary ) ;
                                                                                    in
                                                                                        ''
                                                                                            export ${ cache-timestamp }=${ environment-variable "${ cache-timestamp }:=$( ${ pkgs.coreutils }/bin/date +%s )" } &&
                                                                                                ARGUMENTS=${ environment-variable "@" } &&
                                                                                                if ${ has-standard-input }
                                                                                                then
                                                                                                    HAS_STANDARD_INPUT=true &&
                                                                                                        STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee )
                                                                                                else
                                                                                                    HAS_STANDARD_INPUT=false &&
                                                                                                        STANDARD_INPUT=""
                                                                                                fi &&
                                                                                                PARENT_CACHE_EPOCH_HASH=${ environment-variable cache-epoch-hash } &&
                                                                                                export ${ cache-epoch-hash }=$( ${ pkgs.coreutils }/bin/echo -n $(( ${ environment-variable cache-timestamp } / ${ builtins.toString populate.epoch } )) ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } $( ${ pkgs.coreutils }/bin/whoami ) ${ builtins.hashString "sha512" ( builtins.concatStringsSep "" ( builtins.concatLists [ path ( builtins.map builtins.toString [ name populate.epoch populate.temporary ] ) ] ) ) } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                                exec 10> ${ cache-directory }/${ environment-variable cache-epoch-hash }.lock &&
                                                                                                if ${ pkgs.flock }/bin/flock 10
                                                                                                then
                                                                                                    if [ ! -d ${ cache-directory }/${ environment-variable cache-epoch-hash } ]
                                                                                                    then
                                                                                                        WORK_DIRECTORY=$( ${ cache-work-directory } ) &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "WORK_DIRECTORY" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "ARGUMENTS" } > ${ environment-variable "WORK_DIRECTORY" }/arguments &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "HAS_STANDARD_INPUT" } > ${ environment-variable "WORK_DIRECTORY" }/has-standard-input &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } > ${ environment-variable "WORK_DIRECTORY" }/standard-input &&
                                                                                                            ${ pkgs.coreutils }/bin/echo $(( ${ builtins.toString populate.epoch } + ${ builtins.toString populate.epoch } * ( ${ environment-variable cache-timestamp } / ${ builtins.toString populate.epoch } ) )) > ${ environment-variable "WORK_DIRECTORY" }/validity &&
                                                                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ populate.temporary } ${ environment-variable "WORK_DIRECTORY" }/temporary &&
                                                                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ cache-directory }/${ environment-variable cache-epoch-hash }/clear ${ environment-variable "WORK_DIRECTORY" }/link &&
                                                                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "clear" clear } ${ environment-variable "WORK_DIRECTORY" }/clear &&
                                                                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "manage" manage } ${ environment-variable "WORK_DIRECTORY" }/manage &&
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "WORK_DIRECTORY" }/arguments ${ environment-variable "WORK_DIRECTORY" }/has-standard-input ${ environment-variable "WORK_DIRECTORY" }/standard-input ${ environment-variable "WORK_DIRECTORY" }/validity &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "WORK_DIRECTORY" }/manage | ${ at } now &&
                                                                                                            while [ ! -f ${ environment-variable "WORK_DIRECTORY" }/flag ]
                                                                                                            do
                                                                                                                ${ pkgs.coreutils }/bin/sleep ${ builtins.toString cache-sleep }s
                                                                                                            done &&
                                                                                                            if [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIRECTORY" }/status ) == 0 ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/mv ${ environment-variable "WORK_DIRECTORY" } ${ cache-directory }/${ environment-variable cache-epoch-hash }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "WORK_DIRECTORY" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo "${ cache-init-error-message }" >&2 &&
                                                                                                                    exit ${ builtins.toString cache-init-error-code }
                                                                                                            fi
                                                                                                    fi &&
                                                                                                        if [ ! -z "${ environment-variable "PARENT_CACHE_EPOCH_HASH" }" ] && [ ! -e ${ cache-directory }/${ environment-variable cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PARENT_CACHE_EPOCH_HASH" }.sh ]
                                                                                                        then
                                                                                                           ${ pkgs.coreutils }/bin/ln --symbolic ${ cache-directory }/${ environment-variable "PARENT_CACHE_EPOCH_HASH" }/clear ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PARENT_CACHE_EPOCH_HASH" }.sh
                                                                                                        fi &&
                                                                                                        if [ ! -e ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PPID" }.pid ]
                                                                                                        then
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "PPID" } > ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PPID" }.pid &&
                                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ cache-directory }/${ environment-variable cache-epoch-hash }/${ environment-variable "PPID" }.pid
                                                                                                        fi
                                                                                                        ${ pkgs.coreutils }/bin/cat ${ cache-directory }/${ environment-variable cache-epoch-hash }/out
                                                                                                else
                                                                                                    ${ pkgs.coreutils }/bin/echo "${ cache-lock-message }" >&2 &&
                                                                                                        exit ${ builtins.toString cache-lock-exit }
                                                                                                fi
                                                                                        '' ;
                                                                            manage =
                                                                                ''
                                                                                    WORK_DIRECTORY=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable 0 } ) &&
                                                                                        ARGUMENTS=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIRECTORY" }/arguments ) &&
                                                                                        HAS_STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIRECTORY" }/has-standard-input ) &&
                                                                                        STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIRECTORY" }/standard-input ) &&
                                                                                        if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                        then
                                                                                            if ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "WORK_DIRECTORY" }/temporary ${ environment-variable "ARGUMENTS" } > ${ environment-variable "WORK_DIRECTORY" }/out 2> ${ environment-variable "WORK_DIRECTORY" }/err
                                                                                            then
                                                                                                STATUS=${ environment-variable "?" }
                                                                                            else
                                                                                                STATUS=${ environment-variable "?" }
                                                                                            fi
                                                                                        else
                                                                                            if ${ environment-variable "WORK_DIRECTORY" }/temporary ${ environment-variable "ARGUMENTS" } > ${ environment-variable "WORK_DIRECTORY" }/out 2> ${ environment-variable "WORK_DIRECTORY" }/err
                                                                                            then
                                                                                                STATUS=${ environment-variable "?" }
                                                                                            else
                                                                                                STATUS=${ environment-variable "?" }
                                                                                            fi
                                                                                        fi &&
                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable "WORK_DIRECTORY" }/status &&
                                                                                        ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "WORK_DIRECTORY" }/out ${ environment-variable "WORK_DIRECTORY" }/err ${ environment-variable "WORK_DIRECTORY" }/status &&
                                                                                        if [ ${ environment-variable "STATUS" } == 0 ]
                                                                                        then
                                                                                            SLEEP=$(( $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIRECTORY" }/validity ) - $( ${ pkgs.coreutils }/bin/date +%s ) ))
                                                                                        else
                                                                                            SLEEP=0
                                                                                        fi &&
                                                                                        CLEAR=$( ${ pkgs.coreutils }/bin/readlink ${ environment-variable "WORK_DIRECTORY" }/link ) &&
                                                                                        ${ pkgs.coreutils }/bin/touch ${ environment-variable "WORK_DIRECTORY" }/flag &&
                                                                                        ${ pkgs.coreutils }/bin/sleep ${ environment-variable "SLEEP" }s &&
                                                                                        if [ ${ environment-variable "STATUS" } == 0 ] && [ -x ${ environment-variable "CLEAR" } ]
                                                                                        then
                                                                                            ${ environment-variable "CLEAR" }
                                                                                        fi
                                                                                '' ;
                                                                            in
                                                                                strip
                                                                                    ''
                                                                                        write_it ${ pkgs.writeShellScript name hook } ${ builtins.concatStringsSep "/" path } "${ name }"
                                                                                    ''
                                                                    else if builtins.typeOf value == "set" then builtins.mapAttrs ( cache ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                    else builtins.throw ( invalid-cache-throw value ) ;
                                                            scripts =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then
                                                                        strip
                                                                            ''
                                                                                write_it ${ pkgs.writeShellScript name ( strip ( value secondary target ) ) } ${ builtins.concatStringsSep "/" path } "${ name }"
                                                                            ''
                                                                    else if builtins.typeOf value == "set" then  builtins.mapAttrs ( scripts ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                    else builtins.throw ( invalid-script-throw value ) ;
                                                            temporary =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then
                                                                        let
                                                                            init =
                                                                                let
                                                                                    clean =
                                                                                        let
                                                                                            wipe =
                                                                                                ''
                                                                                                    ${ pkgs.findutils }/bin/find ${ environment-variable resource } -mindepth 1 -maxdepth 1 -type f -name "*.pid" | while read PID_FILE
                                                                                                    do
                                                                                                        PID=${ environment-variable "PID_FILE%.*" } &&
                                                                                                             ${ pkgs.coreutils }/bin/tail --follow /dev/null --pid ${ environment-variable "PID" } &&
                                                                                                             ${ pkgs.coreutils }/bin/rm ${ environment-variable "PID_FILE" }
                                                                                                    done &&
                                                                                                            ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release }
                                                                                                '' ;
                                                                                            in
                                                                                                ''
                                                                                                    export ${ resource }=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable 0 } ) &&
                                                                                                        ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "wipe" wipe }
                                                                                                '' ;
                                                                                    prepare =
                                                                                        if builtins.typeOf temporary.init == "null" then
                                                                                            {
                                                                                                does-not-have-standard-input = "${ pkgs.coreutils }/bin/echo 0" ;
                                                                                                has-standard-input = "${ pkgs.coreutils }/bin/echo 0" ;
                                                                                            }
                                                                                        else
                                                                                            {
                                                                                                does-not-have-standard-input =
                                                                                                    ''
                                                                                                        ARGUMENTS=${ environment-variable "@" } &&
                                                                                                            ${ pkgs.coreutils }/bin/cat ${ temporary.init } > ${ environment-variable resource }/init.sh &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "ARGUMENTS" } > ${ environment-variable resource }/arguments.asc &&
                                                                                                            if ${ temporary.init } ${ environment-variable "ARGUMENTS" } > ${ environment-variable resource }/init.out.log 2> ${ environment-variable resource }/init.err.log
                                                                                                            then
                                                                                                                STATUS=${ environment-variable "?" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo 0
                                                                                                            else
                                                                                                                STATUS=${ environment-variable "?" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ builtins.toString temporary-init-error-code }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable resource }/init.status.asc
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable resource }/init.sh ${ environment-variable resource }/arguments.asc ${ environment-variable resource }/init.out.log ${ environment-variable resource }/init.err.log ${ environment-variable resource }/init.status.asc
                                                                                                    '' ;
                                                                                                has-standard-input =
                                                                                                    ''
                                                                                                        ARGUMENTS=${ environment-variable "@" } &&
                                                                                                            STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                                            ${ pkgs.coreutils }/bin/cat ${ temporary.init } > ${ environment-variable resource }/init.sh &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "ARGUMENTS" } > ${ environment-variable resource }/arguments.asc &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } > ${ environment-variable resource }/standard-input.asc &&
                                                                                                            if ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ temporary.init } ${ environment-variable "ARGUMENTS" } > ${ environment-variable resource }/init.out.log 2> ${ environment-variable resource }/init.err.log
                                                                                                            then
                                                                                                                STATUS=${ environment-variable "?" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo 0
                                                                                                            else
                                                                                                                STATUS=${ environment-variable "?" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ builtins.toString temporary-init-error-code }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable resource }/init.status.asc
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable resource }/init.sh ${ environment-variable "ARGUMENTS" } ${ environment-variable "STANDARD_INPUT" } ${ environment-variable resource }/init.out.log ${ environment-variable resource }/init.err.log ${ environment-variable resource }/init.status.asc
                                                                                                     '' ;
                                                                                            } ;
                                                                                    in
                                                                                        ''
                                                                                            export ${ resource }=$( ${ temporary-resource-directory } ) &&
                                                                                                ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "clean" clean } ${ environment-variable resource }/clean &&
                                                                                                export ${ target }=${ environment-variable resource }/target &&
                                                                                                if ${ has-standard-input }
                                                                                                then
                                                                                                    WAIT_PID=${ environment-variable "PPID//[[:space:]]/I a" } &&
                                                                                                        STATUS=$( ${ pkgs.coreutils }/bin/tee | ${ pkgs.writeShellScript "prepare" prepare.has-standard-input } ${ environment-variable "@" } )
                                                                                                else
                                                                                                    WAIT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PPID" } | ${ pkgs.findutils }/bin/xargs ) &&
                                                                                                        STATUS=$( ${ pkgs.writeShellScript "prepare" prepare.does-not-have-standard-input } ${ environment-variable "@" } )
                                                                                                fi &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "WAIT_PID" } > ${ environment-variable resource }/${ environment-variable "WAIT_PID" }.pid
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ environment-variable resource }/clean | ${ at } now > /dev/null 2>&1 &&
                                                                                                if [ ${ environment-variable "STATUS" } == 0 ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                else
                                                                                                    BROKEN=$( ${ temporary-broken-directory } ) &&
                                                                                                        ${ pkgs.coreutils }/bin/mv ${ environment-variable resource } ${ environment-variable "BROKEN" } &&
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "BROKEN" }/target &&
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
                                                                                    in identity ( value paths.scripts ) ;
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
                                                                    scripts = scripts [ ( environment-variable out ) "scripts" ] ;
                                                                    temporary = temporary [ ( environment-variable out ) "temporary" ] ;
                                                                } ;
                                                    write =
                                                        let
                                                            input =
                                                                {
                                                                    "${ environment-variable out }" =
                                                                        {
                                                                            cache = builtins.mapAttrs mappers.cache cache ;
                                                                            scripts = builtins.mapAttrs mappers.scripts scripts ;
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
                                                                ${ pkgs.coreutils }/bin/cp --recursive util $out &&
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
                                                                at =
                                                                    pkgs.writeShellScript
                                                                        "at"
                                                                        ''
                                                                            ${ pkgs.coreutils }/bin/tee &
                                                                        '' ;
                                                                inc = 2 ;
                                                                out = "f37312f2785157f375f8fe159e6122c7c9378b5a4052cadd17e6faff1851b35c749baa51c5d132da58bdfb88e54a81ecc36a989e07baa9cca69dab2f6e28024d" ;
                                                                resources =
                                                                    {
                                                                        scripts =
                                                                            lib
                                                                                {
                                                                                    out = out ;
                                                                                    scripts =
                                                                                        let
                                                                                            script =
                                                                                                status : { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        ARGUMENTS=${ environment-variable "@" } &&
                                                                                                            if ${ has-standard-input }
                                                                                                            then
                                                                                                                STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                                                    HAS_STANDARD_INPUT=true
                                                                                                            else
                                                                                                                STANDARD_INPUT= &&
                                                                                                                    HAS_STANDARD_INPUT=false
                                                                                                            fi &&
                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable 0 } | ${ pkgs.gnused }/bin/sed -e "s#^${ environment-variable out }/scripts/##" -e "s#[.]sh\$##" ) &&
                                                                                                            ${ pkgs.coreutils }/bin/echo SCRIPT OUTPUT ${ environment-variable "RELATIVE" } ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo SCRIPT ERROR ${ environment-variable "RELATIVE" } ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } >&2 &&
                                                                                                            exit ${ builtins.toString status }
                                                                                                    '' ;
                                                                                            in
                                                                                                {
                                                                                                    bad = script 65 ;
                                                                                                    good = script 0 ;
                                                                                                } ;
                                                                                    secondary = secondary ;
                                                                                } ;
                                                                        temporary =
                                                                            lib
                                                                                {
                                                                                    at = at ;
                                                                                    out = out ;
                                                                                    scripts =
                                                                                        let
                                                                                            script =
                                                                                                status : { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        ARGUMENTS=${ environment-variable "@" } &&
                                                                                                            if ${ has-standard-input }
                                                                                                            then
                                                                                                                STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                                                    HAS_STANDARD_INPUT=true
                                                                                                            else
                                                                                                                STANDARD_INPUT= &&
                                                                                                                    HAS_STANDARD_INPUT=false
                                                                                                            fi &&
                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable 0 } | ${ pkgs.gnused }/bin/sed -e "s#^${ environment-variable out }/scripts/##" -e "s#[.]sh\$##" ) &&
                                                                                                            ${ pkgs.coreutils }/bin/echo TEMPORARY OUTPUT ${ environment-variable "RELATIVE" } ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo TEMPORARY ERROR ${ environment-variable "RELATIVE" } ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } >&2 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "ARGUMENTS" } >> ${ environment-variable target } &&
                                                                                                            exit ${ builtins.toString status }
                                                                                                    '' ;
                                                                                            in
                                                                                                {
                                                                                                    bad = script 66 ;
                                                                                                    good = script 0 ;
                                                                                                } ;
                                                                                    secondary = { pkgs = pkgs ; } ;
                                                                                    temporary =
                                                                                        {
                                                                                            bad =
                                                                                                {
                                                                                                    bad = scripts : { init = scripts.bad ; release = scripts.bad ; } ;
                                                                                                    good = scripts : { init = scripts.bad ; release = scripts.bad ; } ;
                                                                                                    null = scripts : { init = scripts.bad ; } ;
                                                                                                } ;
                                                                                            good =
                                                                                                {
                                                                                                    bad = scripts : { init = scripts.bad ; release = scripts.bad ; } ;
                                                                                                    good = scripts : { init = scripts.bad ; release = scripts.bad ; } ;
                                                                                                    null = scripts : { init = scripts.bad ; } ;
                                                                                                } ;
                                                                                            null =
                                                                                                {
                                                                                                    bad = scripts : { release = scripts.bad ; } ;
                                                                                                    good = scripts : { release = scripts.bad ; } ;
                                                                                                    null = scripts : { } ;
                                                                                                } ;
                                                                                        } ;
                                                                                } ;
                                                                        util =
                                                                            lib
                                                                                {
                                                                                    at = at ;
                                                                                    cache =
                                                                                        {
                                                                                            work = temporary : { temporary = temporary.work ; epoch = 8 * inc ; } ;
                                                                                        } ;
                                                                                    out = out ;
                                                                                    scripts =
                                                                                        {
                                                                                            directory =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        ROOT=${ environment-variable 1 } &&
                                                                                                            ${ pkgs.findutils }/bin/find /build -mindepth 2 -maxdepth 2 -name target | while read FILE
                                                                                                            do
                                                                                                                if [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "FILE" } ) == $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ROOT" }/1/target ) ]
                                                                                                                then
                                                                                                                    SOURCE=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable "FILE" } ) &&
                                                                                                                        INDEX=$( ${ pkgs.findutils }/bin/find ${ environment-variable "ROOT" }/2 -mindepth 1 | ${ pkgs.coreutils }/bin/wc --lines ) &&
                                                                                                                        DESTINATION=${ environment-variable "ROOT" }/2/${ environment-variable "INDEX" } &&
                                                                                                                        ${ pkgs.coreutils }/bin/cp --recursive ${ environment-variable "SOURCE" } ${ environment-variable "DESTINATION" } &&
                                                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "DESTINATION" } | while read FILE
                                                                                                                        do
                                                                                                                            ${ pkgs.coreutils }/bin/stat --format %A ${ environment-variable "FILE" } > ${ environment-variable "FILE" }.permissions
                                                                                                                        done &&
                                                                                                                        if [ -f ${ environment-variable "DESTINATION" }/init.sh ]
                                                                                                                        then
                                                                                                                            ${ pkgs.gnused }/bin/sed -e "s#/nix/store/.*#/nix/store#" ${ environment-variable "DESTINATION" }/init.sh -e w${ environment-variable "DESTINATION" }/init.sh.archive &&
                                                                                                                                ${ pkgs.coreutils }/bin/rm ${ environment-variable "DESTINATION" }/init.sh
                                                                                                                        fi                                                                                                                        
                                                                                                                fi
                                                                                                            done
                                                                                                    '' ;
                                                                                            record =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        COMMAND=${ environment-variable 1 } &&
                                                                                                            HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                            OUT=${ environment-variable 3 } &&
                                                                                                            ERR=${ environment-variable 4 } &&
                                                                                                            STATUS=${ environment-variable 5 } &&
                                                                                                            DIRECTORY=${ environment-variable 6 } &&
                                                                                                            if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                            then
                                                                                                                if ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "OUT" } 2> ${ environment-variable "ERR" }
                                                                                                                then
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                else
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                fi
                                                                                                            else
                                                                                                                if ${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "OUT" } 2> ${ environment-variable "ERR" }
                                                                                                                then
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                else
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                fi
                                                                                                            fi &&
                                                                                                            if [ ! -z ${ environment-variable "DIRECTORY" } ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/cp --recursive $( ${ pkgs.coreutils }/bin/dirname $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "OUT" } ) ) ${ environment-variable "DIRECTORY" } &&
                                                                                                                    ${ pkgs.findutils }/bin/find ${ environment-variable "DIRECTORY" } | while read FILE
                                                                                                                    do
                                                                                                                        ${ pkgs.coreutils }/bin/stat --format %A ${ environment-variable "FILE" } > ${ environment-variable "FILE" }.permissions
                                                                                                                    done &&
                                                                                                                    if [ -f ${ environment-variable "DIRECTORY" }/init.sh ]
                                                                                                                    then
                                                                                                                        ${ pkgs.gnused }/bin/sed -e "s#/nix/store/.*#/nix/store#" ${ environment-variable "DIRECTORY" }/init.sh -e w${ environment-variable "DIRECTORY" }/init.sh.archive &&
                                                                                                                            ${ pkgs.coreutils }/bin/rm ${ environment-variable "DIRECTORY" }/init.sh
                                                                                                                    fi
                                                                                                            fi
                                                                                                    '' ;
                                                                                            scripts =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        COMMAND=${ environment-variable 1 } &&
                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/realpath --relative-to ${ resources.scripts }/scripts ${ environment-variable "COMMAND" } ) &&
                                                                                                            ABSOLUTE=${ environment-variable "OBSERVED_DIRECTORY" }/scripts/${ environment-variable "RELATIVE" } &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir --parents ${ environment-variable "ABSOLUTE" } &&
                                                                                                            ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } false ${ environment-variable "ABSOLUTE" }/1.out ${ environment-variable "ABSOLUTE" }/1.err ${ environment-variable "ABSOLUTE" }/1.status &&
                                                                                                            ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } true ${ environment-variable "ABSOLUTE" }/2.out ${ environment-variable "ABSOLUTE" }/2.err ${ environment-variable "ABSOLUTE" }/2.status
                                                                                                    '' ;
                                                                                            temporary =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        COMMAND=${ environment-variable 1 } &&
                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/realpath --relative-to ${ resources.temporary }/temporary ${ environment-variable "COMMAND" } ) &&
                                                                                                            ABSOLUTE=${ environment-variable "OBSERVED_DIRECTORY" }/temporary/${ environment-variable "RELATIVE" } &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir --parents ${ environment-variable "ABSOLUTE" } &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "ABSOLUTE" }/1 &&
                                                                                                            ARGUMENTS="${ environment-variable "RELATIVE" }:1" ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } false ${ environment-variable "ABSOLUTE" }/1.out ${ environment-variable "ABSOLUTE" }/1.err ${ environment-variable "ABSOLUTE" }/1.status ${ environment-variable "ABSOLUTE" }/1/1 &&
                                                                                                            ${ pkgs.gnused }/bin/sed -i "s#/build/.*[.]##" ${ environment-variable "ABSOLUTE" }/1.out &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "ABSOLUTE" }/2 &&
                                                                                                            ARGUMENTS="${ environment-variable "RELATIVE" }:2" ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } true ${ environment-variable "ABSOLUTE" }/2.out ${ environment-variable "ABSOLUTE" }/2.err ${ environment-variable "ABSOLUTE" }/1.status ${ environment-variable "ABSOLUTE" }/2/1
                                                                                                            ${ pkgs.gnused }/bin/sed -i "s#/build/.*[.]##" ${ environment-variable "ABSOLUTE" }/2.out
                                                                                                    '' ;
                                                                                            test =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        test_diff ( )
                                                                                                            {
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "OBSERVED_DIRECTORY" } &&
                                                                                                                    assert_equals "" "$( ${ pkgs.diffutils }/bin/diff --brief --recursive ${ environment-variable "EXPECTED_DIRECTORY" } ${ environment-variable "OBSERVED_DIRECTORY" } )" "We expect expected to exactly equal observed."
                                                                                                            } &&
                                                                                                                test_expected_observed ( )
                                                                                                                    {
                                                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "EXPECTED_DIRECTORY" } -type f | while read EXPECTED_FILE
                                                                                                                        do
                                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/realpath --relative-to ${ environment-variable "EXPECTED_DIRECTORY" } ${ environment-variable "EXPECTED_FILE" } ) &&
                                                                                                                                OBSERVED_FILE=${ environment-variable "OBSERVED_DIRECTORY" }/${ environment-variable "RELATIVE" } &&
                                                                                                                                if [ ! -f ${ environment-variable "OBSERVED_FILE" } ]
                                                                                                                                then
                                                                                                                                    fail "The observed file for ${ environment-variable "RELATIVE" } does not exist."
                                                                                                                                fi &&
                                                                                                                                assert_equals "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "EXPECTED_FILE" } )" "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "OBSERVED_FILE" } )" "The expected file does not equal the observed file for ${ environment-variable "RELATIVE" }."
                                                                                                                        done
                                                                                                                    } &&
                                                                                                                test_observed_expected ( )
                                                                                                                    {
                                                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "OBSERVED_DIRECTORY" } -type f | while read OBSERVED_FILE
                                                                                                                        do
                                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/realpath --relative-to ${ environment-variable "OBSERVED_DIRECTORY" } ${ environment-variable "OBSERVED_FILE" } ) &&
                                                                                                                                EXPECTED_FILE=${ environment-variable "EXPECTED_DIRECTORY" }/${ environment-variable "RELATIVE" } &&
                                                                                                                                if [ ! -f ${ environment-variable "EXPECTED_FILE" } ]
                                                                                                                                then
                                                                                                                                    fail "The expected file for ${ environment-variable "RELATIVE" } does not exist."
                                                                                                                                fi &&
                                                                                                                                assert_equals "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "EXPECTED_FILE" } )" "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "OBSERVED_FILE" } )" "The observed file does not equal the expected file for ${ environment-variable "RELATIVE" }."
                                                                                                                        done
                                                                                                                    }
                                                                                                    '' ;
                                                                                            work =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/mkdir ${ target }
                                                                                                    '' ;
                                                                                        } ;
                                                                                    secondary = secondary ;
                                                                                    temporary =
                                                                                        {
                                                                                            work = scripts : { init = scripts.work ; } ;
                                                                                        } ;
                                                                                } ;
                                                                            } ;
                                                                        secondary = { pkgs = pkgs ; } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            export ARGUMENTS=a0d791e90486ab349661235cd0913d11649f6659c848ef4fb8639d04267ecfa03d1c922c455f53727e01fd42749a37b816334d75588127384b9772a61840a25b &&
                                                                            export STANDARD_INPUT=9f94b1c83ef72dc398aadf0931f9e723303d34781d433efb685ca793d054c810c6a752c94c0a4944ab43658cede7f1059616659110d3944e8645f5c79aeff59e &&
                                                                            export EXPECTED_DIRECTORY=${ ./expected } &&
                                                                            export OBSERVED_DIRECTORY=$out &&
                                                                            NOW=$( ${ pkgs.coreutils }/bin/date +%s ) &&
                                                                            ${ pkgs.coreutils }/bin/sleep $(( ${ builtins.toString ( 8 * inc ) } + ${ builtins.toString ( 8 * inc ) } * ( ${ environment-variable "NOW" } / ${ builtins.toString ( 8 * inc ) } ) - ${ environment-variable "NOW" } )) &&
                                                                            ${ pkgs.findutils }/bin/find ${ resources.scripts }/scripts -mindepth 1 -type f -not -name "*.sh" -exec ${ resources.util }/scripts/scripts {} \; &&
                                                                            ${ pkgs.findutils }/bin/find ${ resources.temporary }/temporary -mindepth 1 -type f -not -name "*.sh" -exec ${ resources.util }/scripts/temporary {} \; &&
                                                                            ${ pkgs.bash_unit }/bin/bash_unit ${ resources.util }/scripts/test.sh
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
