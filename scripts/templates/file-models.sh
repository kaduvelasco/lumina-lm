#!/usr/bin/env bash
# =============================================================================
# Script Name     : file-models.sh
# Description     : Create template files in the user templates directory
# Version         : 1.0.0
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

if [[ ! -f "$SCRIPT_DIR/../lib/utils.sh" ]]; then
    printf '\033[0;31m❌ Erro fatal: ../lib/utils.sh não encontrado.\033[0m\n' >&2
    exit 1
fi
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../lib/utils.sh"

# --- funções auxiliares ---
ensure_dependencies() {
    ensure_pkg python3
    ensure_pkg xdg-user-dirs
}

create_minimal_docx() {
    local destination="$1"
    python3 - "$destination" <<'PYEOF'
import sys
import zipfile

dest = sys.argv[1]
content_types = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>'
rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>'
document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p/></w:body></w:document>'

with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as archive:
    archive.writestr("[Content_Types].xml", content_types)
    archive.writestr("_rels/.rels", rels)
    archive.writestr("word/document.xml", document)
PYEOF
}

create_minimal_xlsx() {
    local destination="$1"
    python3 - "$destination" <<'PYEOF'
import sys
import zipfile

dest = sys.argv[1]
content_types = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>'
rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'
workbook = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets></workbook>'
workbook_rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>'
sheet = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData/></worksheet>'

with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as archive:
    archive.writestr("[Content_Types].xml", content_types)
    archive.writestr("_rels/.rels", rels)
    archive.writestr("xl/workbook.xml", workbook)
    archive.writestr("xl/_rels/workbook.xml.rels", workbook_rels)
    archive.writestr("xl/worksheets/sheet1.xml", sheet)
PYEOF
}

create_text_templates() {
    local templates_dir="$1"

    cat <<EOF > "${templates_dir}/Texto.txt"
Criado em: $(date '+%d/%m/%Y %H:%M')
EOF

    cat <<'EOF' > "${templates_dir}/PHP.php"
<?php

// Created by Lumina Linux Management

?>
EOF

    cat <<'EOF' > "${templates_dir}/Shell.sh"
#!/usr/bin/env bash
set -euo pipefail

# Created by Lumina Linux Management
EOF

    cat <<'EOF' > "${templates_dir}/HTML.html"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Novo Projeto</title>
</head>
<body>
</body>
</html>
EOF
}

# --- funções de negócio ---
create_models() {
    local templates_dir

    ensure_dependencies
    templates_dir="$(xdg-user-dir TEMPLATES 2>/dev/null || printf '%s' "${HOME}/Templates")"
    mkdir -p "${templates_dir}"

    info "Criando modelos em: ${templates_dir}"
    create_minimal_docx "${templates_dir}/Documento.docx"
    create_minimal_xlsx "${templates_dir}/Planilha.xlsx"
    create_text_templates "${templates_dir}"

    chmod 644 "${templates_dir}/Documento.docx" \
        "${templates_dir}/Planilha.xlsx" \
        "${templates_dir}/Texto.txt" \
        "${templates_dir}/PHP.php" \
        "${templates_dir}/HTML.html"
    chmod +x "${templates_dir}/Shell.sh"

    success "Modelos criados com sucesso."
    pause_screen
}

# --- funções de interface ---
show_header() {
    show_lumina_header
}

# --- ponto de entrada ---
main() {
    show_header
    create_models
}

main "$@"
