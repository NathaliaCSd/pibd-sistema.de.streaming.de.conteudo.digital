-- Definição das Entidades Principais
-- 1. Tabela Autor
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

-- 2. Tabela Gênero
CREATE TABLE genero (
    id_genero SERIAL PRIMARY KEY,
    nome_genero VARCHAR(50) NOT NULL
);

-- 3. Tabela Livro (Estrutura normalizada)
CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    colecao VARCHAR(100),
    data_publicacao DATE
);

-- Definição das Tabelas de Relacionamento (Associações N:N)

-- 4. Tabela Livro_Autor (Relacionamento entre Livro e Autor)
CREATE TABLE livro_autor (
    id_livro INT NOT NULL,
    id_autor INT NOT NULL,
    PRIMARY KEY (id_livro, id_autor),
    CONSTRAINT fk_livro_aut FOREIGN KEY (id_livro) REFERENCES livro(id_livro) ON DELETE CASCADE,
    CONSTRAINT fk_autor_liv FOREIGN KEY (id_autor) REFERENCES autor(id_autor) ON DELETE CASCADE
);

-- 5. Tabela Livro_Genero (Relacionamento entre Livro e Gênero)
CREATE TABLE livro_genero (
    id_livro INT NOT NULL,
    id_genero INT NOT NULL,
    PRIMARY KEY (id_livro, id_genero),
    CONSTRAINT fk_livro_gen FOREIGN KEY (id_livro) REFERENCES livro(id_livro) ON DELETE CASCADE,
    CONSTRAINT fk_genero_liv FOREIGN KEY (id_genero) REFERENCES genero(id_genero) ON DELETE CASCADE
);
