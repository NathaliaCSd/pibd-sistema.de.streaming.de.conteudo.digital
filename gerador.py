import random
import psycopg2

#conexao com o banco 
conn = psycopg2.connect(
    dbname="sistema",
    user="usuario",
    password="senha",
    host="localhost"
)

cur = conn.cursor()

#geracao de usuarios 

for i in range(100):
    cur.execute("""
    INSERT INTO USUARIO(id, nome, idade, pais)
    VALUES(%s, %s, %s, %s)
    """,
    (
        i, #idade do usuario
        f"User{i}", #nome 
        random.randint(18,60), #idade
        "Brasil"

    ))

    #geracao de conteudos 

    generos = ['Ação', 'Comédia', 'Drama', 'Romance', 'Terror']

    for i in range(50):
        cur.execute("""
            INSERT INTO CONTEUDO(id, titulo, genero, duracao)
            VALUES(%s, %s, %s, %s)
        """,
        (
            i, #id do conteudo
            f"Livro{i}", #titulo
            random.choice(generos), #genero
            random.randint(80, 180) #duracao
        ))

    #confirma insercoes
    conn.commit()

    #encerra conexao
    cur.close()
    conn.close()
        