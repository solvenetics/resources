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
                                { scripts ? { } } :
                                    let
                                        environment-variable = name : builtins.concatStringsSep "" [ "$" "{" name "}" ] ;
                                        outputs =
                                            {
                                                scripts =
                                                    let
                                                        mapper =
                                                            path : name : value :
                                                                if builtins.typeOf value == "set" then builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                else pkgs.writeShellScript name value ;
                                                        in builtins.mapAttrs ( mapper [ ] ) scripts ;
                                            } ;
                                        in
                                            {
                                                environment-variable = environment-variable ;
                                                scripts = outputs.scripts ;
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
                                                                                        ''
                                                                                            ${ pkgs.coreutils }/bin/echo hi
                                                                                        '' ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            da9276c8b8e38cc2a707f129adbb126dcba08f4d72364b741725c23614f980e3bcf5643a2b46157ecf1e8f62dd9bd3c1bb5b18d4566cf430892eb1a4f28a3287=b63ab4cc53c0fb0ed14976cace70f3c4ea9fa95dee38fc2f9cdbcf7e48757787401e626f9374d93e7fe8f3ac43086931299314d87cc99f5ef255a4bb7fbd3dc4 &&
                                                                            if [ ${ resources.environment-variable "da9276c8b8e38cc2a707f129adbb126dcba08f4d72364b741725c23614f980e3bcf5643a2b46157ecf1e8f62dd9bd3c1bb5b18d4566cf430892eb1a4f28a3287" } == b63ab4cc53c0fb0ed14976cace70f3c4ea9fa95dee38fc2f9cdbcf7e48757787401e626f9374d93e7fe8f3ac43086931299314d87cc99f5ef255a4bb7fbd3dc4 ]
                                                                            then
                                                                                ${ pkgs.coreutils }/bin/echo The environment variable was set correctly.
                                                                            else
                                                                                ${ pkgs.coreutils }/bin/echo The environment variable was not set correctly. &&
                                                                                    exit 64
                                                                            fi &&
                                                                            ${ pkgs.coreutils }/bin/echo ${ resources.scripts.alpha } &&
                                                                            exit 64

                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
