#Script Python de Consulta
import psycopg2

conn = psycopg2.connect(
	dbname="streaming",
	user="postgres",
	password="postgres",
	host="localhost",
	port="5432"
)

cur = conn.cursor()

cur.execute("""
SELECT
	id_livro,
	titulo,
	media_avaliacao
FROM livro
ORDER BY media_avaliacao DESC;
""")

resultados = cur.fetchall()

print("=== LIVROS MAIS BEM AVALIADOS ===")

for livro in resultados:
	print(livro)

cur.close()
conn.close()

#Consulta de Livros por Usuário
import psycopg2

conn = psycopg2.connect(
	dbname="streaming",
	user="postgres",
	password="postgres",
	host="localhost",
	port="5432"
)

cur = conn.cursor()

id_usuario = input("Digite o ID do usuário: ")

cur.execute("""
SELECT
	l.titulo
FROM historico_leitura h
JOIN livro l
ON h.id_livro = l.id_livro
WHERE h.id_usuario = %s;
""", (id_usuario,))

livros = cur.fetchall()

print("\nLivros lidos:")

for livro in livros:
	print(livro[0])

cur.close()
conn.close()

#Cadastro de Avaliação via Terminal
import psycopg2

conn = psycopg2.connect(
	dbname="streaming",
	user="postgres",
	password="postgres",
	host="localhost",
	port="5432"
)

cur = conn.cursor()

id_usuario = input("ID do usuário: ")
id_livro = input("ID do livro: ")
nota = input("Nota (1-5): ")
comentario = input("Comentário: ")

cur.execute("""
INSERT INTO avaliacoes
(
	id_usuario,
	id_livro,
	nota,
	texto
)
VALUES
(
	%s,
	%s,
	%s,
	%s
);
""",
(
	id_usuario,
	id_livro,
	nota,
	comentario
))

conn.commit()

print("Avaliação cadastrada com sucesso!")

cur.close()
conn.close()
