; install ACE presets

INSTALL PRESET="etc/registry/presets/ace.api"
INSTALL PRESET="etc/registry/presets/ace.dictionary"
INSTALL PRESET="etc/registry/presets/ace.gadgets"
INSTALL PRESET="etc/registry/presets/ace.structure"
INSTALL PRESET="etc/registry/presets/ace.syntax"
INSTALL PRESET="etc/registry/presets/ace.tabs"

; install filetype for ACE Basic Compiler

FILETYPE ADD="#?.b" PRI=127 PRESETS "ace.api" "ace.dictionary" "ace.gadgets" "ace.structure" "ace.syntax" "ace.tabs" NAME="ACE" ACTIVATION="SET TYPE VALUE=*".b*""

; optional: uninstall section

:uninstall

UNINSTALL FILETYPE="ACE"

UNINSTALL BASEDIR="golded:add-ons/ace"
