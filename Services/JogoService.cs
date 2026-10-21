using ApiJogosMVC.Models;

namespace ApiJogosMVC.Services;

public class JogoService
{
    private readonly List<JogoModel> _jogos = [];
    private readonly object _lock = new();
    private int _proximoId = 1;

    public List<JogoModel> Listar(string? nome = null)
    {
        lock (_lock)
        {
            var pesquisa = nome?.Trim();
            return _jogos
                .Where(jogo => string.IsNullOrWhiteSpace(pesquisa)
                    || jogo.Nome.Contains(pesquisa, StringComparison.OrdinalIgnoreCase))
                .Select(Copiar)
                .ToList();
        }
    }

    public JogoModel? BuscarPorId(int id)
    {
        lock (_lock)
        {
            var jogo = _jogos.Find(jogo => jogo.Id == id);
            return jogo is null ? null : Copiar(jogo);
        }
    }

    public void Cadastrar(JogoModel jogo)
    {
        lock (_lock)
        {
            var novoJogo = Copiar(jogo);
            novoJogo.Id = _proximoId++;
            _jogos.Add(novoJogo);
        }
    }

    public bool Atualizar(int id, JogoModel jogo)
    {
        lock (_lock)
        {
            var indice = _jogos.FindIndex(item => item.Id == id);
            if (indice < 0)
                return false;

            var atualizado = Copiar(jogo);
            atualizado.Id = id;
            _jogos[indice] = atualizado;
            return true;
        }
    }

    public bool Excluir(int id)
    {
        lock (_lock)
        {
            return _jogos.RemoveAll(jogo => jogo.Id == id) > 0;
        }
    }

    private static JogoModel Copiar(JogoModel jogo) => new()
    {
        Id = jogo.Id,
        Nome = jogo.Nome.Trim(),
        Preco = jogo.Preco,
        DataLancamento = jogo.DataLancamento.Date,
        Genero = jogo.Genero
    };
}
