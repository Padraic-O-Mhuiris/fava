{ pkgs, ... }:

let
  inherit (pkgs) python3 buildNpmPackage;

  frontend = buildNpmPackage {
    pname = "fava-frontend";
    version = "0.0.0";

    src = ../../frontend;

    npmDepsHash = "sha256-J7zh2+DJDI6t4CeSbd8nfc87M/36A7fGnK00KFmWElA=";

    preBuild = ''
      mkdir -p $out/static
      substituteInPlace ./build.ts \
         --replace-fail "outfile: \"../src/fava/static/app.js\"," "outfile: \"$out/static/app.js\","
    '';

    postInstall = ''
      rm -rf $out/lib
    '';
  };

in python3.pkgs.buildPythonApplication {
  pname = "fava";
  version = "0.0.0";
  format = "pyproject";

  src = ../..;

  nativeBuildInputs = with python3.pkgs; [ setuptools-scm ];

  propagatedBuildInputs = with python3.pkgs; [
    babel
    beancount
    cheroot
    click
    flask
    flask-babel
    jaraco-functools
    jinja2
    markdown2
    ply
    simplejson
    watchfiles
    werkzeug
  ];

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];

  postPatch = ''
    substituteInPlace ./pyproject.toml \
      --replace-fail 'setuptools_scm>=8.0' 'setuptools_scm'

    sed -i '/_compile_frontend()/d' ./_build_backend.py
  '';

  preCheck = ''
    export HOME=$TEMPDIR
  '';

  preBuild = ''
    cp ./src/fava/static/favicon.ico ./favicon.ico
    cp -rf ${frontend}/static ./src/fava/
    cp ./favicon.ico ./src/fava/static
  '';

  disabledTests = [
    # runs fava in debug mode, which tries to interpret bash wrapper as Python
    "test_cli"
  ];
}
