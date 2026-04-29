#!/usr/bin/env bash
# =============================================================================
# Script Name     : apps-install.sh
# Description     : Install Flatpak applications from a categorized menu
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

# --- globals compartilhados entre funções ---
declare -a MENU_NAMES=()
declare -a MENU_IDS=()
declare -i MENU_INDEX=1
declare -a APPS_TO_INSTALL=()

# --- funções auxiliares ---
is_flatpak_installed() {
    local app_id="$1"
    flatpak list --app --columns=application 2>/dev/null | grep -qxF "$app_id"
}

append_menu_item() {
    local label="$1"
    local app_id="$2"
    local index="$3"

    MENU_NAMES+=("$label")
    MENU_IDS+=("$app_id")

    if is_flatpak_installed "$app_id"; then
        printf '%b\n' "  ${C2}${index}.${RESET} ${SIM_OK} ${label} ${C6}(instalado)${RESET}"
        return 0
    fi

    printf '%b\n' "  ${C2}${index}.${RESET} ${label}"
}

process_selections() {
    local -a raw_choices=("$@")
    local choice
    local selected_name

    APPS_TO_INSTALL=()

    for choice in "${raw_choices[@]}"; do
        if [[ "$choice" == '0' ]]; then
            return 10
        fi

        if [[ "$choice" == 'all' ]]; then
            APPS_TO_INSTALL=("${MENU_IDS[@]}")
            return 0
        fi

        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            warn "Entrada ignorada: ${choice}"
            continue
        fi

        if ((choice < 1 || choice > ${#MENU_NAMES[@]})); then
            warn "Opção fora do intervalo: ${choice}"
            continue
        fi

        selected_name="${MENU_NAMES[$((choice - 1))]}"
        info "Selecionado: ${selected_name}"
        APPS_TO_INSTALL+=("${MENU_IDS[$((choice - 1))]}")
    done
}

install_selected_apps() {
    if ((${#APPS_TO_INSTALL[@]} == 0)); then
        warn "Nenhum aplicativo foi selecionado."
        pause_screen
        return 0
    fi

    info "Instalando ${#APPS_TO_INSTALL[@]} aplicativo(s)..."
    flatpak install -y flathub "${APPS_TO_INSTALL[@]}"
    success "Instalação concluída."
    pause_screen
}

# --- funções de interface ---
show_header() {
    show_lumina_header
}

show_menu() {
    local -a selections

    show_header
    ensure_flatpak_ready

    MENU_NAMES=()
    MENU_IDS=()
    MENU_INDEX=1

    printf '%b\n' "Selecione os aplicativos pelo número ou use ${C2}all${RESET}."
    printf '%b\n' ""
    append_menu_item "AnyDesk" "com.anydesk.Anydesk" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Apostrophe - Markdown Editor" "org.gnome.gitlab.somas.Apostrophe" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Eyedropper - Color picker" "com.github.finefindus.eyedropper" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Gear Lever - AppImages" "it.mijorus.gearlever" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Web Apps" "net.codelogistics.webapps" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Flatseal" "com.github.tchx84.Flatseal" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Chromium" "org.chromium.Chromium" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "FileZilla" "org.filezillaproject.Filezilla" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Firefox" "org.mozilla.firefox" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Parabolic" "org.nickvision.tubeconverter" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Zen Browser" "app.zen_browser.zen" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Inkscape" "org.inkscape.Inkscape" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Krita" "org.kde.krita" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Penpot" "com.authormore.penpotdesktop" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "LibreOffice" "org.libreoffice.LibreOffice" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "ONLYOFFICE" "org.onlyoffice.desktopeditors" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Lunacy - UX/UI" "com.icons8.Lunacy" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))
    append_menu_item "Meld - File Compare" "org.gnome.meld" "$MENU_INDEX"
    MENU_INDEX=$((MENU_INDEX + 1))

    printf '%b\n' ""
    printf '%b\n' "  ${C2}all${RESET} Instalar todos"
    printf '%b\n' "  ${C1}0.${RESET} Voltar"
    printf '%b\n' ""
    printf '%s' "Digite os números desejados: "
    read -r -a selections

    local process_status=0
    if process_selections "${selections[@]}"; then
        process_status=0
    else
        process_status=$?
    fi

    if [[ ${process_status} -eq 10 ]]; then
        return 10
    fi
    if [[ ${process_status} -ne 0 ]]; then
        return 0
    fi

    install_selected_apps
}

# --- ponto de entrada ---
main() {
    show_menu
}

main "$@"
