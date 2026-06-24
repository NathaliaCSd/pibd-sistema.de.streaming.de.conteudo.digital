--Busca por um livro específico;
SELECT * FROM livro WHERE titulo = 'O Hobbit';

--Adição de um novo livro no sistema;
INSERT INTO livro (titulo, colecao, data_publicacao) 
VALUES ('ds', 'Coleção Tolkien', '21/09/1937');

--adição de gêneros e ligação de gênero com livro, para depois fazer a buscar por gênero;
INSERT INTO genero(nome_genero) 
VALUES ('fantasia');

INSERT INTO Genero(nome_genero) 
VALUES ('Literatura Infantojuvenil');
INSERT INTO livro_genero (id_livro, id_genero)
SELECT l.id_livro, g.id_genero
FROM livro l, genero g
WHERE l.titulo = 'O Hobbit' 
  AND g.nome_genero IN ('fantasia', 'Literatura Infantojuvenil');

SELECT l.titulo, l.data_publicacao
FROM livro l
JOIN livro_genero lg ON l.id_livro = lg.id_livro
JOIN genero g ON g.id_genero = lg.id_genero
WHERE g.nome_genero = 'fantasia';

--Criar usuário no sistema;
WITH novo_usuario AS (
    INSERT INTO usuario (nome, email, telefone, data_nasc, sexo)
   VALUES ('Carlos Silva', 'carlos@email.com', '11988888888', '1995-05-15','Masculino')
    RETURNING id_usuario
)
INSERT INTO usuario_comum (id_usuario)

-- Aqui, o Carlos é um USER do banco de dados 
CREATE USER carlos_silva WITH PASSWORD 'carlos123'; 

--  Carlos começa como um usuário comum 
GRANT grupo_comum TO carlos_silva;

--Adicionar avaliação de livro;
INSERT INTO avaliacoes (id_livro, id_usuario, nota, texto)
VALUES (1, 10, 5, 'Excelente leitura! A construção dos personagens é fascinante.');

