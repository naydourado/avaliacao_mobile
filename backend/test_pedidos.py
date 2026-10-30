"""Testes da Etapa 3: criar pedido, calcular total, consultar e atualizar."""
import importlib
from fastapi.testclient import TestClient


def test_pedidos_persistencia_permissoes_e_total(tmp_path, monkeypatch):
    monkeypatch.setenv('DB_PATH', str(tmp_path / 'pedidos.db'))
    monkeypatch.setenv('ADMIN_KEY', 'chave-de-teste')
    import main
    importlib.reload(main)
    chave = {'X-Admin-Key': 'chave-de-teste'}
    with TestClient(main.app) as client:
        dados = {'nome_cliente': 'Ana', 'pagamento': 'PIX',
                 'itens': [{'produto_id': 1, 'quantidade': 2},
                           {'produto_id': 3, 'quantidade': 1}]}
        r = client.post('/pedidos', json=dados)
        assert r.status_code == 201, r.text
        p = r.json()
        assert p['total'] == 38.0  # 12*2 + 14, do servidor
        assert p['status'] == 'RECEBIDO'
        assert len(p['codigo']) >= 20
        assert client.get('/pedidos').status_code == 403
        assert client.get('/pedidos/' + p['codigo']).json()['id'] == p['id']
        assert client.get('/pedidos/errado').status_code == 404
        assert client.put(f"/pedidos/{p['id']}/status", json={'status': 'PRONTO'}).status_code == 403
        assert client.put(f"/pedidos/{p['id']}/status", json={'status': 'INVENTADO'}, headers=chave).status_code == 422
        assert client.put(f"/pedidos/{p['id']}/status", json={'status': 'PRONTO'}, headers=chave).status_code == 200
        assert client.get('/pedidos/' + p['codigo']).json()['status'] == 'PRONTO'
        assert len(client.get('/pedidos', headers=chave).json()) == 1
        assert client.post('/pedidos', json={**dados, 'itens': []}).status_code == 422
        assert client.post('/pedidos', json={**dados, 'nome_cliente': '  '}).status_code == 422
        assert client.post('/pedidos', json={**dados, 'pagamento': 'CARTAO'}).status_code == 422
        assert client.post('/pedidos', json={**dados, 'itens': [{'produto_id': 9999, 'quantidade': 1}]}).status_code == 404
        # Excluir o produto não apaga os dados históricos do pedido.
        assert client.delete('/produtos/1', headers=chave).status_code == 204
        assert len(client.get('/pedidos/' + p['codigo']).json()['itens']) == 2

    # Pedido sobrevive ao reinício da API.
    with TestClient(main.app) as client:
        assert len(client.get('/pedidos', headers=chave).json()) == 1
        assert client.get('/pedidos/' + p['codigo']).json()['total'] == 38.0
