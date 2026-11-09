"""API simples de produtos para o projeto escolar Sweets by Isa.

Iniciar (PowerShell, nesta pasta):
    $env:ADMIN_KEY = "uma-chave-escolhida-por-voce"
    python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
"""

import os
import secrets
import sqlite3
from contextlib import contextmanager
from pathlib import Path

from fastapi import Depends, FastAPI, Header, HTTPException, Response, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

DB_PATH = Path(os.getenv("DB_PATH", str(Path(__file__).with_name("sweets.db"))))

app = FastAPI(title="API Sweets by Isa", version="1.0")

# Necessário para o Flutter Web (Chrome) acessar a API durante o desenvolvimento.
# Para colocar na internet, restrinja os domínios permitidos e use HTTPS.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Content-Type", "X-Admin-Key"],
)


class ProdutoEntrada(BaseModel):
    nome: str = Field(min_length=1, max_length=100)
    categoria: str = Field(min_length=1, max_length=80)
    preco: float = Field(gt=0, allow_inf_nan=False)
    imagem: str = "assets/images/doce_padrao.png"


@contextmanager
def conectar():
    conexao = sqlite3.connect(DB_PATH)
    conexao.row_factory = sqlite3.Row
    try:
        yield conexao
        conexao.commit()
    except Exception:
        conexao.rollback()
        raise
    finally:
        conexao.close()


def criar_banco():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    with conectar() as conexao:
        conexao.execute(
            """CREATE TABLE IF NOT EXISTS produtos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nome TEXT NOT NULL,
                categoria TEXT NOT NULL,
                preco REAL NOT NULL,
                imagem TEXT NOT NULL
            )"""
        )
        quantidade = conexao.execute("SELECT COUNT(*) FROM produtos").fetchone()[0]
        # O banco novo começa com o cardápio confirmado. Não repopulamos um banco
        # existente, inclusive se todos os produtos forem excluídos.
        primeira_vez = conexao.execute(
            "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='configuracao'"
        ).fetchone()[0] == 0
        if primeira_vez:
            if quantidade == 0:
                conexao.executemany(
                    "INSERT INTO produtos (nome, categoria, preco, imagem) VALUES (?, ?, ?, ?)",
                    [
                        ("Brownie", "Brownies", 12.0, "assets/images/brownie.png"),
                        ("Cookie tradicional", "Cookies", 12.0, "assets/images/cookie_tradicional.png"),
                        ("Cookie recheado", "Cookies", 14.0, "assets/images/cookie_recheado.png"),
                        ("Palha italiana", "Palhas italianas", 12.0, "assets/images/palha_italiana.png"),
                    ],
                )
            conexao.execute("CREATE TABLE configuracao (id INTEGER PRIMARY KEY)")
            conexao.execute("INSERT INTO configuracao (id) VALUES (1)")


def exigir_admin(x_admin_key: str | None = Header(default=None)):
    chave = os.getenv("ADMIN_KEY", "")
    if not chave:
        raise HTTPException(status_code=503, detail="Configure ADMIN_KEY no servidor.")
    if x_admin_key is None or not secrets.compare_digest(
        x_admin_key.encode('utf-8'), chave.encode('utf-8')
    ):
        raise HTTPException(status_code=403, detail="Chave administrativa incorreta.")


def buscar_por_id(conexao, produto_id: int):
    linha = conexao.execute(
        "SELECT id, nome, categoria, preco, imagem FROM produtos WHERE id = ?",
        (produto_id,),
    ).fetchone()
    if linha is None:
        raise HTTPException(status_code=404, detail="Produto não encontrado.")
    return dict(linha)


criar_banco()


@app.get("/")
def inicio():
    return {"mensagem": "API Sweets by Isa funcionando"}


class LoginEntrada(BaseModel):
    usuario: str = Field(min_length=1, max_length=60)
    senha: str = Field(min_length=1, max_length=200)


@app.post("/login")
def login(dados: LoginEntrada):
    """Login didático por perfil, sem salvar senha no celular.

    Para administradora, usa a mesma ADMIN_KEY que protege o CRUD.
    CLIENT_PASSWORD serve apenas como acesso de cliente de demonstração.
    Ainda não há cadastro de contas individuais.
    """
    usuario = dados.usuario.strip().lower()
    if usuario == "admin":
        chave = os.getenv("ADMIN_KEY", "")
        if not chave:
            raise HTTPException(status_code=503, detail="Configure ADMIN_KEY no servidor.")
        if secrets.compare_digest(dados.senha.encode('utf-8'), chave.encode('utf-8')):
            return {"usuario": "admin", "perfil": "ADMIN"}
    elif usuario == "cliente":
        senha_cliente = os.getenv("CLIENT_PASSWORD", "")
        if not senha_cliente:
            raise HTTPException(status_code=503, detail="Configure CLIENT_PASSWORD no servidor.")
        if secrets.compare_digest(dados.senha.encode('utf-8'), senha_cliente.encode('utf-8')):
            return {"usuario": "cliente", "perfil": "CLIENTE"}
    raise HTTPException(status_code=401, detail="Usuário ou senha incorretos.")




@app.get("/produtos")
def listar_produtos():
    with conectar() as conexao:
        linhas = conexao.execute(
            "SELECT id, nome, categoria, preco, imagem FROM produtos ORDER BY id"
        ).fetchall()
        return [dict(linha) for linha in linhas]


@app.get("/produtos/{produto_id}")
def ver_produto(produto_id: int):
    with conectar() as conexao:
        return buscar_por_id(conexao, produto_id)


@app.post("/produtos", status_code=status.HTTP_201_CREATED)
def criar_produto(produto: ProdutoEntrada, _: None = Depends(exigir_admin)):
    dados = produto.model_dump()
    dados["nome"] = dados["nome"].strip()
    dados["categoria"] = dados["categoria"].strip()
    if not dados["nome"] or not dados["categoria"]:
        raise HTTPException(status_code=422, detail="Nome e categoria são obrigatórios.")
    with conectar() as conexao:
        cursor = conexao.execute(
            "INSERT INTO produtos (nome, categoria, preco, imagem) VALUES (?, ?, ?, ?)",
            (dados["nome"], dados["categoria"], dados["preco"], dados["imagem"]),
        )
        return buscar_por_id(conexao, cursor.lastrowid)


@app.put("/produtos/{produto_id}")
def editar_produto(produto_id: int, produto: ProdutoEntrada,
                   _: None = Depends(exigir_admin)):
    dados = produto.model_dump()
    dados["nome"] = dados["nome"].strip()
    dados["categoria"] = dados["categoria"].strip()
    if not dados["nome"] or not dados["categoria"]:
        raise HTTPException(status_code=422, detail="Nome e categoria são obrigatórios.")
    with conectar() as conexao:
        buscar_por_id(conexao, produto_id)
        conexao.execute(
            "UPDATE produtos SET nome=?, categoria=?, preco=?, imagem=? WHERE id=?",
            (dados["nome"], dados["categoria"], dados["preco"], dados["imagem"], produto_id),
        )
        return buscar_por_id(conexao, produto_id)


@app.delete("/produtos/{produto_id}", status_code=status.HTTP_204_NO_CONTENT)
def excluir_produto(produto_id: int, _: None = Depends(exigir_admin)):
    with conectar() as conexao:
        buscar_por_id(conexao, produto_id)
        conexao.execute("DELETE FROM produtos WHERE id = ?", (produto_id,))
    return Response(status_code=status.HTTP_204_NO_CONTENT)

# ETAPA 3 - Pedidos. O total nunca é recebido do app: é calculado aqui com
# os preços consultados no banco. O código aleatório permite ao cliente
# acompanhar somente o próprio pedido sem criar um login complexo.
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP
from typing import Literal


class ItemPedidoEntrada(BaseModel):
    produto_id: int = Field(gt=0)
    quantidade: int = Field(ge=1, le=50)


class PedidoEntrada(BaseModel):
    nome_cliente: str = Field(min_length=1, max_length=100)
    pagamento: Literal['PIX', 'DINHEIRO']
    observacoes: str = Field(default='', max_length=250)
    itens: list[ItemPedidoEntrada] = Field(min_length=1, max_length=30)


class AtualizarStatus(BaseModel):
    status: Literal['RECEBIDO', 'EM_PREPARO', 'PRONTO', 'ENTREGUE', 'CANCELADO']


def criar_tabelas_pedidos():
    with conectar() as conexao:
        conexao.execute('''CREATE TABLE IF NOT EXISTS pedidos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo TEXT UNIQUE NOT NULL,
            nome_cliente TEXT NOT NULL,
            pagamento TEXT NOT NULL,
            observacoes TEXT NOT NULL,
            status TEXT NOT NULL,
            total_centavos INTEGER NOT NULL,
            criado_em TEXT NOT NULL
        )''')
        conexao.execute('''CREATE TABLE IF NOT EXISTS itens_pedido (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pedido_id INTEGER NOT NULL,
            produto_nome TEXT NOT NULL,
            quantidade INTEGER NOT NULL,
            preco_centavos INTEGER NOT NULL,
            FOREIGN KEY(pedido_id) REFERENCES pedidos(id)
        )''')


criar_tabelas_pedidos()


def centavos(preco):
    return int((Decimal(str(preco)) * 100).quantize(
        Decimal('1'), rounding=ROUND_HALF_UP))


def detalhar_pedido(conexao, pedido):
    resultado = dict(pedido)
    resultado['total'] = resultado.pop('total_centavos') / 100
    itens = conexao.execute('''SELECT produto_nome, quantidade, preco_centavos
            FROM itens_pedido WHERE pedido_id = ? ORDER BY id''',
        (resultado['id'],)).fetchall()
    resultado['itens'] = [{
        'produto_nome': item['produto_nome'],
        'quantidade': item['quantidade'],
        'preco_unitario': item['preco_centavos'] / 100,
    } for item in itens]
    return resultado


@app.post('/pedidos', status_code=status.HTTP_201_CREATED)
def criar_pedido(dados: PedidoEntrada):
    nome = dados.nome_cliente.strip()
    if not nome:
        raise HTTPException(status_code=422, detail='Informe o seu nome.')
    observacoes = dados.observacoes.strip()
    # Junta produtos repetidos sem confiar em valores ou totais do Flutter.
    quantidades = {}
    for item in dados.itens:
        quantidades[item.produto_id] = quantidades.get(item.produto_id, 0) + item.quantidade
        if quantidades[item.produto_id] > 50:
            raise HTTPException(status_code=422, detail='Quantidade máxima por produto: 50.')

    with conectar() as conexao:
        itens = []
        total_centavos = 0
        for produto_id, quantidade in quantidades.items():
            produto = buscar_por_id(conexao, produto_id)
            preco = centavos(produto['preco'])
            itens.append((produto['nome'], quantidade, preco))
            total_centavos += preco * quantidade
        codigo = secrets.token_urlsafe(18)
        cursor = conexao.execute('''INSERT INTO pedidos
            (codigo, nome_cliente, pagamento, observacoes, status,
             total_centavos, criado_em) VALUES (?, ?, ?, ?, ?, ?, ?)''',
            (codigo, nome, dados.pagamento, observacoes, 'RECEBIDO',
             total_centavos, datetime.now(timezone.utc).isoformat()))
        conexao.executemany('''INSERT INTO itens_pedido
            (pedido_id, produto_nome, quantidade, preco_centavos)
            VALUES (?, ?, ?, ?)''',
            [(cursor.lastrowid, item_nome, quantidade, preco)
             for item_nome, quantidade, preco in itens])
        pedido = conexao.execute('SELECT * FROM pedidos WHERE id = ?',
                                 (cursor.lastrowid,)).fetchone()
        return detalhar_pedido(conexao, pedido)


@app.get('/pedidos')
def listar_pedidos(_: None = Depends(exigir_admin)):
    with conectar() as conexao:
        pedidos = conexao.execute('SELECT * FROM pedidos ORDER BY id DESC LIMIT 100').fetchall()
        return [detalhar_pedido(conexao, pedido) for pedido in pedidos]


@app.get('/pedidos/{codigo}')
def consultar_pedido(codigo: str):
    with conectar() as conexao:
        pedido = conexao.execute('SELECT * FROM pedidos WHERE codigo = ?',
                                 (codigo,)).fetchone()
        if pedido is None:
            raise HTTPException(status_code=404, detail='Pedido não encontrado.')
        return detalhar_pedido(conexao, pedido)


@app.put('/pedidos/{pedido_id}/status')
def atualizar_status_pedido(pedido_id: int, dados: AtualizarStatus,
                            _: None = Depends(exigir_admin)):
    with conectar() as conexao:
        pedido = conexao.execute('SELECT * FROM pedidos WHERE id = ?',
                                 (pedido_id,)).fetchone()
        if pedido is None:
            raise HTTPException(status_code=404, detail='Pedido não encontrado.')
        conexao.execute('UPDATE pedidos SET status = ? WHERE id = ?',
                        (dados.status, pedido_id))
        pedido = conexao.execute('SELECT * FROM pedidos WHERE id = ?',
                                 (pedido_id,)).fetchone()
        return detalhar_pedido(conexao, pedido)
