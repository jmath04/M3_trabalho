const bodyParser = require("body-parser");

const session = require("express-session");

const express = require('express');

const mysql = require('mysql2');


const urlencodedParser = bodyParser.urlencoded({extended:false});


const app = express();

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
    res.sendFile(__dirname + "/front/moradores.html");
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
    conect.query("CALL cadastra_moradores(" + nome + "," + sobrenome + "," + email + "," + rg + "," + telefone + ");");   
    }
});