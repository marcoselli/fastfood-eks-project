#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configurações
GIT_REPO_URL="git@github.com:marcoselli/fastfood-eks-project.git"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519_almeida_devops_042"
EMAIL="almeidadevops042@gmail.com"
BRANCH="eduardo/infraestrutura-terraform-tech"
COMMIT_MESSAGE="create cluster EKS - infraestructure terraform com sucesso e ajustes em .yaml para apply dos resources do k8s"

git@github.com:marcoselli/fastfood-eks-project.git

# Função para log
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Configurar SSH
setup_ssh() {
    log "Configurando SSH..."

    if [ ! -f "$SSH_KEY_PATH" ]; then
        log "Gerando nova chave SSH..."
        ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY_PATH" -N "" || log_error "Falha ao gerar chave SSH"
    else
        log "Chave SSH existente encontrada"
    fi

    chmod 600 "$SSH_KEY_PATH" || log_error "Falha ao configurar permissões da chave SSH"
    chmod 644 "${SSH_KEY_PATH}.pub" || log_error "Falha ao configurar permissões da chave SSH pública"

    eval "$(ssh-agent -s)" || log_error "Falha ao iniciar ssh-agent"
    ssh-add "$SSH_KEY_PATH" || log_error "Falha ao adicionar chave SSH ao agente"

    log "Chave SSH pública para adicionar ao GitHub:"
    cat "${SSH_KEY_PATH}.pub"
    log "Adicione esta chave em https://github.com/settings/keys"
}

# Configurar Git
setup_git() {
    log "Configurando Git..."

    # Configurações globais
    git config --global user.email "$EMAIL" || log_error "Falha ao configurar email do Git"
    git config --global core.sshCommand "ssh -i $SSH_KEY_PATH" || log_error "Falha ao configurar SSH no Git"

    # Inicializar repositório se necessário
    if [ ! -d ".git" ]; then
        git init || log_error "Falha ao inicializar repositório Git"
    fi

    # Configurar remote
    if git remote | grep -q "origin"; then
        git remote set-url origin "$GIT_REPO_URL" || log_error "Falha ao atualizar URL do remote"
    else
        git remote add origin "$GIT_REPO_URL" || log_error "Falha ao adicionar remote"
    fi
}

# Testar conexão SSH
test_ssh_connection() {
    log "Testando conexão SSH com GitHub..."
    if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_error "Falha na autenticação SSH com GitHub"
    fi
}

# Preparar e fazer commit
prepare_commit() {
    log "Preparando commit..."

    # Verificar status
    if git status --porcelain | grep -q '^??'; then
        log "Arquivos não rastreados encontrados"
        git add . || log_error "Falha ao adicionar arquivos"
    fi

    # Verificar se há mudanças para commit
    if ! git diff --cached --quiet; then
        log "Realizando commit..."
        git commit -m "$COMMIT_MESSAGE" || log_error "Falha ao realizar commit"
    else
        log_warning "Nenhuma mudança para commit"
    fi
}

# Push para GitHub
push_to_github() {
    log "Realizando push para GitHub..."

    # Verificar e criar branch se necessário
    if ! git rev-parse --verify "$BRANCH" &>/dev/null; then
        git checkout -b "$BRANCH" || log_error "Falha ao criar branch $BRANCH"
    fi

    # Push com upstream
    git push -u origin "$BRANCH" || log_error "Falha ao realizar push"
}

# Execução principal
main() {
    check_src_directory
    setup_ssh
    setup_git
    test_ssh_connection
    prepare_commit
    push_to_github
    log "Processo concluído com sucesso!"
}

# Executar script
main
