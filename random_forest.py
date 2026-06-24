import psycopg2
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix

# CONEXÃO COM O BANCO
conn = psycopg2.connect(
    dbname="streaming",
    user="nati",
    password="nati",  # Agora a senha é 'nati'
    host="localhost",
    port="5432"
)

# CONSULTA DOS DADOS

query = """
SELECT
    u.id_usuario,
    u.idade,
    l.id_livro,
    5.0 AS popularidade, -- Valor placeholder
    a.nota
FROM usuario u
JOIN avaliacoes a ON u.id_usuario = a.id_usuario
JOIN livro l ON l.id_livro = a.id_livro
"""
df = pd.read_sql(query, conn)

df["idade"] = df["idade"].fillna(df["idade"].mean()) # Preenche os vazios com a média

print("Dados carregados:")
print(df.head())

# PREPARAÇÃO DOS DADOS

X = df[
    [
        "idade",
        "popularidade"
    ]
]

y = (df["nota"] >= 4).astype(int)

# DIVISÃO TREINO E TESTE

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42
)

# TREINAMENTO

modelo = RandomForestClassifier(
    n_estimators=100,
    random_state=42
)

modelo.fit(X_train, y_train)

# AVALIAÇÃO

y_pred = modelo.predict(X_test)

acuracia = accuracy_score(y_test, y_pred)

print("\nAcurácia:")
print(acuracia)

print("\nMatriz de Confusão:")
print(confusion_matrix(y_test, y_pred))

# PREDIÇÕES

df["predicao"] = modelo.predict(X)

print("\nPrimeiras Recomendações:")
print(df.head())

# SALVAR RESULTADOS NO BANCO

cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS recomendacao (
    id_recomendacao SERIAL PRIMARY KEY,
    id_usuario INT,
    id_livro INT,
    score FLOAT
)
""")

for _, row in df.iterrows():

    cur.execute("""
    INSERT INTO recomendacao (
        id_usuario,
        id_livro,
        score
    )
    VALUES (%s, %s, %s)
    """,
    (
        int(row["id_usuario"]),
        int(row["id_livro"]),
        float(row["predicao"])
    ))

conn.commit()

print("\nRecomendações gravadas com sucesso!")

cur.close()
conn.close()
