const bodyParser = require("body-parser");

const session = require("express-session");

const express = require('express');

const mysql = require('mysql2');


const urlencodedParser = bodyParser.urlencoded({extended:false});


const app = express();

const conect = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Mag27081*',
    database: 'M3'
})

app.listen(4000, () => {
    console.log("server rodando na porta 4000");
})

app.use(session(
    {
        secret: 'segredinho',
        resave: false,
        saveUninitialized: false,
        cookie: {secure: false}
    }
));

app.get("/", (req, post) =>{
    post.send("<p>teste</p>");
    conect.query('SELECT * FROM produto', (resultados) =>{
        console.log(resultados);
    });
});