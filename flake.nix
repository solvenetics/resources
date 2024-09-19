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
                                                                                            in identity ( value tertiary.temporary ) ;
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
                                                                                                exec 10> ${ cache-directory }/${ cache-epoch-hash }.lock &&
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
                                                                    ## ENTRYPOINT 1
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
                                                    wtf =
                                                        let
                                                            mapper =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then builtins.concatStringsSep "/" ( builtins.concatLists [ path [ name ] ])
                                                                    else builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                            in
                                                                {
                                                                    temporary = builtins.mapAttrs ( mapper [ ( environment-variable out ) "temporary" ] ) temporary ;
                                                                } ;
                                                    tertiary =
                                                        let
                                                            mapper =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then builtins.concatStringsSep "/" ( builtins.concatLists [ path [ name ] ])
                                                                    else builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                            in
                                                                {
                                                                    ## ENTRYPOINT 2
                                                                    cache = builtins.mapAttrs ( mapper [ ( environment-variable out ) "cache" ] ) cache ;
                                                                    environment-variable = environment-variable ;
                                                                    has-standard-input = has-standard-input ;
                                                                    scripts = builtins.mapAttrs ( mapper [ ( environment-variable out ) "scripts" ] ) scripts ;
                                                                    target = target ;
                                                                    temporary = wtf.temporary ;
                                                                    strip = strip ;
                                                                } ;
                                                    write =
                                                        let
                                                            input =
                                                                {
                                                                    "${ environment-variable out }" =
                                                                        {
                                                                            ## ENTRYPOINT 3
                                                                            cache = builtins.mapAttrs mappers.cache cache ;
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
                                                                out = "f37312f2785157f375f8fe159e6122c7c9378b5a4052cadd17e6faff1851b35c749baa51c5d132da58bdfb88e54a81ecc36a989e07baa9cca69dab2f6e28024d" ;
                                                                resources =
                                                                    lib
                                                                        {
                                                                            at =
                                                                                pkgs.writeShellScript
                                                                                    "at"
                                                                                    ''
                                                                                        ${ pkgs.coreutils }/bin/tee | ${ pkgs.bash }/bin/bash &
                                                                                    '' ;
                                                                            cache =
                                                                                {
                                                                                    null = temporary : { temporary = temporary.null ; epoch = 2 ; } ;
                                                                                } ;
                                                                            lock = "/build/resources.lock" ;
                                                                            out = out ;
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            scripts =
                                                                                let
                                                                                    seed = "9e1080281ac5543c0bee9e50d6349afe5b0e26644c57d52faed76cc17905f2928613bb17e3549a648297696971ceb10f2d8811aee353cc23bd0e9833d392a022" ;
                                                                                    in
                                                                                        {
                                                                                            test =
                                                                                                { pkgs , ... } : { environment-variable , scripts , strip , temporary , ... } :
                                                                                                    let
                                                                                                        functions =
                                                                                                            let
                                                                                                                generator =
                                                                                                                    index :
                                                                                                                        strip
                                                                                                                            ''
                                                                                                                                test_${ builtins.toString ( 101 + index ) } ( )
                                                                                                                                    {
                                                                                                                                        ${ builtins.elemAt list index ( builtins.hashString "sha512" ( builtins.concatStringsSep "" [ seed ( builtins.toString ( 2 * index ) ) ] ) ) ( builtins.hashString "sha512" ( builtins.concatStringsSep "" [ seed ( builtins.toString ( 2 * index + 1 ) ) ] ) ) }
                                                                                                                                    }
                                                                                                                            '' ;
                                                                                                                list =
                                                                                                                    let
                                                                                                                        script =
                                                                                                                             delta : has-standard-input : arguments : standard-input :
                                                                                                                                strip
                                                                                                                                    ''
                                                                                                                                        COMMAND=${ if delta then scripts.verification.good else scripts.verification.bad } &&
                                                                                                                                            export ARGUMENTS=${ arguments } &&
                                                                                                                                            export STANDARD_INPUT=${ if has-standard-input then standard-input else "" } &&
                                                                                                                                            EXPECTED_STATUS=${ builtins.toString ( if delta then 0 else 64 ) } &&
                                                                                                                                            EXPECTED_STANDARD_OUTPUT=$( ${ scripts.util.identity } standard output ) &&
                                                                                                                                            EXPECTED_STANDARD_ERROR=$( ${ scripts.util.identity } standard error ) &&
                                                                                                                                            EXPECTED_SCRIPTS_FILE="cache.null=${ environment-variable out }/cache/null,scripts.test=${ environment-variable out }/scripts/test,scripts.util.identity=${ environment-variable out }/scripts/util/identity,scripts.util.write=${ environment-variable out }/scripts/util/write,scripts.verification.bad=${ environment-variable out }/scripts/verification/bad,scripts.verification.good=${ environment-variable out }/scripts/verification/good,scripts.verification.temporary.init.bad=${ environment-variable out }/scripts/verification/temporary/init/bad,scripts.verification.temporary.init.good=${ environment-variable out }/scripts/verification/temporary/init/good,scripts.verification.temporary.release.bad=${ environment-variable out }/scripts/verification/temporary/release/bad,scripts.verification.temporary.release.good=${ environment-variable out }/scripts/verification/temporary/release/good,scripts.verification.terminal=${ environment-variable out }/scripts/verification/terminal,temporary.null=${ environment-variable out }/temporary/null,temporary.verification.bad.bad=${ environment-variable out }/temporary/verification/bad/bad,temporary.verification.bad.good=${ environment-variable out }/temporary/verification/bad/good,temporary.verification.bad.null=${ environment-variable out }/temporary/verification/bad/null,temporary.verification.good.bad=${ environment-variable out }/temporary/verification/good/bad,temporary.verification.good.good=${ environment-variable out }/temporary/verification/good/good,temporary.verification.good.null=${ environment-variable out }/temporary/verification/good/null,temporary.verification.null.bad=${ environment-variable out }/temporary/verification/null/bad,temporary.verification.null.good=${ environment-variable out }/temporary/verification/null/good,temporary.verification.null.null=${ environment-variable out }/temporary/verification/null/null" &&
                                                                                                                                            EXPECTED_STRIP="715f817552f2e98e7e0ef267a8da8a762f4ad673c6dbc95c0a20a7d8c87cf078eb6f8d79cff71ea7fd981c05251dc238827abce2488ccda42887654026dd604d" &&
                                                                                                                                            EXPECTED_TARGET="${ environment-variable "c8725e4d573bd4d32254ea39a3fb3c77a823eb505445f5d4299e4a6d26fda26ee71af14503e1b6c401618b5cf7e6789ad0777ddd9e7eb0a9df7a6c61e119c089" }" &&
                                                                                                                                            EXPECTED_NO_CACHE_ARGUMENTS=$( ${ scripts.util.identity } no-cache arguments ) &&
                                                                                                                                            EXPECTED_NO_CACHE_STANDARD_OUTPUT=\/build\/[a-zA-Z0-9]{8}\.resource\/target &&
                                                                                                                                            EXPECTED_NO_CACHE_STANDARD_ERROR="" &&
                                                                                                                                            EXPECTED_NO_CACHE_SCRIPTS_FILE=${ environment-variable "EXPECTED_SCRIPTS_FILE" } &&
                                                                                                                                            EXPECTED_NO_CACHE_STRIP="2595332087bd2ebeebd3624af4be8541452ade795cb047b32a296dafb68375723b7e2b523855bb45b4770ae3ac811b6462f378a4b88477770bac7afb17979eed" &&
                                                                                                                                            EXPECTED_YES_CACHE_ARGUMENTS=$( ${ scripts.util.identity } yes-cache arguments ) &&
                                                                                                                                            EXPECTED_YES_CACHE_STANDARD_INPUT=$( ${ scripts.util.identity } yes-cache standard input ) &&
                                                                                                                                            EXPECTED_YES_CACHE_STANDARD_OUTPUT=\/build\/[a-zA-Z0-9]{8}\.resource\/target &&
                                                                                                                                            EXPECTED_YES_CACHE_STANDARD_ERROR= &&
                                                                                                                                            EXPECTED_YES_CACHE_SCRIPTS_FILE=${ environment-variable "EXPECTED_SCRIPTS_FILE" } &&
                                                                                                                                            EXPECTED_YES_CACHE_STRIP="2595332087bd2ebeebd3624af4be8541452ade795cb047b32a296dafb68375723b7e2b523855bb45b4770ae3ac811b6462f378a4b88477770bac7afb17979eed" &&
                                                                                                                                            EXPECTED_NO_SCRIPT_ARGUMENTS=$( ${ scripts.util.identity } no-script arguments ) &&
                                                                                                                                            EXPECTED_NO_SCRIPT_STANDARD_OUTPUT=$( ARGUMENTS=${ environment-variable "EXPECTED_NO_SCRIPT_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } standard output ) &&
                                                                                                                                            EXPECTED_NO_SCRIPT_STANDARD_ERROR=$( ARGUMENTS=${ environment-variable "EXPECTED_NO_SCRIPT_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } standard error ) &&
                                                                                                                                            EXPECTED_NO_SCRIPT_SCRIPTS_FILE=${ environment-variable "EXPECTED_SCRIPTS_FILE" } &&
                                                                                                                                            EXPECTED_NO_SCRIPT_STRIP="2595332087bd2ebeebd3624af4be8541452ade795cb047b32a296dafb68375723b7e2b523855bb45b4770ae3ac811b6462f378a4b88477770bac7afb17979eed" &&
                                                                                                                                            EXPECTED_NO_SCRIPT_TARGET=${ environment-variable "EXPECTED_TARGET" } &&
                                                                                                                                            EXPECTED_YES_SCRIPT_ARGUMENTS=$( ${ scripts.util.identity } yes-script arguments ) &&
                                                                                                                                            EXPECTED_YES_SCRIPT_STANDARD_INPUT=$( ${ scripts.util.identity } yes-script standard input ) &&
                                                                                                                                            EXPECTED_YES_SCRIPT_STANDARD_OUTPUT=$( ARGUMENTS=${ environment-variable "EXPECTED_YES_SCRIPT_ARGUMENTS" } STANDARD_INPUT="${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_INPUT" }" ${ scripts.util.identity } standard output ) &&
                                                                                                                                            EXPECTED_YES_SCRIPT_STANDARD_ERROR=$( ARGUMENTS=${ environment-variable "EXPECTED_YES_SCRIPT_ARGUMENTS" } STANDARD_INPUT="${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_INPUT" }" ${ scripts.util.identity } standard error ) &&
                                                                                                                                            EXPECTED_YES_SCRIPT_SCRIPTS_FILE=${ environment-variable "EXPECTED_SCRIPTS_FILE" } &&
                                                                                                                                            EXPECTED_YES_SCRIPT_STRIP="2595332087bd2ebeebd3624af4be8541452ade795cb047b32a296dafb68375723b7e2b523855bb45b4770ae3ac811b6462f378a4b88477770bac7afb17979eed" &&
                                                                                                                                            EXPECTED_YES_SCRIPT_TARGET=${ environment-variable "EXPECTED_TARGET" } &&
                                                                                                                                            EXPECTED_NO_TEMPORARY_ARGUMENTS=$( ${ scripts.util.identity } no-temporary arguments ) &&
                                                                                                                                            EXPECTED_NO_TEMPORARY_STANDARD_OUTPUT=\/build\/[a-zA-Z0-9]{8}\.resource\/target &&
                                                                                                                                            EXPECTED_NO_TEMPORARY_STANDARD_ERROR="" &&
                                                                                                                                            EXPECTED_NO_TEMPORARY_SCRIPTS_FILE=${ environment-variable "EXPECTED_SCRIPTS_FILE" } &&
                                                                                                                                            EXPECTED_NO_TEMPORARY_STRIP="2595332087bd2ebeebd3624af4be8541452ade795cb047b32a296dafb68375723b7e2b523855bb45b4770ae3ac811b6462f378a4b88477770bac7afb17979eed" &&
                                                                                                                                            EXPECTED_YES_TEMPORARY_ARGUMENTS=$( ${ scripts.util.identity } yes-temporary arguments ) &&
                                                                                                                                            EXPECTED_YES_TEMPORARY_STANDARD_INPUT=$( ${ scripts.util.identity } yes-temporary standard input ) &&
                                                                                                                                            EXPECTED_YES_TEMPORARY_STANDARD_OUTPUT=\/build\/[a-zA-Z0-9]{8}\.resource\/target &&
                                                                                                                                            EXPECTED_YES_TEMPORARY_STANDARD_ERROR= &&
                                                                                                                                            EXPECTED_YES_TEMPORARY_SCRIPTS_FILE=${ environment-variable "EXPECTED_SCRIPTS_FILE" } &&
                                                                                                                                            EXPECTED_YES_TEMPORARY_STRIP="2595332087bd2ebeebd3624af4be8541452ade795cb047b32a296dafb68375723b7e2b523855bb45b4770ae3ac811b6462f378a4b88477770bac7afb17979eed" &&
                                                                                                                                            assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } > /build/$( ${ scripts.util.identity } standard output file ) 2> /build/$( ${ scripts.util.identity } standard error file )" &&
                                                                                                                                            OBSERVED_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } standard output file ) ) &&
                                                                                                                                            OBSERVED_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } standard error file ) ) &&
                                                                                                                                            OBSERVED_SCRIPTS_FILE=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } scripts file ) ) &&
                                                                                                                                            OBSERVED_STRIP=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } strip file ) ) &&
                                                                                                                                            OBSERVED_TARGET=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } target file ) ) &&
                                                                                                                                            OBSERVED_NO_CACHE_ARGUMENTS=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-cache arguments file ) ) &&
                                                                                                                                            OBSERVED_NO_CACHE_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-cache standard output file ) ) &&
                                                                                                                                            OBSERVED_NO_CACHE_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-cache standard error file ) ) &&
                                                                                                                                            OBSERVED_NO_CACHE_SCRIPTS_FILE=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_CACHE_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } scripts file ) ) &&
                                                                                                                                            OBSERVED_NO_CACHE_STRIP=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_CACHE_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } strip file ) ) &&
                                                                                                                                            OBSERVED_NO_CACHE_TARGET=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_CACHE_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } target file ) ) &&
                                                                                                                                            OBSERVED_YES_CACHE_ARGUMENTS=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-cache arguments file ) ) &&
                                                                                                                                            OBSERVED_YES_CACHE_STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-cache standard input file ) ) &&
                                                                                                                                            OBSERVED_YES_CACHE_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-cache standard output file ) ) &&
                                                                                                                                            OBSERVED_YES_CACHE_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-cache standard error file ) ) &&
                                                                                                                                            OBSERVED_YES_CACHE_SCRIPTS_FILE=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_CACHE_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_CACHE_STANDARD_INPUT" } ${ scripts.util.identity } scripts file ) ) &&
                                                                                                                                            OBSERVED_YES_CACHE_STRIP=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_CACHE_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_CACHE_STANDARD_INPUT" } ${ scripts.util.identity } strip file ) ) &&
                                                                                                                                            OBSERVED_YES_CACHE_TARGET=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_CACHE_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_CACHE_STANDARD_INPUT" } ${ scripts.util.identity } target file ) ) &&
                                                                                                                                            OBSERVED_NO_SCRIPT_ARGUMENTS=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-script arguments file ) ) &&
                                                                                                                                            OBSERVED_NO_SCRIPT_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-script standard output file ) ) &&
                                                                                                                                            OBSERVED_NO_SCRIPT_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-script standard error file ) ) &&
                                                                                                                                            OBSERVED_NO_SCRIPT_SCRIPTS_FILE=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_SCRIPT_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } scripts file ) ) &&
                                                                                                                                            OBSERVED_NO_SCRIPT_STRIP=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_SCRIPT_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } strip file ) ) &&
                                                                                                                                            OBSERVED_NO_SCRIPT_TARGET=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_SCRIPT_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } target file ) ) &&
                                                                                                                                            OBSERVED_YES_SCRIPT_ARGUMENTS=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-script arguments file ) ) &&
                                                                                                                                            OBSERVED_YES_SCRIPT_STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-script standard input file ) ) &&
                                                                                                                                            OBSERVED_YES_SCRIPT_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-script standard output file ) ) &&
                                                                                                                                            OBSERVED_YES_SCRIPT_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-script standard error file ) ) &&
                                                                                                                                            OBSERVED_YES_SCRIPT_SCRIPTS_FILE=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_SCRIPT_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_INPUT" } ${ scripts.util.identity } scripts file ) ) &&
                                                                                                                                            OBSERVED_YES_SCRIPT_STRIP=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_SCRIPT_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_INPUT" } ${ scripts.util.identity } strip file ) ) &&
                                                                                                                                            OBSERVED_YES_SCRIPT_TARGET=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_SCRIPT_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_INPUT" } ${ scripts.util.identity } target file ) ) &&
                                                                                                                                            OBSERVED_NO_TEMPORARY_ARGUMENTS=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-temporary arguments file ) ) &&
                                                                                                                                            OBSERVED_NO_TEMPORARY_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-temporary standard output file ) ) &&
                                                                                                                                            OBSERVED_NO_TEMPORARY_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } no-temporary standard error file ) ) &&
                                                                                                                                            OBSERVED_NO_TEMPORARY_SCRIPTS_FILE=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_TEMPORARY_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } scripts file ) ) &&
                                                                                                                                            OBSERVED_NO_TEMPORARY_STRIP=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_TEMPORARY_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } strip file ) ) &&
                                                                                                                                            OBSERVED_NO_TEMPORARY_TARGET=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_NO_TEMPORARY_ARGUMENTS" } STANDARD_INPUT="" ${ scripts.util.identity } target file ) ) &&
                                                                                                                                            OBSERVED_YES_TEMPORARY_ARGUMENTS=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-temporary arguments file ) ) &&
                                                                                                                                            OBSERVED_YES_TEMPORARY_STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-temporary standard input file ) ) &&
                                                                                                                                            OBSERVED_YES_TEMPORARY_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-temporary standard output file ) ) &&
                                                                                                                                            OBSERVED_YES_TEMPORARY_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } yes-temporary standard error file ) ) &&
                                                                                                                                            OBSERVED_YES_TEMPORARY_SCRIPTS_FILE=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_TEMPORARY_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_INPUT" } ${ scripts.util.identity } scripts file ) ) &&
                                                                                                                                            OBSERVED_YES_TEMPORARY_STRIP=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_TEMPORARY_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_INPUT" } ${ scripts.util.identity } strip file ) ) &&
                                                                                                                                            OBSERVED_YES_TEMPORARY_TARGET=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS=${ environment-variable "EXPECTED_YES_TEMPORARY_ARGUMENTS" } STANDARD_INPUT=${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_INPUT" } ${ scripts.util.identity } target file ) ) &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_STANDARD_OUTPUT" } "We expect this standard output.  Since this uses identity, arguments, and standard input this confirm these values." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_STANDARD_ERROR" } ${ environment-variable "OBSERVED_STANDARD_ERROR" } "We expect this standard error.  Since this uses identity, arguments, and standard input this confirms these values." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_SCRIPTS_FILE" } "We expected the predicted scripts to be available to our script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_STRIP" } ${ environment-variable "OBSERVED_STRIP" } "We expect the predicted strip value." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_TARGET" }" "${ environment-variable "OBSERVED_TARGET" }" "We expected the target to be blank." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_CACHE_ARGUMENTS" } ${ environment-variable "OBSERVED_NO_CACHE_ARGUMENTS" } "We expect the predicted argument to no-cache." &&
                                                                                                                                            assert_matches ${ environment-variable "EXPECTED_NO_CACHE_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_NO_CACHE_STANDARD_OUTPUT" } "We expect the predicted standard output to match.  It will be computed and not exact." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_NO_CACHE_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_NO_CACHE_STANDARD_ERROR" }" "We expect the predicted standard error to no-cache." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_CACHE_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_NO_CACHE_SCRIPTS_FILE" } "We expect the predicted scripts to be available to no-cache." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_CACHE_STRIP" } ${ environment-variable "OBSERVED_NO_CACHE_STRIP" } "We expect the the predicted strip value to the no-cache." &&
                                                                                                                                            assert_equals "${ environment-variable "OBSERVED_NO_CACHE_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_NO_CACHE_TARGET" }" "We expect the no-cache target to be as computed." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_CACHE_ARGUMENTS" } ${ environment-variable "OBSERVED_YES_CACHE_ARGUMENTS" } "We expect the predicted argument to yes-cache." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_CACHE_STANDARD_INPUT" } ${ environment-variable "OBSERVED_YES_CACHE_STANDARD_INPUT" } "We expect the predicted standard input to yes-cache." &&
                                                                                                                                            assert_matches ${ environment-variable "EXPECTED_YES_CACHE_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_YES_CACHE_STANDARD_OUTPUT" } "We expect the predicted standard output to match.  It will be computed and not exactl." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_YES_CACHE_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_YES_CACHE_STANDARD_ERROR" }" "We expect the predicted standard error to yes-cache." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_CACHE_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_YES_CACHE_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the yes_cache." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_CACHE_STRIP" } ${ environment-variable "OBSERVED_YES_CACHE_STRIP" } "We expect the the predicted strip value to the yes_cache." &&
                                                                                                                                            assert_equals "${ environment-variable "OBSERVED_YES_CACHE_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_YES_CACHE_TARGET" }" "We expect the yes-cache target to be as computed."
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_ARGUMENTS" } ${ environment-variable "OBSERVED_NO_SCRIPT_ARGUMENTS" } "We expect the predicted argument to no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_NO_SCRIPT_STANDARD_OUTPUT" } "We expect the predicted standard output to no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_STANDARD_ERROR" } ${ environment-variable "OBSERVED_NO_SCRIPT_STANDARD_ERROR" } "We expect the predicted standard error to no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_NO_SCRIPT_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_STRIP" } ${ environment-variable "OBSERVED_NO_SCRIPT_STRIP" } "We expect the the predicted strip value to the no-script." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_NO_SCRIPTS_TARGET" }" "${ environment-variable "OBSERVED_NO_SCRIPT_TARGET" }" "We expected the NO_SCRIPT target to be blank." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_ARGUMENTS" } ${ environment-variable "OBSERVED_YES_SCRIPT_ARGUMENTS" } "We expect the predicted argument to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_INPUT" } ${ environment-variable "OBSERVED_YES_SCRIPT_STANDARD_INPUT" } "We expect the predicted standard input to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_YES_SCRIPT_STANDARD_OUTPUT" } "We expect the predicted standard output to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_ERROR" } ${ environment-variable "OBSERVED_YES_SCRIPT_STANDARD_ERROR" } "We expect the predicted standard error to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_YES_SCRIPT_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the yes_SCRIPT." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STRIP" } ${ environment-variable "OBSERVED_YES_SCRIPT_STRIP" } "We expect the the predicted strip value to the yes_SCRIPT." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_YES_SCRIPTS_TARGET" }" "${ environment-variable "OBSERVED_YES_SCRIPT_TARGET" }" "We expected the yes_SCRIPT target to be blank." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_TEMPORARY_ARGUMENTS" } ${ environment-variable "OBSERVED_NO_TEMPORARY_ARGUMENTS" } "We expect the predicted argument to no-temporary." &&
                                                                                                                                            assert_matches ${ environment-variable "EXPECTED_NO_TEMPORARY_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_NO_TEMPORARY_STANDARD_OUTPUT" } "We expect the predicted standard output to match.  It will be computed and not exact." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_NO_TEMPORARY_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_NO_TEMPORARY_STANDARD_ERROR" }" "We expect the predicted standard error to no-temporary." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_TEMPORARY_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_NO_TEMPORARY_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the no-temporary." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_TEMPORARY_STRIP" } ${ environment-variable "OBSERVED_NO_TEMPORARY_STRIP" } "We expect the the predicted strip value to the no-temporary." &&
                                                                                                                                            assert_equals "${ environment-variable "OBSERVED_NO_TEMPORARY_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_NO_TEMPORARY_TARGET" }" "We expect the no-temporary output to be as predicted." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_ARGUMENTS" } ${ environment-variable "OBSERVED_YES_TEMPORARY_ARGUMENTS" } "We expect the predicted argument to yes-temporary." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_INPUT" } ${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_INPUT" } "We expect the predicted standard input to yes-temporary." &&
                                                                                                                                            assert_matches ${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_OUTPUT" } "We expect the predicted standard output to yes-temporary." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_ERROR" }" "We expect the predicted standard error to yes-temporary." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_YES_TEMPORARY_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the yes_temporary." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_STRIP" } ${ environment-variable "OBSERVED_YES_TEMPORARY_STRIP" } "We expect the the predicted strip value to the yes_temporary." &&
                                                                                                                                            assert_equals "${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_YES_TEMPORARY_TARGET" }" "We expected the yes_temporary target to be as computed."
                                                                                                                                    '' ;
                                                                                                                        temp =
                                                                                                                            init : release : has-standard-input : arguments : standard-input :
                                                                                                                                let
                                                                                                                                    command =
                                                                                                                                        let
                                                                                                                                            to-string = t : if builtins.typeOf t == "bool" && t then "good" else if builtins.typeOf t == "bool" && ! t then "bad" else "null" ;
                                                                                                                                            in builtins.getAttr ( to-string release ) ( builtins.getAttr ( to-string init ) temporary.verification ) ;
                                                                                                                                    computed-assertion = if is-init then "assert_equals" else "assert_matches" ;
                                                                                                                                    computed-status = if is-init then "0" else "64" ;
                                                                                                                                    computed-standard-error = if is-init then "" else "We were unable to complete initiation:  \/build/[a-zA-Z0-9]{8}\.broken" ;
                                                                                                                                    computed-standard-output = if is-init then "\/build\/[a-zA-Z0-9]{8}\.resource\/target" else "\/build\/[a-zA-Z0-9]{8}\.broken\/target" ;
                                                                                                                                    computed-logs =
                                                                                                                                        let
                                                                                                                                            log-01 = if builtins.typeOf init == "bool" then "_init" else "WRONG_A" ;
                                                                                                                                            log-02 = builtins.concatStringsSep "" [ log-01 ( if builtins.typeOf init == "bool" && init && builtins.typeOf release == "bool" then "_release" else "" ) ( if builtins.typeOf init == "null" && builtins.typeOf release == "bool" then "_release" else "" ) ] ;
                                                                                                                                            log-03 = if builtins.typeOf init == "bool" then "_init_init" else "WRONG_C" ;
                                                                                                                                            in
                                                                                                                                                {
                                                                                                                                                    log-01 = log-01 ;
                                                                                                                                                    log-02 = log-02 ;
                                                                                                                                                    log-03 = log-03 ;
                                                                                                                                                    log-04 = log-03 ;
                                                                                                                                                    log-05 = log-02 ;
                                                                                                                                                    log-06 = log-02 ;
                                                                                                                                                    log-07 = log-02 ;
                                                                                                                                                } ;
                                                                                                                                    computed-06 =
                                                                                                                                        if has-standard-input then
                                                                                                                                            {
                                                                                                                                                assertions =
                                                                                                                                                    strip
                                                                                                                                                        ''
                                                                                                                                                            assert_matches ${ environment-variable "EXPECTED_06_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_06_STANDARD_OUTPUT" } "We expect the standard output of the comparison one (except standard input) to match." &&
                                                                                                                                                            ${ computed-assertion } "${ environment-variable "EXPECTED_06_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_06_STANDARD_ERROR" }" "We expect the standard error of the comparison one (except standard input) to match." &&
                                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_06_LOG" } ${ environment-variable "OBSERVED_06_LOG" } "We expect the log of the comparison one (except standard input) to match."
                                                                                                                                                        '' ;
                                                                                                                                                invocation =
                                                                                                                                                    strip
                                                                                                                                                        ''
                                                                                                                                                            ${ if has-standard-input then "" else "# " }assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.bash }/bin/bash -c \"${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } 06 | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } 03 > /build/$( ${ scripts.util.identity } 06 standard output file ) 2> /build/$( ${ scripts.util.identity } 06 standard error file )\"" "identical to the comparison one except for different standard input"
                                                                                                                                                        '' ;
                                                                                                                                                observeds =
                                                                                                                                                    strip
                                                                                                                                                        ''
                                                                                                                                                            OBSERVED_06_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 06 standard output file ) ) &&
                                                                                                                                                            OBSERVED_06_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 06 standard error file ) ) &&
                                                                                                                                                            OBSERVED_06_LOG=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS="${ environment-variable "ARGUMENTS" } 06" STANDARD_INPUT="${ if has-standard-input then "${ environment-variable "STANDARD_INPUT" } 03" else "" }" ${ scripts.util.identity } ) )
                                                                                                                                                            if [ -e ${ environment-variable "EXPECTED_06_STANDARD_OUTPUT" } ]
                                                                                                                                                            then
                                                                                                                                                                fail "WTF"
                                                                                                                                                            fi
                                                                                                                                                        '' ;
                                                                                                                                            }
                                                                                                                                        else
                                                                                                                                            {
                                                                                                                                                assertions = "# WE ARE NOT ASSERTING 06 BECAUSE WITHOUT STANDARD INPUT IT IS IDENTICAL." ;
                                                                                                                                                invocation = "# WE ARE NOT INVOCATING 06 BECAUSE WITHOUT STANDARD INPUT IT IS IDENTICAL." ;
                                                                                                                                                observeds = "# WE ARE NOT EXTRACTING OBSERVED FOR 06 BECAUSE WE DID NOT CREATE THOSE FILES." ;
                                                                                                                                            } ;
                                                                                                                                    is-init = if builtins.typeOf init == "bool" && ! init then false else true ;
                                                                                                                                    is-release = if is-init && builtins.typeOf release == "bool" && ! release then false else true ;
                                                                                                                                    not-equals =
                                                                                                                                        list :
                                                                                                                                            let
                                                                                                                                                assertions = builtins.map ( envir : "assert_not_equals ${ environment-variable envir.i } ${ environment-variable envir.j } \"We expect ${ envir.i } to be not equal to ${ envir.j }.\"" ) envir ;
                                                                                                                                                envir = builtins.map ( indices : { i = builtins.elemAt list ( indices.i ) ; j = builtins.elemAt list ( indices.j ) ; } ) indices ;
                                                                                                                                                indices = builtins.filter ( elem : elem.i < elem.j ) ( builtins.concatLists ( builtins.genList ( i : builtins.genList ( j : { i = i ; j = j ; } ) n ) n ) ) ;
                                                                                                                                                n = builtins.length list ;
                                                                                                                                                in builtins.concatStringsSep " && " assertions ;
                                                                                                                                    in
                                                                                                                                        strip
                                                                                                                                            ''
                                                                                                                                                export COMMAND=${ command } &&
                                                                                                                                                    export ARGUMENTS=${ arguments } &&
                                                                                                                                                    export STANDARD_INPUT=${ if has-standard-input then standard-input else "" } &&
                                                                                                                                                    EXPECTED_STATUS=${ computed-status } &&
                                                                                                                                                    EXPECTED_01_STANDARD_OUTPUT=${ computed-standard-output } &&
                                                                                                                                                    EXPECTED_01_STANDARD_ERROR="${ computed-standard-error }" &&
                                                                                                                                                    EXPECTED_01_LOG=${ computed-logs.log-01 } &&
                                                                                                                                                    EXPECTED_02_STANDARD_OUTPUT=${ computed-standard-output } &&
                                                                                                                                                    EXPECTED_02_STANDARD_ERROR="${ computed-standard-error }" &&
                                                                                                                                                    EXPECTED_02_LOG=${ computed-logs.log-02 } &&
                                                                                                                                                    EXPECTED_03_STANDARD_OUTPUT=${ computed-standard-output } &&
                                                                                                                                                    EXPECTED_03_STANDARD_ERROR="${ computed-standard-error }" &&
                                                                                                                                                    EXPECTED_03_LOG=${ computed-logs.log-03 } &&
                                                                                                                                                    EXPECTED_04_STANDARD_OUTPUT=${ computed-standard-output } &&
                                                                                                                                                    EXPECTED_04_STANDARD_ERROR="${ computed-standard-error }" &&
                                                                                                                                                    EXPECTED_04_LOG=${ environment-variable "EXPECTED_03_LOG" } &&
                                                                                                                                                    EXPECTED_05_STANDARD_OUTPUT=${ computed-standard-output } &&
                                                                                                                                                    EXPECTED_05_STANDARD_ERROR="${ computed-standard-error }" &&
                                                                                                                                                    EXPECTED_05_LOG=${ computed-logs.log-05 } &&
                                                                                                                                                    EXPECTED_06_STANDARD_OUTPUT=${ computed-standard-output } &&
                                                                                                                                                    EXPECTED_06_STANDARD_ERROR="${ computed-standard-error }" &&
                                                                                                                                                    EXPECTED_06_LOG=${ computed-logs.log-06 } &&
                                                                                                                                                    EXPECTED_07_STANDARD_OUTPUT=${ computed-standard-output } &&
                                                                                                                                                    EXPECTED_07_STANDARD_ERROR="${ computed-standard-error }" &&
                                                                                                                                                    EXPECTED_07_LOG=${ computed-logs.log-07 } &&
                                                                                                                                                    assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } 01 | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } 01 > /build/$( ${ scripts.util.identity } 01 standard output file ) 2> /build/$( ${ scripts.util.identity } 01 standard error file )" "the process one." &&
                                                                                                                                                    assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.bash }/bin/bash -c \"${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } 02 | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } 02 > /build/$( ${ scripts.util.identity } 02 standard output file ) 2> /build/$( ${ scripts.util.identity } 02 standard error file )\"" "model one" &&
                                                                                                                                                    assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.bash }/bin/bash -c \"${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } 03 | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } 03 > /build/$( ${ scripts.util.identity } 03 standard output file ) 2> /build/$( ${ scripts.util.identity } 03 standard error file )\"" "comparison one" &&
                                                                                                                                                    assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.bash }/bin/bash -c \"${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } 03 | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } 03 > /build/$( ${ scripts.util.identity } 04 standard output file ) 2> /build/$( ${ scripts.util.identity } 04 standard error file )\"" "identical to the comparison one" &&
                                                                                                                                                    assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.bash }/bin/bash -c \"${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } 03 | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } 05 > /build/$( ${ scripts.util.identity } 05 standard output file ) 2> /build/$( ${ scripts.util.identity } 05 standard error file )\"" "identical to the comparison one except for different arguments" &&
                                                                                                                                                    ${ computed-06.invocation } &&
                                                                                                                                                    assert_status_code ${ environment-variable "EXPECTED_STATUS" } "${ pkgs.bash }/bin/bash -c \"${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } 07 | " else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } 07 > /build/$( ${ scripts.util.identity } 07 standard output file ) 2> /build/$( ${ scripts.util.identity } 07 standard error file )\"" "identical to the comparison one except for different arguments and standard input" &&
                                                                                                                                                    OBSERVED_01_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 01 standard output file ) ) &&
                                                                                                                                                    OBSERVED_01_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 01 standard error file ) ) &&
                                                                                                                                                    OBSERVED_01_LOG=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS="${ environment-variable "ARGUMENTS" } 01" STANDARD_INPUT="${ if has-standard-input then "${ environment-variable "STANDARD_INPUT" } 01" else "" }" ${ scripts.util.identity } ) ) &&
                                                                                                                                                    OBSERVED_02_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 02 standard output file ) ) &&
                                                                                                                                                    OBSERVED_02_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 02 standard error file ) ) &&
                                                                                                                                                    OBSERVED_02_LOG=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS="${ environment-variable "ARGUMENTS" } 02" STANDARD_INPUT="${ if has-standard-input then "${ environment-variable "STANDARD_INPUT" } 02" else "" }" ${ scripts.util.identity } ) ) &&
                                                                                                                                                    OBSERVED_03_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 03 standard output file ) ) &&
                                                                                                                                                    OBSERVED_03_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 03 standard error file ) ) &&
                                                                                                                                                    OBSERVED_03_LOG=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS="${ environment-variable "ARGUMENTS" } 03" STANDARD_INPUT="${ if has-standard-input then "${ environment-variable "STANDARD_INPUT" } 03" else "" }" ${ scripts.util.identity } ) ) &&
                                                                                                                                                    OBSERVED_04_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 04 standard output file ) ) &&
                                                                                                                                                    OBSERVED_04_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 04 standard error file ) ) &&
                                                                                                                                                    OBSERVED_04_LOG=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS="${ environment-variable "ARGUMENTS" } 03" STANDARD_INPUT="${ if has-standard-input then "${ environment-variable "STANDARD_INPUT" } 03" else "" }" ${ scripts.util.identity } ) ) &&
                                                                                                                                                    OBSERVED_05_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 05 standard output file ) ) &&
                                                                                                                                                    OBSERVED_05_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 05 standard error file ) ) &&
                                                                                                                                                    OBSERVED_05_LOG=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS="${ environment-variable "ARGUMENTS" } 05" STANDARD_INPUT="${ if has-standard-input then "${ environment-variable "STANDARD_INPUT" } 03" else "" }" ${ scripts.util.identity } ) ) &&
                                                                                                                                                    ${ computed-06.observeds } &&
                                                                                                                                                    OBSERVED_07_STANDARD_OUTPUT=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 07 standard output file ) ) &&
                                                                                                                                                    OBSERVED_07_STANDARD_ERROR=$( ${ pkgs.coreutils }/bin/cat /build/$( ${ scripts.util.identity } 07 standard error file ) ) &&
                                                                                                                                                    OBSERVED_07_LOG=$( ${ pkgs.coreutils }/bin/cat /build/$( ARGUMENTS="${ environment-variable "ARGUMENTS" } 07" STANDARD_INPUT="${ if has-standard-input then "${ environment-variable "STANDARD_INPUT" } 07" else "" }" ${ scripts.util.identity } ) ) &&
                                                                                                                                                    assert_matches ${ environment-variable "EXPECTED_01_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_01_STANDARD_OUTPUT" } "We expect the standard output of the process one to match." &&
                                                                                                                                                    ${ computed-assertion } "${ environment-variable "EXPECTED_01_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_01_STANDARD_ERROR" }" "We expect the standard error of the process one to match." &&
                                                                                                                                                    assert_equals ${ environment-variable "EXPECTED_01_LOG" } ${ environment-variable "OBSERVED_01_LOG" } "We expect the log of the process one to match." &&
                                                                                                                                                    if [ -e ${ environment-variable "EXPECTED_02_STANDARD_OUTPUT" } ]
                                                                                                                                                    then
                                                                                                                                                        fail "WTF"
                                                                                                                                                    fi &&
                                                                                                                                                    assert_matches "${ environment-variable "EXPECTED_02_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_02_STANDARD_OUTPUT" }" "We expect the standard output of the model one to match." &&
                                                                                                                                                    ${ computed-assertion } "${ environment-variable "EXPECTED_02_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_02_STANDARD_ERROR" }" "We expect the standard error of the model one to match." &&
                                                                                                                                                    assert_equals "${ environment-variable "EXPECTED_02_LOG" }" "${ environment-variable "OBSERVED_02_LOG" }" "We expect the log of the model one to match." &&
                                                                                                                                                    assert_matches ${ environment-variable "EXPECTED_03_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_03_STANDARD_OUTPUT" } "We expect the standard output of the comparison one to match." &&
                                                                                                                                                    ${ computed-assertion } "${ environment-variable "EXPECTED_03_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_03_STANDARD_ERROR" }" "We expect the standard error of the comparison one to match." &&
                                                                                                                                                    assert_equals ${ environment-variable "EXPECTED_03_LOG" } ${ environment-variable "OBSERVED_03_LOG" } "We expect the log of the comparison one to match." &&
                                                                                                                                                    if [ -e ${ environment-variable "EXPECTED_03_STANDARD_OUTPUT" } ]
                                                                                                                                                    then
                                                                                                                                                        fail "WTF"
                                                                                                                                                    fi &&
                                                                                                                                                    assert_matches ${ environment-variable "EXPECTED_04_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_04_STANDARD_OUTPUT" } "We expect the standard output of the identical match." &&
                                                                                                                                                    ${ computed-assertion } "${ environment-variable "EXPECTED_04_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_04_STANDARD_ERROR" }" "We expect the standard error of the identical one to match." &&
                                                                                                                                                    assert_equals ${ environment-variable "EXPECTED_04_LOG" } ${ environment-variable "OBSERVED_04_LOG" } "We expect the log of the identical one to match." &&
                                                                                                                                                    if [ -e ${ environment-variable "EXPECTED_04_STANDARD_OUTPUT" } ]
                                                                                                                                                    then
                                                                                                                                                        fail "WTF"
                                                                                                                                                    fi &&
                                                                                                                                                    assert_matches ${ environment-variable "EXPECTED_05_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_05_STANDARD_OUTPUT" } "We expect the standard output of the comparison one (except arguments) to match." &&
                                                                                                                                                    ${ computed-assertion } "${ environment-variable "EXPECTED_05_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_05_STANDARD_ERROR" }" "We expect the standard error of the comparison one (except arguments) to match." &&
                                                                                                                                                    assert_equals ${ environment-variable "EXPECTED_05_LOG" } ${ environment-variable "OBSERVED_05_LOG" } "We expect the log of the comparison one (except arguments)" &&
                                                                                                                                                    if [ -e ${ environment-variable "EXPECTED_05_STANDARD_OUTPUT" } ]
                                                                                                                                                    then
                                                                                                                                                        fail "WTF"
                                                                                                                                                    fi &&
                                                                                                                                                    ${ computed-06.assertions } &&
                                                                                                                                                    assert_matches "${ environment-variable "EXPECTED_07_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_07_STANDARD_OUTPUT" }" "We expect the standard output of the comparison one (except arguments and standard input) to match." &&
                                                                                                                                                    ${ computed-assertion } "${ environment-variable "EXPECTED_07_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_07_STANDARD_ERROR" }" "We expect the standard error of the comparison one (except arguments and standard input) to match." &&
                                                                                                                                                    assert_equals ${ environment-variable "EXPECTED_07_LOG" } ${ environment-variable "OBSERVED_07_LOG" }  "We expect the standard error of the comparison one (except arguments and standard input) to match." &&
                                                                                                                                                    if [ -e ${ environment-variable "EXPECTED_07_STANDARD_OUTPUT" } ]
                                                                                                                                                    then
                                                                                                                                                        fail "WTF"
                                                                                                                                                    fi &&
                                                                                                                                                    ${ not-equals [ "OBSERVED_01_STANDARD_OUTPUT" "OBSERVED_02_STANDARD_OUTPUT" "OBSERVED_03_STANDARD_OUTPUT" "OBSERVED_04_STANDARD_OUTPUT" "OBSERVED_05_STANDARD_OUTPUT" "OBSERVED_06_OUTPUT" "OBSERVED_07_STANDARD_OUTPUT" ] }
                                                                                                                                            '' ;
                                                                                                                        in
                                                                                                                            [
                                                                                                                                ( script true true )
                                                                                                                                ( script true false )
                                                                                                                                ( script false true )
                                                                                                                                ( script false false )
                                                                                                                                ( temp false false false )
                                                                                                                                ### ( temp false false true )
                                                                                                                                ( temp false true false )
                                                                                                                                ### ( temp false true true )
                                                                                                                                ( temp false null false )
                                                                                                                                ### ( temp false null true )
                                                                                                                                #### ( temp true false false )
                                                                                                                                ### ( temp true false true )
                                                                                                                                # ( temp true true false )
                                                                                                                                ### ( temp true true true )
                                                                                                                                ( temp true null false )
                                                                                                                                ### ( temp true null true )
                                                                                                                            ] ;
                                                                                                                in builtins.genList generator ( builtins.length list ) ;
                                                                                                        in builtins.concatStringsSep " &&\n" functions ;
                                                                                            util =
                                                                                                {
                                                                                                    identity =
                                                                                                        { pkgs , ... } : { environment-variable , strip , ... } :
                                                                                                            ''
                                                                                                                IDENTITY=$( ${ pkgs.coreutils }/bin/echo -n "-${ environment-variable "ARGUMENTS" }-${ environment-variable "STANDARD_INPUT" }-" | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n "${ environment-variable "IDENTITY" } ${ environment-variable "@" }" | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128
                                                                                                            '' ;
                                                                                                    write =
                                                                                                        { pkgs , ... } : { environment-variable , ... } :
                                                                                                            ''
                                                                                                                if [ -e ${ environment-variable "@" } ]
                                                                                                                then
                                                                                                                    ${ pkgs.coreutils }/bin/echo We can not write to ${ environment-variable "@" } because it already has content. >&2 &&
                                                                                                                        exit 65
                                                                                                                else
                                                                                                                    ${ pkgs.coreutils }/bin/tee > ${ environment-variable "@" } &&
                                                                                                                        ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "@" }
                                                                                                                fi
                                                                                                            '' ;
                                                                                                } ;
                                                                                            verification =
                                                                                                let
                                                                                                    internal =
                                                                                                        status : { pkgs , ... } : { cache , environment-variable , has-standard-input , scripts , strip , target , temporary } :
                                                                                                            ''
                                                                                                                export ARGUMENTS=${ environment-variable "@" } &&
                                                                                                                    if ${ has-standard-input }
                                                                                                                    then
                                                                                                                        export STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee )
                                                                                                                    else
                                                                                                                        export STANDARD_INPUT=""
                                                                                                                    fi &&
                                                                                                                    ${ scripts.util.identity } standard output &&
                                                                                                                    ${ scripts.util.identity } standard error >&2 &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo "${ builtins.concatStringsSep "," ( builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( mapper [ ] ) { cache = cache ; scripts = scripts ; temporary = temporary ; } ) ) ) }" | ${ scripts.util.write } /build/$( ${ scripts.util.identity } scripts file ) &&
                                                                                                                    NO_CACHE_ARGUMENTS=$( ${ scripts.util.identity } no-cache arguments ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "NO_CACHE_ARGUMENTS" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-cache arguments file ) &&
                                                                                                                    ${ cache.null } ${ environment-variable "NO_CACHE_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-cache standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-cache standard error file ) ) &&
                                                                                                                    YES_CACHE_ARGUMENTS=$( ${ scripts.util.identity } yes-cache arguments ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_CACHE_ARGUMENTS" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache arguments file ) &&
                                                                                                                    YES_CACHE_STANDARD_INPUT=$( ${ scripts.util.identity } yes-cache standard input ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_CACHE_STANDARD_INPUT" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache standard input file ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_CACHE_STANDARD_INPUT" } | ${ cache.null } ${ environment-variable "YES_CACHE_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache standard error file ) ) &&
                                                                                                                    NO_SCRIPT_ARGUMENTS=$( ${ scripts.util.identity } no-script arguments ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "NO_SCRIPT_ARGUMENTS" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-script arguments file ) &&
                                                                                                                    ${ scripts.verification.terminal } ${ environment-variable "NO_SCRIPT_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-script standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-script standard error file ) ) &&
                                                                                                                    YES_SCRIPT_ARGUMENTS=$( ${ scripts.util.identity } yes-script arguments ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_SCRIPT_ARGUMENTS" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-script arguments file ) &&
                                                                                                                    YES_SCRIPT_STANDARD_INPUT=$( ${ scripts.util.identity } yes-script standard input ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_SCRIPT_STANDARD_INPUT" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-script standard input file ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_SCRIPT_STANDARD_INPUT" } | ${ scripts.verification.terminal } ${ environment-variable "YES_SCRIPT_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-script standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-script standard error file ) ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ strip ( wild "715f817552f2e98e7e0ef267a8da8a762f4ad673c6dbc95c0a20a7d8c87cf078eb6f8d79cff71ea7fd981c05251dc238827abce2488ccda42887654026dd604d" ) } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } strip file )
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } target file ) &&
                                                                                                                    NO_TEMPORARY_ARGUMENTS=$( ${ scripts.util.identity } no-temporary arguments ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "NO_TEMPORARY_ARGUMENTS" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-temporary arguments file ) &&
                                                                                                                    ${ temporary.null } ${ environment-variable "NO_TEMPORARY_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-temporary standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-temporary standard error file ) ) &&
                                                                                                                    YES_TEMPORARY_ARGUMENTS=$( ${ scripts.util.identity } yes-temporary arguments ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_TEMPORARY_ARGUMENTS" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-temporary arguments file ) &&
                                                                                                                    YES_TEMPORARY_STANDARD_INPUT=$( ${ scripts.util.identity } yes-temporary standard input ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_TEMPORARY_STANDARD_INPUT" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-temporary standard input file ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_TEMPORARY_STANDARD_INPUT" } | ${ temporary.null } ${ environment-variable "YES_TEMPORARY_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-temporary standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-temporary standard error file ) ) &&
                                                                                                                    exit ${ builtins.toString status }
                                                                                                            '' ;
                                                                                                    mapper =
                                                                                                        path : name : value :
                                                                                                            if builtins.typeOf value == "string" then [ "${ builtins.concatStringsSep "." ( builtins.concatLists [ path [ name ] ] ) }=${ value }" ]
                                                                                                            else builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ) ) ;
                                                                                                    ###
                                                                                                    temporary =
                                                                                                        message : status : { pkgs , ... } : { environment-variable , has-standard-input , scripts , target , ... } :
                                                                                                            ''
                                                                                                                if [ ! -f ${ environment-variable target } ]
                                                                                                                then
                                                                                                                    export ARGUMENTS=${ environment-variable "@" } &&
                                                                                                                    if ${ has-standard-input }
                                                                                                                    then
                                                                                                                        export STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee )
                                                                                                                    else
                                                                                                                        export STANDARD_INPUT=""
                                                                                                                    fi &&
                                                                                                                    ${ pkgs.coreutils }/bin/ln --symbolic /build/$( ${ scripts.util.identity } ) ${ environment-variable target }
                                                                                                                fi &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n "_${ message }" >> ${ environment-variable target } &&
                                                                                                                        exit ${ builtins.toString status }
                                                                                                            '' ;
                                                                                                    terminal =
                                                                                                        { pkgs , ... } : { cache , environment-variable , has-standard-input , scripts , strip , target , temporary } :
                                                                                                            ''
                                                                                                                export ARGUMENTS=${ environment-variable "@" } &&
                                                                                                                    if ${ has-standard-input }
                                                                                                                    then
                                                                                                                        export STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee )
                                                                                                                    else
                                                                                                                        export STANDARD_INPUT=""
                                                                                                                    fi &&
                                                                                                                    ${ scripts.util.identity } standard output &&
                                                                                                                    ${ scripts.util.identity } standard error >&2
                                                                                                                    ${ pkgs.coreutils }/bin/echo "${ builtins.concatStringsSep "," ( builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs ( mapper [ ] ) { cache = cache ; scripts = scripts ; temporary = temporary ; } ) ) ) }" | ${ scripts.util.write } /build/$( ${ scripts.util.identity } scripts file ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ strip ( wild "2595332087bd2ebeebd3624af4be8541452ade795cb047b32a296dafb68375723b7e2b523855bb45b4770ae3ac811b6462f378a4b88477770bac7afb17979eed" ) } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } strip file )
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } target file )
                                                                                                            '' ;
                                                                                                    wild =
                                                                                                        middle :
                                                                                                            ''

                                                                                                                ${ middle }

                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = internal 64 ;
                                                                                                            good = internal 0 ;
                                                                                                            temporary =
                                                                                                                {
                                                                                                                    init =
                                                                                                                        {
                                                                                                                            bad = temporary "init" 66 ;
                                                                                                                            good = temporary "init" 0 ;
                                                                                                                        } ;
                                                                                                                    release =
                                                                                                                        {
                                                                                                                            bad = temporary "release" 67 ;
                                                                                                                            good = temporary "release" 0 ;
                                                                                                                        } ;
                                                                                                                } ;
                                                                                                            terminal = terminal ;
                                                                                                        } ;
                                                                                        } ;
                                                                                target = "c8725e4d573bd4d32254ea39a3fb3c77a823eb505445f5d4299e4a6d26fda26ee71af14503e1b6c401618b5cf7e6789ad0777ddd9e7eb0a9df7a6c61e119c089" ;
                                                                                temporary =
                                                                                    {
                                                                                        null = scripts : { init = scripts.verification.terminal ; } ;
                                                                                        verification =
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
                                                                                                null =
                                                                                                    {
                                                                                                        bad = scripts : { release = scripts.verification.temporary.release.bad ; } ;
                                                                                                        good = scripts : { release = scripts.verification.temporary.release.good ; } ;
                                                                                                        null = scripts : { } ;
                                                                                                    } ;
                                                                                            } ;
                                                                                    } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            export ${ out }=${ builtins.trace ( builtins.toString resources ) resources } &&
                                                                            ${ pkgs.bash_unit }/bin/bash_unit ${ builtins.toString resources }/scripts/test.sh
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
