const bodyParser = require("body-parser");

const session = require("express-session");

const express = require('express');

const mysql = require('mysql2');

const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.set('view engine', 'ejs');
app.set('views','./front');

const conect = mysql.createConnection({
    host: 'localhost',
    user: 'server',
    password: 'Senha@123',
    database: 'M3'
})

app.listen(4000, () => {
    console.log("server rodando na porta 4000");
})

app.use(express.static(__dirname + "/front"));


app.use(session(
    {
        secret: 'segredinho',
        resave: false,
        saveUninitialized: false,
        cookie: {secure: false}
    }
));

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
    res.sendFile(__dirname + "/front/unidades.html");
});

app.get("/pagamentos", (req, res) => {
    res.sendFile(__dirname + "/front/pagamentos.html");
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