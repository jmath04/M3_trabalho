const bodyParser = require("body-parser");
const session = require("express-session");
const express = require('express');
const mysql = require('mysql2');
const multer = require('multer');
const fs = require('fs');

const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.set('view engine', 'ejs');
app.set('views','./front');

const upload = multer({ 
    dest: 'uploads/',
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
    fileFilter: (req, file, cb) => {
        // Permitir PDFs
        if (file.mimetype === 'application/pdf' || 
            file.mimetype === 'application/octet-stream' ||
            file.originalname.match(/\.(pdf)$/)) {
            cb(null, true);
        } else {
            cb(new Error('Apenas arquivos PDF são permitidos'), false);
        }
    }
});

const conect = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Patifaria7#',
    database: 'M3_bd'
});

app.post("/del_moradores", (req, res) => {
    const { id_morador } = req.body;
    
    conect.query("CALL deletar_morador(?)", [id_morador], (erro) => {
        if (erro) {
            console.log("Erro ao deletar morador:", erro);
            res.send("Erro ao deletar morador");
            return;
        }
        res.redirect("/moradores");
    });
});

app.listen(4000, () => {
    console.log("server rodando na porta 4000");
});

app.use(express.static(__dirname + "/front"));

app.use(session({
    secret: 'segredinho',
    resave: false,
    saveUninitialized: false,
    cookie: {secure: false}
}));

app.get("/", (req, res) => {
    res.sendFile(__dirname + "/front/index.html");
});

app.get("/moradores", (req, res) => {
    conect.query("select * FROM moradores", (erro, dadosDoBanco) => {
        if (erro) {
            console.log("Deu erro no SQL:", erro);
            res.send("Erro ao consultar banco");
            return;
        }
        res.render('moradores', { lista: dadosDoBanco });
    });
});

app.get("/unidades", (req, res) => {
    const query = `
        SELECT u.id_unidade, u.loc, 
               CONCAT(m.nome, ' ', m.sobrenome) as nome_morador,
               m.id_morador
        FROM unidades u
        LEFT JOIN moradores m ON u.id_morador = m.id_morador
    `;
    
    const queryMoradores = "SELECT id_morador, nome, sobrenome FROM moradores";
    
    conect.query(query, (erro, unidades) => {
        if (erro) {
            console.log("Erro ao buscar unidades:", erro);
            res.send("Erro ao consultar banco");
            return;
        }
        
        conect.query(queryMoradores, (erro2, moradores) => {
            if (erro2) {
                console.log("Erro ao buscar moradores:", erro2);
                res.send("Erro ao consultar banco");
                return;
            }
            
            res.render('unidades', { 
                listaUnidades: unidades, 
                listaMoradores: moradores 
            });
        });
    });
});

app.post("/cad_unidades", (req, res) => {
    const { loc, id_morador } = req.body;
    
    conect.query("CALL inserir_unds(?, ?)", [loc, id_morador], (erro) => {
        if (erro) {
            console.log("Erro ao cadastrar unidade:", erro);
            res.send("Erro ao cadastrar unidade");
            return;
        }
        res.redirect("/unidades");
    });
});

app.post("/del_unidades", (req, res) => {
    const { id_unidade } = req.body;
    
    conect.query("CALL deletar_unds(?)", [id_unidade], (erro) => {
        if (erro) {
            console.log("Erro ao deletar unidade:", erro);
            res.send("Erro ao deletar unidade");
            return;
        }
        res.redirect("/unidades");
    });
});

app.get("/pagamentos", (req, res) => {
    const queryPagamentos = "SELECT * FROM pgts_lista ORDER BY ano_ref DESC, mes_ref DESC";
    const queryMoradores = "SELECT id_morador, nome, sobrenome FROM moradores";
    const queryUnidades = "SELECT id_unidade, loc FROM unidades";
    
    conect.query(queryPagamentos, (erro, pagamentos) => {
        if (erro) {
            console.log("Erro ao buscar pagamentos:", erro);
            res.send("Erro ao consultar banco");
            return;
        }
        
        conect.query(queryMoradores, (erro2, moradores) => {
            if (erro2) {
                console.log("Erro ao buscar moradores:", erro2);
                res.send("Erro ao consultar banco");
                return;
            }
            
            conect.query(queryUnidades, (erro3, unidades) => {
                if (erro3) {
                    console.log("Erro ao buscar unidades:", erro3);
                    res.send("Erro ao consultar banco");
                    return;
                }
                
                res.render('pagamentos', {
                    pagamentos: pagamentos,
                    moradores: moradores,
                    unidades: unidades
                });
            });
        });
    });
});

app.post("/cad_pagamentos", upload.single('comprovante'), (req, res) => {
    const { id_morador, data_pagamento, ano_ref, mes_ref, id_unidade } = req.body;
    
    if (!req.file) {
        res.send("É necessário enviar um comprovante em PDF");
        return;
    }
    
    const pdfBuffer = fs.readFileSync(req.file.path);
    fs.unlinkSync(req.file.path);
    
    conect.query("CALL inserir_pgts(?, ?, ?, ?, ?, ?)", 
        [id_morador, id_unidade, mes_ref, ano_ref, data_pagamento, pdfBuffer],
        (erro) => {
            if (erro) {
                console.log("Erro ao cadastrar pagamento:", erro);
                res.send("Erro ao cadastrar pagamento");
                return;
            }
            res.redirect("/pagamentos");
        }
    );
});

app.get("/download_comprovante/:id", (req, res) => {
    const idPagamento = req.params.id;
    
    conect.query("SELECT comprovante FROM pagamentos WHERE id_pagamento = ?", 
        [idPagamento], 
        (erro, resultados) => {
            if (erro || resultados.length === 0) {
                console.log("Erro ao buscar comprovante:", erro);
                res.send("Comprovante não encontrado");
                return;
            }
            
            const comprovante = resultados[0].comprovante;
            
            res.setHeader('Content-Type', 'application/pdf');
            res.setHeader('Content-Disposition', `attachment; filename="comprovante_${idPagamento}.pdf"`);
            
            res.send(comprovante);
        }
    );
});

app.post("/del_pagamentos", (req, res) => {
    const { id_pagamento } = req.body;
    
    conect.query("CALL deletar_pgts(?)", [id_pagamento], (erro) => {
        if (erro) {
            console.log("Erro ao deletar pagamento:", erro);
            res.send("Erro ao deletar pagamento");
            return;
        }
        res.redirect("/pagamentos");
    });
});

app.get("/comprovante", (req, res) => {
    res.sendFile(__dirname + "/front/comprovante.html");
});

app.post("/cad_moradores", (req, res) =>{
    if(req){
        const {nome, sobrenome,email,rg,telefone} = req.body;
        conect.query("CALL inserir_morador(?,?,?,?,?)", [nome,sobrenome,email,rg,telefone]);   
    }
    res.redirect("/moradores");
});

app.get("/busca", (req, res) => {
    res.sendFile(__dirname + "/front/busca.html")
});

app.get("/api/busca", (req, res) => {
    const nome = req.query.nome || null;
    const sobrenome = req.query.sobrenome || null;
    const email = req.query.email || null;
    const rg = req.query.rg || null;
    const telefone = req.query.telefone || null;
    conect.query(
        "CALL pesquisa_moradores(?,?,?,?,?)",
        [nome,sobrenome,email,rg,telefone],
        (erro, resultado) => {
            if (erro) {
                console.log("Erro SQL: ", erro);
                res.send([]);
                return;
            }
            res.send(resultado[0]);
        }
    );
});