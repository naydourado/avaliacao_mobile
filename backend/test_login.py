"""Verifica os dois perfis e bloqueio das rotas administrativas."""
import importlib
import pytest
from fastapi.testclient import TestClient


def test_login_e_perfis(tmp_path, monkeypatch):
    monkeypatch.setenv('DB_PATH', str(tmp_path / 'login.db'))
    monkeypatch.setenv('ADMIN_KEY', 'chave-de-teste-secreta')
    monkeypatch.setenv('CLIENT_PASSWORD', 'senha-do-cliente')
    import main
    importlib.reload(main)

    with TestClient(main.app) as client:
        cliente = client.post('/login', json={
            'usuario': 'cliente', 'senha': 'senha-do-cliente'})
        assert cliente.status_code == 200
        assert cliente.json()['perfil'] == 'CLIENTE'
        admin = client.post('/login', json={
            'usuario': 'admin', 'senha': 'chave-de-teste-secreta'})
        assert admin.status_code == 200
        assert admin.json()['perfil'] == 'ADMIN'
        assert client.post('/login', json={
            'usuario': 'admin', 'senha': 'errada'}).status_code == 401
        assert client.post('/login', json={
            'usuario': 'cliente', 'senha': 'errada'}).status_code == 401
        assert client.post('/login', json={
            'usuario': 'desconhecido', 'senha': '123'}).status_code == 401
        assert client.post('/login', json={
            'usuario': '', 'senha': '123'}).status_code == 422
        # Cliente logado não ganha privilégios administrativos.
        novo = {'nome': 'Teste', 'categoria': 'Outros', 'preco': 4}
        assert client.post('/produtos', json=novo).status_code == 403
        assert client.post('/produtos', json=novo,
            headers={'X-Admin-Key': 'senha-do-cliente'}).status_code == 403
        assert client.post('/produtos', json=novo,
            headers={'X-Admin-Key': 'chave-de-teste-secreta'}).status_code == 201


def test_admin_sem_chave(tmp_path, monkeypatch):
    monkeypatch.setenv('DB_PATH', str(tmp_path / 'sem-chave.db'))
    monkeypatch.delenv('ADMIN_KEY', raising=False)
    import main
    importlib.reload(main)
    with TestClient(main.app) as client:
        resposta = client.post('/login', json={'usuario': 'admin', 'senha': 'qualquer'})
        assert resposta.status_code == 503


@pytest.mark.parametrize('chave', [None, 'chave-incorreta', 'senha-do-cliente'])
def test_todas_rotas_administrativas_bloqueiam_cliente(tmp_path, monkeypatch, chave):
    monkeypatch.setenv('DB_PATH', str(tmp_path / 'permissoes.db'))
    monkeypatch.setenv('ADMIN_KEY', 'chave-admin')
    monkeypatch.setenv('CLIENT_PASSWORD', 'senha-do-cliente')
    import main
    importlib.reload(main)
    headers = {} if chave is None else {'X-Admin-Key': chave}
    with TestClient(main.app) as client:
        pedido = client.post('/pedidos', json={
            'nome_cliente': 'Ana', 'pagamento': 'PIX',
            'itens': [{'produto_id': 1, 'quantidade': 1}],
        }).json()
        produto = {'nome': 'Teste', 'categoria': 'Doces', 'preco': 5}
        assert client.get('/pedidos', headers=headers).status_code == 403
        assert client.post('/produtos', json=produto, headers=headers).status_code == 403
        assert client.put('/produtos/1', json=produto, headers=headers).status_code == 403
        assert client.delete('/produtos/1', headers=headers).status_code == 403
        assert client.put(f"/pedidos/{pedido['id']}/status",
            json={'status': 'PRONTO'}, headers=headers).status_code == 403
        assert client.get('/produtos/1').json()['nome'] == 'Brownie'
        assert client.get(f"/pedidos/{pedido['codigo']}").json()['status'] == 'RECEBIDO'


def test_login_senha_com_acentos(tmp_path, monkeypatch):
    monkeypatch.setenv('DB_PATH', str(tmp_path / 'acentos.db'))
    monkeypatch.setenv('CLIENT_PASSWORD', 'pão-de-mel')
    import main
    importlib.reload(main)
    with TestClient(main.app) as client:
        correto = client.post('/login', json={'usuario': 'cliente', 'senha': 'pão-de-mel'})
        assert correto.status_code == 200
        assert correto.json()['perfil'] == 'CLIENTE'
        assert client.post('/login', json={
            'usuario': 'cliente', 'senha': 'inválida'}).status_code == 401
