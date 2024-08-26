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
                                                    tertiary =
                                                        let
                                                            mapper =
                                                                path : name : value :
                                                                    if builtins.typeOf value == "lambda" then builtins.concatStringsSep "/" ( builtins.concatLists [ path [ name ] ])
                                                                    else builtins.mapAttrs ( mapper ( builtins.concatLists [ path [ name ] ] ) ) value ;
                                                            in
                                                                {
                                                                    environment-variable = environment-variable ;
                                                                    has-standard-input = has-standard-input ;
                                                                    scripts = builtins.mapAttrs ( mapper [ ( environment-variable out ) "scripts" ] ) scripts ;
                                                                    target = target ;
                                                                    temporary = builtins.mapAttrs ( mapper [ ( environment-variable out ) "temporary" ] ) temporary ;
                                                                    strip = strip ;
                                                                } ;
                                                    write =
                                                        let
                                                            input =
                                                                {
                                                                    "${ environment-variable out }" =
                                                                        {
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
                                                                            at =
                                                                                pkgs.writeShellScript
                                                                                    "at"
                                                                                    ''
                                                                                        ${ pkgs.coreutils }/bin/tee &
                                                                                    '' ;
                                                                            secondary = { pkgs = pkgs ; } ;
                                                                            scripts =
                                                                                {
                                                                                    test=
                                                                                        { ... } : { environment-variable , scripts , temporary , ... } :
                                                                                            ''
                                                                                                util_mktemp ( )
                                                                                                    {
                                                                                                        ${ pkgs.coreutils }/bin/mktemp --dry-run -t XXXXXXXX.verification
                                                                                                    }
                                                                                                    para_script ( )
                                                                                                        {
                                                                                                            SCRIPT=${ environment-variable 1 } &&
                                                                                                                HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                STATUS_CODE=${ environment-variable 3 } &&
                                                                                                                LOG_FILE=${ environment-variable 4 } &&
                                                                                                                EXPECTED=${ environment-variable 5 } &&
                                                                                                                ARGUMENTS=${ environment-variable 6 } &&
                                                                                                                STANDARD_INPUT=${ environment-variable 7 } &&
                                                                                                                EXPECTED_STANDARD_OUTPUT=${ environment-variable 8 } &&
                                                                                                                EXPECTED_STANDARD_ERROR=${ environment-variable 9 } &&
                                                                                                                STANDARD_OUTPUT_FILE=$( util_mktemp ) &&
                                                                                                                STANDARD_ERROR_FILE=$( util_mktemp ) &&
                                                                                                                ${ pkgs.coreutils }/bin/echo > ${ environment-variable "LOG_FILE" } &&
                                                                                                                if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                then
                                                                                                                    assert_status_code ${ environment-variable "STATUS_CODE" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "STANDARD_OUTPUT_FILE" } 2> ${ environment-variable "STANDARD_ERROR_FILE" }"
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                then
                                                                                                                    assert_status_code ${ environment-variable "STATUS_CODE" } "${ environment-variable "SCRIPT" } ${ environment-variable "ARGUMENTS" } > ${ environment-variable "STANDARD_OUTPUT_FILE" } 2> ${ environment-variable "STANDARD_ERROR_FILE" }"
                                                                                                                else
                                                                                                                    fail "We did not expect HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" }"
                                                                                                                fi &&
                                                                                                                assert_equals ${ environment-variable "EXPECTED" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "LOG_FILE" } ) "We expect the log file to match exactly." &&
                                                                                                                assert_equals ${ environment-variable "EXPECTED_STANDARD_OUTPUT" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_OUTPUT_FILE" } ) "We expect the standard output to match exactly." &&
                                                                                                                assert_equals ${ environment-variable "EXPECTED_STANDARD_ERROR" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_ERROR_FILE" } ) "We expect the standard error to match exactly."
                                                                                                        } &&
                                                                                                    para_temporary ( )
                                                                                                        {
                                                                                                            TEMPORARY=${ environment-variable 1 } &&
                                                                                                                HAS_STANDARD_INPUT=${ environment-variable 2 } &&
                                                                                                                INIT_ARGUMENTS=${ environment-variable 3 } &&
                                                                                                                STANDARD_INPUT=${ environment-variable 4 } &&
                                                                                                                TARGET_FILE=${ environment-variable 5 } &&
                                                                                                                HAS_TARGET=${ environment-variable 6 } &&
                                                                                                                HAS_INIT=${ environment-variable 7 } &&
                                                                                                                EXPECTED_INIT_STANDARD_OUTPUT=${ environment-variable 8 } &&
                                                                                                                EXPECTED_INIT_STANDARD_ERROR=${ environment-variable 9 } &&
                                                                                                                EXPECTED_INIT_STATUS=${ environment-variable 10 } &&
                                                                                                                if [ ${ environment-variable "HAS_TARGET" } == true ]
                                                                                                                then
                                                                                                                    STATUS_CODE=0
                                                                                                                elif [ ${ environment-variable "HAS_TARGET" } == false ]
                                                                                                                then
                                                                                                                    STATUS_CODE=90
                                                                                                                else
                                                                                                                    fail "We did not expect HAS_TARGET=${ environment-variable "HAS_TARGET" }"
                                                                                                                fi &&
                                                                                                                STANDARD_OUTPUT_FILE=$( util_mktemp ) &&
                                                                                                                STANDARD_ERROR_FILE=$( util_mktemp ) &&
                                                                                                                if [ ${ environment-variable "HAS_STANDARD_INPUT" } == true ]
                                                                                                                then
                                                                                                                    assert_status_code ${ environment-variable "STATUS_CODE" } "${ pkgs.coreutils }/bin/echo ${ environment-variable "STANDARD_INPUT" } | ${ environment-variable "TEMPORARY" } ${ environment-variable "INIT_ARGUMENTS" } > ${ environment-variable "STANDARD_OUTPUT_FILE" } 2> ${ environment-variable "STANDARD_ERROR_FILE" }"
                                                                                                                elif [ ${ environment-variable "HAS_STANDARD_INPUT" } == false ]
                                                                                                                then
                                                                                                                    assert_status ${ environment-variable "STATUS_CODE" } "${ environment-variable "TEMPORARY" } ${ environment-variable "INIT_ARGUMENTS" } > ${ environment-variable "STANDARD_OUTPUT_FILE" } 2> ${ environment-variable "STANDARD_ERROR_FILE" }" "We expect the temporary's status."
                                                                                                                else
                                                                                                                    fail "We did not expect HAS_STANDARD_INPUT=${ environment-variable "HAS_STANDARD_INPUT" }"
                                                                                                                fi &&
                                                                                                                if [ ${ environment-variable "HAS_TARGET" } == true ]
                                                                                                                then
                                                                                                                    assert_equals $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "TARGET_FILE" } ) $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_OUTPUT_FILE" } ) "If HAS_TARGET, then the output of should be the target."
                                                                                                                        assert_equals "" "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_ERROR_FILE" } )" "If HAS_TARGET then the error should be blank."
                                                                                                                elif [ ${ environment-variable "HAS_TARGET" } == false ]
                                                                                                                then
                                                                                                                    assert_not_equals "" "$( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_OUTPUT_FILE" } )" "If not HAS_TARGET then the output should be the location of the broken target." &&
                                                                                                                        assert_equals jsq $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_ERROR_FILE" } ) "If not HAS_TARGET then the error should be as given." &&
                                                                                                                        if [ -e $( ${ pkgs.coreutils }/bin/dirname $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "TARGET_FILE" } ) ) ]
                                                                                                                        then
                                                                                                                            fail "We were expecting the target file and its containing resource directory to be moved."
                                                                                                                        fi
                                                                                                                else
                                                                                                                    fail "We did not expect HAS_TARGET=${ environment-variable "HAS_TARGET" }"
                                                                                                                fi &&
                                                                                                                RESOURCE=$( ${ pkgs.coreutils }/bin/dirname $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "STANDARD_OUTPUT_FILE" } ) ) &&
                                                                                                                if [ ! -d ${ environment-variable "RESOURCE" } ]
                                                                                                                then
                                                                                                                    fail "We expected the RESOURCE directory to exist."
                                                                                                                fi &&
                                                                                                                if [ ${ environment-variable "HAS_INIT" } == true ]
                                                                                                                then
                                                                                                                    assert_equals ${ environment-variable "EXPECTED_INIT_STANDARD_OUTPUT" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.out.log ) "We were expecting the init out." &&
                                                                                                                        assert_equals 400 $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.out.log ) "We were expecting the init out to be locked." &&
                                                                                                                        assert_equals ${ environment-variable "EXPECTED_INIT_STANDARD_ERROR" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.err.log ) "We were expecting the init err." &&
                                                                                                                        assert_equals 400 $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.err.log ) "We were expecting the init err to be locked." &&
                                                                                                                        assert_equals ${ environment-variable "EXPECTED_INIT_STATUS" } $( ${ pkgs.coreutils }/bin/cat ${ environment-variable "RESOURCE" }/init.status.asc ) "We were expecting the init status." &&
                                                                                                                        assert_equals 400 $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/init.status.asc ) "We were expecting the init status to be locked."
                                                                                                                 elif [ ${ environment-variable "HAS_INIT" } == false ]
                                                                                                                then
                                                                                                                    if [ -e ${ environment-variable "RESOURCE" }/init.out.log ]
                                                                                                                    then
                                                                                                                        fail "We were not expecting any output."
                                                                                                                    fi &&
                                                                                                                    if [ -e ${ environment-variable "RESOURCE" }/init.err.log ]
                                                                                                                    then
                                                                                                                        fail "We were not expecting any init error."
                                                                                                                    fi &&
                                                                                                                    if [ -e ${ environment-variable "RESOURCE" }/init.status.asc ]
                                                                                                                    then
                                                                                                                        fail "We were not expecting any init status."
                                                                                                                    fi
                                                                                                                else
                                                                                                                    fail "We did not expect HAS_INIT=${ environment-variable "HAS_INIT" }"
                                                                                                                fi &&
                                                                                                                assert_equals 400 $( ${ pkgs.coreutils }/bin/stat --format %a ${ environment-variable "RESOURCE" }/invalidate.sh ) "We were expecting the invalidation script to be locked."
                                                                                                        } &&
                                                                                                    test_script ( )
                                                                                                        {
                                                                                                             para_script ${ scripts.verification.script.script.bad } true 71 /build/UhVGqTXa.confirm bvq_qyr_izw_yfp_lmc_vft_tsp_fsk_ izw vft nqt yun &&
                                                                                                                para_script ${ scripts.verification.script.script.bad } false 71 /build/UhVGqTXa.confirm bvq_qyr_jue_yfp_yzr_fsk_ jue djz nqt yun &&
                                                                                                                para_script ${ scripts.verification.script.script.good } true 0 /build/dFz88Etj.confirm miv_nma_aff_zgm_ytw_knj_eod_kjo_ aff knj itp nbg &&
                                                                                                                para_script ${ scripts.verification.script.script.good } false 0 /build/dFz88Etj.confirm miv_nma_gkw_zgm_jmu_kjo_ gkw hdd itp nbg
                                                                                                         } &&
                                                                                                     test_temporary ( )
                                                                                                        {
                                                                                                            para_script ${ scripts.verification.temporary.init.bad } true 72 /build/LuSCtrEw.confirm rtw_rlc_txc_hgb_wmp_smf_bww_zpp_ txc smf epz vdl &&
                                                                                                                para_script ${ scripts.verification.temporary.init.bad } false 72 /build/LuSCtrEw.confirm rtw_rlc_mgp_hgb_xtn_zpp_ mgp iwc epz vdl &&
                                                                                                                para_script ${ scripts.verification.temporary.init.good } true 0 /build/dDmoVMf4.confirm zvu_nvv_hwi_eyg_doe_khh_baj_xne_ hwi khh zus qki &&
                                                                                                                para_script ${ scripts.verification.temporary.init.good } false 0 /build/dDmoVMf4.confirm zvu_nvv_exh_eyg_nrq_xne_ exh iej zus qki &&
                                                                                                                para_script ${ scripts.verification.temporary.release.bad } true 73 /build/Jh4pICL7.confirm aue_mmx_mml_vpr_gei_whp_orm_mck_ mml whp uoz jtg &&
                                                                                                                para_script ${ scripts.verification.temporary.release.bad } false 73 /build/Jh4pICL7.confirm aue_mmx_gcs_vpr_toa_mck_ gcs vgm uoz jtg &&
                                                                                                                para_script ${ scripts.verification.temporary.release.good } true 0 /build/ODb8uwnZ.confirm eiz_nos_mgh_sae_keb_lhc_yho_hex_ mgh lhc eec jxv &&
                                                                                                                para_script ${ scripts.verification.temporary.release.good } false 0 /build/ODb8uwnZ.confirm eiz_nos_ixa_sae_lql_hex_ ixa vfd eec jxv &&
                                                                                                                para_temporary ${ temporary.bad.bad } true fzp onj /build/m9WX7Bnd.confirm false true epz vdl 72 &&
                                                                                                                para_temporary ${ temporary.good.good } true mfr fay /build/ccNePxLX.confirm true true zus qki 0
                                                                                                        }
                                                                                            '' ;
                                                                                    verification =
                                                                                        let
                                                                                            script =
                                                                                                 {
                                                                                                    log-file ,
                                                                                                    status-code ,
                                                                                                    log-begin ,
                                                                                                    log-end ,
                                                                                                    log-no ,
                                                                                                    arguments-begin ,
                                                                                                    arguments-end ,
                                                                                                    arguments-no ,
                                                                                                    standard-input-begin ,
                                                                                                    standard-input-end ,
                                                                                                    standard-input-no ,
                                                                                                    standard-output ,
                                                                                                    standard-error ,
                                                                                                    target-file ? builtins.null
                                                                                                } : { pkgs , ... } : { environment-variable , has-standard-input , scripts , strip , target , temporary } :
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
                                                                                                            ${ if builtins.typeOf target-file == "string" then "${ pkgs.coreutils }/bin/echo ${ environment-variable target } > ${ target-file }" else "# NO TARGET FILE" } &&
                                                                                                            exit ${ builtins.toString status-code }
                                                                                                    '' ;
                                                                                            in
                                                                                                {
                                                                                                    script =
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
                                                                                                                    good =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                log-file = "/build/dFz88Etj.confirm" ;
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "miv" ;
                                                                                                                                log-end = "kjo" ;
                                                                                                                                log-no = "uer" ;
                                                                                                                                arguments-begin = "nma" ;
                                                                                                                                arguments-end = "zgm" ;
                                                                                                                                arguments-no = "pjc" ;
                                                                                                                                standard-input-begin = "ytw" ;
                                                                                                                                standard-input-end = "eod" ;
                                                                                                                                standard-input-no = "jmu" ;
                                                                                                                                standard-output = "itp" ;
                                                                                                                                standard-error = "nbg" ;
                                                                                                                            } ;
                                                                                                                } ;
                                                                                                         } ;
                                                                                                    temporary =
                                                                                                        {
                                                                                                            init =
                                                                                                                {
                                                                                                                    bad =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                log-file = "/build/LuSCtrEw.confirm" ;
                                                                                                                                status-code = 72 ;
                                                                                                                                log-begin = "rtw" ;
                                                                                                                                log-end = "zpp" ;
                                                                                                                                log-no = "lce" ;
                                                                                                                                arguments-begin = "rlc" ;
                                                                                                                                arguments-end = "hgb" ;
                                                                                                                                arguments-no = "qnj" ;
                                                                                                                                standard-input-begin = "wmp" ;
                                                                                                                                standard-input-end = "bww" ;
                                                                                                                                standard-input-no = "xtn" ;
                                                                                                                                standard-output = "epz" ;
                                                                                                                                standard-error = "vdl" ;
                                                                                                                                target-file = "/build/m9WX7Bnd.confirm" ;
                                                                                                                            } ;
                                                                                                                    good =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                log-file = "/build/dDmoVMf4.confirm" ;
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "zvu" ;
                                                                                                                                log-end = "xne" ;
                                                                                                                                log-no = "hkh" ;
                                                                                                                                arguments-begin = "nvv" ;
                                                                                                                                arguments-end = "eyg" ;
                                                                                                                                arguments-no = "srv" ;
                                                                                                                                standard-input-begin = "doe" ;
                                                                                                                                standard-input-end = "baj" ;
                                                                                                                                standard-input-no = "nrq" ;
                                                                                                                                standard-output = "zus" ;
                                                                                                                                standard-error = "qki" ;
                                                                                                                                target-file = "/build/ccNePxLX.confirm" ;
                                                                                                                            } ;
                                                                                                                } ;
                                                                                                            release =
                                                                                                                {
                                                                                                                    bad =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                log-file = "/build/Jh4pICL7.confirm" ;
                                                                                                                                status-code = 73 ;
                                                                                                                                log-begin = "aue" ;
                                                                                                                                log-end = "mck" ;
                                                                                                                                log-no = "uya" ;
                                                                                                                                arguments-begin = "mmx" ;
                                                                                                                                arguments-end = "vpr" ;
                                                                                                                                arguments-no = "xdj" ;
                                                                                                                                standard-input-begin = "gei" ;
                                                                                                                                standard-input-end = "orm" ;
                                                                                                                                standard-input-no = "toa" ;
                                                                                                                                standard-output = "uoz" ;
                                                                                                                                standard-error = "jtg" ;
                                                                                                                            } ;
                                                                                                                    good =
                                                                                                                        script
                                                                                                                            {
                                                                                                                                log-file = "/build/ODb8uwnZ.confirm" ;
                                                                                                                                status-code = 0 ;
                                                                                                                                log-begin = "eiz" ;
                                                                                                                                log-end = "hex" ;
                                                                                                                                log-no = "zgc" ;
                                                                                                                                arguments-begin = "nos" ;
                                                                                                                                arguments-end = "sae" ;
                                                                                                                                arguments-no = "gku" ;
                                                                                                                                standard-input-begin = "keb" ;
                                                                                                                                standard-input-end = "yho" ;
                                                                                                                                standard-input-no = "lql" ;
                                                                                                                                standard-output = "eec" ;
                                                                                                                                standard-error = "jxv" ;
                                                                                                                            } ;
                                                                                                                } ;
                                                                                                        } ;
                                                                                                } ;
                                                                                } ;
                                                                            temporary =
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
                                                                            temporary-init-error-code = 90 ;
                                                                            temporary-init-error-message = "jsq" ;
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
