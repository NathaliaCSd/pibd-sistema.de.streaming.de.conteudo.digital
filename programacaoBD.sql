-- SISTEMA DE STREAMING DE LIVROS
-- PROGRAMAÇÃO NO BANCO DE DADOS - PL/pgSQL

-- FUNCTION 1
-- CALCULAR MÉDIA DAS AVALIAÇÕES DE UM LIVRO

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


-- 
-- PROCEDURE 1
-- TRANSFORMAR USUÁRIO EM PREMIUM

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


-- PROCEDURE 2
-- CADASTRAR NOVO LIVRO

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


-- FUNCTION DA TRIGGER
-- ATUALIZA MÉDIA DAS AVALIAÇÕES

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


-- TRIGGER 1
-- ATUALIZAR MÉDIA AUTOMATICAMENTE

DROP TRIGGER IF EXISTS trg_atualizar_media_livro
ON avaliacoes;

CREATE TRIGGER trg_atualizar_media_livro
AFTER INSERT
ON avaliacoes
FOR EACH ROW
EXECUTE FUNCTION atualizar_media_avaliacao();


-- FUNCTION DA TRIGGER
-- LIMITAR USUÁRIO BÁSICO A 5 LIVROS/MÊS

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


-- TRIGGER 2
-- CONTROLE DE LIVROS MENSAIS

DROP TRIGGER IF EXISTS trg_limite_usuario_basico
ON historico_leitura;

CREATE TRIGGER trg_limite_usuario_basico
BEFORE INSERT
ON historico_leitura
FOR EACH ROW
EXECUTE FUNCTION verificar_limite_usuario_basico();


-- FUNCTION DA TRIGGER
-- REGISTRAR HISTÓRICO DE LEITURA

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


-- TRIGGER 3
-- REGISTRAR LEITURA APÓS AVALIAÇÃO

DROP TRIGGER IF EXISTS trg_registrar_historico
ON avaliacoes;

CREATE TRIGGER trg_registrar_historico
AFTER INSERT
ON avaliacoes
FOR EACH ROW
EXECUTE FUNCTION registrar_historico_leitura();


-- TESTES
-- TESTE FUNCTION

SELECT calcular_media_livro(1);


-- TESTE PROCEDURE PREMIUM

CALL tornar_usuario_premium(
    1,
    'Mensal'
);


-- TESTE PROCEDURE LIVRO

CALL cadastrar_livro(
    'Dom Casmurro',
    'Literatura Brasileira',
    '1899-01-01'
);


-- TESTE AVALIAÇÃO

INSERT INTO avaliacoes
(
    id_livro,
    id_usuario,
    nota,
    texto
)
VALUES
(
    1,
    1,
    5,
    'Excelente leitura'
);


-- VERIFICAR MÉDIA

SELECT
    id_livro,
    titulo,
    media_avaliacao
FROM livro;


-- VERIFICAR HISTÓRICO

SELECT *
FROM historico_leitura;


-- VERIFICAR USUÁRIOS PREMIUM

SELECT *
FROM usuario_premium;
