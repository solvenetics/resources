{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils?rev=b1d9ab70662946ef0850d488da1c9019f3a9752a" ;
            nixpkgs.url = "github:NixOs/nixpkgs?rev=b1d9ab70662946ef0850d488da1c9019f3a9752a" ;
        } ;
    outputs =
        { flake-utils , nixpkgs , self } :
            let
                fun =
                    system :
                        let
                            lib = null ;
                            pkgs = builtins.import nixpkgs { system = system ; } ;
                            in
                                {
                                    checks = { } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
