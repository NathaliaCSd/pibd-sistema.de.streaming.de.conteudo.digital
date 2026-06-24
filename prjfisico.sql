-- 1. Tabela Principal (Superclasse)
CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    data_nasc DATE,
    sexo VARCHAR(10) -- Ou CHAR(1)
);

-- 2. Especializações (Subclasses)
-- PK é também uma FK para a tabela usuario
CREATE TABLE usuario_premium (
    id_usuario INT PRIMARY KEY,
    forma_assinatura VARCHAR(50),
    data_assinatura DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_premium_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE administrador (
    id_usuario INT PRIMARY KEY,
    id_admin VARCHAR(20) UNIQUE NOT NULL, 
 CONSTRAINT fk_admin_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE usuario_basico (
    id_usuario INT PRIMARY KEY,
    CONSTRAINT fk_basico_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- 3. Entidade Livro
CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    autor VARCHAR(100),
    genero VARCHAR(50),
    colecao VARCHAR(100),
    popularidade INT DEFAULT 0,
    data_publicacao DATE,
    media_avaliacao DECIMAL(3,2) DEFAULT 0.0 -- Atributo derivado
);

-- 4. Relacionamentos e Entidades Associativas
CREATE TABLE historico_leitura (
    id_historico SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_livro INT NOT NULL,
    status_leitura VARCHAR(50),
    data_leitura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hist_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_hist_livro FOREIGN KEY (id_livro) REFERENCES livro(id_livro)
);

CREATE TABLE avaliacoes (
    id_avaliacoes SERIAL PRIMARY KEY,
    id_livro INT NOT NULL,
    id_usuario INT NOT NULL, -- Quem avaliou
    nota INT CHECK (nota >= 1 AND nota <= 5),
    texto TEXT,
    data_avaliacao DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_ava_livro FOREIGN KEY (id_livro) REFERENCES livro(id_livro),
    CONSTRAINT fk_ava_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- 5. Financeiro e Dados Bancários
CREATE TABLE dados_bancarios (
    id_dados_bancarios SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    banco VARCHAR(50),
    num_conta VARCHAR(20),
    tipo_conta VARCHAR(20),
    agencia VARCHAR(10),
    CONSTRAINT fk_dados_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE pagamento (
    id_pagamento SERIAL PRIMARY KEY,
    id_dados_bancarios INT NOT NULL,
    meios_pagamento VARCHAR(50),
    data_inicio DATE,
    data_venc DATE,
    valor_total DECIMAL(10,2), -- Atributo derivado (soma das parcelas)
    CONSTRAINT fk_pag_dados FOREIGN KEY (id_dados_bancarios) REFERENCES dados_bancarios(id_dados_bancarios)
);

-- 6. Entidade Fraca (Parcela)
-- Chave primária composta (id_pagamento + num_parcela)
CREATE TABLE parcela (
    id_pagamento INT,
    num_parcela INT,
    valor_parcela DECIMAL(10,2),
    juros DECIMAL(5,2) DEFAULT 0,
    data_venc DATE,
    data_pag DATE,
    hora_pag TIME,
    PRIMARY KEY (id_pagamento, num_parcela),
    CONSTRAINT fk_parcela_pagamento FOREIGN KEY (id_pagamento) REFERENCES pagamento(id_pagamento) ON DELETE CASCADE
);

-- 7. Tabela de Gerência (N:N entre Admin e Livro)
CREATE TABLE gerencia (
    id_usuario_admin INT,
    id_livro INT,
    PRIMARY KEY (id_usuario_admin, id_livro),
    CONSTRAINT fk_gerencia_admin FOREIGN KEY (id_usuario_admin) REFERENCES administrador(id_usuario),
    CONSTRAINT fk_gerencia_livro FOREIGN KEY (id_livro) REFERENCES livro(id_livro)
);

