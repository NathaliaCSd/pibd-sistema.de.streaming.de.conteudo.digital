--1
CREATE VIEW view_livro_comum AS
SELECT
	id_livro,
	titulo,
	colecao,
       data_publicacao,
	nivel_acesso
FROM livro
WHERE nivel_acesso = 'comum’';

--2
CREATE VIEW view_historico_usuario AS
SELECT
	u.nome AS usuario,
	l.titulo AS livro,
	h.status_leitura,
	h.data_leitura
FROM historico_leitura h
JOIN usuario u
	ON h.id_usuario = u.id_usuario
JOIN livro l
	ON h.id_livro = l.id_livro;
