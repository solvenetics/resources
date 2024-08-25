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
                                    lock ? "/tmp/tmp.JnWlkWVHzR.lock" ,
                                    out ? "e07240d0b9209443a0219b9486f9c4e1fbbc3a3f58875105789ea8210f114bbf2c4d420efff457da21738b8cd00c5ae2c0935fc17ca575260d51d0903797f82d" ,
                                    secondary ? { } ,
                                    scripts ? secondary : { } ,
                                    target ? "e4608844be8ee356014f54c180b70cce7b8f1c34d9b73a8f3d9f516135ef5b889f9bd2ca55f4d1d66d3b81ed58f2c90a5e7ff082fa3c704339c0772ead4c644a" ,
                                    temporary ? { } ,
                                    temporary-init-error-code ? 64 ,
                                    temporary-init-error-message ? resource-directory : "We were unable to complete initiation:  ${ resource-directory }." ,
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
                                                    environment-variable = name : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString name ) "}" ] ;
                                                    mappers =
                                                        let
                                                            script =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then
                                                                        strip
                                                                            ''
                                                                                write_it ${ pkgs.writeShellScript name ( value secondary tertiary ) } ${ builtins.concatStringsSep "/" path } "${ name }"
                                                                            ''
                                                                    else if builtins.typeOf value == "set" then  builtins.mapAttrs ( script ( builtins.concatLists [ path [ name ] ] ) ) value
                                                                    else builtins.throw ( invalid-script-throw value ) ;
                                                            in
                                                                {
                                                                    script = script [ ( environment-variable out ) "scripts" ] ;
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
                                                    tertiary =
                                                        let
                                                            has-standard-input =
                                                                strip
                                                                    ''
                                                                        [ -t 0 ] || [[ "$( ${ pkgs.coreutils }/bin/readlink /proc/self/fd/0 )" == pipe:* ]]
                                                                    '' ;
                                                            mapper =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then builtins.concatStringsSep "/" ( builtins.concatLists [ path [ name ] ])
                                                                    else builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                            in
                                                                {
                                                                    environment-variable = environment-variable ;
                                                                    has-standard-input = has-standard-input ;
                                                                    scripts = builtins.mapAttrs ( mapper [ ( environment-variable out ) "scripts" ] ) scripts ;
                                                                    strip = strip ;
                                                                } ;
                                                    write =
                                                        let
                                                            input =
                                                                {
                                                                    "${ environment-variable out }" =
                                                                        {
                                                                            scripts = builtins.mapAttrs mappers.script scripts ;
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
                                                                resources =
                                                                    lib
                                                                        {
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            scripts =
                                                                                {
                                                                                    test=
                                                                                        { ... } : { environment-variable , scripts , ... } :
                                                                                            ''
                                                                                                para_script ( )
                                                                                                    {
                                                                                                        SCRIPT=${ environment-variable 1 } &&
                                                                                                            HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                            STATUS_CODE=${ environment-variable 3 } &&
                                                                                                            LOG_FILE=${ environment-variable 4 } &&
                                                                                                            EXPECTED=${ environment-variable 5 } &&
                                                                                                            ARGUMENTS=${ environment-variable 6 } &&
                                                                                                            STANDARD_INPUT=${ environment-variable 7 } &&
                                                                                                            if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                            then
                                                                                                                assert_status_code ${ environment-variable "STATUS_CODE" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" }"
                                                                                                            elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                            then
                                                                                                                assert_status_code ${ environment-variable "STATUS_CODE" } "${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" }"
                                                                                                            else
                                                                                                                fail "We did not expect STATUS_CODE=${ environment-variable "STATUS_CODE" }"
                                                                                                            fi
                                                                                                    } &&
                                                                                                    test_script ( )
                                                                                                        {
                                                                                                             para_script ${ scripts.verification.script.bad } true 71 /build/UhVGqTXa.confirm "" izw vft
                                                                                                        }
                                                                                            '' ;
                                                                                    verification =
                                                                                        let
                                                                                            script =
                                                                                                 { log-file , status-code , log-begin , log-end , arguments-begin , arguments-end , arguments-no , standard-input-begin , standard-input-end , standard-input-no , standard-output , standard-error , ... } : { pkgs , ... } : { environment-variable , has-standard-input , scripts , strip } :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo -n ${ log-begin }_ >> ${ log-file } &&
                                                                                                            if [ -z "${ environment-variable "@" }" ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ arguments-no }_ >> ${ log-file }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ arguments-begin }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "@" }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ arguments-end }_ >> ${ log-file }
                                                                                                            fi &&
                                                                                                            if ${ has-standard-input }
                                                                                                            then
                                                                                                                STANDARD_INPUT=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ standard-input-begin }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "STANDARD_INPUT" }_ >> ${ log-file } &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo -n ${ standard-input-end }_ >> ${ log-file }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ standard-input-no }_ >> ${ log-file }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ standard-output } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ standard-error } >&2 &&
                                                                                                            ${ pkgs.coreutils }/bin/echo -n ${ log-end }_ >> ${ log-file } &&
                                                                                                            exit ${ builtins.toString status-code }
                                                                                                    '' ;
                                                                                            in
                                                                                                {
                                                                                                    script =
                                                                                                        {
                                                                                                            bad =
                                                                                                                script
                                                                                                                    {
                                                                                                                        log-file = "/build/UhVGqTXa.confirm" ;
                                                                                                                        status-code = 71 ;
                                                                                                                        log-begin = "bvq" ;
                                                                                                                        log-end = "fsk" ;
                                                                                                                        log-no = "ses" ;
                                                                                                                        arguments-begin = "qyr" ;
                                                                                                                        arguments-end = "yfp" ;
                                                                                                                        arguments-no = "neb" ;
                                                                                                                        standard-input-begin = "lmc" ;
                                                                                                                        standard-input-end = "tsp" ;
                                                                                                                        standard-input-no = "yzr" ;
                                                                                                                        standard-output = "nqt" ;
                                                                                                                        standard-error = "yun" ;
                                                                                                                    } ;
                                                                                                        } ;
                                                                                                } ;
                                                                                } ;
                                                                        } ;
                                                                in
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                            export e07240d0b9209443a0219b9486f9c4e1fbbc3a3f58875105789ea8210f114bbf2c4d420efff457da21738b8cd00c5ae2c0935fc17ca575260d51d0903797f82d=${ resources } &&
                                                                            ${ pkgs.bash_unit }/bin/bash_unit ${ resources }/scripts/test.sh
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
