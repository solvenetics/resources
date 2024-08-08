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
                                                                            ''
                                                                                RESOURCE=$( ${ temporary-resource-directory } ) &&
                                                                                    export ${ target }=${ environment-variable "RESOURCE" }/target &&
                                                                                    PARENT_PID=${ environment-variable "PPID" } &&
                                                                                    if ${ has-standard-input }
                                                                                    then
                                                                                        if [ "${ builtins.typeOf temporary.init }" == "null" ]
                                                                                        then
                                                                                            GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PARENT_PID" } ) &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "GRANDPARENT_PID" } | ${ at } now > /dev/null 2>&1 &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                        elif ${ pkgs.coreutils }/bin/tee | ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                        then
                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                GRANDPARENT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PARENT_PID" } ) &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "GRANDPARENT_PID" } | ${ at } now > /dev/null 2>&1 &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                        else
                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                BROKEN=$( ${ temporary-broken-directory } ) &&
                                                                                                ${ pkgs.coreutils }/bin/mv ${ environment-variable "RESOURCE" } ${ environment-variable "BROKEN" } &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target } &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ temporary-init-error-message "${ environment-variable "RESOURCE" }" } >&2 &&
                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                exit ${ builtins.toString temporary-init-error-code }
                                                                                        fi
                                                                                    else
                                                                                        if [ "${ builtins.typeOf temporary.init }" == "null" ]
                                                                                        then
                                                                                            ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PARENT_PID" } | ${ at } now > /dev/null 2>&1
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                        elif [ "${ builtins.typeOf temporary.init }" == "null" ] || ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                        then
                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ pkgs.writeShellScript "release" release } ${ environment-variable "RESOURCE" } ${ environment-variable "PARENT_PID" } | ${ at } now > /dev/null 2>&1
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                        else
                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "RESOURCE" }/init.status.asc &&
                                                                                                BROKEN=$( ${ temporary-broken-directory } ) &&
                                                                                                ${ pkgs.coreutils }/bin/mv ${ environment-variable "RESOURCE" } ${ environment-variable "BROKEN" } &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target } &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ temporary-init-error-message "${ environment-variable "RESOURCE" }" } >&2 &&
                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable "RESOURCE" }/init.out.log ${ environment-variable "RESOURCE" }/init.err.log ${ environment-variable "RESOURCE" }/init.status.asc
                                                                                                exit ${ builtins.toString temporary-init-error-code }
                                                                                        fi
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
                                                                                                { pkgs , environment-variable , target , ... } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ environment-variable "RELEASE_FLAG" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo 1fde421ae9408105115c8d8ce99551b3dd427f69e72ed6b3e274bfd5af8e5fd39ebefb00e334c0deb1997908ae402138a711e5856daac0c6b26ef9c2f28782b6 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo 52b1688f54a45391114a3ddcda15b6ac1845b0ec2abc4499aa45fb3b55d472441891a2b044c29df64531d4ca8260c2411deeb92bf2fc256fed055c214c5f99e3 >&2
                                                                                                    '' ;
                                                                                        } ;
                                                                                    verification =
                                                                                        {
                                                                                            temporary =
                                                                                                { environment-variable , has-standard-input , target ,... } :
                                                                                                    let
                                                                                                        inner =
                                                                                                            ''
                                                                                                                cleanup ( )
                                                                                                                    {
                                                                                                                        STATUS=${ environment-variable "?" } &&
                                                                                                                            if [ ${ environment-variable "STATUS" } != 0 ]
                                                                                                                            then
                                                                                                                                ${ pkgs.findutils }/bin/find ${ environment-variable "RESOURCE" } >&2 &&
                                                                                                                                    ${ pkgs.coreutils }/bin/env >&2 &&
                                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "MESSAGE" } >&2
                                                                                                                                    exit 64
                                                                                                                            fi
                                                                                                                    } &&
                                                                                                                    trap cleanup EXIT
                                                                                                                    export TEMPORARY=${ environment-variable 1 } &&
                                                                                                                    export INIT_STATUS=${ environment-variable 2 } &&
                                                                                                                    export RELEASE_STATUS=${ environment-variable 3 } &&
                                                                                                                    export ARGUMENTS=${ environment-variable 4 } &&
                                                                                                                    export STDIN=${ environment-variable 5 } &&
                                                                                                                    export HAS_STDIN=${ environment-variable 6 } &&
                                                                                                                    export TEST_INIT=${ environment-variable 7 } &&
                                                                                                                    if [ "${ environment-variable "HAS_STDIN" }" == "true" ]
                                                                                                                    then
                                                                                                                        TARGET=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable "STDIN" } | ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } )
                                                                                                                    else
                                                                                                                        TARGET=$( ${ environment-variable "TEMPORARY" } ${ environment-variable "ARGUMENTS" } )
                                                                                                                    fi &&
                                                                                                                    RESOURCE=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable "TARGET" } ) &&
                                                                                                                    if [ ! -d ${ environment-variable "RESOURCE" } ]
                                                                                                                    then
                                                                                                                        MESSAGE="We did not create the RESOURCE directory." &&
                                                                                                                            exit 64
                                                                                                                    fi &&
                                                                                                                    if [ ${ environment-variable "TEST_INIT" } == "true" ]
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/sleep &&
                                                                                                                            if [ ! -f ${ environment-variable "TARGET" } ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not create the TARGET file." &&
                                                                                                                                    exit 64
                                                                                                                            fi &&
                                                                                                                            if [ ! -f ${ environment-variable "RESOURCE" }/init.out.log ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not log init out." &&
                                                                                                                                    exit 64
                                                                                                                            elif [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.out.log )" != "eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not correctly log init out." &&
                                                                                                                                    export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.log.out )" &&
                                                                                                                                    export EXPECTED="eac99df8ad2fd51672d0504f02c2b1ea4af884a2705273f9653649cb7264c31fbc27e4daa328b3d1651da8b3880434b972b42200670c03f86fd0a77c371fea24" &&
                                                                                                                                    exit 64
                                                                                                                            elif [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.out.log ) != "400" ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not lock init out." &&
                                                                                                                                    exit 64
                                                                                                                            fi &&
                                                                                                                            if [ ! -f ${ environment-variable "RESOURCE" }/init.err.log ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not log init err." &&
                                                                                                                                    exit 64
                                                                                                                            elif [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.err.log )" != "193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952" ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not correctly log init err." &&
                                                                                                                                    export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.err.log )" &&
                                                                                                                                    export EXPECTED="193c8f5b2f5b97ba3ed5cd30c625144f71a361d8f9b225ae6614725ea1b59a8de3d995628902ca8fa5a5d4bb4376258302538eb922d2283fc7894dda1ffa8952" &&
                                                                                                                                    exit 64
                                                                                                                            elif [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.err.log ) != "400" ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not lock init err." &&
                                                                                                                                    exit 64
                                                                                                                            fi &&
                                                                                                                            if [ ! -f ${ environment-variable "RESOURCE" }/init.status.asc ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not record the init status." &&
                                                                                                                                    exit 64
                                                                                                                            elif [ $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.status.asc ) != ${ environment-variable "INIT_STATUS" } ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not correctly record the init status." &&
                                                                                                                                    export OBSERVED="$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.status.asc )" &&
                                                                                                                                    exit 64
                                                                                                                            elif [ $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.status.asc ) != "0400" ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not lock init status." &&
                                                                                                                                    exit 64
                                                                                                                            fi &&
                                                                                                                            if [ ! -f ${ environment-variable "INIT_ARGUMENTS" } ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not write init arguments." &&
                                                                                                                                    exit 64
                                                                                                                            elif [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "INIT_ARGUMENTS" } )" != "${ environment-variable "ARGUMENTS" }" ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did not correctly write the init arguments." &&
                                                                                                                                    exit 54
                                                                                                                            fi
                                                                                                                    else
                                                                                                                        if [ -e ${ environment-variable "TARGET" } ]
                                                                                                                        then
                                                                                                                            export MESSAGE="We did create the TARGET." &&
                                                                                                                                exit 64
                                                                                                                        fi &&
                                                                                                                            if [ -e ${ environment-variable "RESOURCE" }/init.out.log ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did log init out." &&
                                                                                                                                    exit 64
                                                                                                                            fi &&
                                                                                                                            if [ -e ${ environment-variable "RESOURCE" }/init.err.log ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did log init err." &&
                                                                                                                                    exit 64
                                                                                                                            fi &&
                                                                                                                            if [ -e ${ environment-variable "RESOURCE" }/init.status.asc ]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did record the initial status" &&
                                                                                                                                    exit 64
                                                                                                                            fi &&
                                                                                                                            if [ -e ${ environment-variable "INIT_ARGUMENTS"  }]
                                                                                                                            then
                                                                                                                                export MESSAGE="We did write the arguments." &&
                                                                                                                                    exit 64
                                                                                                                            fi
                                                                                                                    fi &&

                                                                                                                    if [ -e ${ environment-variable "RELEASE_FLAG" } ]
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/echo inner present release flag >&2 &&
                                                                                                                            exit 64
                                                                                                                    fi &&
                                                                                                                    if [ -e ${ environment-variable "RESOURCE" }/release.out.log ]
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/echo inner present release log out >&2 &&
                                                                                                                            exit 64
                                                                                                                    fi &&
                                                                                                                    if [ -e ${ environment-variable "RESOURCE" }/release.err.log ]
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/echo inner present release log err >&2 &&
                                                                                                                            exit 64
                                                                                                                    fi
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "TARGET" }
                                                                                                            '' ;
                                                                                                        outer =
                                                                                                            let
                                                                                                                mktemp = "${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.verification" ;
                                                                                                                in
                                                                                                                    ''
                                                                                                                        RELEASE_STATUS=${ environment-variable 3 } &&
                                                                                                                            export INIT_ARGUMENTS=$( ${ mktemp } ) &&
                                                                                                                            export INIT_STDIN=$( ${ mktemp } ) &&
                                                                                                                            export RELEASE_FLAG=$( ${ mktemp } ) &&
                                                                                                                            if [ -z "${ environment-variable "RELEASE_STATUS" }" ]
                                                                                                                            then
                                                                                                                                TEST_RELEASE=false
                                                                                                                            else
                                                                                                                                TEST_RELEASE=true
                                                                                                                            fi &&
                                                                                                                            if ${ has-standard-input }
                                                                                                                            then
                                                                                                                                TARGET=$( ${ pkgs.coreutils }/bin/tee | ${ pkgs.writeShellScript "inner" inner } ${ environment-variable "@" } )
                                                                                                                            else
                                                                                                                                TARGET=$( ${ pkgs.writeShellScript "inner" inner } ${ environment-variable "@" } )
                                                                                                                            fi &&
                                                                                                                            RESOURCE=$( ${ pkgs.coreutils }/bin/dirname ${ environment-variable "TARGET" } ) &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo RESOURCE=${ environment-variable "RESOURCE" } &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo We have determined that sleep 1 second is too fast because the test for removal happens before the removal has had a chance. &&
                                                                                                                            ${ pkgs.coreutils }/bin/sleep 10s &&
                                                                                                                            if [ "${ environment-variable "TEST_RELEASE" }" == "true" ]
                                                                                                                            then
                                                                                                                                ${ pkgs.coreutils }/bin/true NOTHING FOR NOW
                                                                                                                            else
                                                                                                                                if [ ! -f ${ environment-variable "RELEASE_FLAG" } ]
                                                                                                                                then
                                                                                                                                    ${ pkgs.coreutils }/bin/echo outer missing release flag >&2 &&
                                                                                                                                       exit 64
                                                                                                                                fi &&
                                                                                                                                if [ -e ${ environment-variable "RESOURCE" } ]
                                                                                                                                then
                                                                                                                                    ${ pkgs.coreutils }/bin/echo outer present resource directory >&2 &&
                                                                                                                                        exit 64
                                                                                                                                fi
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
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-11 } 0 0 59eea253e2372353f978847b87e80d02b0568754c503e3718bbc8388ee99bf7381479ca8a2935362188f581cdab6ffb59dc403381b59d66ae1d62eb4802d93f4 5127cbcfc550b084ca27070a3d5b4aeb034cb174fd9aedb19f9e3c85c95f97d138123ca6b826fd5d009e9f24e1c25d6aedefc8c91f92b8284fae94942a488c9d true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-11 } 0 0 c8a2d7e7f7683f8f2db452bf311013d17d321a077489e4928f1a95d38a26a5b99942c2b69608238c31816eba23369bab3f43f51c7eb1c954bcaa56a7898d3886 47ce8fce72162158377951a30e52a638c2dd87b849d88ce4e4d65622ecda0fcffde884831cd1cca3ad03e46b7bf3cceb3136bcff9b8c55461567c29d20292657 false true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-21 } 65 0 57e593f977b1be52e9bfdc465811aa7ade6d6d99b202e64fb0a4d0f5bc9ae581244a7eba872cd073ff9bbd374282421ff24590d703d75d4b82596811531344d7 c1cdefe06092f250e1a05013e2d78957927cb865300fb03b86a2788c812f56a29cf074a7d7291b17c965ddddc6f1b7c9d99885a4827a925b5d72cf1b9bb81191 true true &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta-21 } 65 0 a650fec07ebe71e3bd0cc888f03bbb023c11b6cd0a5565d8ed579e899ba40f100e83f24feb9043d1df8f764bc30a70b752520bb79a03daac773af921cffa6021 891e854719b25e5610aadac6bd2e7351fcfbdf489a1a07701a743e5b381d870be1d49e1f7b49fb7dd7d916daa203c2fc4e27593295933532980de39938e27a5c false true
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
