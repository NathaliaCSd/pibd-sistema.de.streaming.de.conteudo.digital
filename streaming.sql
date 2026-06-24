-- ==========================================================
-- 1. DDL: ESTRUTURA DO BANCO DE DADOS
-- ==========================================================

-- Tabelas Base
CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    data_nasc DATE,
    sexo VARCHAR(10),
    idade INT,            -- 
    pais VARCHAR(50)      --
);

CREATE TABLE usuario_premium (
    id_usuario INT PRIMARY KEY REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    forma_assinatura VARCHAR(50),
    data_assinatura DATE DEFAULT CURRENT_DATE
);

CREATE TABLE administrador (
    id_usuario INT PRIMARY KEY REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_admin VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE usuario_basico (
    id_usuario INT PRIMARY KEY REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- Tabelas normalizadas de Livros
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE genero (
    id_genero SERIAL PRIMARY KEY,
    nome_genero VARCHAR(50) NOT NULL
);

CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    colecao VARCHAR(100),
    data_publicacao DATE,
    media_avaliacao DECIMAL(3,2) DEFAULT 0.0,
    nivel_acesso VARCHAR(10) DEFAULT 'comum'
);

-- Tabelas Associativas
CREATE TABLE livro_autor (
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE CASCADE,
    id_autor INT NOT NULL REFERENCES autor(id_autor) ON DELETE CASCADE,
    PRIMARY KEY (id_livro, id_autor)
);

CREATE TABLE livro_genero (
    id_livro INT NOT NULL REFERENCES livro(id_livro) ON DELETE CASCADE,
    id_genero INT NOT NULL REFERENCES genero(id_genero) ON DELETE CASCADE,
    PRIMARY KEY (id_livro, id_genero)
);

CREATE TABLE historico_leitura (
    id_historico SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES usuario(id_usuario),
    id_livro INT NOT NULL REFERENCES livro(id_livro),
    status_leitura VARCHAR(50),
    data_leitura TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE avaliacoes (
    id_avaliacoes SERIAL PRIMARY KEY,
    id_livro INT NOT NULL REFERENCES livro(id_livro),
    id_usuario INT NOT NULL REFERENCES usuario(id_usuario),
    nota INT CHECK (nota >= 1 AND nota <= 5),
    texto TEXT,
    data_avaliacao DATE DEFAULT CURRENT_DATE
);

-- ==========================================================
-- 2. CONFIGURAÇÃO DE SEGURANÇA (RLS)
-- ==========================================================

CREATE ROLE grupo_admins;
CREATE ROLE grupo_comum;
CREATE ROLE grupo_premium;

GRANT SELECT ON livro, autor, genero, livro_autor, livro_genero TO grupo_comum, grupo_premium;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO grupo_admins;

ALTER TABLE livro ENABLE ROW LEVEL SECURITY;

CREATE POLICY politica_ver_livros_comuns ON livro FOR SELECT TO grupo_comum USING (nivel_acesso = 'comum');
CREATE POLICY politica_ver_tudo_premium ON livro FOR SELECT TO grupo_premium USING (true);
CREATE POLICY politica_admin_total ON livro TO grupo_admins USING (true) WITH CHECK (true);

-- ==========================================================
-- 3. LÓGICA (FUNÇÕES E TRIGGERS)
-- ==========================================================

CREATE OR REPLACE FUNCTION atualizar_media_avaliacao() RETURNS TRIGGER AS $$
BEGIN
    UPDATE livro SET media_avaliacao = (SELECT AVG(nota) FROM avaliacoes WHERE id_livro = NEW.id_livro)
    WHERE id_livro = NEW.id_livro;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_media_livro
AFTER INSERT ON avaliacoes FOR EACH ROW EXECUTE FUNCTION atualizar_media_avaliacao();

CREATE OR REPLACE FUNCTION verificar_limite_usuario_basico() RETURNS TRIGGER AS $$
DECLARE qtd_livros INT;
BEGIN
    IF EXISTS (SELECT 1 FROM usuario_basico WHERE id_usuario = NEW.id_usuario) THEN
        SELECT COUNT(*) INTO qtd_livros FROM historico_leitura 
        WHERE id_usuario = NEW.id_usuario AND DATE_TRUNC('month', data_leitura) = DATE_TRUNC('month', CURRENT_DATE);
        IF qtd_livros >= 5 THEN RAISE EXCEPTION 'Usuário básico atingiu o limite mensal'; END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limite_usuario_basico
BEFORE INSERT ON historico_leitura FOR EACH ROW EXECUTE FUNCTION verificar_limite_usuario_basico();

-- ==========================================================
-- 4. POPULAÇÃO DE TESTE
-- ==========================================================

INSERT INTO usuario (nome, email) VALUES ('Carlos Silva', 'carlos@email.com');
INSERT INTO usuario_basico (id_usuario) VALUES (1);
INSERT INTO livro (titulo, nivel_acesso) VALUES ('O Hobbit', 'comum');
INSERT INTO genero (nome_genero) VALUES ('fantasia');
INSERT INTO livro_genero (id_livro, id_genero) VALUES (1, 1);

-- ==========================================================
-- 5. CONSULTAS DE DEMONSTRAÇÃO
-- ==========================================================

-- Busca livro por título
SELECT * FROM livro WHERE titulo = 'O Hobbit';

-- Adicionar avaliação (testando a Trigger de média)
INSERT INTO avaliacoes (id_livro, id_usuario, nota, texto) VALUES (1, 1, 5, 'Excelente!');

-- Conferir média atualizada
SELECT titulo, media_avaliacao FROM livro WHERE id_livro = 1;
