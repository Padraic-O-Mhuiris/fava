{ pkgs, ... }:

let python = pkgs.python312.withPackages (ps: with ps; [ build tox ]);
in pkgs.mkShell {
  packages = with pkgs; [
    nodePackages_latest.nodejs
    python
    uv
    steam-run
    prefetch-npm-deps
    nixfmt
  ];
}
