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
