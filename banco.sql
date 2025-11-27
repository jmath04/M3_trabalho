use M3;

create user server@localhost identified by 'Senha@123';

grant EXECUTE on *.* to server@localhost;

create table moradores(
	id_morador int primary key auto_increment,
    nome varchar(200),
    sobrenome varchar(200),
    email varchar(200),
    RG varchar(7),
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
