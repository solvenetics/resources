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
                                    cache-directory ? environment-variable "TMPDIR" ,
                                    cache-epoch-hash ? "cc3be3d5e123a64b31bd74e9d3e3a4e13337ad02c5d3b622af5094688f9255b773448e911a4bf1fb156e2a05ea599108f96ac0e056cbb27d489d6f9cc4c2324a" ,
                                    cache-init-error-code ? 64 ,
                                    cache-init-error-message ? "We were unable to instantiate:  ${ environment-variable "WORK_DIR" }" ,
                                    cache-lock-exit ? 64 ,
                                    cache-lock-message ? "We were unable to lock the cache." ,
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
                                                                                        ${ pkgs.coreutils }/bin/mv ${ cache-directory }/${ environment-variable cache-epoch-hash } ${ environment-variable cache-work-directory } &&
                                                                                        ${ pkgs.flock }/bin/flock -u 10 &&
                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "WORK_DIRECTORY" } -mindepth 1 -maxdepth 1 -type f -name "*.pid" | while read PID_FILE
                                                                                        do
                                                                                            PID=${ environment-variable "PID_FILE*.%" } &&
                                                                                                ${ pkgs.coreutils }/bin/tail --follow /dev/null --pid ${ environment-variable "PID" } &&
                                                                                                ${ pkgs.coreutils }/bin/rm ${ environment-variable "PID_FILE" }
                                                                                        done &&
                                                                                        ${ pkgs.findutils }/bin/find ${ environment-variable "WORK_DIRECTORY" } -mindepth 1 -maxdepth 1 -type f -name "*.cache" | while read CACHE_FILE
                                                                                        do
                                                                                            ${ environment-variable "CACHE_LINK" }/clear.sh &&
                                                                                                ${ pkgs.coreutils }/bin/rm ${ environment-variable "CACHE_LINK" }
                                                                                        done &&
                                                                                        ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable "WORK_DIRECTORY" }
                                                                                '' ;
                                                                            hook =
                                                                                let
                                                                                    populate =
                                                                                        let
                                                                                            identity =
                                                                                                {
                                                                                                    cache ? cache-default-epoch
                                                                                                    temporary
                                                                                                } :
                                                                                                    {
                                                                                                        temporary = temporary tertiary.temporary ;
                                                                                                        validity = builtins.toString cache ;
                                                                                                    } ;
                                                                                            in value identity ;
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
                                                                                                PARENT_EPOCH_HASH=${ environment-variable cache-epoch-hash } &&
                                                                                                export ${ cache-epoch-hash }=$( ${ pkgs.coreutils }/bin/echo -n $(( ${ environment-variable cache-timestamp } / ${ builtins.trace "HI" "60" } )) $( ${ pkgs.coreutils }/bin/whoami ) | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -0 ) &&
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

                                                                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ cache-directory }/${ environment-variable cache-epoch-hash }/clear ${ environment-variable "WORK_DIRECTORY" }/link &&
                                                                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "clear" clear } ${ environment-variable "WORK_DIRECTORY" }/clear &&
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "WORK_DIRECTORY" }/arguments ${ environment-variable "WORK_DIRECTORY" }/has-standard-input ${ environment-variable "WORK_DIRECTORY" }/standard-input &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ pkgs.writeShellScript "manage" manage } ${ environment-variable "WORK_DIRECTORY" } | ${ at } now &&
                                                                                                            ${ pkgs.inotify-tools }/bin/inotifywait --event create ${ environment-variable "WORK_DIRECTORY" }/flag > /dev/null 2>&1 &&
                                                                                                            if [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIRECTORY" }/status ) == 0 ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/mv ${ environment-variable "WORK_DIRECTORY" } ${ cache-directory }/${ environment-variable cache-epoch-hash }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "WORK_DIRECTORY" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo "${ cache-init-error-message }" >&2 &&
                                                                                                                    exit ${ builtins.toString cache-init-error-code }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/true
                                                                                                    fi
                                                                                                else
                                                                                                    ${ pkgs.coreutils }/bin/echo "${ cache-lock-message }" >&2 &&
                                                                                                        exit ${ builtins.toString cache-lock-exit }
                                                                                                fi &&
                                                                                                ${ pkgs.coreutils }/bin/true
                                                                                        '' ;
                                                                            manage =
                                                                                ''
                                                                                    WORK_DIRECTORY=${ environment-variable "@" } &&
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
                                                                                            SLEEP=$(( $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "WORK_DIRECTORY" }/epoch ) - $( ${ pkgs.coreutils }/bin/date +%s ) ))
                                                                                        else
                                                                                            SLEEP=0
                                                                                        fi &&
                                                                                        CLEAR=$( ${ pkgs.coreutils }/bin/readlink ${ environment-variable "WORK_DIRECTORY" }/link ) &&
                                                                                        ${ pkgs.coreutils }/bin/touch ${ environment-variable "WORK_DIRECTORY" }/flag &&
                                                                                        ${ pkgs.coreutils }/bin/sleep ${ environment-variable "SLEEP" } &&
                                                                                        if [ ${ environment-variable "STATUS" } == 0 ] && [ -x ${ environment-variable "CLEAR" } ]
                                                                                        then
                                                                                            ${ environment-variable "CLEAR" }
                                                                                        fi
                                                                                '' ;
                                                                            in strip hook
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
                                                                                        ${ pkgs.coreutils }/bin/tee &
                                                                                    '' ;
                                                                            cache =
                                                                                {
                                                                                    null = temporary : { temporary = temporary.null ; epoch = 2 ; } ;
                                                                                } ;
                                                                            out = out ;
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            scripts =
                                                                                let
                                                                                    seed = "9e1080281ac5543c0bee9e50d6349afe5b0e26644c57d52faed76cc17905f2928613bb17e3549a648297696971ceb10f2d8811aee353cc23bd0e9833d392a022" ;
                                                                                    in
                                                                                        {
                                                                                            test =
                                                                                                { pkgs , ... } : { environment-variable , scripts , strip , ... } :
                                                                                                    let
                                                                                                        functions =
                                                                                                            let
                                                                                                                generator =
                                                                                                                    index :
                                                                                                                        strip
                                                                                                                            ''
                                                                                                                                test_${ builtins.toString index } ( )
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
                                                                                                                                            EXPECTED_SCRIPTS_FILE="cache.null=${ environment-variable out }/cache/null,scripts.test=${ environment-variable out }/scripts/test,scripts.util.identity=${ environment-variable out }/scripts/util/identity,scripts.util.write=${ environment-variable out }/scripts/util/write,scripts.verification.bad=${ environment-variable out }/scripts/verification/bad,scripts.verification.good=${ environment-variable out }/scripts/verification/good,scripts.verification.temporary.init=${ environment-variable out }/scripts/verification/temporary/init,scripts.verification.temporary.release=${ environment-variable out }/scripts/verification/temporary/release,scripts.verification.terminal=${ environment-variable out }/scripts/verification/terminal,temporary.null=${ environment-variable out }/temporary/null,temporary.verification.good=${ environment-variable out }/temporary/verification/good" &&
                                                                                                                                            EXPECTED_STRIP="715f817552f2e98e7e0ef267a8da8a762f4ad673c6dbc95c0a20a7d8c87cf078eb6f8d79cff71ea7fd981c05251dc238827abce2488ccda42887654026dd604d" &&
                                                                                                                                            EXPECTED_TARGET="${ environment-variable "c8725e4d573bd4d32254ea39a3fb3c77a823eb505445f5d4299e4a6d26fda26ee71af14503e1b6c401618b5cf7e6789ad0777ddd9e7eb0a9df7a6c61e119c089" }" &&
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
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_ARGUMENTS" } ${ environment-variable "OBSERVED_NO_SCRIPT_ARGUMENTS" } "We expect the predicted argument to no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_NO_SCRIPT_STANDARD_OUTPUT" } "We expect the predicted standard output to no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_STANDARD_ERROR" } ${ environment-variable "OBSERVED_NO_SCRIPT_STANDARD_ERROR" } "We expect the predicted standard error to no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_NO_SCRIPT_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the NO_SCRIPT." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_SCRIPT_STRIP" } ${ environment-variable "OBSERVED_NO_SCRIPT_STRIP" } "We expect the the predicted strip value to the NO_SCRIPT." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_NO_SCRIPTS_TARGET" }" "${ environment-variable "OBSERVED_NO_SCRIPT_TARGET" }" "We expected the NO_SCRIPT target to be blank." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_ARGUMENTS" } ${ environment-variable "OBSERVED_YES_SCRIPT_ARGUMENTS" } "We expect the predicted argument to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_INPUT" } ${ environment-variable "OBSERVED_YES_SCRIPT_STANDARD_INPUT" } "We expect the predicted standard input to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_YES_SCRIPT_STANDARD_OUTPUT" } "We expect the predicted standard output to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STANDARD_ERROR" } ${ environment-variable "OBSERVED_YES_SCRIPT_STANDARD_ERROR" } "We expect the predicted standard error to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_YES_SCRIPT_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the yes_SCRIPT." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_SCRIPT_STRIP" } ${ environment-variable "OBSERVED_YES_SCRIPT_STRIP" } "We expect the the predicted strip value to the yes_SCRIPT." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_YES_SCRIPTS_TARGET" }" "${ environment-variable "OBSERVED_YES_SCRIPT_TARGET" }" "We expected the yes_SCRIPT target to be blank." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_TEMPORARY_ARGUMENTS" } ${ environment-variable "OBSERVED_NO_TEMPORARY_ARGUMENTS" } "We expect the predicted argument to no-script." &&
                                                                                                                                            assert_matches ${ environment-variable "EXPECTED_NO_TEMPORARY_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_NO_TEMPORARY_STANDARD_OUTPUT" } "We expect the predicted standard output to no-script." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_NO_TEMPORARY_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_NO_TEMPORARY_STANDARD_ERROR" }" "We expect the predicted standard error to no-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_TEMPORARY_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_NO_TEMPORARY_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the NO_SCRIPT." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_NO_TEMPORARY_STRIP" } ${ environment-variable "OBSERVED_NO_TEMPORARY_STRIP" } "We expect the the predicted strip value to the NO_SCRIPT." &&
                                                                                                                                            assert_equals "${ environment-variable "OBSERVED_NO_TEMPORARY_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_NO_TEMPORARY_TARGET" }" "We expected the NO_SCRIPT target to be blank." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_ARGUMENTS" } ${ environment-variable "OBSERVED_YES_TEMPORARY_ARGUMENTS" } "We expect the predicted argument to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_INPUT" } ${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_INPUT" } "We expect the predicted standard input to yes-script." &&
                                                                                                                                            assert_matches ${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_OUTPUT" } ${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_OUTPUT" } "We expect the predicted standard output to yes-script." &&
                                                                                                                                            assert_equals "${ environment-variable "EXPECTED_YES_TEMPORARY_STANDARD_ERROR" }" "${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_ERROR" }" "We expect the predicted standard error to yes-script." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_SCRIPTS_FILE" } ${ environment-variable "OBSERVED_YES_TEMPORARY_SCRIPTS_FILE" } "We expect the predicted scripts to be available to the yes_SCRIPT." &&
                                                                                                                                            assert_equals ${ environment-variable "EXPECTED_YES_TEMPORARY_STRIP" } ${ environment-variable "OBSERVED_YES_TEMPORARY_STRIP" } "We expect the the predicted strip value to the yes_SCRIPT." &&
                                                                                                                                            assert_equals "${ environment-variable "OBSERVED_YES_TEMPORARY_STANDARD_OUTPUT" }" "${ environment-variable "OBSERVED_YES_TEMPORARY_TARGET" }" "We expected the yes_SCRIPT target to be blank."
                                                                                                                                    '' ;
                                                                                                                        temporary =
                                                                                                                            delta : has-standard-input : arguments : standard-input :
                                                                                                                                ''
                                                                                                                                    export COMMAND=${ temporary.verification.good } &&
                                                                                                                                        export ARGUMENTS=${ arguments } &&
                                                                                                                                        export STANDARD_INPUT=${ if has-standard-input then standard-input else "" } &&
                                                                                                                                        IDENTITY=$( ${ scripts.util.identity } ) &&
                                                                                                                                        EXPECTED="init release" &&
                                                                                                                                        assert_status_code 0 "${ if has-standard-input then "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } |" else "" }${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" }" &&
                                                                                                                                        OBSERVED=$( ${ pkgs.coreutils }/bin/cat /build/${ environment-variable "IDENTITY" } ) &&
                                                                                                                                        assert_equals ${ environment-variable "EXPECTED" } ${ environment-variable "OBSERVED" }
                                                                                                                                '' ;
                                                                                                                        in
                                                                                                                            [
                                                                                                                                ( script true true )
                                                                                                                                ( script true false )
                                                                                                                                ( script false true )
                                                                                                                                ( script false false )
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
                                                                                                                    # ${ cache.null } ${ environment-variable "NO_CACHE_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-cache standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } no-cache standard error file ) ) &&
                                                                                                                    YES_CACHE_ARGUMENTS=$( ${ scripts.util.identity } yes-cache arguments ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_CACHE_ARGUMENTS" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache arguments file ) &&
                                                                                                                    YES_CACHE_STANDARD_INPUT=$( ${ scripts.util.identity } yes-cache standard input ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_CACHE_STANDARD_INPUT" } | ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache standard input file ) &&
                                                                                                                    # ${ pkgs.coreutils }/bin/echo ${ environment-variable "YES_CACHE_STANDARD_INPUT" } | ${ cache.null } ${ environment-variable "YES_CACHE_ARGUMENTS" } > >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache standard output file ) ) 2> >( ${ scripts.util.write } /build/$( ${ scripts.util.identity } yes-cache standard error file ) ) &&



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
                                                                                                    temporary =
                                                                                                        {
                                                                                                            init =
                                                                                                                { pkgs , ... } : { environment-variable , scripts , target , ... } :
                                                                                                                    ''
                                                                                                                        IDENTITY=$( ${ scripts.util.identity } ) &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "IDENTITY" } | ${ scripts.util.write } ${ target } &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo -e INIT > /build/${ environment-variable "IDENTITY" }
                                                                                                                    '' ;
                                                                                                            release =
                                                                                                                { pkgs , ... } : { environment-variable , target , ... } :
                                                                                                                    ''
                                                                                                                        IDENTITY=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable target } ) &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo -e _RELEASE >> /build/${ environment-variable "IDENTITY" }
                                                                                                                    '' ;
                                                                                                        } ;
                                                                                                    wild =
                                                                                                        middle :
                                                                                                            ''

                                                                                                                ${ middle }

                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = internal 64 ;
                                                                                                            good = internal 0 ;
                                                                                                            temporary = temporary ;
                                                                                                            terminal = terminal ;
                                                                                                        } ;
                                                                                        } ;
                                                                                target = "c8725e4d573bd4d32254ea39a3fb3c77a823eb505445f5d4299e4a6d26fda26ee71af14503e1b6c401618b5cf7e6789ad0777ddd9e7eb0a9df7a6c61e119c089" ;
                                                                                temporary =
                                                                                    {
                                                                                        null = scripts : { init = scripts.verification.terminal ; } ;
                                                                                        verification =
                                                                                            {
                                                                                                good = scripts : { init = scripts.verification.temporary.init ; release = scripts.verification.temporary.release ; } ;
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
