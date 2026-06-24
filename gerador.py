import random
import psycopg2

conn = psycopg2.connect(dbname="streaming", user="nati", password="nati", host="localhost")
cur = conn.cursor()

# Geração de usuários
for i in range(100):
    cur.execute("""
    INSERT INTO usuario(nome, email, telefone, data_nasc, sexo, idade, pais)
    VALUES(%s, %s, %s, %s, %s, %s, %s)
    """,
    (f"User{i}", f"user{i}@email.com", "11999999999", "1990-01-01", "Indefinido", random.randint(18,60), "Brasil"))

# Geração de livros 
generos = ['Ação', 'Comédia', 'Drama', 'Romance', 'Terror']
for i in range(50):
    cur.execute("""
        INSERT INTO livro(titulo, colecao, data_publicacao, nivel_acesso)
        VALUES(%s, %s, %s, %s)
    """,
    (f"Livro{i}", "Coleção Padrão", "2023-01-01", "comum"))
    

# 3. Geração de Avaliações Aleatórias
for usuario_id in range(1, 101): # IDs de 1 a 100
    # Seleciona aleatoriamente alguns livros para este usuário avaliar
    livros_para_avaliar = random.sample(range(1, 51), random.randint(5, 10))
    
    for livro_id in livros_para_avaliar:
        nota = random.randint(1, 5) # Nota de 1 a 5
        cur.execute("""
            INSERT INTO avaliacoes(id_livro, id_usuario, nota, texto)
            VALUES(%s, %s, %s, %s)
        """,
        (livro_id, usuario_id, nota, "Avaliação gerada automaticamente pelo sistema."))

conn.commit()
cur.close()
conn.close()
