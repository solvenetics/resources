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
                                                                                    if [ "${ builtins.typeOf temporary.release }" == null ] || ${ pkgs.writeShellScript "release" temporary.release } > ${ environment-variable "RESOURCE" }/release.out.log 2> ${ environment-variable "RESOURCE" }/release.err.log
                                                                                    then
                                                                                        ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable "RESOURCE" }
                                                                                    fi
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
                                                                                        { pkgs , environment-variable , ... } :
                                                                                            ''
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "e8f69632444d7b53bd5cba03f969154d93562ef09e791e97ce95d2b5c35bd8c4f821bbc48697268d6c819f7b7a1a21a13411ff55f86cc339de375411681fe839" }
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
                                                                                        } ;
                                                                                    release =
                                                                                        {
                                                                                            beta =
                                                                                                { pkgs , environment-variable , has-standard-input , target , ... } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ environment-variable "RELEASE_TARGET" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } > ${ environment-variable "RELEASE_ARGUMENTS" } &&
                                                                                                            if ${ has-standard-input }
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/tee > ${ environment-variable "RELEASE_STDIN" }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo 1fde421ae9408105115c8d8ce99551b3dd427f69e72ed6b3e274bfd5af8e5fd39ebefb00e334c0deb1997908ae402138a711e5856daac0c6b26ef9c2f28782b6 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo 52b1688f54a45391114a3ddcda15b6ac1845b0ec2abc4499aa45fb3b55d472441891a2b044c29df64531d4ca8260c2411deeb92bf2fc256fed055c214c5f99e3 >&2 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ environment-variable "RELEASE_TARGET" }
                                                                                                    '' ;
                                                                                        } ;
                                                                                    verification =
                                                                                        {
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
                                                                                                                    ${ pkgs.writeShellScript "transient" transient } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "TARGET" }
                                                                                                            '' ;
                                                                                                        outer =
                                                                                                            let
                                                                                                                mktemp = "${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.verification" ;
                                                                                                                in
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
                                                                                                                            if ${ has-standard-input }
                                                                                                                            then
                                                                                                                                TARGET=$( ${ pkgs.coreutils }/bin/tee | ${ pkgs.writeShellScript "inner" inner } ${ environment-variable "@" } )
                                                                                                                            else
                                                                                                                                TARGET=$( ${ pkgs.writeShellScript "inner" inner } ${ environment-variable "@" } )
                                                                                                                            fi &&
                                                                                                                            export TARGET &&
                                                                                                                            export RESOURCE=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable "TARGET" } ) &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo RESOURCE=${ environment-variable "RESOURCE" } &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo We have determined that sleep 1 second is too fast because the test for removal happens before the removal has had a chance. &&
                                                                                                                            ${ pkgs.coreutils }/bin/sleep 10s &&
                                                                                                                            ${ pkgs.writeShellScript "persistent" persistent } &&
                                                                                                                            if [ ${ environment-variable "INIT_GOOD" } != true ] || [ ${ environment-variable "RELEASE_GOOD" } != true ]
                                                                                                                            then
                                                                                                                                ${ pkgs.writeShellScript "transient" transient }
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
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } == false ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RELEASE_TARGET" } ) == ${ environment-variable "TARGET" } ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly create the release target." &&
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
                                                                                                                                ${ pkgs.findutils }/bin/find ${ environment-variable "RESOURCE" } >&2 &&
                                                                                                                                    ${ pkgs.coreutils }/bin/env >&2 &&
                                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "MESSAGE" } >&2
                                                                                                                                    exit 64
                                                                                                                            fi
                                                                                                                    } &&
                                                                                                                    trap cleanup EXIT &&
                                                                                                                    if [ ! -d ${ environment-variable "RESOURCE" } ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not create the RESOURCE directory." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "RESOURCE" }/init.out.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not log init out." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.out.log )" != "eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly log init out." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.log.out )" &&
                                                                                                                            export EXPECTED="eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.out.log ) != "400" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not lock init out." &&
                                                                                                                            export OBSERVED=$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.out.log ) &&
                                                                                                                            export EXPECTED=400 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "RESOURCE" }/init.out.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did log init out." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "RESOURCE" }/init.err.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not log init err." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.err.log )" != "193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly log init err." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.err.log )" &&
                                                                                                                            export EXPECTED="193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952" &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "RESOURCE" }/init.err.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did log init err ." &&
                                                                                                                           exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ! -f ${ environment-variable "RESOURCE" }/init.status.asc ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not record the init status." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.status.asc ) != 0 ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly record the init status." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.status.asc )" &&
                                                                                                                            export EXPECTED=0 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } == false ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.status.asc ) != 64 ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly record the init status." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.status.asc )" &&
                                                                                                                            export EXPECTED=64 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ ${ environment-variable "INIT_GOOD" } != true ] && [ ${ environment-variable "INIT_GOOD" } != false ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not expect this INIT_GOOD" &&
                                                                                                                            export OBSERVED="${ environment-variable "INIT_GOOD" }" &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.status.asc ) != "400" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not lock init status." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.status.asc )" &&
                                                                                                                            export EXPECTED=400 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_INIT" } == false ] && [ -e ${ environment-variable "RESOURCE" }/init.status.asc ]
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
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "RESOURCE" }/release.out.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not log release out." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.out.log )" != "eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly log release out." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.out.log )" &&
                                                                                                                            export EXPECTED="eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/release.out.log ) != "400" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not lock release out." &&
                                                                                                                            export OBSERVED=$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/release.out.log ) &&
                                                                                                                            export EXPECTED=400 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "RESOURCE" }/release.out.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did log release out." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "RESOURCE" }/release.err.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not log release err." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.err.log )" != "193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly log release err." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.err.log )" &&
                                                                                                                            export EXPECTED="193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952" &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "RESOURCE" }/release.err.log ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did log release err ." &&
                                                                                                                           exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ! -f ${ environment-variable "RESOURCE" }/release.status.asc ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not record the release status." &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } == true ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.status.asc ) != 0 ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly record the release status." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.status.asc )" &&
                                                                                                                            export EXPECTED=0 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } ==false ] && [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.status.asc ) != 64 ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not correctly record the release status." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/release.status.asc )" &&
                                                                                                                            export EXPECTED=64 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ ${ environment-variable "RELEASE_GOOD" } != true ] && [ ${ environment-variable "RELEASE_GOOD" } != false ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not expect this RELEASE_GOOD" &&
                                                                                                                            export OBSERVED="${ environment-variable "RELEASE_GOOD" }" &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == true ] && [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/release.status.asc ) != "400" ]
                                                                                                                    then
                                                                                                                        export MESSAGE="We did not lock release status." &&
                                                                                                                            export OBSERVED="$( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/release.status.asc )" &&
                                                                                                                            export EXPECTED=400 &&
                                                                                                                            exit 64
                                                                                                                    elif [ ${ environment-variable "TEST_RELEASE" } == false ] && [ -e ${ environment-variable "RESOURCE" }/release.status.asc ]
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
                                                                                    beta-01 = scripts : { release = scripts.release.beta ; } ;
                                                                                    beta-10 = scripts : { init = scripts.init.beta.good ; } ;
                                                                                    beta-20 = scripts : { init = scripts.init.beta.bad ; } ;
                                                                                    beta-11 = scripts : { init = scripts.init.beta.good ; release = scripts.release.beta ; } ;
                                                                                    beta-21 = scripts : { init = scripts.init.beta.bad ; release = scripts.release.beta ; } ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            export e8f69632444d7b53bd5cba03f969154d93562ef09e791e97ce95d2b5c35bd8c4f821bbc48697268d6c819f7b7a1a21a13411ff55f86cc339de375411681fe839=5bc84c7df8361e1fbebf1af143c7714b25f534582d57d36bb2c693886508bf4b3d5a755a3ae15d3f463ad826ecaec4acc5469a07ed3f7cc0601578cab6062542 &&
                                                                            if [ "$( ${ resources.scripts.alpha } )" == "5bc84c7df8361e1fbebf1af143c7714b25f534582d57d36bb2c693886508bf4b3d5a755a3ae15d3f463ad826ecaec4acc5469a07ed3f7cc0601578cab6062542" ]
                                                                            then
                                                                                ${ pkgs.coreutils }/bin/echo GOOD SCRIPT
                                                                            else
                                                                                ${ pkgs.coreutils }/bin/echo BAD SCRIPT &&
                                                                                    ${ pkgs.coreutils }/bin/echo EXPECTED
                                                                                    ${ pkgs.coreutils }/bin/echo 5bc84c7df8361e1fbebf1af143c7714b25f534582d57d36bb2c693886508bf4b3d5a755a3ae15d3f463ad826ecaec4acc5469a07ed3f7cc0601578cab6062542 &&
                                                                                    ${ pkgs.coreutils }/bin/echo OBSERVED: &&
                                                                                    ${ resources.scripts.alpha } &&
                                                                                    exit 64
                                                                            fi &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-01 } 0 true 0 true 51a069aca5a245d4a4126f3e72b0948ec95b04d8b71bc6fd0ae32c24cde791e8ccd4614fee864efa07968852c1fb917cb632b4dacc276fa6f37e47d00ed40641 c8eb81542e5be3bb30d9feca1696f09410f3c13f818d3c5e5df0acefca87d6d49f3d313dd2729468c2855bc6e573e2ee7fbb88e0c68d75c96a474973126737b9 true false true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-01 } 0 true 0 true 57276151c295ac304b86ec13adc28688fc4d1a8aace8e5e9d9b4b7f7197d5731dc27b9453b3175ae5064c37512507e3449c531ce0883082642c7b84e830ab5bb 742a4d7c99cd0b323ba5d9cb51124e4d3b07309b7093b5d80e739c284186201e5483fc6fe35476a3cf72f72b833de3bb168169ee92b053968859d2e91136b76f false false true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-11 } 0 true 0 true 59eea253e2372353f978847b87e80d02b0568754c503e3718bbc8388ee99bf7381479ca8a2935362188f581cdab6ffb59dc403381b59d66ae1d62eb4802d93f4 5127cbcfc550b084ca27070a3d5b4aeb034cb174fd9aedb19f9e3c85c95f97d138123ca6b826fd5d009e9f24e1c25d6aedefc8c91f92b8284fae94942a488c9d true true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-11 } 0 true 0 true c8a2d7e7f7683f8f2db452bf311013d17d321a077489e4928f1a95d38a26a5b99942c2b69608238c31816eba23369bab3f43f51c7eb1c954bcaa56a7898d3886 47ce8fce72162158377951a30e52a638c2dd87b849d88ce4e4d65622ecda0fcffde884831cd1cca3ad03e46b7bf3cceb3136bcff9b8c55461567c29d20292657 false true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-21 } 65 false 0 false 57e593f977b1be52e9bfdc465811aa7ade6d6d99b202e64fb0a4d0f5bc9ae581244a7eba872cd073ff9bbd374282421ff24590d703d75d4b82596811531344d7 c1cdefe06092f250e1a05013e2d78957927cb865300fb03b86a2788c812f56a29cf074a7d7291b17c965ddddc6f1b7c9d99885a4827a925b5d72cf1b9bb81191 true true false &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-21 } 65 false 0 false a5ff6c460d52e4b01cfdd05a93bf01e08175aa8eec1d3d910c60ee578a628b95a3bcb433d47b2c0c5b3f7f9d1bcb4c3c6a1696e4609a5b448c20eb617984b086 952b7bd06c69a9b757c663bf00dd892d46be65382ba27bb8f557257f86f9f4fc2f9609e91e782bc05489f2d6b107ff72b531772913a3a80c81e36d92fe7a026e false true false &&
                                                                            true
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
