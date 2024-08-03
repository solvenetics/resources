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
                                    at ? "/run/wrappers/at" ,
                                    invalid-script-throw ?  value : "b01a14bb7131a8e7bd216e451e4203a123c0b8df5e15dbf52ab6aea134f9eebc33572e663103bf60fcdb71ea6761d8bcb2cc6f8a9170165b5023138f05d1b172:  ${ builtins.typeOf value }" ,
                                    invalid-temporary-throw ? value : "5a675ed32421e1ca7f99ad18413cc5ae2b4bde11700e6f0cf77e326c1af9767cc27a87ecb806979701239425790efeb06bc3e3e65d501fdc799a0a685ecf4ad2:  ${ builtins.typeOf value }" ,
                                    secondary ? { } ,
                                    scripts ? secondary : { } ,
                                    target ? "e4608844be8ee356014f54c180b70cce7b8f1c34d9b73a8f3d9f516135ef5b889f9bd2ca55f4d1d66d3b81ed58f2c90a5e7ff082fa3c704339c0772ead4c644a" ,
                                    temporary ? { } ,
                                    temporary-init-error-code ? 64 ,
                                    temporary-init-error-message ? resource-directory : "We were unable to complete initiation:  ${ resource-directory }." ,
                                    temporary-resource-directory ? "${ pkgs.coreutils }/bin/mktemp --directory -t XXXXXXXX.resource"
                                } :
                                    let
                                        environment-variable = name : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString name ) "}" ] ;
                                        outputs =
                                            {
                                                scripts =
                                                    let
                                                        mapper =
                                                            path : name : value :
                                                                if builtins.typeOf value == "lambda" then pkgs.writeShellScript name ( value ( secondary // { environment-variable = environment-variable ; target = target ; } ) )
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
                                                                                    if [ -t 0 ]
                                                                                    then
                                                                                        if ${ pkgs.coreutils }/bin/tee | ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                        then
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                        else
                                                                                             ${ pkgs.coreutils }/bin/echo ${ temporary-init-error-message "${ environment-variable "RESOURCE" }" } >&2 &&
                                                                                                exit ${ builtins.toString temporary-init-error-code }
                                                                                        fi
                                                                                    else
                                                                                        if ${ temporary.init } ${ environment-variable "@" } > ${ environment-variable "RESOURCE" }/init.out.log 2> ${ environment-variable "RESOURCE" }/init.err.log
                                                                                        then
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable target }
                                                                                        else
                                                                                           ${ pkgs.coreutils }/bin/echo ${ temporary-init-error-message "${ environment-variable "RESOURCE" }" } >&2 &&
                                                                                                exit ${ builtins.toString temporary-init-error-code }
                                                                                        fi
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
                                                                                                { pkgs , environment-variable , target , ... } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target } &&
                                                                                                            ${ pkgs.coreutils }/bin/touch ${ environment-variable target } > ${ environment-variable "f8ddb5346d7a40337e77b2f8dc621f0fca7901a106e8b69cd0840a5cfea61cfc92073b1af215b5f8d8c687f41dc711594da655233f1965c269990f0c55903933" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } > ${ environment-variable target }/arguments &&
                                                                                                            if [ -t 0 ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/tee > ${ environment-variable target }/stdin
                                                                                                            fi
                                                                                                    '' ;
                                                                                        } ;
                                                                                    release =
                                                                                        {
                                                                                            beta =
                                                                                                { pkgs , environment-variable , target , ... } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ environment-variable "e89cff209ac3b6e3b22c0f3b1a7c0a246c95857f513785cb39a60a7181aec208b29bb9dbbba8b08c742319915810a402446d8760da285db887f0933423aed2f6" }
                                                                                                    '' ;
                                                                                        } ;
                                                                                    verification =
                                                                                        {
                                                                                            temporary =
                                                                                                { pkgs , environment-variable , target ,... } :
                                                                                                    let
                                                                                                        mktemp = "${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.verification" ;
                                                                                                        in
                                                                                                            ''
                                                                                                                export f8ddb5346d7a40337e77b2f8dc621f0fca7901a106e8b69cd0840a5cfea61cfc92073b1af215b5f8d8c687f41dc711594da655233f1965c269990f0c55903933=$( ${ mktemp } ) &&
                                                                                                                    export e44a5854dee7d93638bc69f1dc0001cffb6826f723779d53195a93bcac4e976f52bf03f583212c1a88db6f8d8685204d0ed6b7f8bb5c6cb6f3e945796acbc549=$( ${ mktemp } ) &&
                                                                                                                    TARGET=$( ${ environment-variable 1 } ${ environment-variable 2 } ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo TARGET=${ environment-variable "TARGET" } &&
                                                                                                                    if [ ! -f ${ environment-variable "f8ddb5346d7a40337e77b2f8dc621f0fca7901a106e8b69cd0840a5cfea61cfc92073b1af215b5f8d8c687f41dc711594da655233f1965c269990f0c55903933" } ]
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/echo missing init flag &&
                                                                                                                            exit 64
                                                                                                                    fi &&
                                                                                                                    if [ "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "TARGET" }/arguments )" != "${ environment-variable 2 }" ]
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/echo wrong arguments &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo EXPECTED &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable 2 } &&
                                                                                                                            ${ pkgs.coreutils }/bin/echo OBSERVED &&
                                                                                                                            ${ pkgs.coreutils }/bin/cat ${ environment-variable "TARGET" }/arguments
                                                                                                                    fi &&
                                                                                                                    if [ ${ environment-variable "#" } == 2 ]
                                                                                                                    then
                                                                                                                        if [ -e ${ environment-variable "TARGET" }/stdin ]
                                                                                                                        then
                                                                                                                            ${ pkgs.coreutils }/bin/echo UNEXPECTED stdin file
                                                                                                                        fi
                                                                                                                    fi &&
                                                                                                                    exit 64

                                                                                                            '' ;
                                                                                        } ;
                                                                                } ;
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            temporary =
                                                                                {
                                                                                    beta =
                                                                                        scripts :
                                                                                            {
                                                                                                init = scripts.init.beta ;
                                                                                                release = scripts.release.beta ;
                                                                                            } ;
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
                                                                                    ${ resources.scripts.alpha } ${ resources.temporary.beta } &&
                                                                                    exit 64
                                                                            fi &&
                                                                            ${ resources.scripts.verification.temporary } ${ resources.temporary.beta } 1e9dd5648ba703f4ff798808bd0fbcc8f97241fc20a44c39272d42935a4dbc7945b64f855a4ddf3b1a3337098192b19545854b0cff4c9c0aa5128ee64ed97802
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
