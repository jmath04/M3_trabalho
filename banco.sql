Create database M3;

use M3;

create table moradores(
	id_morador int primary key auto_increment,
    nome varchar(200),
    sobrenome varchar(200),
    email varchar(200),
    RG varchar(9),
    telefone varchar(14)
);

create table unidades(
	id_unidade int primary key auto_increment,
    loc varchar(50),
    id_morador int,
    foreign key (id_morador) references moradores(id_morador)
);


create table pagamentos(
	id_pagamento int auto_increment primary key,
    id_morador int,
    data_pagamento varchar(10),
    comprovante MEDIUMBLOB,
    mes_ref varchar(2),
    ano_ref varchar(4),
    id_unidade int,
    data_reg varchar(10),
	foreign key (id_morador) references moradores(id_morador),
    foreign key (id_unidade) references unidades(id_unidade)
);

-- Na frente das variveis dos Procedures coloquei o P so p/ n confundor com as colunas das tabelas

-- Deletar PGTS 
DELIMITER $$
CREATE PROCEDURE deletar_pgts(IN p_id_pagamento INT)
BEGIN
    DELETE FROM pagamentos WHERE id_pagamento = p_id_pagamento;
END$$
DELIMITER ;
-- Inserir PGTS 
DELIMITER $$ 
CREATE PROCEDURE inserir_pgts(
	IN p_id_morador INT,
    IN p_id_unidade INT,
    IN p_mes_ref VARCHAR(2),
    IN p_ano_ref VARCHAR(4),
    IN p_data_pagamento DATE,
    IN p_comprovante MEDIUMBLOB
)
BEGIN
	INSERT INTO pagamentos (id_morador, id_unidade, mes_ref, ano_ref, data_pagamento, comprovante)
	VALUES (p_id_morador, p_id_unidade, p_mes_ref, p_ano_ref, p_data_pagamento, p_comprovante);
END $$
DELIMITER ;     
	
-- Deletar MORADORES 
DELIMITER $$
CREATE PROCEDURE deletar_morador(IN p_id_morador INT)
BEGIN
    DELETE FROM moradores WHERE id_morador = p_id_morador;
END$$
DELIMITER ;
-- Inserir MORADORES 
DELIMITER $$
CREATE PROCEDURE inserir_morador(
    IN p_nome VARCHAR(200),
    IN p_sobrenome VARCHAR(200),
    IN p_email VARCHAR(200),
    IN p_RG VARCHAR(20),
    IN p_telefone VARCHAR(14)
)
BEGIN
    INSERT INTO moradores (nome, sobrenome, email, RG, telefone)
    VALUES (p_nome, p_sobrenome, p_email, p_RG, p_telefone);
END$$
DELIMITER ;

-- TESTES 
INSERT INTO unidades (loc, id_morador) VALUES  ('Bloco A, Apt 101', 1); -- INSIRIR A UND PARA CONSEGUIR PROCEDECER COM ALGUSN DELETE E SELECT
CALL inserir_morador('Nome1', 'Nome1.0', 'Nome1@email.com', '123456789', '(11) 1111-1111');
SELECT * FROM moradores;
DELETE FROM unidades WHERE id_morador = 1;
CALL deletar_morador(1);
CALL inserir_pgts(1, 1, '11', '2025', '2025-11-30', 'comprovante');
SELECT * FROM pagamentos;
CALL deletar_pgts(1);

-- View PGTS - Ordenado
CREATE VIEW pgts_lista AS
SELECT 
    p.id_pagamento,
    CONCAT(m.nome, ' ', m.sobrenome) AS nome_pagador,
    p.data_pagamento,
    p.mes_ref,
    p.ano_ref,
    u.loc AS localizacao_unidade,
    p.data_reg
FROM pagamentos p
INNER JOIN moradores m ON p.id_morador = m.id_morador
INNER JOIN unidades u ON p.id_unidade = u.id_unidade
ORDER BY p.ano_ref, p.mes_ref;
-- TESTE
SELECT * FROM pgts_lista;

-- Inserir UNDS
DELIMITER $$
CREATE PROCEDURE inserir_unds(
	IN p_loc VARCHAR(50),
    IN p_id_morador INT
)
BEGIN 
	INSERT INTO unidades (loc, id_morador)
	VALUES (p_loc, p_id_morador);
END$$
DELIMITER ;
-- Deletar UNDS
DELIMITER $$
CREATE PROCEDURE deletar_unds(IN p_id_unidade INT)
BEGIN
    DELETE FROM unidades WHERE id_unidade = p_id_unidade;
END$$
DELIMITER ;
-- TESTE
CALL inserir_morador('Nome1', 'Nome1.0', 'Nome1@email.com', '123456789', '(11) 1111-1111');
SELECT * FROM moradores;
CALL inserir_unds('Bloco A, Apt 101', 2);
SELECT * FROM unidades;
CALL deletar_unds(3);
CALL deletar_morador(2);

-- Trigger para Data_Pagamento (RNF06)
DELIMITER $$
CREATE TRIGGER data_registro_pgt
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
    IF NEW.data_reg IS NULL THEN
        SET NEW.data_reg = NOW();
    END IF;
END$$
DELIMITER ;
-- TESTES
-- Inserir um morador
CALL inserir_morador('Nome2', 'Trigger Test', 'Nome2@email.com', '987654321', '(22) 2222-2222');
SELECT * FROM moradores;
-- Inserir uma unidade
CALL inserir_unds('Bloco B, Apt 202', 1);
SELECT * FROM unidades;

-- 2. Teste 1: Inserir pagamento SEM informar data_reg (deve ser preenchida automaticamente)
CALL inserir_pgts(1, 1, '12', '2024', '2024-12-01', 'comprovante_1');
-- 3. Verificar o resultado
SELECT * FROM pagamentos;
-- 4. Teste 2: Inserir outro pagamento INFORMANDO data_reg (deve manter o valor informado)
CALL inserir_pgts(1, 1, '11', '2024', '2024-11-30', 'comprovante_teste2');
-- 5. Verificar ambos os registros
SELECT 
    id_pagamento,
    mes_ref,
    ano_ref,
    data_pagamento,
    data_reg
FROM pagamentos;

DELIMITER $$

CREATE PROCEDURE pesquisa_moradores(
	IN p_nome VARCHAR(200),
    IN p_sobrenome VARCHAR(200),
    IN p_email VARCHAR(200),
    IN p_RG VARCHAR(20),
    IN p_telefone VARCHAR(14)
)
BEGIN
    SELECT * FROM moradores
    WHERE 
        (nome LIKE CONCAT('%', p_nome, '%') OR p_nome IS NULL)
        
        or
        (p_sobrenome like concat('%',p_sobrenome,'%') or p_sobrenome IS NULL)
        
        or
        (p_email like concat('%',p_email,'%') or p_email IS NULL)
        
        or
        (p_RG like concat('%',p_RG,'%')or p_RG IS NULL)
        
		or
        (p_telefone like concat('%',p_telefone,'%') or p_telefone IS NULL);
        
END $$

DELIMITER ;

DELIMITER $$

create procedure moradores_all()

begin
	
    Select * from moradores;


end $$

DELIMITER $$

call moradores_all();
