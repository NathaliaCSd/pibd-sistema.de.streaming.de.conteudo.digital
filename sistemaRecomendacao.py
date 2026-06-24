#importacao de bibliotecas
import pandas as pd
import psycopg2

from sklearn.metrics.pairwise import cosine_similarity


#conexao com o banco de dados 
conn = psycopg2.connect(
    dbname="streaming",
    user="nati",
    password="nati",  # Agora a senha é 'nati'
    host="localhost",
    port="5432"
)
#extracao de dados
#obtem matriz de avaliacoes (usuario x conteudo)

query = """
    SELECT id_usuario, id_livro, nota
    FROM avaliacoes
"""
df = pd.read_sql(query, conn)

# Ajuste no pivot_table
matriz = df.pivot_table(
    index='id_usuario',
    columns='id_livro',
    values='nota'
).fillna(0)

#calculo de similaridade

#similaridade entre usuarios 
similaridade = cosine_similarity(matriz)

#transforma em dataframe para facilitar uso 
sim_df = pd.DataFrame(
    similaridade, 
    index=matriz.index,
    columns=matriz.index
)

#funcao de recomendacao 

def recomendar(usuario_id, top_n=5):
    #usuarios mais similares (excluindo ele mesmo)
    similares = sim_df[usuario_id].sort_values(ascending=False)[1:6]
    
    #conteudos que o usuario ainda nao assistiu 
    vistos = matriz.loc[usuario_id]
    nao_vistos = vistos[vistos == 0].index

    recomendacoes = {}

    #calcula score baseado em usuarios similares
    for conteudo in nao_vistos:
        score = 0
        for similar_usuario, similaridade in similares.items():
            score += similaridade * matriz.loc[similar_usuario, conteudo]
        recomendacoes[conteudo] = score

    #ordena e retorna top n 
    return sorted(recomendacoes.items(), key=lambda x: x[1], reverse=True)[:top_n]


#exemplo de uso 

recs = recomendar(usuario_id = 1)

print("Recomendacoes para o usuario 1:")
for conteudo, score in recs:
    print(f"Conteudo {conteudo} -> Score: {score}")

#salvando no banco 

cur = conn.cursor()

#cria tabela de recomendacoes
cur.execute("""
CREATE TABLE IF NOT EXISTS recomendacao_ml(
usuario_id INT,
conteudo_id INT,
score FLOAT
)""")

#insere recomendacoes no banco 
for conteudo, score in recs:
    cur.execute("""
    INSERT INTO recomendacao_ml (usuario_id, conteudo_id, score)
    VALUES(%s, %s, %s)
    """, (1, int(conteudo), float(score)))

conn.commit()

cur.close()
conn.close()
