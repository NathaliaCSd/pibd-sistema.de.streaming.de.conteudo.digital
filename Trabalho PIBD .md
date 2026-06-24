**UNIVERSIDADE FEDERAL DE SÃO CARLOS**   
**UFSCar Departamento de Computação**

 **Trabalho – Banco de Dados** 

**Tema: Sistema de Streaming de Conteúdo Digital**

**Nathalia Cristina Santos – 795698**  
**Gabriel Luiz Antonio da Silva \- 833230**  
**Yara Vieira de Lima – 824341**

**Descrição Geral** 

O trabalho consiste no desenvolvimento de um projeto completo de banco de dados para um **sistema de streaming**, semelhante a plataformas de distribuição de conteúdo digital (filmes, séries, documentários, livros, etc.). 

**Parte 1 – Modelagem e Implementação Inicial**

• **Descrição do problema e requisitos de dados**  
	Um sistema de streaming de livros digitais, que o usuário deve fazer uma conta para ter acesso aos conteúdos do sistema. O sistema contará um catálogo de livros que será categorizado pelo nome do livro, autor(es), data de publicação, editora, coleção, gênero e popularidade(baseado nas avaliações dos usuários).   
	Um usuário possui um ID\_usuario(código), nome, sexo, telefone, data de nascimento e idade, email.   
Se o usuário for um usuário premium (paga assinatura), ele terá acesso ilimitado aos livros do sistema, fora o acesso offline disponível e sem anúncios durante o uso. Se for um usuário básico (não paga assinatura), ele terá acesso limitado aos recursos, como limite de 5 livros ao mês, fora ser limitado ao acesso somente online do sistema, e com anúncios periódicos durante o uso.   
	Após ou durante a leitura de algum livro, o usuário (premium ou básico) poderá escrever avaliações sobre o livro. As avaliações poderão ser baseadas em quantidade de estrelas (0 a 5 estrelas), ou, em texto, limitado a 200 caracteres. As avaliações serão públicas. Cada livro mostrará a média das notas que eles são avaliados, sendo uma das métricas de busca do sistema.   
   	Um administrador controlará o sistema, com a função de adicionar e deletar livros da biblioteca.  Um administrador possui um ID\_adm(código), nome, sexo, telefone, data de nascimento e idade, email.  
  	Será disponibilizado que o usuário veja o histórico de leitura, permitindo a busca de até os últimos cem livros lidos pelo usuário, disponibilizando as datas e nomes das últimas leituras. Ficará disponível também uma estatística de quantos livros completos o usuário leu, quantos ele está lendo no momento e qual a porcentagem de leitura do livro atual.   
       O usuário premium pode visualizar o histórico de pagamento, que contém valor pago pela assinatura, data dos pagamentos anteriores,  e do próximo.  Armazenará os dados bancários de cada usuário.   
 	O pagamento será de forma mensal ou anual, função definida na assinatura,e poderá ser feito por meio de débito,crédito e pix. Ele pode ser dividido em parcelas, com pix e débito são somente uma parcela, e com crédito podendo ser divididos em até 12 parcelas. Cada parcela terá um histórico de pagamentos, que contém datas e horários de pagamento, juros e o valor pago em cada pagamento/parcela. 

**• Projeto Conceitual**   
Visualização na íntegra em:  
 [https://drive.google.com/file/d/1jjMzTbPjehLn7\_7QQobz43CiOxDCE1NW/view?usp=sharing](https://drive.google.com/file/d/1jjMzTbPjehLn7_7QQobz43CiOxDCE1NW/view?usp=sharing)

Foi utilizado a plataforma draw io para fazer o desenvolvimento do projeto conceitual do sistema de streaming.   
![][image1]

**• Projeto Lógico** 

fk \= foreign key, 

wk= weak key, 

pw \= primary key  
         

          usuario \= { **pk:id\_usuario**, email,telefone,data\_nasc, nome,sexo};

usuario\_premium \={**pk/fk : id\_usuario**,forma\_assinatura,data\_assinatura}

administrador \= {**pk/fk : id\_usuario**,id\_admin}

usuario\_basico \={**pk/fk: id\_usuario**}

historico­\_leitura \= {**pk: id\_historico, fk: usuario, fk:livros**, status\_leitura, data leitura}

livro \= **{pk:id\_livro**, titulo, popularidade, colecao, autor, genero, data\_publicacao, media\_avaliacao};

avaliações \= **{pk: id\_avaliacoes, fk:livros**\_ava, nota,texto, data\_avaliacao, autor\_avalacao}

dados\_bancarios \= {**pk: id\_dados\_bancarios, fk:user**, banco, num\_conta, tipo\_conta, agencia}

pagamento=**{pk: id\_pagamento, fk:dados\_banca**, meios\_pagamento, data\_inicio, data\_venc, valor\_total}

parcela \= {pk:{fk: id\_pagamento, wk: num\_parcela}, juros, hora\_pag, data\_venc, data\_pag, valor\_parcela

gerencia \= { pk : {fk:id\_usuario\_admin, fk:livros}}

Discussões:

*  Necessidade de um id\_admin: será que é necessário usar uma chave para identificar o administrador?  
*  Atributos derivados não são armazenados em colunas,eles devem aparecer no modelo relacional?  
* Os relacionamentos 1:1 e 1:N foram feitos usando o método da chave estrangeira.  
* Pequenas mudanças de nomes de chaves estrangeiras em entidades para facilitar na hora de transformar em SQL.

**• Projeto Físico** 

```sql
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

```

**• Dependências Funcionais e Normalização** 

Tabela **livro**: Problema de **1FN**:  
 Os atributos autor e gênero são multivalorados (um livro pode ter vários autores e vários gêneros). No modelo relacional, não pode ter listas dentro de uma coluna.  
 É obrigatório criar tabelas para Autor e Gênero, e tabelas associativas (N:M) ligando-as ao livro.

**2FN**: nossa entidades fortes não contém múltiplas chaves, portanto passa no 2FN. 

**3FN**: Nenhuma tabela possui atributos transitivos, que não esteja fortemente ligado com a chave, logo, está no 3FN. 

**Após normalização:**  
livro \= {pk: id\_livro, titulo, colecao, data\_publicacao}   
autor \= {pk: id\_autor, nome}  
genero \= {pk: id\_genero, nome\_genero}  
livro\_autor \= {pk/fk: id\_livro, pk/fk: id\_autor} (Tabela associativa)  
livro\_genero \= {pk/fk: id\_livro, pk/fk: id\_genero} (Tabela associativa)  
   
     
**SQL após a normalização:**

```
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
```

**• Consultas SQL** 

* Busca por um livro específico;

```sql
SELECT * FROM livro WHERE titulo = 'O Hobbit';

```


* Adição de um novo livro no sistema;

```sql
INSERT INTO livro (titulo, colecao, data_publicacao) 
VALUES ('ds', 'Coleção Tolkien', '21/09/1937');
```

* adição de gêneros e ligação de gênero com livro, para depois fazer a 

  buscar por gênero;

```sql
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
```

* Criar usuário no sistema;

```sql
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

```

* Adicionar avaliação de livro;

```sql
INSERT INTO avaliacoes (id_livro, id_usuario, nota, texto)
VALUES (1, 10, 5, 'Excelente leitura! A construção dos personagens é fascinante.');

```

**• Gerenciamento de Usuários** 

           Vimos que não tinha forma de diferenciar um livro que o usuário comum pode ver dos livros que ele não pode,então decidimos adicionar o atributo nível acesso a tabela livro com valor padrão  ‘comum’.    
E como nosso projeto deve permitir que o usuário comum veja somente livros com atributo nivel\_acesso \= comum, percebemos que com GRANT conseguimos somente controlar a coluna, pesquisamos na internet e vimos que existe uma função RLS que consegue filtrar as linhas, também vimos que podíamos somente ter feito uma visão específica, que como foi ensinado em aula, é usado na controle de linha também, mas como achei interessante essa função, deixei as duas opções, no tópico visão eu vou colocar a outra alternativa. 

```sql
ALTER TABLE livro ADD COLUMN nivel_acesso VARCHAR(10) DEFAULT 'comum';
-- Livros 'comum' todos veem. Livros 'premium' só o premium e o admin veem.
-- 1. Criação dos Papéis (Roles)
CREATE ROLE grupo_admins;
CREATE ROLE grupo_comum;
CREATE ROLE grupo_premium;

-- 2. Permissões de Acesso (Quem pode "entrar na sala")
-- Damos acesso de leitura para os dois grupos de usuários
GRANT SELECT ON livro, autor, genero, livro_autor, livro_genero TO grupo_comum, grupo_premium;

-- Admins podem tudo
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO grupo_admins;

-- 3. Habilitar a Segurança de Linha (RLS)
ALTER TABLE livro ENABLE ROW LEVEL SECURITY;

-- 4. Criar as Políticas (Quem pode "ver os móveis")

-- Política para o Grupo Comum: Só vê se acesso = 'comum'
CREATE POLICY politica_ver_livros_comuns
ON livro
FOR SELECT
TO grupo_comum
USING (nivel_acesso = 'comum'); -- Use o nome da coluna que você criou (ex: nivel_acesso)

-- Política para o Grupo Premium: Vê tudo (true)
CREATE POLICY politica_ver_tudo_premium
ON livro
FOR SELECT
TO grupo_premium
USING (true);

-- Política para o Grupo Admin: Vê e faz tudo
CREATE POLICY politica_admin_total
ON livro
TO grupo_admins
USING (true)
WITH CHECK (true);
```

**• Visões (Views)** 

1-

```sql
CREATE VIEW view_livro_comum AS
SELECT
	id_livro,
	titulo,
	colecao,
       data_publicacao,
	nivel_acesso
FROM livro
WHERE nivel_acesso = 'comum’';
```

**Justificativa**

A view **view\_livro\_comum**foi criada para mostrar somente os livros que o usuário básico pode acessar. Dessa forma, **view\_livro\_comum** o sistema consegue separar os livros comuns dos livros premium de maneira mais simples e organizada. Além disso, a view evita a necessidade de fazer o filtro dos livros em todas as consultas do sistema, facilitando o uso e a manutenção do banco de dados.

2-

```sql
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
```

### **Justificativa**

A view de histórico de leitura foi criada para facilitar a visualização das informações de leitura dos usuários. Com ela, é possível ver de forma mais organizada os usuários, os livros lidos e as datas das leituras em uma única consulta.

**• Organização Física e Indexação** 

**Criação de índices:**

**\-- Índice para busca de livros pelo título**

```sql
CREATE INDEX idx_titulo_livro
ON livro(titulo);
```

**\-- Índice para consultas no histórico de leitura por usuário**

```sql
CREATE INDEX idx_historico_usuario
ON historico_leitura(id_usuario);
```

**\-- Índice para buscas de avaliações por livro**

```sql
CREATE INDEX idx_avaliacao_livro
ON avaliacoes(id_livro);
```

**\-- Índice para consultas de pagamentos dos usuários**

```sql
CREATE INDEX idx_pagamento_dados
ON pagamento(id_dados_bancarios);
```

### **Justificativa baseada em desempenho:**

Os índices foram criados para melhorar a velocidade das consultas realizadas com mais frequências no sistemas,como busca de livro,histórico de leitura,avaliações,pagamento.Sem índices o banco precisaria verificar todos os registros das tabelas,o que os deixaria as consultas mais lentas conforme o sistema crescesse.

**Justificativa de uso:**

O índice **idx\_titulo\_livro** foi criado para facilitar e acelerar a busca de livros pelo título.

O índice **idx\_historico\_usuario** foi criado para melhorar consultas relacionadas ao histórico de leitura de cada usuário.

O índice **idx\_avaliacao\_livro** foi criado para tornar mais rápidas as consultas de avaliações feitas nos livros.

O índice **idx\_pagamento\_dados** foi criado para melhorar consultas relacionadas aos pagamentos e dados bancários dos usuários.

# **Parte 2 – Extensões Avançadas e Inteligência de Dados**

## **Objetivo**

Nesta etapa, os grupos deverão expandir o sistema com funcionalidades avançadas de banco de dados e integração com técnicas de aprendizado de máquina.

## **Programação no Banco de Dados**

* Implementação de funções e/ou procedures utilizando PL/pgSQL e/ou PL/Python;  
* Implementação de triggers com regras de negócio.

### **Função: calcular\_media\_livro**

```sql
CREATE OR REPLACE FUNCTION calcular_media_livro(
	p_id_livro INT
)
RETURNS DECIMAL(3,2)
AS
$$
DECLARE
	v_media DECIMAL(3,2);
BEGIN

	SELECT AVG(nota)
	INTO v_media
	FROM avaliacoes
	WHERE id_livro = p_id_livro;

	RETURN COALESCE(v_media,0);

END;
$$
LANGUAGE plpgsql;
```

### **Procedure: tornar\_usuario\_premium**

```sql
CREATE OR REPLACE PROCEDURE tornar_usuario_premium(
	p_id_usuario INT,
	p_forma_assinatura VARCHAR(50)
)
LANGUAGE plpgsql
AS
$$
BEGIN

	INSERT INTO usuario_premium
	(
    	id_usuario,
    	forma_assinatura,
    	data_assinatura
	)
	VALUES
	(
    	p_id_usuario,
    	p_forma_assinatura,
    	CURRENT_DATE
	);

END;
$$;
```

### **Procedure: cadastrar\_livro**

```sql
CREATE OR REPLACE PROCEDURE cadastrar_livro(
	p_titulo VARCHAR(150),
	p_colecao VARCHAR(100),
	p_data_publicacao DATE
)
LANGUAGE plpgsql
AS
$$
BEGIN

	INSERT INTO livro
	(
    	titulo,
    	colecao,
    	data_publicacao
	)
	VALUES
	(
    	p_titulo,
    	p_colecao,
    	p_data_publicacao
	);

END;
$$;
```

### **Trigger: trg\_atualizar\_media\_livro**

```sql
CREATE OR REPLACE FUNCTION atualizar_media_avaliacao()
RETURNS TRIGGER
AS
$$
BEGIN

	UPDATE livro
	SET media_avaliacao =
	(
    	SELECT AVG(nota)
    	FROM avaliacoes
    	WHERE id_livro = NEW.id_livro
	)
	WHERE id_livro = NEW.id_livro;

	RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_media_livro
AFTER INSERT
ON avaliacoes
FOR EACH ROW
EXECUTE FUNCTION atualizar_media_avaliacao();
```

### **Trigger: trg\_limite\_usuario\_basico**

```sql
CREATE OR REPLACE FUNCTION verificar_limite_usuario_basico()
RETURNS TRIGGER
AS
$$
DECLARE
	qtd_livros INT;
BEGIN

	IF EXISTS
	(
    	SELECT 1
    	FROM usuario_basico
    	WHERE id_usuario = NEW.id_usuario
	)
	THEN

    	SELECT COUNT(*)
    	INTO qtd_livros
    	FROM historico_leitura
    	WHERE id_usuario = NEW.id_usuario
    	AND DATE_TRUNC('month',data_leitura)
        	=
        	DATE_TRUNC('month',CURRENT_DATE);

    	IF qtd_livros >= 5 THEN

        	RAISE EXCEPTION
        	'Usuário básico atingiu o limite mensal de 5 livros';

    	END IF;

	END IF;

	RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_limite_usuario_basico
BEFORE INSERT
ON historico_leitura
FOR EACH ROW
EXECUTE FUNCTION verificar_limite_usuario_basico();
```

### **Trigger: trg\_registrar\_historico**

```sql
CREATE OR REPLACE FUNCTION registrar_historico_leitura()
RETURNS TRIGGER
AS
$$
BEGIN

	INSERT INTO historico_leitura
	(
    	id_usuario,
    	id_livro,
    	status_leitura,
    	data_leitura
	)
	VALUES
	(
    	NEW.id_usuario,
    	NEW.id_livro,
    	'Concluído',
    	CURRENT_TIMESTAMP
	);

	RETURN NEW;

END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_registrar_historico
AFTER INSERT
ON avaliacoes
FOR EACH ROW
EXECUTE FUNCTION registrar_historico_leitura();
```

## **Integração com Python**

* Conexão com o banco de dados utilizando a biblioteca **psycopg2**;  
* Execução de consultas via script Python;  
* Interação via terminal.

### **Script Python de Consulta**

```py
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
```

### **Consulta de Livros por Usuário**

```py
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
```

### **Cadastro de Avaliação via Terminal**

```py
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
```

## **Aplicação de Aprendizado de Máquina**

### **Recomendação de Conteúdos**

```sql
#importacao de bibliotecas
import pandas as pd
import psycopg2

from sklearn.metrics.pairwise import cosine_similarity


#conexao com o banco de dados 
conn = psycopg2.connect(
	dbname="streaming",
	user="postgres",
	password="postgres",
	host="localhost",
	port="5432"
)

#extracao de dados
#obtem matriz de avaliacoes (usuario x conteudo)

query = """
    SELECT usuario_id, conteudo_id, nota
    FROM AVALIACOES
"""

df = pd.read_sql(query, conn)

#cria matriz usuario-item
#linhas = usuarios
#colunas = conteudos
#valores = nota (ou 0 se nao avaliado)

matriz = df.pivot_table(
    index='usuario_id',
    columns='conteudo_id',
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
    """, (1, conteudo, float(score)))

conn.commit()

cur.close()
conn.close()

```

## **Integração Banco \+ Machine Learning**

* Extração de dados do banco;  
* Processamento em Python;  
* Retorno de resultados ao banco.

```sql
import random
import psycopg2

#conexao com o banco 
conn = psycopg2.connect(

    dbname="streaming",

    user="postgres",

    password="postgres",
    host="localhost"

    port="5432"
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
        

```

## **Apresentação Final**

Link para a apresentação: [https://canva.link/gkqauh5nd0qhj3k](https://canva.link/gkqauh5nd0qhj3k)  


[image1]: <data:image/png;base64,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>