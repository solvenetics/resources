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
                                                                                            in identity ( value ( builtins.mapAttrs set [ "temporary" ] ) temporary ) ;
                                                                                    in
                                                                                        ''
                                                                                            ${ pkgs.coreutils }/bin/echo AAA 0001000 ${ environment-variable 0 } >> /build/debug &&
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
                                                                                                ${ pkgs.coreutils }/bin/echo AAA 0001100 ${ environment-variable 0 } >> /build/debug &&
                                                                                                export ${ cache-epoch-hash }=$( ${ pkgs.coreutils }/bin/echo -n $(( ${ environment-variable cache-timestamp } / ${ builtins.toString populate.epoch } )) ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } $( ${ pkgs.coreutils }/bin/whoami ) ${ builtins.hashString "sha512" ( builtins.concatStringsSep "" ( builtins.concatLists [ path ( builtins.map builtins.toString [ name populate.epoch populate.temporary ] ) ] ) ) } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                                ${ pkgs.coreutils }/bin/echo AAA 0001200 ${ environment-variable 0 } >> /build/debug &&
                                                                                                exec 10> ${ cache-directory }/${ environment-variable cache-epoch-hash }.lock &&
                                                                                                ${ pkgs.coreutils }/bin/echo AAA 0001300 ${ environment-variable 0 } ${ environment-variable cache-epoch-hash }>> /build/debug &&
                                                                                                if ${ pkgs.flock }/bin/flock 10
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/echo AAA 00013\410 ${ environment-variable 0 } >> /build/debug &&
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
                                                                                                    ${ pkgs.coreutils }/bin/echo AAA 0001420 ${ environment-variable 0 } >> /build/debug &&
                                                                                                    ${ pkgs.coreutils }/bin/echo "${ cache-lock-message }" >&2 &&
                                                                                                        exit ${ builtins.toString cache-lock-exit }
                                                                                                fi
                                                                                        '' ;
                                                                            manage =
                                                                                ''
                                                                                    ${ pkgs.coreutils }/bin/echo AAA 0002000 >> /build/debug &&
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
                                                            set = path : name : value : if builtins.typeOf value == "lambda" then builtins.concatStringsSep "/" ( builtins.concatLists [ path [ name ] ] ) else builtins.mapAttrs ( set ( builtins.concatLists [ path [ name ] ] ) ) value ;
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
                                                                                                        thenscripts
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
                                                                                            does-not-have-standard-input = "${ environment-variable "RESOURCE" } $( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PPID" } ) " ;
                                                                                            has-standard-input = "${ environment-variable "RESOURCE" } ${ environment-variable "PPID" }" ;
                                                                                        } ;
                                                                                    in
                                                                                        ''
                                                                                            ${ pkgs.coreutils }/bin/echo AAA 0003000 ${ builtins.toString temporary.init } >> /build/debug &&
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
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PPID" } > ${ environment-variable "RESOURCE" }/invalidate.sh &&
                                                                                                ${ pkgs.coreutils }/bin/chmod 0500 ${ environment-variable "RESOURCE" }/invalidate.sh &&
                                                                                                if [ ${ environment-variable "STATUS" } == 0 ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ pkgs.bash }/bin/bash -c ${ environment-variable "RESOURCE" }/invalidate.sh | ${ at } now >> /build/debug 2>&1 &&
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
                                                                                    ######
                                                                                    # temporary =
                                                                                    #     {
                                                                                    #         work = scripts : { init = scripts.work ; } ;
                                                                                    #     } ;
                                                                                    in identity ( value { work = "/" ; } ) ;
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
                                                                inc = 2 ;
                                                                out = "f37312f2785157f375f8fe159e6122c7c9378b5a4052cadd17e6faff1851b35c749baa51c5d132da58bdfb88e54a81ecc36a989e07baa9cca69dab2f6e28024d" ;
                                                                resources =
                                                                    {
                                                                        scripts =
                                                                            lib
                                                                                {
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
                                                                                                            ${ pkgs.coreutils }/bin/echo OUTPUT ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ERROR ${ environment-variable "ARGUMENTS" } ${ environment-variable "HAS_STANDARD_INPUT" } ${ environment-variable "STANDARD_INPUT" }
                                                                                                            exit ${ builtins.toString status }
                                                                                                    '' ;
                                                                                            in
                                                                                                {
                                                                                                    bad = script 64 ;
                                                                                                    good = script 0 ;
                                                                                                } ;
                                                                                    secondary = { pkgs = pkgs ; } ;
                                                                                } ;
                                                                        util =
                                                                            lib
                                                                                {
                                                                                    scripts =
                                                                                        {
                                                                                            scripts =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        TARGET=${ environment-variable 1 } &&
                                                                                                            ARGUMENTS=${ environment-variable 2 } &&
                                                                                                            STANDARD_INPUT=${ environment-variable 3 } &&
                                                                                                            COMMAND=${ environment-variable 4 } &&
                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/realpath --relative-to ${ environment-variable "OUT" } ${ environment-variable "COMMAND" } ) &&
                                                                                                            ABSOLUTE=${ environment-variable "TARGET" }/${ environment-variable "RELATIVE" } &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir --parents ${ environment-variable "ABSOLUTE" } &&
                                                                                                            if ${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "ABSOLUTE" }/1.out 2> { environment-variable "ABSOLUTE" } 1.err
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "ABSOLUTE" }/1.status
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "ABSOLUTE" }/1.status
                                                                                                            fi &&
                                                                                                            if ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "ABSOLUTE" }/2.out 2> { environment-variable "ABSOLUTE" } 2.err
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "ABSOLUTE" }/2.status
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "ABSOLUTE" }/2.status
                                                                                                            fi
                                                                                                    '' ;
                                                                                                work =
                                                                                                    { pkgs , ... } : target :
                                                                                                        ''
                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ target }
                                                                                                        '' ;
                                                                                        } ;
                                                                                    secondary = { pkgs = pkgs ; } ;
                                                                                    temporary =
                                                                                        {
                                                                                            work = scripts : { init = scripts.work ; } ;
                                                                                        } ;
                                                                                } ;
                                                                            } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            ${ pkgs.coreutils }/bin/mkdir $out/cache &&
                                                                            NOW=$( ${ pkgs.coreutils }/bin/date +%s ) &&
                                                                            ARGUMENTS=$( ${ pkgs.libuuid }/bin/uuidgen | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                            STANDARD_INPUT=$( ${ pkgs.libuuid }/bin/uuidgen | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                            ${ pkgs.coreutils }/bin/sleep $(( ${ builtins.toString ( 8 * inc ) } + ${ builtins.toString ( 8 * inc ) } * ( ${ environment-variable "NOW" } / ${ builtins.toString ( 8 * inc ) } ) - ${ environment-variable "NOW" } )) &&
                                                                            ${ pkgs.findutils }/bin/find ${ resources.scripts }/scripts -mindepth 1 -type f -not -name "*.sh" -exec ${ resources.util }/scripts/scripts $( ${ resources.util }/cache/work ) ${ environment-variable "ARGUMENTS" } ${ environment-variable "STANDARD_INPUT" } {}
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
