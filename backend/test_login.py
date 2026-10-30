"""Verifica os dois perfis e bloqueio das rotas administrativas."""
import importlib
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
