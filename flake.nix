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
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PARENT_PID" } | ${ at } now > /dev/null 2>&1
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                '' ;
                                                                                            has-standard-input =
                                                                                                ''
                                                                                                    GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PARENT_PID" } ) &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "GRANDPARENT_PID" } | ${ at } now > /dev/null 2>&1 &&
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                                '' ;
                                                                                        }
                                                                                    else
                                                                                        {
                                                                                            does-not-have-standard-input =
                                                                                                ''
                                                                                                    if [ "${ builtins.typeOf temporary.init }" == "null" ] || ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PARENT_PID" } | ${ at } now > /dev/null 2>&1
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
                                                                                            has-standard-input =
                                                                                                ''
                                                                                                    if ${ pkgs.coreutils }/bin/tee | ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                            GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PARENT_PID" } ) &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "GRANDPARENT_PID" } | ${ at } now > /dev/null 2>&1 &&
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
                                                                resources =
                                                                    lib
                                                                        {
                                                                            at =
                                                                                pkgs.writeShellScript
                                                                                    "at"
                                                                                    ''
                                                                                        ${ pkgs.bash }/bin/bash -c "$( ${ pkgs.coreutils }/bin/tee )" > /dev/null 2>&1 &
                                                                                    '' ;
                                                                            scripts =
                                                                                {
                                                                                    alpha =
                                                                                        { pkgs , environment-variable , has-standard-input , ... } :
                                                                                            ''
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } > ${ environment-variable "ARGUMENTS_TARGET" } &&
                                                                                                    if ${ has-standard-input }
                                                                                                    then
                                                                                                       ${ pkgs.coreutils }/bin/tail > ${ environment-variable "STANDARD_INPUT_TARGET" }
                                                                                                    fi &&
                                                                                                    exit ${ environment-variable "EXIT" }
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
                                                                                                        { constant-hash , environment-variable , epoch-hash , epoch-timestamp , has-standard-input , pkgs , target , ... } : exit :
                                                                                                            ''
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable epoch-timestamp } > ${ environment-variable "INIT_EPOCH_TIMESTAMP" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable epoch-hash } > ${ environment-variable "INIT_EPOCH_HASH" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable constant-hash } > ${ environment-variable "INIT_CONSTANT_HASH" } &&
                                                                                                                    exit ${ builtins.toString exit }
                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = primary : gamma primary 64 ;
                                                                                                            good = primary : gamma primary 0 ;
                                                                                                        } ;
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
                                                                                                        { constant-hash , environment-variable , epoch-hash , epoch-timestamp , has-standard-input , pkgs , target , ... } : exit :
                                                                                                            ''
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable epoch-timestamp } > ${ environment-variable "RELEASE_EPOCH_TIMESTAMP" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable epoch-hash } > ${ environment-variable "RELEASE_EPOCH_HASH" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable constant-hash } > ${ environment-variable "RELEASE_CONSTANT_HASH" } &&
                                                                                                                    exit ${ builtins.toString exit }
                                                                                                            '' ;
                                                                                                    in
                                                                                                        {
                                                                                                            bad = primary : gamma primary 64 ;
                                                                                                            good = primary : gamma primary 0 ;
                                                                                                        } ;
                                                                                        } ;
                                                                                    verification =
                                                                                        let
                                                                                            mktemp = "${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.verification" ;
                                                                                            in
                                                                                            {
                                                                                                script =
                                                                                                    { environment-variable , pkgs , ... } :
                                                                                                        ''
                                                                                                            cleanup ( )
                                                                                                                {
                                                                                                                    export STATUS=${ environment-variable "?" } &&
                                                                                                                        if [ ${ environment-variable "STATUS" } != 0 ]
                                                                                                                        then
                                                                                                                            export STATUS=${ environment-variable 0 } &&
                                                                                                                                ${ pkgs.coreutils }/bin/env >&2 &&
                                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "MESSAGE" } >&2 &&
                                                                                                                                exit 64
                                                                                                                        fi
                                                                                                                } &&
                                                                                                                trap cleanup EXIT &&
                                                                                                                export TEMPORARY=${ environment-variable 1 } &&
                                                                                                                export HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                export ARGUMENTS=${ environment-variable 3 } &&
                                                                                                                export STANDARD_INPUT=${ environment-variable 4 } &&
                                                                                                                export EXIT=${ environment-variable 5 } &&
                                                                                                                export ARGUMENTS_TARGET=$( ${ mktemp } ) &&
                                                                                                                export STANDARD_INPUT_TARGET=$( ${ mktemp } ) &&
                                                                                                                if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                then
                                                                                                                    if ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "TEMPORARY" }
                                                                                                                    then
                                                                                                                        TEMPORARY_STATUS=${ environment-variable "?" }
                                                                                                                    else
                                                                                                                        TEMPORARY_STATUS=${ environment-variable "?" }
                                                                                                                    fi
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                then
                                                                                                                    if ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" }
                                                                                                                    then
                                                                                                                        TEMPORARY_STATUS=${ environment-variable "?" }
                                                                                                                    else
                                                                                                                        TEMPORARY_STATUS=${ environment-variable "?" }
                                                                                                                    fi
                                                                                                                fi &&
                                                                                                                if [ ! -f ${ environment-variable "ARGUMENTS_TARGET" } ]
                                                                                                                then
                                                                                                                     export MESSAGE="We did not write the ARGUMENTS_TARGET." &&
                                                                                                                        exit 64
                                                                                                                elif [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ARGUMENTS_TARGET" } ) != ${ environment-variable "ARGUMENTS" } ]
                                                                                                                then
                                                                                                                    export MESSAGE="We did not write the ARGUMENTS_TARGET correctly." &&
                                                                                                                        export OBSERVED=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ARGUMENTS_TARGET" } ) &&
                                                                                                                        export EXPECTED=${ environment-variable "ARGUMENTS_TARGET" } &&
                                                                                                                        exit 64
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ] && [ -e ${ environment-variable "STANDARD_INPUT_TARGET" } ]
                                                                                                                then
                                                                                                                    export MESSAGE="We did write the STANDARD_INPUT_TARGET." &&
                                                                                                                        exit 64
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ] && [ ! -f ${ environment-variable "STANDARD_INPUT_TARGET" } ]
                                                                                                                then
                                                                                                                     export MESSAGE="We did not write the STANDARD_INPUT_TARGET." &&
                                                                                                                        exit 64
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_INPUT_TARGET" } ) != ${ environment-variable "STANDARD_INPUT" } ]
                                                                                                                then
                                                                                                                    export MESSAGE="We did not write the STANDARD_INPUT_TARGET correctly." &&
                                                                                                                        export OBSERVED=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_INPUT_TARGET" } ) &&
                                                                                                                        export EXPECTED=${ environment-variable "STANDARD_INPUT_TARGET" } &&
                                                                                                                        exit 64
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } != true ] && [ ${ environment-variable "HAS_STANDARD_INPUT" } != false ]
                                                                                                                then
                                                                                                                    export MESSAGE="We did not expect this STANDARD_INPUT." &&
                                                                                                                        export OBSERVED=${ environment-variable "STANDARD_INPUT" } &&
                                                                                                                        exit 64
                                                                                                                elif [ ${ environment-variable "TEMPORARY_STATUS" } != ${ environment-variable "STATUS" } ]
                                                                                                                then
                                                                                                                    export MESSAGE="We did not expect this status." &&
                                                                                                                        export OBSERVED=${ environment-variable "TEMPORARY_STATUS" } &&
                                                                                                                        export EXPECTED=${ environment-variable "STATUS" } &&
                                                                                                                        exit 64
                                                                                                                fi
                                                                                                        '' ;
                                                                                                temporary =
                                                                                                    { environment-variable , has-standard-input , target ,... } :
                                                                                                        let
                                                                                                            inner =
                                                                                                                ''
                                                                                                                    export TEST_RELEASE=false &&
                                                                                                                        if [ "${ environment-variable "HAS_STDIN" }" == "true" ]
                                                                                                                        then
                                                                                                                            if TARGET=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable "STDIN" } | ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } )
                                                                                                                            then
                                                                                                                                if [ ${ environment-variable "INIT_GOOD" } != true ]
                                                                                                                                then
                                                                                                                                    export MESSAGE="We had an unexpected initialization problem." &&
                                                                                                                                        exit 64
                                                                                                                                fi
                                                                                                                            else
                                                                                                                                if [ ${ environment-variable "INIT_GOOD" } != false ]
                                                                                                                                then
                                                                                                                                    export MESSAGE="We did not have an expected initialization problem." &&
                                                                                                                                        exit 64
                                                                                                                                fi
                                                                                                                            fi
                                                                                                                        else
                                                                                                                            if TARGET=$( ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } )
                                                                                                                            then
                                                                                                                                if [ ${ environment-variable "INIT_GOOD" } != true ]
                                                                                                                                then
                                                                                                                                    export MESSAGE="We had an unexpected initialization problem." &&
                                                                                                                                        exit 64
                                                                                                                                fi
                                                                                                                            else
                                                                                                                                if [ ${ environment-variable "INIT_GOOD" } != false ]
                                                                                                                                then
                                                                                                                                    export MESSAGE="We did not have an expected initialization problem." &&
                                                                                                                                        exit 64
                                                                                                                                fi
                                                                                                                            fi
                                                                                                                        fi &&
                                                                                                                        export TARGET &&
                                                                                                                        export RESOURCE=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable "TARGET" } ) &&
                                                                                                                        ${ pkgs.writeShellScript "persistent" persistent } &&
                                                                                                                        ${ pkgs.writeShellScript "transient" transient } ${ environment-variable "RESOURCE" } &&
                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "TARGET" }
                                                                                                                '' ;
                                                                                                            outer =
                                                                                                                ''
                                                                                                                    export TEMPORARY=${ environment-variable 1 } &&
                                                                                                                        export INIT_STATUS=${ environment-variable 2 } &&
                                                                                                                        export INIT_GOOD=${ environment-variable 3 } &&
                                                                                                                        export RELEASE_STATUS=${ environment-variable 4 } &&
                                                                                                                        export RELEASE_GOOD=${ environment-variable 5 } &&
                                                                                                                        export ARGUMENTS=${ environment-variable 6 } &&
                                                                                                                        export STDIN=${ environment-variable 7 } &&
                                                                                                                        export HAS_STDIN=${ environment-variable 8 } &&
                                                                                                                        export TEST_INIT=${ environment-variable 9 } &&
                                                                                                                        export TEST_RELEASE=${ environment-variable 10 } &&
                                                                                                                        export INIT_ARGUMENTS=$( ${ mktemp } ) &&
                                                                                                                        export INIT_STDIN=$( ${ mktemp } ) &&
                                                                                                                        export INIT_TARGET=$( ${ mktemp } ) &&
                                                                                                                        export RELEASE_ARGUMENTS=$( ${ mktemp } ) &&
                                                                                                                        export RELEASE_STDIN=$( ${ mktemp } ) &&
                                                                                                                        export RELEASE_TARGET=$( ${ mktemp } ) &&
                                                                                                                        ${ pkgs.coreutils }/bin/rm --recursive --force /build/*.broken &&
                                                                                                                        if ${ has-standard-input }
                                                                                                                        then
                                                                                                                            export TARGET=$( ${ pkgs.coreutils }/bin/tee | ${ pkgs.writeShellScript "inner" inner } ${ environment-variable "@" } )
                                                                                                                        else
                                                                                                                            export TARGET=$( ${ pkgs.writeShellScript "inner" inner } ${ environment-variable "@" } )
                                                                                                                        fi &&
                                                                                                                        export RESOURCE=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable "TARGET" } ) &&
                                                                                                                        ${ pkgs.coreutils }/bin/echo RESOURCE=${ environment-variable "RESOURCE" } &&
                                                                                                                        ${ pkgs.coreutils }/bin/echo We have determined that sleep 1 second is too fast because the test for removal happens before the removal has had a chance. &&
                                                                                                                        ${ pkgs.coreutils }/bin/sleep 10s &&
                                                                                                                        ${ pkgs.writeShellScript "persistent" persistent } &&
                                                                                                                        if [ ${ environment-variable "INIT_GOOD" } != true ] || [ ${ environment-variable "RELEASE_GOOD" } != true ]
                                                                                                                        then
                                                                                                                            export BROKEN=$( ${ pkgs.findutils }/bin/find /build -type d -name "*.broken" ) &&
                                                                                                                                ${ pkgs.writeShellScript "transient" transient } ${ environment-variable "BROKEN" }
                                                                                                                        fi
                                                                                                                '' ;
                                                                                                            persistent =
                                                                                                                ''
                                                                                                                    cleanup ( )
                                                                                                                        {
                                                                                                                            export STATUS=${ environment-variable "?" } &&
                                                                                                                                if [ ${ environment-variable "STATUS" } != 0 ]
                                                                                                                                then
                                                                                                                                    ${ pkgs.coreutils }/bin/env >&2 &&
                                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "MESSAGE" } >&2
                                                                                                                                        exit 64
                                                                                                                                fi
                                                                                                                        } &&
                                                                                                                        trap cleanup EXIT &&
                                                                                                                        if [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "INIT_ARGUMENTS" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not write init arguments." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "INIT_ARGUMENTS" } )" != "${ environment-variable "ARGUMENTS" }" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly write the init arguments." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "INIT_ARGUMENTS" } )" &&
                                                                                                                                export EXPECTED="${ environment-variable "ARGUMENTS" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "INIT_ARGUMENTS" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did write the init arguments." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "HAS_STDIN" } == true ] && [ ! -f ${ environment-variable "INIT_STDIN" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not write init stdin." &&
                                                                                                                               exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "HAS_STDIN" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "INIT_STDIN" } ) != ${ environment-variable "STDIN" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not write the init stdin." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "INIT_STDIN" } )" &&
                                                                                                                                export EXPECTED="${ environment-variable "STDIN" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "HAS_STDIN" } != true ] && [ ${ environment-variable "HAS_STDIN" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect that has stdin." &&
                                                                                                                                export OBSERVED=${ environment-variable "HAS_STDIN" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "INIT_STDIN" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did write the init stdin." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == false ] && [ ${ environment-variable "HAS_STDIN" } != true ] && [ ${ environment-variable "HAS_STDIN" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect that has stdin." &&
                                                                                                                                export OBSERVED=${ environment-variable "HAS_STDIN" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "INIT_TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not create the init target." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "INIT_TARGET" } ) != ${ environment-variable "TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly create the init target." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } == false ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "INIT_TARGET" } ) == ${ environment-variable "TARGET" } ]
                                                                                                                        then
                                                                                                                           export MESSAGE="We did not correctly create the init target." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } != true ] && [ ${ environment-variable "INIT_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect that init good." &&
                                                                                                                                export OBSERVED="${ environment-variable "INIT_GOOD" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "INIT_TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did write the init target." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } != true ] && [ ${ environment-variable "INIT_GOOD" }  != true ] && [ ${ environment-variable "INIT_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect that init good." &&
                                                                                                                                export OBSERVED=${ environment-variable "INIT_GOOD" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } != true ] && [ ${ environment-variable "INIT_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect this INIT_GOOD" &&
                                                                                                                                export OBSERVED="${ environment-variable "INIT_GOOD" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } != true ] && [ ${ environment-variable "TEST_INIT" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We were not expecting this test init." &&
                                                                                                                                export OBSERVED=${ environment-variable "TEST_INIT" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "RELEASE_ARGUMENTS" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not write release arguments." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -z "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RELEASE_ARGUMENTS" } )" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly write the release arguments." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RELEASE_ARGUMENTS" } )" &&
                                                                                                                                export EXPECTED="" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "RELEASE_ARGUMENTS" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did write the release arguments." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ -e ${ environment-variable "RELEASE_STDIN" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did write the release stdin." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "RELEASE_STDIN" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did write the release stdin." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "RELEASE_TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not create the release target." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RELEASE_TARGET" } ) != ${ environment-variable "TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly create the release target." &&
                                                                                                                                export OBSERVED=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RELEASE_TARGET" } ) &&
                                                                                                                                export EXPECTED=${ environment-variable "TARGET" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } == false ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RELEASE_TARGET" } ) != ${ environment-variable "TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly create the release target." &&
                                                                                                                                export OBSERVED=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RELEASE_TARGET" } ) &&
                                                                                                                                export UNEXPECTED=${ environment-variable "TARGET" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect that release good." &&
                                                                                                                                export OBSERVED="${ environment-variable "RELEASE_GOOD" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "RELEASE_TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did write the release target." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect that release good." &&
                                                                                                                                export OBSERVED=${ environment-variable "TEST_RELEASE" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect this RELEASE_GOOD" &&
                                                                                                                                export OBSERVED="${ environment-variable "RELEASE_GOOD" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } != true ] && [ ${ environment-variable "TEST_RELEASE" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We were not expecting this test release." &&
                                                                                                                                export OBSERVED=${ environment-variable "TEST_RELEASE" } &&
                                                                                                                                exit 64
                                                                                                                        fi
                                                                                                                '' ;
                                                                                                            transient =
                                                                                                                ''
                                                                                                                    cleanup ( )
                                                                                                                        {
                                                                                                                            export STATUS=${ environment-variable "?" } &&
                                                                                                                                export MODE=transient &&
                                                                                                                                if [ ${ environment-variable "STATUS" } != 0 ]
                                                                                                                                then
                                                                                                                                    ${ pkgs.findutils }/bin/find /build >&2 &&
                                                                                                                                        ${ pkgs.coreutils }/bin/env >&2 &&
                                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "MESSAGE" } >&2
                                                                                                                                        exit 64
                                                                                                                                fi
                                                                                                                        } &&
                                                                                                                        trap cleanup EXIT &&
                                                                                                                        export ASSET=${ environment-variable "1" } &&
                                                                                                                        if [ ! -d ${ environment-variable "ASSET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not create the ASSET directory." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "ASSET" }/init.out.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not log init out." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.out.log )" != "eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly log init out." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.log.out )" &&
                                                                                                                                export EXPECTED="eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/init.out.log ) != "400" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not lock init out." &&
                                                                                                                                export OBSERVED=$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/init.out.log ) &&
                                                                                                                                export EXPECTED=400 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "ASSET" }/init.out.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did log init out." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "ASSET" }/init.err.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not log init err." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.err.log )" != "193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly log init err." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.err.log )" &&
                                                                                                                                export EXPECTED="52b1688f54a45391114a3ddcda15b6ac1845b0ec2abc4499aa45fb3b55d472441891a2b044c29df64531d4ca8260c2411deeb92bf2fc256fed055c214c5f99e3" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "ASSET" }/init.err.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did log init err ." &&
                                                                                                                               exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "ASSET" }/init.status.asc ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not record the init status." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.status.asc ) != 0 ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly record the init status." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.status.asc )" &&
                                                                                                                                export EXPECTED=0 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } == false ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.status.asc ) != 64 ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly record the init status." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/init.status.asc )" &&
                                                                                                                                export EXPECTED=64 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } != true ] && [ ${ environment-variable "INIT_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect this INIT_GOOD" &&
                                                                                                                                export OBSERVED="${ environment-variable "INIT_GOOD" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/init.status.asc ) != "400" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not lock init status." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/init.status.asc )" &&
                                                                                                                                export EXPECTED=400 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "ASSET" }/init.status.asc ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did record the initial status." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_INIT" } != true ] && [ ${ environment-variable "TEST_INIT" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We were not expecting this test init." &&
                                                                                                                                export OBSERVED=${ environment-variable "TEST_INIT" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect that release good." &&
                                                                                                                                export OBSERVED=${ environment-variable "TEST_RELEASE" } &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "ASSET" }/release.out.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not log release out." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.out.log )" != "a92513f231769b19b4529ae89634bfb1593de9a55751805c1ed2a657ae45cde5773de852162d54c82559611d4ce49e58c17a93e2d5c042924832122b5e9985a4" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly log release out." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.out.log )" &&
                                                                                                                                export EXPECTED="a92513f231769b19b4529ae89634bfb1593de9a55751805c1ed2a657ae45cde5773de852162d54c82559611d4ce49e58c17a93e2d5c042924832122b5e9985a4" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/release.out.log ) != "400" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not lock release out - ${ environment-variable "ASSET" }." &&
                                                                                                                                export OBSERVED=$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/release.out.log ) &&
                                                                                                                                export EXPECTED=400 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "ASSET" }/release.out.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did log release out." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "ASSET" }/release.err.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not log release err." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.err.log )" != "52b1688f54a45391114a3ddcda15b6ac1845b0ec2abc4499aa45fb3b55d472441891a2b044c29df64531d4ca8260c2411deeb92bf2fc256fed055c214c5f99e3" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly log release err." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.err.log )" &&
                                                                                                                                export EXPECTED="52b1688f54a45391114a3ddcda15b6ac1845b0ec2abc4499aa45fb3b55d472441891a2b044c29df64531d4ca8260c2411deeb92bf2fc256fed055c214c5f99e3" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "ASSET" }/release.err.log ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did log release err ." &&
                                                                                                                               exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "ASSET" }/release.status.asc ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not record the release status." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.status.asc ) != 0 ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly record the release status." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.status.asc )" &&
                                                                                                                                export EXPECTED=0 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } ==false ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.status.asc ) != 64 ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not correctly record the release status." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "ASSET" }/release.status.asc )" &&
                                                                                                                                export EXPECTED=64 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not expect this RELEASE_GOOD" &&
                                                                                                                                export OBSERVED="${ environment-variable "RELEASE_GOOD" }" &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/release.status.asc ) != "400" ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did not lock release status." &&
                                                                                                                                export OBSERVED="$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "ASSET" }/release.status.asc )" &&
                                                                                                                                export EXPECTED=400 &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "ASSET" }/release.status.asc ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did record the release status." &&
                                                                                                                                exit 64
                                                                                                                        elif [ ${ environment-variable "TEST_RELEASE" } != true ] && [ ${ environment-variable "TEST_RELEASE" } != false ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We were not expecting this test release." &&
                                                                                                                                export OBSERVED=${ environment-variable "TEST_RELEASE" } &&
                                                                                                                                exit 64
                                                                                                                        fi
                                                                                                                '' ;
                                                                                                    in outer ;
                                                                                            } ;
                                                                                } ;
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            temporary =
                                                                                {
                                                                                    beta-00 = scripts : { } ;
                                                                                    beta-01 = scripts : { release = scripts.release.beta.good ; } ;
                                                                                    beta-02 = scripts : { release = scripts.release.beta.bad ; } ;
                                                                                    beta-10 = scripts : { init = scripts.init.beta.good ; } ;
                                                                                    beta-11 = scripts : { init = scripts.init.beta.good ; release = scripts.release.beta.good ; } ;
                                                                                    beta-12 = scripts : { init = scripts.init.beta.good ; release = scripts.release.beta.bad ; } ;
                                                                                    beta-20 = scripts : { init = scripts.init.beta.bad ; } ;
                                                                                    beta-21 = scripts : { init = scripts.init.beta.bad ; release = scripts.release.beta.good ; } ;
                                                                                    beta-22 = scripts : { init = scripts.init.beta.bad ; release = scripts.release.beta.bad ; } ;
                                                                                    gamma-11 = scripts : { init = scripts.init.gamma.good ; release = scripts.release.gamma.good ; } ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            ${ resources.scripts.verification.script } ${ resources.scripts.alpha } true bf3422439178649ee4005ed7fd80dba8e8e115400d5a6cee7c5f133c0946f66b7b37df18d2fff6683a846229898dbcafd22acce14d27e1731dda5b128b360e58 56f8b13200cbf7e4239210a6041537a1bfd100eaf0a0e6473085ecc6817c3b2634e1c6ac3d32271c3ac3a94ccbfa7462a7e6902851901fdc45e59fc639f5ea98 0 &&
                                                                            ${ resources.scripts.verification.script } ${ resources.scripts.alpha } true 043eedc4fd488a0b3d332a8b73879ab47eeaf9f32f73dd800233b92f02b56a50ae575dcfc15de8f6f0adc02e8e0049d5e0689dcf7050ce4809d030f5f34b2005 6b9f78c864afdadae4f1aa1222e3cad9dfb6d4eb5c2cfd2b8da4e84177cd0346233e4564013970c3ea53a90eda89aa3f9a1734f06a671cfd7515657ae9f4dff4 65 &&
                                                                            ${ resources.scripts.verification.script } ${ resources.scripts.alpha } false b2cb54440691821c8520a3d2419e79224c725c04ce686eb5dc4300458c96c354797ad8460917eb85f8155d76a56af681912f0c3eade398ea3f3563aba790b543 981f61ca06127c8f119a46760412c050ed7a98ee11b1b5107bd0dece4a9d206f6c70a6c6ae05d6860707397013b27dfaef6c77b0fb7661e44eaf2c60ccfad2fd 0 &&
                                                                            ${ resources.scripts.verification.script } ${ resources.scripts.alpha } false bae5ba536f62dc70409d77db6bf8577d21e4e436a5b23053d701c67de3b0b5d00caf26a922909140b3b5fa7189b7192de244dbbb4a85d66d58f68e39d1fdc4ae 6e1c489ff6f6ac269f7d7c04eedf8252bfcba6ba4e231d8506a8753da842b0da16dbb34230fe27f637898ed0399d6cc3a318e06e8afd71af5cc692e820380a34 65 &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-00 } 0 true 0 true 3dc4203b7bd30561219e4df7fd2a3cd2e9b6c8c704daa3a224649394a30b9eb01bd67d8da271f823abb1c5c66e3810634b68190e3d5e6fee22250a465afa68b0 bdd6b1c7fea2d0a2ad5b32f5ccc8f635e478bf0c32badfae80a15f002ab7c20b7b188df4743eda29d17aa9a592b6a8894474e0c71148fa12d2eb953897d2a132 true false false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-00 } 0 true 0 true 44334890f47da05db3917e6a3d1a421777afdc8dc3975897a57fbcf2ddb8c0e85edf006df6555cb5dc644eb01505c227cc2181efb7a2aad9bcfe19b8b405f1a9 d25e1dcda42f12477de86e24831bf31c29005d1989ee79e372dd377d6c6d1c48262d0a5f5b475aef849df2ac7774372c60210aa852ed531442129a48a5b4fb3c false false false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-01 } 0 true 0 true 51a069aca5a245d4a4126f3e72b0948ec95b04d8b71bc6fd0ae32c24cde791e8ccd4614fee864efa07968852c1fb917cb632b4dacc276fa6f37e47d00ed40641 c8eb81542e5be3bb30d9feca1696f09410f3c13f818d3c5e5df0acefca87d6d49f3d313dd2729468c2855bc6e573e2ee7fbb88e0c68d75c96a474973126737b9 true false true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-01 } 0 true 0 true 57276151c295ac304b86ec13adc28688fc4d1a8aace8e5e9d9b4b7f7197d5731dc27b9453b3175ae5064c37512507e3449c531ce0883082642c7b84e830ab5bb 742a4d7c99cd0b323ba5d9cb51124e4d3b07309b7093b5d80e739c284186201e5483fc6fe35476a3cf72f72b833de3bb168169ee92b053968859d2e91136b76f false false true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-02 } 0 true 65 false 918f84be76f1c44fe870388651dc2a99a46307eca68874d0616c200bbde3edea2f1d94e6f0de960cdc59424bcd46683703ea35da4bf2bcb66fbe498f0d8b66d1 380ba759d8e04d9226965e5cda8fbcdd9d33cf46dd25d11689b33b7eba1bf4cc3ae905fe12e7682d9b289c8892bd9d2d3c79675aed85d1f2a74df83c54843287 true false true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-02 } 0 true 65 false 57276151c295ac304b86ec13adc28688fc4d1a8aace8e5e9d9b4b7f7197d5731dc27b9453b3175ae5064c37512507e3449c531ce0883082642c7b84e830ab5bb 742a4d7c99cd0b323ba5d9cb51124e4d3b07309b7093b5d80e739c284186201e5483fc6fe35476a3cf72f72b833de3bb168169ee92b053968859d2e91136b76f false false true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-10 } 0 true 0 true 0c86ffe02059590b00941d8b071c2e6f7dda0f97b258982b3fe0f6687b714339cdadfacdbeb1ebcf3215ce891e3acf873f9bf31149bcdf4caa138133ca6fc67e d8a7ebec5360cbe16d9f3584e3d9dce45df459480e0b845ed386c56bbd3b99abb708f75c3c9348558b7e3bcae5f6c1205d577d3a449783b854bb180ef3394bbb true true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-10 } 0 true 0 true dbfe38adccdc35ab7767b8c5ebec8df4478c1790a37054ef76749f4ef736db85ffd71057280b6803e29bd08e5e8d9e7788741dfe1e2df378c80061c612db8545 78d0377edb6981865ce8313c958db5ffaed451d32fcef703cd6f0c45dce57d3815775bb0995a5535bca93b04c8a35e3d9c0301cffc00e85668b9cda689e44ee7 false true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-11 } 0 true 0 true 59eea253e2372353f978847b87e80d02b0568754c503e3718bbc8388ee99bf7381479ca8a2935362188f581cdab6ffb59dc403381b59d66ae1d62eb4802d93f4 5127cbcfc550b084ca27070a3d5b4aeb034cb174fd9aedb19f9e3c85c95f97d138123ca6b826fd5d009e9f24e1c25d6aedefc8c91f92b8284fae94942a488c9d true true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-11 } 0 true 0 true c8a2d7e7f7683f8f2db452bf311013d17d321a077489e4928f1a95d38a26a5b99942c2b69608238c31816eba23369bab3f43f51c7eb1c954bcaa56a7898d3886 47ce8fce72162158377951a30e52a638c2dd87b849d88ce4e4d65622ecda0fcffde884831cd1cca3ad03e46b7bf3cceb3136bcff9b8c55461567c29d20292657 false true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-12 } 0 true 65 false 41bc0828cfe82a8e315a913f458b5d9b45662073cc31e40d65e10daed4397875f71c4a884051906672da0739b10aecb8fef43a6dc96b35fbc7530ff0b376ed44 4de86775757c6bcdaa4868b0a5286616a85a335244ed3d1bd838a84380e3d61c37211495de50dabaffeb8b2248b19cdc05778783c0e900744b05e0a49ed4d36a true true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-12 } 0 true 65 false 7499405b0a3caea45e8934c0f402f43ec11df2b39a8a77b1caefbe5b705cb4414a30ffb59b48861d07eb90bf074f1e67e4d30fe81712cd8d1d6aead04b8bbe97 7499405b0a3caea45e8934c0f402f43ec11df2b39a8a77b1caefbe5b705cb4414a30ffb59b48861d07eb90bf074f1e67e4d30fe81712cd8d1d6aead04b8bbe97 false true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-20 } 65 false 0 false 57e593f977b1be52e9bfdc465811aa7ade6d6d99b202e64fb0a4d0f5bc9ae581244a7eba872cd073ff9bbd374282421ff24590d703d75d4b82596811531344d7 c1cdefe06092f250e1a05013e2d78957927cb865300fb03b86a2788c812f56a29cf074a7d7291b17c965ddddc6f1b7c9d99885a4827a925b5d72cf1b9bb81191 true true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-20 } 65 false 0 false a5ff6c460d52e4b01cfdd05a93bf01e08175aa8eec1d3d910c60ee578a628b95a3bcb433d47b2c0c5b3f7f9d1bcb4c3c6a1696e4609a5b448c20eb617984b086 952b7bd06c69a9b757c663bf00dd892d46be65382ba27bb8f557257f86f9f4fc2f9609e91e782bc05489f2d6b107ff72b531772913a3a80c81e36d92fe7a026e false true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-21 } 65 false 0 false 25ae6bbfb942a3c9840bcd0b5adaa23d8090a02f10d75b20767be230b6fadab63479c4af85923d05c85ce99461101c8f36b20970268593c840d97d885b9aeb74 65c8c75c2c0bb7cc07ee2c305c1ffffad7fb31daffd0ba70d6fdc9d700e1de91a4f6684a1f780c74272dce4d9c0725502084db3842d2ad413d8504ec85261794 true true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-21 } 65 false 0 false bc133c0bc62432eff66d388dc6c4894ba0cb6d9f35a124541a5536d9a6da812e5f2238bbf3f1230ec0ce1184c7973d375a28678fc839f9de2bbede82bc4c9b24 b99f61d249e11db2fcb6e0459235961a34158643836e7fb36f183fccd5b56a353c099e8776b5dbb423144a68619d41b03b19edafad85467644885991483f6274  false true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-22 } 65 false 65 false 1f3daa30c141d3b438262d4a48e8ba4bb71f08b7890d798ed30ef5f106019417edff26e3b2150752e8c3f059b3527f386c865e49e4bc4ae7e5b171d41c9b0d20 0cb519a4a9617ec43916a8c5f29a5bf040a2ad50bbf166ab7b934ce678949ab0c45687e9e5c354467b72c1eeec1f517de5d9d6218b711e5414ea2d56b50e5611 true true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-22 } 65 false 65 false 2a6047bffdcb4d27b75f19aa40eaf5d9de2b89aa587f5d8b06beaa0a3deb2e46bd6235c43d77cebecd2aeb4279c3fe3c868b488acc243c7bb572d9b3adb37447 00ef4851e7c5df918ca18a81a3475ce16fcfce9caa8ed767b36762056584b43c95be535a302771d042dc301571a482192fac490a9db5bd8f9ae29bc70731bcf3 false true false
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
