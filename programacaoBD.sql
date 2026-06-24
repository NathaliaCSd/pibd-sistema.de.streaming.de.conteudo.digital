--Função: calcular_media_livro
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

--Procedure: tornar_usuario_premium
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
--Procedure: cadastrar_livro
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

--Trigger: trg_atualizar_media_livro
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

--Trigger: trg_limite_usuario_basico
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

--Trigger: trg_registrar_historico
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

END;
$$;

