# Lumina LM

📄 English version: see [README.md](README.md)

![Bash](https://img.shields.io/badge/Bash-5%2B-121011?logo=gnubash)
![Platform](https://img.shields.io/badge/Platform-Linux-1793D1?logo=linux)

## Descrição

Lumina LM é um toolkit de terminal para tarefas recorrentes de configuração e manutenção de workstations Linux. Ele oferece menus guiados para automação de pós-instalação, gerenciamento de Flatpaks, criação de modelos de arquivos e instalação do comando de atualização do sistema.

## Recursos

- Rotinas de pós-instalação para Linux Mint 22.3, Pop!_OS 24.04 LTS (COSMIC) e CachyOS
- Instalação de aplicativos Flatpak por menu numerado
- Desinstalação de aplicativos Flatpak a partir da lista de apps instalados
- Geração de modelos de arquivos no diretório de modelos do usuário
- Instalação global do comando `update-system` em `/usr/local/bin`
- Mensagens amigáveis antes de ações que exigem privilégios de administrador

## Estrutura do Projeto

```text
.
├── lumina-lm.sh
├── scripts/
│   ├── apps/
│   ├── installers/
│   ├── lib/
│   ├── menus/
│   ├── post-install/
│   ├── system/
│   └── templates/
└── exemplos/
```

## Instalação

Torne os scripts executáveis:

```bash
chmod +x lumina-lm.sh scripts/lib/*.sh scripts/menus/*.sh scripts/post-install/*.sh scripts/apps/*.sh scripts/templates/*.sh scripts/system/*.sh scripts/installers/*.sh
```

## Uso

Execute o menu principal:

```bash
bash lumina-lm.sh
```

Opções do menu principal:

- `1` Executar rotinas de pós-instalação
- `2` Criar modelos de arquivos do usuário
- `3` Instalar aplicativos Flatpak
- `4` Desinstalar aplicativos Flatpak instalados
- `5` Instalar globalmente o comando `update-system`
- `0` Sair

Dentro dos submenus, `0` retorna diretamente ao menu principal.

## Configuração

- Execute o launcher como usuário comum
- O projeto solicita `sudo` apenas nas operações que exigem privilégios elevados
- O comando `update-system` é copiado para `/usr/local/bin/update-system`
- Operações com Flatpak exigem que o Flatpak esteja disponível; o instalador pode preparar o ambiente quando necessário

## Validação

Quando disponível, valide os scripts shell alterados com ShellCheck:

```bash
shellcheck --severity=warning --shell=bash --exclude=SC1091 lumina-lm.sh
shellcheck --severity=warning --shell=bash --exclude=SC1091 scripts/lib/utils.sh
```

## Contribuição

Veja [CONTRIBUINDO.md](CONTRIBUINDO.md).

## Licença

Nenhum arquivo de licença está incluído atualmente neste repositório.

---

Made with ❤️ and AI by [Kadu Velasco](https://github.com/kaduvelasco)
