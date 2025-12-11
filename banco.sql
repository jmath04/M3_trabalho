-- ===========================================
-- DROP E RECRIAÇÃO COMPLETA DO BANCO DE DADOS
-- ===========================================

DROP DATABASE IF EXISTS M3_bd;
CREATE DATABASE M3_bd;
USE M3_bd;

DROP USER IF EXISTS 'server'@'localhost';
CREATE USER 'server'@'localhost' IDENTIFIED BY 'Senha@123'; (padrão local)
GRANT ALL PRIVILEGES ON M3_bd.* TO 'server'@'localhost'; (padrão local)
FLUSH PRIVILEGES;

-- ===========================================
-- CRIAÇÃO DAS TABELAS
-- ===========================================

CREATE TABLE moradores(
    id_morador INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    sobrenome VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    RG VARCHAR(20) NOT NULL UNIQUE,
    telefone VARCHAR(15) NOT NULL
);

CREATE TABLE unidades(
    id_unidade INT PRIMARY KEY AUTO_INCREMENT,
    loc VARCHAR(100) NOT NULL,
    id_morador INT,
    FOREIGN KEY (id_morador) REFERENCES moradores(id_morador) ON DELETE SET NULL
);

CREATE TABLE pagamentos(
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_morador INT NOT NULL,
    id_unidade INT NOT NULL,
    data_pagamento DATE NOT NULL,
    mes_ref VARCHAR(2) NOT NULL,
    ano_ref VARCHAR(4) NOT NULL,
    comprovante LONGBLOB NOT NULL,
    data_reg DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_morador) REFERENCES moradores(id_morador) ON DELETE CASCADE,
    FOREIGN KEY (id_unidade) REFERENCES unidades(id_unidade) ON DELETE CASCADE
);

-- ===========================================
-- STORED PROCEDURES - INSERÇÃO
-- ===========================================

DELIMITER $$
CREATE PROCEDURE inserir_morador(
    IN p_nome VARCHAR(200),
    IN p_sobrenome VARCHAR(200),
    IN p_email VARCHAR(200),
    IN p_RG VARCHAR(20),
    IN p_telefone VARCHAR(15)
)
BEGIN
    INSERT INTO moradores (nome, sobrenome, email, RG, telefone)
    VALUES (p_nome, p_sobrenome, p_email, p_RG, p_telefone);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE inserir_unds(
    IN p_loc VARCHAR(100),
    IN p_id_morador INT
)
BEGIN 
    INSERT INTO unidades (loc, id_morador)
    VALUES (p_loc, p_id_morador);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE inserir_pgts(
    IN p_id_morador INT,
    IN p_id_unidade INT,
    IN p_mes_ref VARCHAR(2),
    IN p_ano_ref VARCHAR(4),
    IN p_data_pagamento DATE,
    IN p_comprovante LONGBLOB
)
BEGIN
    INSERT INTO pagamentos (id_morador, id_unidade, mes_ref, ano_ref, 
                           data_pagamento, comprovante)
    VALUES (p_id_morador, p_id_unidade, p_mes_ref, p_ano_ref, 
            p_data_pagamento, p_comprovante);
END$$
DELIMITER ;

-- ===========================================
-- STORED PROCEDURES - EXCLUSÃO
-- ===========================================

DELIMITER $$
CREATE PROCEDURE deletar_morador(IN p_id_morador INT)
BEGIN
    DELETE FROM moradores WHERE id_morador = p_id_morador;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE deletar_unds(IN p_id_unidade INT)
BEGIN
    DELETE FROM unidades WHERE id_unidade = p_id_unidade;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE deletar_pgts(IN p_id_pagamento INT)
BEGIN
    DELETE FROM pagamentos WHERE id_pagamento = p_id_pagamento;
END$$
DELIMITER ;

-- ===========================================
-- STORED PROCEDURES - CONSULTA
-- ===========================================

DELIMITER $$
CREATE PROCEDURE pesquisa_moradores(
    IN p_nome VARCHAR(200),
    IN p_sobrenome VARCHAR(200),
    IN p_email VARCHAR(200),
    IN p_RG VARCHAR(20),
    IN p_telefone VARCHAR(15)
)
BEGIN
    SELECT * FROM moradores
    WHERE 
        (nome LIKE CONCAT('%', COALESCE(p_nome, ''), '%'))
        OR (sobrenome LIKE CONCAT('%', COALESCE(p_sobrenome, ''), '%'))
        OR (email LIKE CONCAT('%', COALESCE(p_email, ''), '%'))
        OR (RG LIKE CONCAT('%', COALESCE(p_RG, ''), '%'))
        OR (telefone LIKE CONCAT('%', COALESCE(p_telefone, ''), '%'));
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE moradores_all()
BEGIN
    SELECT * FROM moradores ORDER BY nome, sobrenome;
END$$
DELIMITER ;

-- ===========================================
-- VIEW PARA LISTAGEM DE PAGAMENTOS
-- ===========================================

CREATE VIEW pgts_lista AS
SELECT 
    p.id_pagamento,
    CONCAT(m.nome, ' ', m.sobrenome) AS nome_pagador,
    p.data_pagamento,
    p.mes_ref,
    p.ano_ref,
    u.loc AS localizacao_unidade,
    p.data_reg,
    p.id_morador,
    p.id_unidade
FROM pagamentos p
INNER JOIN moradores m ON p.id_morador = m.id_morador
INNER JOIN unidades u ON p.id_unidade = u.id_unidade
ORDER BY p.ano_ref DESC, p.mes_ref DESC;

-- ===========================================
-- TRIGGER PARA DATA DE REGISTRO
-- ===========================================

DELIMITER $$
CREATE TRIGGER trg_data_registro_pagamento
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
    IF NEW.data_reg IS NULL THEN
        SET NEW.data_reg = NOW();
    END IF;
END$$
DELIMITER ;

-- ===========================================
-- DADOS DE TESTE
-- ===========================================

CALL inserir_morador('João', 'Silva', 'joao.silva@email.com', '12345678901', '(11) 99999-8888');
CALL inserir_morador('Maria', 'Santos', 'maria.santos@email.com', '98765432109', '(11) 97777-6666');
CALL inserir_morador('Carlos', 'Oliveira', 'carlos.oliveira@email.com', '45678912304', '(11) 95555-4444');

CALL inserir_unds('Bloco A, Apartamento 101', 1);
CALL inserir_unds('Bloco A, Apartamento 102', 2);
CALL inserir_unds('Bloco B, Apartamento 201', 3);
CALL inserir_unds('Bloco B, Apartamento 202', NULL);

SET @pdf_exemplo = 'PDF_SIMULADO_PARA_TESTE';

CALL inserir_pgts(1, 1, '01', '2024', '2024-01-10', @pdf_exemplo);
CALL inserir_pgts(2, 2, '02', '2024', '2024-02-15', @pdf_exemplo);
CALL inserir_pgts(3, 3, '03', '2024', '2024-03-20', @pdf_exemplo);
CALL inserir_pgts(1, 1, '12', '2023', '2023-12-05', @pdf_exemplo);

-- ===========================================
-- CONSULTAS DE VERIFICAÇÃO
-- ===========================================

SELECT * FROM moradores;
SELECT * FROM unidades;
SELECT * FROM pgts_lista;
SELECT * FROM pagamentos;