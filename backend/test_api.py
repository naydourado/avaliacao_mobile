"""Testes rápidos da API; executar com: python -m pytest -q"""
import importlib

from fastapi.testclient import TestClient


def test_crud_e_permissao(tmp_path, monkeypatch):
    monkeypatch.setenv("DB_PATH", str(tmp_path / "teste.db"))
    monkeypatch.setenv("ADMIN_KEY", "senha-temporaria-teste")
    import main
    importlib.reload(main)

    with TestClient(main.app) as client:
        resposta = client.get("/produtos")
        assert resposta.status_code == 200
        assert len(resposta.json()) == 4
        assert resposta.json()[0]["preco"] == 12.0
        novo = {"nome": "Doce teste", "categoria": "Teste", "preco": 7.5,
                "imagem": "assets/images/doce_padrao.png"}
        assert client.post("/produtos", json=novo).status_code == 403
        headers = {"X-Admin-Key": "senha-temporaria-teste"}
        criado = client.post("/produtos", json=novo, headers=headers)
        assert criado.status_code == 201
        id_produto = criado.json()["id"]
        novo["preco"] = 8.5
        editado = client.put(f"/produtos/{id_produto}", json=novo, headers=headers)
        assert editado.status_code == 200
        assert client.get(f"/produtos/{id_produto}").json()["preco"] == 8.5
        assert client.delete(f"/produtos/{id_produto}", headers=headers).status_code == 204
        assert client.get(f"/produtos/{id_produto}").status_code == 404
        assert client.put("/produtos/99999", json=novo, headers=headers).status_code == 404
        assert client.post("/produtos", json={**novo, "preco": -2}, headers=headers).status_code == 422

    # Não repovoar produtos por acidente em cada inicialização.
    with TestClient(main.app) as client:
        assert len(client.get("/produtos").json()) == 4
