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
                                    invalid-script-throw ? value : "b01a14bb7131a8e7bd216e451e4203a123c0b8df5e15dbf52ab6aea134f9eebc33572e663103bf60fcdb71ea6761d8bcb2cc6f8a9170165b5023138f05d1b172:  ${ builtins.typeOf value }" ,
                                    invalid-temporary-throw ? value : "5a675ed32421e1ca7f99ad18413cc5ae2b4bde11700e6f0cf77e326c1af9767cc27a87ecb806979701239425790efeb06bc3e3e65d501fdc799a0a685ecf4ad2:  ${ builtins.typeOf value }" ,
                                    out ? "e07240d0b9209443a0219b9486f9c4e1fbbc3a3f58875105789ea8210f114bbf2c4d420efff457da21738b8cd00c5ae2c0935fc17ca575260d51d0903797f82d" ,
                                    resource ? "bf01d7a5dfd1ad0c7bd4a8ecba39063384d09898d821698c82691d8f28d9aa1067e4abeff96cf3641ab311d22cb5937b9429b6ca0c151d6365fbe0025c575f01" ,
                                    secondary ? { } ,
                                    scripts ? secondary : { } ,
                                    target ? "e4608844be8ee356014f54c180b70cce7b8f1c34d9b73a8f3d9f516135ef5b889f9bd2ca55f4d1d66d3b81ed58f2c90a5e7ff082fa3c704339c0772ead4c644a" ,
                                    temporary ? { } ,
                                    temporary-hold ? 0 ,
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
                                                                                                let
                                                                                                    null =
                                                                                                        ''
                                                                                                            ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable resource }
                                                                                                        '' ;
                                                                                                    set =
                                                                                                        ''
                                                                                                            if ${ pkgs.writeShellScript "release" temporary.release } > ${ environment-variable resource }/release.out.log 2> ${ environment-variable resource }/release.err.log
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable resource }/release.status.asc &&
                                                                                                                    ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable resource }/release.out.log ${ environment-variable resource }/release.err.log ${ environment-variable resource }/release.status.asc &&
                                                                                                                    ${ pkgs.coreutils }/bin/sleep ${ builtins.toString temporary-hold }s &&
                                                                                                                    ${ pkgs.coreutils }/bin/rm --recursive --force ${ environment-variable resource }
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable resource }/release.status.asc &&
                                                                                                                    ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable resource }/release.out.log ${ environment-variable resource }/release.err.log ${ environment-variable resource }/release.status.asc &&
                                                                                                                    ${ pkgs.coreutils }/bin/sleep ${ builtins.toString temporary-hold }s &&
                                                                                                                    ${ pkgs.coreutils }/bin/mv ${ environment-variable resource } $( ${ temporary-broken-directory } )
                                                                                                            fi
                                                                                                        '' ;
                                                                                                    in
                                                                                                        ''
                                                                                                            ${ pkgs.findutils }/bin/find ${ environment-variable resource } -mindepth 1 -maxdepth 1 -type f -name "*.pid" | while read PID_FILE
                                                                                                            do
                                                                                                                PID=$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "PID_FILE" } ) &&
                                                                                                                     ${ pkgs.coreutils }/bin/tail --follow /dev/null --pid ${ environment-variable "PID" } &&
                                                                                                                     ${ pkgs.coreutils }/bin/rm ${ environment-variable "PID_FILE" }
                                                                                                            done &&
                                                                                                            export ${ target }=${ environment-variable resource }/target &&
                                                                                                            ${ if builtins.typeOf temporary.release == "null" then null else set }
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
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "STATUS" } > ${ environment-variable resource }/init.status.asc &&
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
                                                                                                            ${ pkgs.coreutils }/bin/chmod 0400 ${ environment-variable resource }/init.sh ${ environment-variable resource }/arguments.asc ${ environment-variable resource }/standard-input.asc ${ environment-variable resource }/init.out.log ${ environment-variable resource }/init.err.log ${ environment-variable resource }/init.status.asc
                                                                                                     '' ;
                                                                                            } ;
                                                                                    in
                                                                                        ''
                                                                                            export ${ resource }=$( ${ temporary-resource-directory } ) &&
                                                                                                ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "clean" clean } ${ environment-variable resource }/clean &&
                                                                                                export ${ target }=${ environment-variable resource }/target &&
                                                                                                if ${ has-standard-input }
                                                                                                then
                                                                                                    WAIT_PID=${ environment-variable "PPID" } &&
                                                                                                        STATUS=$( ${ pkgs.coreutils }/bin/tee | ${ pkgs.writeShellScript "prepare" prepare.has-standard-input } ${ environment-variable "@" } )
                                                                                                else
                                                                                                    WAIT_PID=$( ${ pkgs.procps }/bin/ps -o ppid= -p ${ environment-variable "PPID" } | ${ pkgs.findutils }/bin/xargs ) &&
                                                                                                        STATUS=$( ${ pkgs.writeShellScript "prepare" prepare.does-not-have-standard-input } ${ environment-variable "@" } )
                                                                                                fi &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "WAIT_PID" } > ${ environment-variable resource }/${ environment-variable "WAIT_PID" }.pid
                                                                                                if [ ${ environment-variable "STATUS" } == 0 ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable target } &&
                                                                                                        ${ pkgs.coreutils }/bin/echo "${ pkgs.coreutils }/bin/nice --adjustment 19 ${ environment-variable resource }/clean" | ${ at } now
                                                                                                else
                                                                                                    BROKEN=$( ${ temporary-broken-directory } ) &&
                                                                                                        ${ pkgs.coreutils }/bin/mv ${ environment-variable resource } ${ environment-variable "BROKEN" } &&
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "BROKEN" }/target &&
                                                                                                        exit ${ builtins.toString temporary-init-error-code }
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
                                                                    scripts = scripts [ ( environment-variable out ) "scripts" ] ;
                                                                    temporary = temporary [ ( environment-variable out ) "temporary" ] ;
                                                                } ;
                                                    write =
                                                        let
                                                            input =
                                                                {
                                                                    "${ environment-variable out }" =
                                                                        {
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
                                                                            COMMAND=$( ${ pkgs.coreutils }/bin/tee ) &&
                                                                                if [ -z "${ environment-variable "COMMAND" }" ]
                                                                                then
                                                                                    ${ pkgs.coreutils }/bin/false
                                                                                else
                                                                                    ${ pkgs.bash }/bin/bash -c "${ environment-variable "COMMAND" }" &
                                                                                fi
                                                                        '' ;
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
                                                                                                            ${ pkgs.coreutils }/bin/echo TEMPORARY TARGET ${ environment-variable "ARGUMENTS" } ${ environment-variable "STANDARD_INPUT" } >> ${ environment-variable target } &&
                                                                                                            ${ pkgs.coreutils }/bin/chmod a+rwx ${ environment-variable target } &&
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
                                                                                                    good = scripts : { init = scripts.bad ; release = scripts.good ; } ;
                                                                                                    null = scripts : { init = scripts.bad ; } ;
                                                                                                } ;
                                                                                            good =
                                                                                                {
                                                                                                    bad = scripts : { init = scripts.good ; release = scripts.bad ; } ;
                                                                                                    good = scripts : { init = scripts.good ; release = scripts.good ; } ;
                                                                                                    null = scripts : { init = scripts.good ; } ;
                                                                                                } ;
                                                                                            null =
                                                                                                {
                                                                                                    bad = scripts : { release = scripts.bad ; } ;
                                                                                                    good = scripts : { release = scripts.good ; } ;
                                                                                                    null = scripts : { } ;
                                                                                                } ;
                                                                                        } ;
                                                                                    temporary-hold = 1 ;
                                                                                } ;
                                                                        util =
                                                                            lib
                                                                                {
                                                                                    at = at ;
                                                                                    out = out ;
                                                                                    scripts =
                                                                                        {
                                                                                            directory =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        INPUT=${ environment-variable 1 } &&
                                                                                                            CAT_DIRECTORY=${ environment-variable 2 } &&
                                                                                                            STAT_DIRECTORY=${ environment-variable 3 } &&
                                                                                                            MISSING_DIRECTORY=${ environment-variable 4 } &&
                                                                                                            CAT_DUPLICATE=${ environment-variable 5 } &&
                                                                                                            STAT_DUPLICATE=${ environment-variable 6 } &&
                                                                                                            if [ -d ${ environment-variable "INPUT" } ]
                                                                                                            then
                                                                                                                ${ pkgs.findutils }/bin/find ${ environment-variable "INPUT" } -not -name "*.pid" | while read I
                                                                                                                do
                                                                                                                    RELATIVE=$( ${ pkgs.coreutils }/bin/echo ${ environment-variable "I" } | ${ pkgs.gnused }/bin/sed -e "s#^${ environment-variable "INPUT" }##" ) &&
                                                                                                                        ABSOLUTE_CAT=${ environment-variable "CAT_DIRECTORY" }${ environment-variable "RELATIVE" } &&
                                                                                                                        ABSOLUTE_STAT=${ environment-variable "STAT_DIRECTORY" }${ environment-variable "RELATIVE" } &&
                                                                                                                        if [ -e ${ environment-variable "ABSOLUTE_CAT" } ]
                                                                                                                        then
                                                                                                                            ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "ABSOLUTE_CAT" } >> ${ environment-variable "CAT_DUPLICATE" }
                                                                                                                        fi &&
                                                                                                                        if [ -e ${ environment-variable "ABSOLUTE_STAT" } ]
                                                                                                                        then
                                                                                                                            ${ pkgs.coreutils }/bin/echo -n ${ environment-variable "ABSOLUTE_STAT" } >> ${ environment-variable "STAT_DUPLICATE" }
                                                                                                                        fi &&
                                                                                                                        if [ -d ${ environment-variable "I" } ]
                                                                                                                        then
                                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "ABSOLUTE_CAT" } &&
                                                                                                                                ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "ABSOLUTE_STAT" }
                                                                                                                        else
                                                                                                                            ${ pkgs.gnused }/bin/sed -e "s#/nix/store/[a-z0-9]\{32\}#/nix/store#g" -e w${ environment-variable "ABSOLUTE_CAT" } ${ environment-variable "I" } > /dev/null 2>&1 &&
                                                                                                                                ${ pkgs.coreutils }/bin/stat --format %A ${ environment-variable "I" } > ${ environment-variable "ABSOLUTE_STAT" }
                                                                                                                        fi
                                                                                                                done
                                                                                                            else
                                                                                                                ${ pkgs.coreutils }/bin/touch ${ environment-variable "MISSING_DIRECTORY" }
                                                                                                            fi
                                                                                                    '' ;
                                                                                            post-create =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        INPUT=${ environment-variable 1 } &&
                                                                                                            POST_CREATE=${ environment-variable 2 } &&
                                                                                                            CAT_DIRECTORY=${ environment-variable 3 } &&
                                                                                                            STAT_DIRECTORY=${ environment-variable 4 } &&
                                                                                                            MISSING_DIRECTORY=${ environment-variable 5 } &&
                                                                                                            CAT_DUPLICATE=${ environment-variable 6 } &&
                                                                                                            STAT_DUPLICATE=${ environment-variable 7 } &&
                                                                                                            ${ pkgs.inotify-tools }/bin/inotifywait --monitor --event create ${ environment-variable "INPUT" } --format "%f" | while read FILE
                                                                                                            do
                                                                                                                if [ ${ environment-variable "FILE" } == "release.status.asc" ]
                                                                                                                then
                                                                                                                    ${ pkgs.inotify-tools }/bin/inotifywait --monitor --event attrib ${ environment-variable "INPUT" }/release.status.asc | while read FILE
                                                                                                                    do
                                                                                                                        ${ environment-variable out }/scripts/directory ${ environment-variable "INPUT" } ${ environment-variable "CAT_DIRECTORY" } ${ environment-variable "STAT_DIRECTORY" } ${ environment-variable "MISSING_DIRECTORY" } ${ environment-variable "CAT_DUPLICATE" } ${ environment-variable "STAT_DUPLICATE" }
                                                                                                                    done
                                                                                                                fi &&
                                                                                                                    if [ ! -d ${ environment-variable "POST_CREATE" } ]
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "POST_CREATE" }
                                                                                                                    fi &&
                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "FILE" } >> ${ environment-variable "POST_CREATE" }/${ environment-variable "FILE" }
                                                                                                            done
                                                                                                    '' ;
                                                                                            post-operate =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        INPUT=${ environment-variable 1 } &&
                                                                                                            OPERATION=${ environment-variable 2 } &&
                                                                                                            FLAG=${ environment-variable 3 } &&
                                                                                                            ${ pkgs.inotify-tools }/bin/inotifywait --monitor --event ${ environment-variable "OPERATION" } ${ environment-variable "INPUT" } | while read FILE
                                                                                                            do
                                                                                                                ${ pkgs.coreutils }/bin/echo -n A >> ${ environment-variable "FLAG" }
                                                                                                            done
                                                                                                    '' ;
                                                                                            record =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        COMMAND=${ environment-variable 1 } &&
                                                                                                            HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                            ARGUMENTS_=${ environment-variable 3 } &&
                                                                                                            STANDARD_INPUT_=${ environment-variable 4 } &&
                                                                                                            ABSOLUTE=${ environment-variable 5 } &&
                                                                                                            IS_TEMPORARY=${ environment-variable 6 } &&
                                                                                                            TEMPORARY_OUT=$( ${ pkgs.coreutils }/bin/mktemp ) &&
                                                                                                            OUT=${ environment-variable "ABSOLUTE" }/out &&
                                                                                                            ERR=${ environment-variable "ABSOLUTE" }/err &&
                                                                                                            STATUS=${ environment-variable "ABSOLUTE" }/status &&
                                                                                                            PRE_CAT_DIRECTORY=${ environment-variable "ABSOLUTE" }/pre.cat &&
                                                                                                            PRE_STAT_DIRECTORY=${ environment-variable "ABSOLUTE" }/pre.stat &&
                                                                                                            PRE_MISSING_FLAG=${ environment-variable "ABSOLUTE" }/pre.missing &&
                                                                                                            PRE_CAT_DUPLICATE_FLAG=${ environment-variable "ABSOLUTE" }/pre.cat.duplicate &&
                                                                                                            PRE_STAT_DUPLICATE_FLAG=${ environment-variable "ABSOLUTE" }/pre.stat.duplicate &&
                                                                                                            POST_CREATE_FLAG=${ environment-variable "ABSOLUTE" }/post.create &&
                                                                                                            POST_CAT_DIRECTORY=${ environment-variable "ABSOLUTE" }/post.cat &&
                                                                                                            POST_STAT_DIRECTORY=${ environment-variable "ABSOLUTE" }/post.stat &&
                                                                                                            POST_MISSING_FLAG=${ environment-variable "ABSOLUTE" }/post.missing &&
                                                                                                            POST_CAT_DUPLICATE_FLAG=${ environment-variable "ABSOLUTE" }/post.cat.duplicate &&
                                                                                                            POST_STAT_DUPLICATE_FLAG=${ environment-variable "ABSOLUTE" }/post.stat.duplicate &&
                                                                                                            POST_DELETE_FLAG=${ environment-variable "ABSOLUTE" }/post.delete &&
                                                                                                            POST_MOVE_FLAG=${ environment-variable "ABSOLUTE" }/post.move &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ environment-variable "ABSOLUTE" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "HAS_STANDARD_INPUT" } > ${ environment-variable "ABSOLUTE" }/has-standard-input &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ environment-variable "ARGUMENTS" } > ${ environment-variable "ABSOLUTE" }/arguments &&
                                                                                                            if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } > ${ environment-variable "ABSOLUTE" }/standard-input &&
                                                                                                                    if ${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "TEMPORARY_OUT" } 2> ${ environment-variable "ERR" }
                                                                                                                    then
                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                    else
                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                    fi
                                                                                                            else
                                                                                                                if ${ environment-variable "COMMAND" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "TEMPORARY_OUT" } 2> ${ environment-variable "ERR" }
                                                                                                                then
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                else
                                                                                                                    ${ pkgs.coreutils }/bin/echo ${ environment-variable "?" } > ${ environment-variable "STATUS" }
                                                                                                                fi
                                                                                                            fi &&
                                                                                                            ${ pkgs.gnused }/bin/sed -e "s#^/build/[0-9a-zA-Z]\{8\}[.]\(resource\|broken\)/target\$#\1#g" -e w${ environment-variable "OUT" } ${ environment-variable "TEMPORARY_OUT" } > /dev/null 2>&1 &&
                                                                                                            if [ ${ environment-variable "IS_TEMPORARY" } == true ]
                                                                                                            then
                                                                                                                INPUT=$( ${ pkgs.coreutils }/bin/dirname $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "TEMPORARY_OUT" } ) ) &&
                                                                                                                    ${ environment-variable out }/scripts/directory ${ environment-variable "INPUT" } ${ environment-variable "PRE_CAT_DIRECTORY" } ${ environment-variable "PRE_STAT_DIRECTORY" } ${ environment-variable "PRE_MISSING_FLAG" } ${ environment-variable "PRE_CAT_DUPLICATE_FLAG" } ${ environment-variable "PRE_STAT_DUPLICATE_FLAG" } > /dev/null 2>&1 &&
                                                                                                                    ${ pkgs.coreutils }/bin/echo "${ environment-variable out }/scripts/post-create ${ environment-variable "INPUT" } ${ environment-variable "POST_CREATE_FLAG" } ${ environment-variable "POST_CAT_DIRECTORY" } ${ environment-variable "POST_STAT_DIRECTORY" } ${ environment-variable "POST_MISSING_FLAG" } ${ environment-variable "POST_CAT_DUPLICATE_FLAG" } ${ environment-variable "POST_STAT_DUPLICATE_FLAG" }" | ${ at } now &&
                                                                                                                    # ${ pkgs.coreutils }/bin/echo "${ environment-variable out }/scripts/directory ${ environment-variable "INPUT" } ${ environment-variable "POST_CAT_DIRECTORY" } ${ environment-variable "POST_STAT_DIRECTORY" }" | ${ at } now > /dev/null 2>&1 &&
                                                                                                                    # ${ pkgs.coreutils }/bin/echo ${ environment-variable out }/scripts/post-operate ${ environment-variable "INPUT" } delete_self ${ environment-variable "POST_DELETE_FLAG" } | ${ at } now > /dev/null 2>&1 &&
                                                                                                                    # ${ pkgs.coreutils }/bin/echo ${ environment-variable out }/scripts/post-operate ${ environment-variable "INPUT" } move_self ${ environment-variable "POST_MOVE_FLAG" } | ${ at } now > /dev/null 2>&1
                                                                                                                    ${ pkgs.coreutils }/bin/true
                                                                                                            fi
                                                                                                    '' ;
                                                                                            scripts =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        COMMAND=${ environment-variable 1 } &&
                                                                                                            ARGUMENTS=${ environment-variable 2 } &&
                                                                                                            STANDARD_INPUT=${ environment-variable 3 } &&
                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/realpath --relative-to ${ resources.scripts }/scripts ${ environment-variable "COMMAND" } ) &&
                                                                                                            ABSOLUTE=${ environment-variable "OBSERVED_DIRECTORY" }/scripts/${ environment-variable "RELATIVE" } &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir --parents ${ environment-variable "ABSOLUTE" } &&
                                                                                                            ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } false $( ${ environment-variable out }/scripts/sha512 ${ environment-variable "ARGUMENTS" } false ) $( ${ environment-variable out }/scripts/sha512 ${ environment-variable "STANDARD_INPUT" } false ) ${ environment-variable "ABSOLUTE" }/false false &&
                                                                                                            ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } true $( ${ environment-variable out }/scripts/sha512 ${ environment-variable "ARGUMENTS" } true ) $( ${ environment-variable out }/scripts/sha512 ${ environment-variable "STANDARD_INPUT" } true ) ${ environment-variable "ABSOLUTE" }/true false
                                                                                                    '' ;
                                                                                            sha512 =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "@" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128
                                                                                                    '' ;
                                                                                            temporary =
                                                                                                { pkgs , ... } : target :
                                                                                                    ''
                                                                                                       COMMAND=${ environment-variable 1 } &&
                                                                                                            ARGUMENTS=${ environment-variable 2 } &&
                                                                                                            STANDARD_INPUT=${ environment-variable 3 } &&
                                                                                                            RELATIVE=$( ${ pkgs.coreutils }/bin/realpath --relative-to ${ resources.temporary }/temporary ${ environment-variable "COMMAND" } ) &&
                                                                                                            ABSOLUTE=${ environment-variable "OBSERVED_DIRECTORY" }/temporary/${ environment-variable "RELATIVE" } &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir --parents ${ environment-variable "ABSOLUTE" } &&
                                                                                                            ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } false ${ environment-variable "ARGUMENTS" } ${ environment-variable "STANDARD_INPUT" } ${ environment-variable "ABSOLUTE" } true &&
                                                                                                            ${ environment-variable out }/scripts/record ${ environment-variable "COMMAND" } true ${ environment-variable "ARGUMENTS" } ${ environment-variable "STANDARD_INPUT" } ${ environment-variable "ABSOLUTE" } true
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
                                                                            export EXPECTED_DIRECTORY=${ ./expected } &&
                                                                            export OBSERVED_DIRECTORY=$out &&
                                                                            ${ pkgs.findutils }/bin/find ${ resources.scripts }/scripts -mindepth 1 -type f -not -name "*.sh" -exec ${ resources.util }/scripts/scripts {} a0d791e90486ab349661235cd0913d11649f6659c848ef4fb8639d04267ecfa03d1c922c455f53727e01fd42749a37b816334d75588127384b9772a61840a25b 9f94b1c83ef72dc398aadf0931f9e723303d34781d433efb685ca793d054c810c6a752c94c0a4944ab43658cede7f1059616659110d3944e8645f5c79aeff59e \; &&
                                                                            # ${ pkgs.findutils }/bin/find ${ resources.temporary }/temporary -mindepth 1 -type f -not -name "*.sh" -exec ${ resources.util }/scripts/temporary {} f00f5a32e1ce243eec06f855b1a92661b0dac509bf625840334d7eb133be726000501227713c666f2e2f69f41b2792f5f77a3374be332a4c07eed1dbd74974d0 1e9e30f7de05fc8d9e3487d10ca229ffd3018ac54dd2213ee56e6891bb05709914478b1836dcc8f40cc0b6fe62616cfdda9f41d032da9069f671e656de1bddd2 \; &&
                                                                            ${ pkgs.coreutils }/bin/sleep 15s &&
                                                                            ${ pkgs.bash_unit }/bin/bash_unit ${ resources.util }/scripts/test.sh
                                                                    '' ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
